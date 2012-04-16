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


dim_vector conn26_dim(3,3,3);
boolNDArray conn26(conn26_dim,1);
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

bool in_range (const coord& a, const dim_vector& size_vec)
{
  for(octave_idx_type i = 0; i < a.nelem (); i++)
    if (a(i) < 0 or a(i) >= size_vec(i))
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

struct coord_hash
{
  inline size_t operator() (const coord& c) const
  {
    size_t seed = 0;
    for(octave_idx_type i = 0; i < c.nelem (); i++)
    {
      //Boost's hash
      seed ^= c(i) + 0x9e3779b9 + (seed<<6) + (seed>>2);
    }
    return seed;
  }

  inline size_t operator()(size_t s) const
  {
    return s;
  }
};

namespace {

// A few basic utility functions
//{
inline
coord
to_coord(const dim_vector& dv,
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
  coord retval( dim_vector(na,1) );
  for (octave_idx_type i = 0; i < na; i++)
    {
      retval(i) = -a(i);
    }
  return retval;
}
//}

bool any_bad_argument (const octave_value_list& args)
{
  return false;

  const int nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return true;
    }

  if (!args (0).is_bool_type ())
    {
      error ("bwlabeln: first input argument must be a 'logical' ND-array");
      return true;
    }

  if (nargin == 2)
    {
      if (!args (1).is_real_scalar () && ! args(1).is_bool_type())
        {
          error ("bwlabeln: second input argument must be a real scalar "
                 "or a 'logical' connectivity array");
            return true;
        }
    }

  return false;
}

//debug
#include <iostream>
using namespace std;

ostream&
operator<< (ostream& os, const coord& aidx)
{
  for (octave_idx_type i = 0; i < aidx.nelem (); i++)
    os << aidx(i) + 1 << " ";
  return os;
}

set<coord>
populate_neighbours(const boolNDArray& conn_mask)
{
  set<coord> neighbours;

  dim_vector conn_size = conn_mask.dims ();
  coord centre(dim_vector(conn_size.length (), 1), 1);
  coord zero(dim_vector(conn_size.length (), 1), 0);
  for (octave_idx_type idx = 0; idx < conn_mask.nelem (); idx++)
    {
      if (conn_mask(idx))
        {
          coord aidx = to_coord(conn_size, idx) - centre;
          //The zero coordinates are the centre, and the negative ones
          //are the ones reflected about the centre, and we don't need
          //to consider those.
          if( aidx == zero or neighbours.find(-aidx) != neighbours.end() )
            continue;
          neighbours.insert (aidx);
         }
    }
  return neighbours;
}

DEFUN_DLD(bwlabeln, args, , "\
-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{l}, @var{num}] =} bwlabeln(@var{bw}, @var{n})\n\
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

  union_find<coord, coord_hash> u_f;

  if (any_bad_argument (args))
    return rval;

  boolNDArray BW = args (0).bool_array_value ();

  dim_vector size_vec = BW.dims ();

  int nargin = args.length ();

  //Connectivity mask
  boolNDArray conn_mask;
  if( nargin == 1)
    conn_mask = conn26; //Implement this properly later
  else
    conn_mask = conn26;

  set<coord> neighbours = populate_neighbours(conn_mask);

  for (octave_idx_type idx = 0; idx < BW.nelem (); idx++)
    {
      if (BW(idx))
        {
          coord aidx = to_coord (size_vec, idx);

          //Insert this one into its group
          u_f.find_id(aidx);

          //Replace this with C++0x range-based for loop later
          //(implemented in gcc 4.6)
          for (auto nbr = neighbours.begin (); nbr!=  neighbours.end (); nbr++)
            {
              coord n = *nbr + aidx;
              if (in_range (n,size_vec) and BW(n) )
                u_f.unite (n,aidx);
            }
        }
    }

  NDArray L (size_vec, 0);
  unordered_map<octave_idx_type, octave_idx_type> ids_to_label;
  octave_idx_type next_label = 1;

  auto idxs  = u_f.get_objects ();

  //C++0x foreach later
  for (auto idx = idxs.begin (); idx != idxs.end (); idx++)
    {
      octave_idx_type label;
      octave_idx_type id = u_f.find_id (idx->first);
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

      L(idx->first) = label;
    }

  rval(0) = L;
  rval(1) = ids_to_label.size ();
  return rval;
}
}//anonymous namespace
