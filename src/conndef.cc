// Copyright (C) 2014 Carnë Draug <carandraug@octave.org>
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

#include <octave/oct.h>
#include "conndef.h"

using namespace octave::image;

connectivity::connectivity ()
{
}

connectivity::connectivity (const octave_idx_type& conn)
{
  if (conn == 4)
    {
      mask = boolNDArray (dim_vector (3, 3), true);
      bool* md = mask.fortran_vec ();
      md[ 0] = false;
      md[ 2] = false;
      md[ 6] = false;
      md[ 8] = false;
    }
  else if (conn == 6)
    {
      mask = boolNDArray (dim_vector (3, 3, 3), false);
      bool* md = mask.fortran_vec ();
      md[ 4] = true;
      md[10] = true;
      md[12] = true;
      md[13] = true;
      md[14] = true;
      md[16] = true;
      md[22] = true;
    }
  else if (conn == 8)
    mask = boolNDArray (dim_vector (3, 3), true);
  else if (conn == 18)
    {
      mask = boolNDArray (dim_vector (3, 3, 3), true);
      bool* md = mask.fortran_vec ();
      md[ 0] = false;
      md[ 2] = false;
      md[ 6] = false;
      md[ 8] = false;
      md[18] = false;
      md[20] = false;
      md[24] = false;
      md[26] = false;
    }
  else if (conn == 26)
    mask = boolNDArray (dim_vector (3, 3, 3), true);
  else
    error ("conndef: invalid CONN `%i'", conn);

  return;
}


connectivity::connectivity (const octave_idx_type& ndims,
                            const std::string& type)
{
  dim_vector size;
  if (ndims == 1)
    size = dim_vector (3, 1);
  else
    size = dim_vector (3, 3);
    size.resize (ndims, 3);

  if (type == "maximal")
    {
      mask = boolNDArray (size, true);
    }
  else if (type == "minimal")
    {
      mask = boolNDArray (size, false);
      bool* md = mask.fortran_vec ();

      md += int (ceil (pow (3, ndims) /2) -1);  // move to center
      md[0] = true;
      for (octave_idx_type dim = 0; dim < ndims; dim++)
        {
          const octave_idx_type stride = pow (3, dim);
          md[ stride] = true;
          md[-stride] = true;
        }
    }
  else
    error ("conndef: invalid TYPE of connectivity '%s'", type.c_str ());

  return;
}

Array<octave_idx_type>
connectivity::offsets (const dim_vector& size) const
{
  const octave_idx_type nnz     = mask.nnz ();
  const octave_idx_type ndims   = mask.ndims ();
  const dim_vector      dims    = mask.dims ();

  Array<octave_idx_type> offsets (dim_vector (nnz, 1)); // retval
  const dim_vector cum_size = size.cumulative ();


  Array<octave_idx_type> diff (dim_vector (ndims, 1));

  Array<octave_idx_type> sub (dim_vector (ndims, 1), 0);
  for (octave_idx_type ind = 0, found = 0; found < nnz;
       ind++, boolNDArray::increment_index (sub, dims))
    {
      if (mask(ind))
        {
          for (octave_idx_type i = 0; i < ndims; i++)
            diff(i) = 1 - sub(i);

          octave_idx_type off = diff(0);
          for (octave_idx_type dim = 1; dim < ndims; dim++)
            off += (diff(dim) * cum_size(dim-1));
          offsets(found) = off;
          found++;
        }
    }

  return offsets;
}


// The conndef() function is really really simple and could have easily
// been a m file (actually it once was, check the hg log if it ever needs
// to be recovered) but then it would be awkward to call it from oct
// functions so we made a C++ class for it.

