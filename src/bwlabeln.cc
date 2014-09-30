// Copyright (C) 2002 Jeffrey E. Boyd <boyd@cpsc.ucalgary.ca>
// Copyright (C) 2011-2012 Jordi Gutiérrez Hermoso <jordigh@octave.org>
// Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see
// <http://www.gnu.org/licenses/>.

// Copyright
// Jeffrey E. Boyd and Carnë Draug for bwlabel_2d
// Jordi Gutiérrez Hermoso for bwlabel_nd

#include <octave/oct.h>
#include <vector>
#include <set>
#include <algorithm>
#include "union-find.h++"

#include "config.h"

#if defined (HAVE_UNORDERED_MAP)
#include <unordered_map>
#elif defined (HAVE_TR1_UNORDERED_MAP)
#include <tr1/unordered_map>
#else
#error Must have the TR1 or C++11 unordered_map header
#endif

typedef Array<octave_idx_type> coord;

bool operator== (const coord& a, const coord& b)
{
  if (a.nelem () != b.nelem())
    return false;
  for (octave_idx_type i = 0; i < a.nelem (); i++)
    if (  a(i) !=  b(i) )
      return false;

  return true;
}

//Lexicographic order for coords
bool operator< (const coord& a, const coord& b)
{
  octave_idx_type na = a.nelem (), nb = b.nelem ();
  if (na < nb)
    return true;
  if (na > nb)
    return false;
  octave_idx_type i = 0;
  while (a(i) == b(i) && i < na)
    {
      i++;
    }

  if (i == na          //They're equal, but this is strict order
      || a(i) > b(i) )
    return false;

  return true;
}

// A few basic utility functions
//{
inline
coord
to_coord (const dim_vector& dv,
          octave_idx_type k)
{
  octave_idx_type n = dv.length ();
  coord retval ( dim_vector (n, 1));
  for (octave_idx_type j = 0; j < n; j++)
    {
      retval(j) = k % dv(j);
      k /= dv(j);
    }
  return retval;
}

inline
octave_idx_type
coord_to_pad_idx (const dim_vector& dv,
                  const coord& c)
{
  octave_idx_type idx = 0;
  octave_idx_type mul = 1;
  for (octave_idx_type j = 0; j < dv.length (); j++)
    {
      idx += mul*c(j);
      mul *= dv(j) + 2;
    }
  return idx;
}

inline
coord
operator- (const coord& a, const coord& b)
{
  octave_idx_type na = a.nelem ();
  coord retval( dim_vector(na,1) );
  for (octave_idx_type i = 0; i < na; i++)
    {
      retval(i) = a(i) - b(i);
    }
  return retval;
}


inline
coord
operator- (const coord& a)
{
  octave_idx_type na = a.nelem ();
  coord retval (dim_vector(na,1) );
  for (octave_idx_type i = 0; i < na; i++)
    {
      retval(i) = -a(i);
    }
  return retval;
}
//}

std::set<octave_idx_type>
populate_neighbours(const boolNDArray& conn_mask,
                    const dim_vector& size_vec)
{
  std::set<octave_idx_type> neighbours_idx;
  std::set<coord> neighbours;

  dim_vector conn_size = conn_mask.dims ();
  coord centre (dim_vector(conn_size.length (), 1), 1);
  coord zero (dim_vector(conn_size.length (), 1), 0);
  for (octave_idx_type idx = 0; idx < conn_mask.nelem (); idx++)
    {
      if (conn_mask(idx))
        {
          coord aidx = to_coord (conn_size, idx) - centre;

          //The zero coordinates are the centre, and the negative ones
          //are the ones reflected about the centre, and we don't need
          //to consider those.
          if( aidx == zero || neighbours.find(-aidx) != neighbours.end() )
            continue;

          neighbours.insert (aidx);

          neighbours_idx.insert (coord_to_pad_idx(size_vec, aidx));
         }
    }
  return neighbours_idx;
}

