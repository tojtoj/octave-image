// Copyright (C) 2011 Jordi Gutiérrez Hermoso <jordigh@octave.org>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

// bwlabeln.cc ---

#include <oct.h>
#include <set>
#include "union-find.h++"
#include <unordered_map>

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
  while (a(i) == b(i) and i < na)
    {
      i++;
    }

  if (i == na          //They're equal, but this is strict order
      or a(i) > b(i) )
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
operator+ (const coord& a, const coord& b)
{
  octave_idx_type na = a.nelem ();
  coord retval( dim_vector(na,1) );
  for (octave_idx_type i = 0; i < na; i++)
    {
      retval(i) = a(i) + b(i);
    }
  return retval;
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
          if( aidx == zero or neighbours.find(-aidx) != neighbours.end() )
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
                         1, 0, 1};

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



DEFUN_DLD(bwlabeln, args, , "\
-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{l}, @var{num}] =} bwlabeln(@var{bw})\n\
@deftypefnx {Loadable Function} {[@var{l}, @var{num}] =} bwlabeln(@var{bw}, @var{n})\n\
Label foreground objects in the n-dimensional binary image @var{bw}.\n\
\n\
The optional argument @var{n} sets the connectivity and defaults 26.\n\
\n\
The output @var{l} is an Nd-array where 0 indicates a background\n\
pixel, 1 indicates that the pixel belong to object number 1, 2 that\n\
the pixel belong to object number 2, etc. The total number of objects\n\
is @var{num}.\n\
\n\
@seealso{bwconncomp, bwlabel, regionprops}\n\
@end deftypefn\n\
")
{
  octave_value_list rval;

  octave_idx_type nargin = args.length ();

  if (nargin < 1 || nargin > 2)
  {
    print_usage ();
    return rval;
  }

  if (!args(0).is_bool_type ())
    {
      error ("bwlabeln: first input argument must be a 'logical' ND-array");
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
      else if (args(2).is_bool_type() )
        {
          conn_mask = args(2).bool_array_value ();
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
               "or a 'logical' connectivity array");
    }
  else
    // Get the maximal mask that has same number of dims as BW.
    conn_mask = get_mask (BW);

  if (error_state)
    return rval;

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


  std::unordered_map<octave_idx_type, octave_idx_type> ids_to_label;
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
        {
          label = try_label -> second;
        }

      L_vec[*idx] = label;
    }

  rval(0) = L;
  rval(1) = ids_to_label.size ();
  return rval;
}