DEFUN_DLD(conndef, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Function File} {} conndef (@var{conn})\n\
@deftypefnx {Function File} {} conndef (@var{ndims}, @var{type})\n\
Create connectivity array.\n\
\n\
Creates a matrix of for morphological operations, where elements with\n\
a value of 1 are considered connected to the center element (a\n\
connectivity array).\n\
\n\
It can be specified by the number of dimensions, @var{ndims}, and\n\
@var{type} which must be one of the following strings:\n\
\n\
@table @asis\n\
@item @qcode{\"minimal\"}\n\
Neighbours touch the central element on a (@var{ndims}-1)-dimensional\n\
surface.\n\
\n\
@item @qcode{\"maximal\"}\n\
Neighbours touch the central element in any way. Equivalent to\n\
@code{ones (repmat (3, 1, @var{ndims}))}.\n\
\n\
@end table\n\
\n\
or the number of connected elements to the center element, @var{conn},\n\
in which case the following are valid:\n\
\n\
@table @asis\n\
@item 4\n\
Two-dimensional 4-connected neighborhood.\n\
\n\
@item 8\n\
Two-dimensional 8-connected neighborhood.\n\
\n\
@item 6\n\
Three-dimensional 6-connected neighborhood.\n\
\n\
@item 18\n\
Three-dimensional 18-connected neighborhood.\n\
\n\
@item 26\n\
Three-dimensional 26-connected neighborhood.\n\
\n\
@end table\n\
\n\
\n\
@seealso{iptcheckconn, strel}\n\
@end deftypefn")
{
  const octave_idx_type nargin = args.length ();

  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return octave_value ();
    }
  const octave_idx_type arg0 = args(0).idx_type_value (true);
  if (error_state || arg0 < 1)
    {
      error ("conndef: NDIMS and CONN must be a positive integer");
      return octave_value ();
    }

  connectivity conn;
  if (nargin == 1)
    conn = connectivity (arg0);
  else
    {
      const std::string type = args(1).string_value ();
      if (error_state)
        {
          error ("conndef: TYPE must be a string");
          return octave_value ();
        }
      conn = connectivity (arg0, type);
    }

  // we must return an array of class double
  return octave_value (NDArray (conn.mask));
}


/*
%!assert (conndef (1, "minimal"), [1; 1; 1]);
%!assert (conndef (2, "minimal"), [0 1 0; 1 1 1; 0 1 0]);

%!test
%! C = zeros (3, 3, 3);
%! C(:,2,2) = 1;
%! C(2,:,2) = 1;
%! C(2,2,:) = 1;
%! assert (conndef (3, "minimal"), C);

%!test
%! C = zeros (3, 3, 3, 3);
%! C(:,:,2,1) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! C(:,:,1,2) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! C(:,:,2,2) = [0   1   0
%!               1   1   1
%!               0   1   0];
%! C(:,:,3,2) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! C(:,:,2,3) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! assert (conndef (4, "minimal"), C);

%!assert (conndef (1, "maximal"), ones (3, 1));
%!assert (conndef (2, "maximal"), ones (3, 3));
%!assert (conndef (3, "maximal"), ones (3, 3, 3));
%!assert (conndef (4, "maximal"), ones (3, 3, 3, 3));

%!assert (nnz (conndef (3, "minimal")), 7)
%!assert (nnz (conndef (4, "minimal")), 9)
%!assert (nnz (conndef (5, "minimal")), 11)
%!assert (nnz (conndef (6, "minimal")), 13)

%!assert (find (conndef (3, "minimal")), [5 11 13 14 15 17 23](:))
%!assert (find (conndef (4, "minimal")), [14 32 38 40 41 42 44 50 68](:))
%!assert (find (conndef (5, "minimal")),
%!        [   41   95  113  119  121  122  123  125  131  149  203](:))
%!assert (find (conndef (6, "minimal")),
%!        [  122  284  338  356  362  364  365  366  368  374  392  446  608](:))

%!error conndef ()
%!error conndef (-2, "minimal")
%!error conndef (char (2), "minimal")
%!error <TYPE of connectivity> conndef (3, "invalid")
%!error conndef ("minimal", 3)
%!error <invalid CONN> conndef (10)

%!assert (conndef (2, "minimal"), conndef (4))
%!assert (conndef (2, "maximal"), conndef (8))
%!assert (conndef (3, "minimal"), conndef (6))
%!assert (conndef (3, "maximal"), conndef (26))

%!assert (conndef (18), reshape ([0 1 0 1 1 1 0 1 0
%!                                1 1 1 1 1 1 1 1 1
%!                                0 1 0 1 1 1 0 1 0], [3 3 3]))

*/