boolNDArray
get_mask(int N){
  bool* mask_ptr;
  octave_idx_type n;

  static bool mask4[] = {0, 1, 0,
                         1, 0, 1,
                         0, 1, 0};

  static bool mask8[] = {1, 1, 1,
                         1, 0, 1,
                         1, 1, 1};

  static bool mask6[] = {0, 0, 0,
                         0, 1, 0,
                         0, 0, 0,

                         0, 1, 0,
                         1, 0, 1,
                         0, 1, 0,

                         0, 0, 0,
                         0, 1, 0,
                         0, 0, 0};

  static bool mask18[] = {0, 1, 0,
                          1, 1, 1,
                          0, 1, 0,

                          1, 1, 1,
                          1, 0, 1,
                          1, 1, 1,

                          0, 1, 0,
                          1, 1, 1,
                          0, 1, 0};

  static bool mask26[] = {1, 1, 1,
                          1, 1, 1,
                          1, 1, 1,

                          1, 1, 1,
                          1, 0, 1,
                          1, 1, 1,

                          1, 1, 1,
                          1, 1, 1,
                          1, 1, 1};

  switch (N){
  case 4:
    n = 2;
    mask_ptr = mask4;
    break;
  case 8:
    n = 2;
    mask_ptr = mask8;
    break;
  case 6:
    n = 3;
    mask_ptr = mask6;
    break;
  case 18:
    n = 3;
    mask_ptr = mask18;
    break;
  case 26:
    n = 3;
    mask_ptr = mask26;
    break;
  default:
    panic_impossible ();
  }

  boolNDArray conn_mask;
  if (n == 2)
    {
      conn_mask.resize (dim_vector (3, 3));
      for (octave_idx_type i = 0; i < 9; i++)
        conn_mask(i) = mask_ptr[i];

    }
  else
    {
      conn_mask.resize (dim_vector (3, 3, 3));
      for (octave_idx_type i = 0; i < 27; i++)
        conn_mask(i) = mask_ptr[i];
    }

  return conn_mask;
}

boolNDArray
get_mask (const boolNDArray& BW)
{
  dim_vector mask_dims = BW.dims();
  for (auto i = 0; i < mask_dims.length (); i++)
    mask_dims(i) = 3;

  return boolNDArray (mask_dims, 1);
}

octave_idx_type
get_padded_index (octave_idx_type r,
                  const dim_vector& dv)
{
  // This function converts a linear index from the unpadded array
  // into a linear index of the array with zero padding around it. I
  // worked it out on paper, but if you want me to explain this, I'd
  // have to work it out again. ;-) --jgh

  octave_idx_type mult = 1;
  octave_idx_type padded = 0;
  for (octave_idx_type j = 0; j < dv.length (); j++)
    {
      padded += mult*(r % dv(j) + 1);
      mult *= dv(j) + 2;
      r /= dv(j);
    }
  return padded;
}

static octave_value_list
bwlabel_nd (const boolNDArray& BW, const boolNDArray& conn_mask)
{
  octave_value_list rval;

  dim_vector size_vec = BW.dims ();
  auto neighbours = populate_neighbours(conn_mask, size_vec);

  // Use temporary array with borders padded with zeros. Labels will
  // also go in here eventually.
  dim_vector padded_size = size_vec;
  for (octave_idx_type j = 0; j < size_vec.length (); j++)
    padded_size(j) += 2;

  NDArray L (padded_size, 0);

  // L(2:end-1, 2:end, ..., 2:end-1) = BW
  L.insert(BW, coord (dim_vector (size_vec.length (), 1), 1));

  double* L_vec = L.fortran_vec ();
  union_find u_f (L.nelem ());

  for (octave_idx_type BWidx = 0; BWidx < BW.nelem (); BWidx++)
    {
      octave_idx_type Lidx = get_padded_index (BWidx, size_vec);

      if (L_vec[Lidx])
        {
          //Insert this one into its group
          u_f.find (Lidx);

          //Replace this with C++0x range-based for loop later
          //(implemented in gcc 4.6)
          for (auto nbr = neighbours.begin (); nbr != neighbours.end (); nbr++)
            {
              octave_idx_type n = *nbr + Lidx;
              if (L_vec[n] )
                u_f.unite (n, Lidx);
            }
        }
    }

#ifdef USE_UNORDERED_MAP_WITH_TR1
  using std::tr1::unordered_map;
#else
  using std::unordered_map;
#endif

  unordered_map<octave_idx_type, octave_idx_type> ids_to_label;
  octave_idx_type next_label = 1;

  auto idxs  = u_f.get_ids ();

  //C++0x foreach later
  for (auto idx = idxs.begin (); idx != idxs.end (); idx++)
    {
      octave_idx_type label;
      octave_idx_type id = u_f.find (*idx);
      auto try_label = ids_to_label.find (id);
      if( try_label == ids_to_label.end ())
        {
          label = next_label++;
          ids_to_label[id] = label;
        }
      else
          label = try_label -> second;

      L_vec[*idx] = label;
    }

  // Remove the zero padding...
  Array<idx_vector> inner_slice (dim_vector (size_vec.length (), 1));
  for (octave_idx_type i = 0; i < padded_size.length (); i++)
    inner_slice(i) = idx_vector (1, padded_size(i) - 1);

  rval(0) = L.index (inner_slice);
  rval(1) = ids_to_label.size ();
  return rval;
}

static octave_idx_type
find (std::vector<octave_idx_type>& lset, octave_idx_type x)
{
  // Follow lset until we find a value that points to itself
  while (lset[x] != x)
    x = lset[x];
  return x;
}

static octave_value_list
bwlabel_2d (const boolMatrix& BW, const octave_idx_type& n)
{
  // This algorithm was derived from  BKP Horn, Robot Vision, MIT Press,
  // 1986, p 65 - 89 by Jeffrey E. Boyd in 2002. Some smaller changes
  // were then introduced by Carnë Draug in 2013 to speed up by iterating
  // down a column, and what values to use when connecting two labels
  // to increase chance of getting them in the right order in the end.

  const octave_idx_type nr = BW.rows ();
  const octave_idx_type nc = BW.columns ();

  // The labelled image
  Matrix L (nr, nc);

  std::vector<octave_idx_type> lset (nc*nr);    // label table/tree

  octave_idx_type ntable = 0; // number of elements in the component table/tree
  octave_idx_type ind    = 0; // linear index

  bool n4, n6, n8;
  n4 = n6 = n8 = false;
  if (n == 4)
    n4 = true;
  else if (n == 6)
    n6 = true;
  else if (n == 8)
    n8 = true;

  const bool* BW_vec = BW.data ();
  double* L_vec = L.fortran_vec ();

  for (octave_idx_type c = 0; c < nc; c++)
    {
      for (octave_idx_type r = 0; r < nr; r++, ind++)
        {
          if (BW_vec[ind]) // if A is an object
            {
              octave_idx_type stride = ind - nr;
              // Get the neighboring pixels B, C, D, and E
              //
              //  D  B
              //  C  A  <-- ind is linear index to A
              //  E
              //
              // C and B will always be needed so we get them here, but
              // D is only needed when n is 6 or 8, and E when n is 8.

              octave_idx_type B, C;
              if (c == 0)
                C = 0;
              else
                C = find (lset, L_vec[stride]);

              if (r == 0)
                B = 0;
              else
                B = find (lset, L_vec[ind -1]);

              if (n4)
                {
                  // apply 4 connectedness
                  if (B && C) // B and C are labeled
                    {
                      if (B != C)
                        lset[B] = C;

                      L_vec[ind] = C;
                    }
                  else if (B) // B is object but C is not
                    L_vec[ind] = B;
                  else if (C) // C is object but B is not
                    L_vec[ind] = C;
                  else // B, C not object - new object
                    {
                      // label and put into table
                      ntable++;
                      L_vec[ind] = lset[ntable] = ntable;
                    }
                }
              else if (n6)
                {
                  // Apply 6 connectedness. Seem there's more than one
                  // possible way to do this for 2D images but for some
                  // reason, the most common seems to be the top left pixel
                  // and the bottom right
                  // See http://en.wikipedia.org/wiki/Pixel_connectivity

                  octave_idx_type D;
                  // D is only required for n6 and n8
                  if (r == 0 || c == 0)
                    D = 0;
                  else
                    D = find (lset, L_vec[stride -1]);

                  if (D) // D object, copy label and move on
                    L_vec[ind] = D;
                  else if (B && C) // B and C are labeled
                    {
                      if (B == C)
                        L_vec[ind] = B;
                      else
                        {
                          octave_idx_type tlabel = std::min (B, C);
                          lset[B] = tlabel;
                          lset[C] = tlabel;
                          L_vec[ind] = tlabel;
                        }
                    }
                  else if (B) // B is object but C is not
                    L_vec[ind] = B;
                  else if (C) // C is object but B is not
                    L_vec[ind] = C;
                  else // B, C, D not object - new object
                    {
                      // label and put into table
                      ntable++;
                      L_vec[ind] = lset[ntable] = ntable;
                    }
                }
              else if (n8)
                {
                  octave_idx_type D, E;
                  // D is only required for n6 and n8
                  if (r == 0 || c == 0)
                    D = 0;
                  else
                    D = find (lset, L_vec[stride -1]);

                  // E is only required for n8
                  if (c == 0 || r == nr -1)
                    E = 0;
                  else
                    E = find (lset, L_vec[stride +1]);

                  // apply 8 connectedness
                  if (B || C || D || E)
                    {
                      octave_idx_type tlabel = D;
                      if (D)
                        ; // do nothing (tlabel is already D)
                      else if (C)
                        tlabel = C;
                      else if (E)
                        tlabel = E;
                      else if (B)
                        tlabel = B;

                      L_vec[ind] = tlabel;

                      if (B && B != tlabel)
                        lset[B] = tlabel;
                      if (C && C != tlabel)
                        lset[C] = tlabel;
                      if (D)
                        // we don't check if B != tlabel since if B
                        // is true, tlabel == B
                        lset[D] = tlabel;
                      if (E && E != tlabel)
                        lset[E] = tlabel;
                    }
                  else
                    {
                      // label and put into table
                      ntable++;  // run image through the look-up table
                      L_vec[ind] = lset[ntable] = ntable;
                    }
                }
            }
          else
            L_vec[ind] = 0; // A is not an object so leave it
        }
    }

  const octave_idx_type numel = BW.numel ();

  // consolidate component table
  for (octave_idx_type i = 0; i <= ntable; i++)
    lset[i] = find (lset, i);

  // run image through the look-up table
  for (octave_idx_type ind = 0; ind < numel; ind++)
    L_vec[ind] = lset[L_vec[ind]];

  // count up the objects in the image
  for (octave_idx_type i = 0; i <= ntable; i++)
    lset[i] = 0;

  for (octave_idx_type ind = 0; ind < numel; ind++)
    lset[L_vec[ind]]++;

  // number the objects from 1 through n objects
  octave_idx_type nobj = 0;
  lset[0] = 0;
  for (octave_idx_type i = 1; i <= ntable; i++)
    if (lset[i] > 0)
      lset[i] = ++nobj;

  // Run through the look-up table again, so that their numbers
  // match the number of labels
  for (octave_idx_type ind = 0; ind < numel; ind++)
    L_vec[ind] = lset[L_vec[ind]];

  octave_value_list rval;
  rval(0) = L;
  rval(1) = double (nobj);
  return rval;
}

DEFUN_DLD(bwlabeln, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {[@var{l}, @var{num}] =} bwlabeln (@var{bw})\n\
@deftypefnx {Loadable Function} {[@var{l}, @var{num}] =} bwlabeln (@var{bw}, @var{n})\n\
Label foreground objects in the n-dimensional binary image @var{bw}.\n\
\n\
The optional argument @var{n} sets the connectivity and defaults 26,\n\
for 26-connectivity in 3-D images. Other possible values are 18 and 6\n\
for 3-D images, 4 and 8 for 2-D images, or an arbitrary N-dimensional\n\
binary connectivity mask where each dimension is of size 3.\n\
\n\
The output @var{l} is an Nd-array where 0 indicates a background\n\
pixel, 1 indicates that the pixel belong to object number 1, 2 that\n\
the pixel belong to object number 2, etc. The total number of objects\n\
is @var{num}.\n\
\n\
The algorithm used is a disjoint-set data structure, a.k.a. union-find.\n\
See, for example, http://en.wikipedia.org/wiki/Union-find\n\
\n\
@seealso{bwconncomp, bwlabel, regionprops}\n\
@end deftypefn\n\
")
{
  octave_value_list rval;

  const octave_idx_type nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return rval;
    }

  if (!args(0).is_numeric_type () && !args(0).is_bool_type ())
    {
      error ("bwlabeln: BW must be a numeric or logical matrix");
      return rval;
    }
  boolNDArray BW = args(0).bool_array_value ();
  dim_vector size_vec = BW.dims ();

  //Connectivity mask
  boolNDArray conn_mask;
  if (nargin == 2)
    {
      if (args(1).is_real_scalar ())
        {
          double N = args(1).scalar_value ();
          if (size_vec.length () == 2 && N != 4 && N != 8)
            error ("bwlabeln: for 2d arrays, scalar N must be 4 or 8");
          else if (size_vec.length () == 3 && N != 6 && N != 18 && N != 26)
            error ("bwlabeln: for 3d arrays, scalar N must be 4 or 8");
          else if (size_vec.length () > 3)
            error ("bwlabeln: for higher-dimensional arrays, N must be a "
                   "connectivity mask");
          else
            conn_mask = get_mask (N);
        }
      else if (args(1).is_numeric_type () || args(1).is_bool_type ())
        {
          conn_mask = args(1).bool_array_value ();
          dim_vector conn_mask_dims = conn_mask.dims ();
          if (conn_mask_dims.length () != size_vec.length ())
            error ("bwlabeln: connectivity mask N must have the same "
                   "dimensions as BW");
          for (octave_idx_type i = 0; i < conn_mask_dims.length (); i++)
            {
              if (conn_mask_dims(i) != 3)
                {
                  error ("bwlabeln: connectivity mask N must have all "
                         "dimensions equal to 3");
                }
            }
        }
      else
        error ("bwlabeln: second input argument must be a real scalar "
               "or a connectivity array");
    }
  else
    // Get the maximal mask that has same number of dims as BW.
    conn_mask = get_mask (BW);

  if (error_state)
    return rval;

  // The implementation in bwlabel_2d is faster so use it if we can
  const octave_idx_type ndims = BW.ndims ();
  if (ndims == 2 && boolMatrix (conn_mask) == get_mask (4))
    rval = bwlabel_2d (BW, 4);
  else if (ndims == 2 && boolMatrix (conn_mask) == get_mask (8))
    rval = bwlabel_2d (BW, 8);
  else
    rval = bwlabel_nd (BW, conn_mask);

  return rval;
}

// PKG_ADD: autoload ("bwlabel", which ("bwlabeln"));
// PKG_DEL: autoload ("bwlabel", which ("bwlabeln"), "remove");
DEFUN_DLD(bwlabel, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {[@var{l}, @var{num}] =} bwlabel(@var{BW})\n\
@deftypefnx {Loadable Function} {[@var{l}, @var{num}] =} bwlabel(@var{BW}, @var{n})\n\
Label binary 2 dimensional image.\n\
\n\
Labels foreground objects in the binary image @var{bw}.\n\
The output @var{l} is a matrix where 0 indicates a background pixel,\n\
1 indicates that the pixel belong to object number 1, 2 that the pixel\n\
belong to object number 2, etc.\n\
The total number of objects is @var{num}.\n\
\n\
To pixels belong to the same object if the are neighbors. By default\n\
the algorithm uses 8-connectivity to define a neighborhood, but this\n\
can be changed through the argument @var{n} that can be either 4, 6, or 8.\n\
\n\
@seealso{bwconncomp, bwlabeln, regionprops}\n\
@end deftypefn\n\
")
{
  octave_value_list rval;

  const octave_idx_type nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return rval;
    }

  // We do not check error state after conversion to boolMatrix
  // because what we want is to actually get a boolean matrix
  // with all non-zero elements as true (Matlab compatibility).
  if ((! args(0).is_numeric_type () && ! args(0).is_bool_type ()) ||
      args(0).ndims () != 2)
    {
      error ("bwlabel: BW must be a 2D matrix");
      return rval;
    }
  // For some reason, we can't use bool_matrix_value() to get a
  // a boolMatrix since it will error if there's values other
  // than 0 and 1 (whatever bool_array_value() does, bool_matrix_value()
  // does not).
  const boolMatrix BW = args(0).bool_array_value ();

  // N-hood connectivity
  const octave_idx_type n = nargin < 2 ? 8 : args(1).idx_type_value ();
  if (error_state || (n != 4 && n!= 6 && n != 8))
    {
      error ("bwlabel: BW must be a 2 dimensional matrix");
      return rval;
    }
  return bwlabel_2d (BW, n);
}

/*
%!shared in
%! in = rand (10) > 0.8;
%!assert (bwlabel (in, 4), bwlabeln (in, 4));
%!assert (bwlabel (in, 4), bwlabeln (in, [0 1 0; 1 0 1; 0 1 0]));
%!assert (bwlabel (in, 8), bwlabeln (in, 8));
%!assert (bwlabel (in, 8), bwlabeln (in, [1 1 1; 1 0 1; 1 1 1]));

%!assert (bwlabel (logical ([0 1 0; 0 0 0; 1 0 1])), [0 2 0; 0 0 0; 1 0 3]);
%!assert (bwlabel ([0 1 0; 0 0 0; 1 0 1]), [0 2 0; 0 0 0; 1 0 3]);

## Support any type of real non-zero value
%!assert (bwlabel ([0 -1 0; 0 0 0; 5 0 0.2]), [0 2 0; 0 0 0; 1 0 3]);

%!shared in, out
%!
%! in = [  0   1   1   0   0   1   0   0   0   0
%!         0   0   0   1   0   0   0   0   0   1
%!         0   1   1   0   0   0   0   0   1   1
%!         1   0   0   0   0   0   0   1   0   0
%!         0   0   0   0   0   1   1   0   0   0
%!         0   0   0   0   0   0   0   0   0   0
%!         0   0   0   1   0   0   0   0   0   0
%!         0   0   0   0   1   1   0   1   0   0
%!         0   0   0   1   0   1   0   1   0   1
%!         1   1   0   0   0   0   0   1   1   0];
%!
%! out = [ 0   3   3   0   0   9   0   0   0   0
%!         0   0   0   5   0   0   0   0   0  13
%!         0   4   4   0   0   0   0   0  13  13
%!         1   0   0   0   0   0   0  11   0   0
%!         0   0   0   0   0  10  10   0   0   0
%!         0   0   0   0   0   0   0   0   0   0
%!         0   0   0   6   0   0   0   0   0   0
%!         0   0   0   0   8   8   0  12   0   0
%!         0   0   0   7   0   8   0  12   0  14
%!         2   2   0   0   0   0   0  12  12   0];
%!assert (nthargout ([1 2], @bwlabel, in, 4), {out, 14});
%!assert (nthargout ([1 2], @bwlabel, logical (in), 4), {out, 14});
%!
%! out = [ 0   3   3   0   0   7   0   0   0   0
%!         0   0   0   3   0   0   0   0   0  11
%!         0   4   4   0   0   0   0   0  11  11
%!         1   0   0   0   0   0   0   9   0   0
%!         0   0   0   0   0   8   8   0   0   0
%!         0   0   0   0   0   0   0   0   0   0
%!         0   0   0   5   0   0   0   0   0   0
%!         0   0   0   0   5   5   0  10   0   0
%!         0   0   0   6   0   5   0  10   0  12
%!         2   2   0   0   0   0   0  10  10   0];
%!assert (nthargout ([1 2], @bwlabel, in, 6), {out, 12});
%!assert (nthargout ([1 2], @bwlabel, logical (in), 6), {out, 12});
%!
%! ## The labeled image is not the same as Matlab, but they are
%! ## labeled correctly. Do we really need to get them properly
%! ## ordered? (the algorithm in bwlabeln does it)
%! mout = [0   1   1   0   0   4   0   0   0   0
%!         0   0   0   1   0   0   0   0   0   5
%!         0   1   1   0   0   0   0   0   5   5
%!         1   0   0   0   0   0   0   5   0   0
%!         0   0   0   0   0   5   5   0   0   0
%!         0   0   0   0   0   0   0   0   0   0
%!         0   0   0   3   0   0   0   0   0   0
%!         0   0   0   0   3   3   0   6   0   0
%!         0   0   0   3   0   3   0   6   0   6
%!         2   2   0   0   0   0   0   6   6   0];
%!
%! out = [ 0   2   2   0   0   4   0   0   0   0
%!         0   0   0   2   0   0   0   0   0   5
%!         0   2   2   0   0   0   0   0   5   5
%!         2   0   0   0   0   0   0   5   0   0
%!         0   0   0   0   0   5   5   0   0   0
%!         0   0   0   0   0   0   0   0   0   0
%!         0   0   0   3   0   0   0   0   0   0
%!         0   0   0   0   3   3   0   6   0   0
%!         0   0   0   3   0   3   0   6   0   6
%!         1   1   0   0   0   0   0   6   6   0];
%!assert (nthargout ([1 2], @bwlabel, in, 8), {out, 6});
%!assert (nthargout ([1 2], @bwlabel, logical (in), 8), {out, 6});
%!
%!error bwlabel (rand (10, 10, 10) > 0.8, 4)
%!error bwlabel (rand (10) > 0.8, "text")
%!error bwlabel ("text", 6)
*/
