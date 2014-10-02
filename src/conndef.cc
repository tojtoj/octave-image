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

connectivity::connectivity (const octave_value& val)
{
  try
    {
      const double conn = double_value (val);
      if (error_state)
          throw invalid_connectivity ("must be in [4 6 8 18 26]");
      ctor (conn);
    }
  catch (invalid_connectivity& e)
    {
      const boolNDArray mask = bool_array_value (val);
      if (error_state)
        throw invalid_connectivity ("must be logical or in [4 6 8 18 26]");
      ctor (mask);
    }
  return;
}


connectivity::connectivity (const boolNDArray& mask)
{
  ctor (mask);
  return;
}

void
connectivity::ctor (const boolNDArray& mask)
{
  // Must be 1x1, 3x1, or 3x3x3x...x3
  const octave_idx_type numel = mask.numel ();
  const octave_idx_type ndims = mask.ndims ();
  const dim_vector      dims  = mask.dims ();

  if (ndims == 2)
    {
      // Don't forget 1x1, and 3x1 which are valid but arrays always
      // have at least 2d
      if (   (dims(1) != 3 && dims(2) != 3)
          && (dims(1) != 3 && dims(2) != 1)
          && (dims(1) != 1 && dims(2) != 1))
        throw invalid_connectivity ("is not 1x1, 3x1, 3x3, or 3x3x...x3");
    }
  else
    {
      for (octave_idx_type i = 0; i < ndims; i++)
        if (dims(i) != 3)
          throw invalid_connectivity ("is not 3x3x...x3");
    }

  // Center must be true
  const octave_idx_type center = floor (numel /2);
  if (! mask(center))
    throw invalid_connectivity ("center is not true");

  // Must be symmetric relative to its center
  const bool* start = mask.fortran_vec ();
  const bool* end   = mask.fortran_vec () + (numel -1);
  for (octave_idx_type i = 0; i < center; i++)
    if (start[i] != end[-i])
      throw invalid_connectivity ("is not symmetric relative to its center");

  this->mask = mask;
  return;
}

connectivity::connectivity (const octave_idx_type& conn)
{
  ctor (conn);
  return;
}

void
connectivity::ctor (const octave_idx_type& conn)
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
    throw invalid_connectivity ("must be in the set [4 6 8 18 26]");

  return;
}


connectivity::connectivity (const octave_idx_type& ndims,
                            const std::string& type)
{
  dim_vector size;
  if (ndims == 1)
    size = dim_vector (3, 1);
  else
    {
      size = dim_vector (3, 3);
      size.resize (ndims, 3);
    }

  if (type == "maximal")
    {
      mask = boolNDArray (size, true);
    }
  else if (type == "minimal")
    {
      mask = boolNDArray (size, false);
      bool* md = mask.fortran_vec ();

      md += int (floor (pow (3, ndims) /2));  // move to center
      md[0] = true;
      for (octave_idx_type dim = 0; dim < ndims; dim++)
        {
          const octave_idx_type stride = pow (3, dim);
          md[ stride] = true;
          md[-stride] = true;
        }
    }
  else
    throw invalid_connectivity ("must be \"maximal\" or \"minimal\"");

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
            diff(i) = 1 - sub(i); // 1 is center since conn is 3x3x...x3

          octave_idx_type off = diff(0);
          for (octave_idx_type dim = 1; dim < ndims; dim++)
            off += (diff(dim) * cum_size(dim-1));

          offsets(found) = off;
          found++;
        }
    }

  return offsets;
}


double
connectivity::double_value (const octave_value& val)
{
  error_state = 0;
  const double conn = val.double_value ();
  // Check is_scalar_type because the warning Octave:array-to-scalar
  // is off by default and we will get the first element only.
  if (error_state || ! val.is_scalar_type ())
    error_state = 1;
  return conn;
}

boolNDArray
connectivity::bool_array_value (const octave_value& val)
{
  error_state = 0;
  const boolNDArray mask = val.bool_array_value ();
  // bool_array_value converts anything other than 0 to true, which will
  // then validate as conn array, hence any_element_not_one_or_zero()
  if (val.array_value ().any_element_not_one_or_zero ())
    error_state = 1;
  return mask;
}


// The conndef() function is really really simple and could have easily
// been a m file (actually it once was, check the hg log if it ever needs
// to be recovered) but then it would be awkward to call it from oct
// functions so we made a C++ class for it.

DEFUN_DLD(conndef, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {} conndef (@var{conn})\n\
@deftypefnx {Loadable Function} {} conndef (@var{ndims}, @var{type})\n\
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
    {
      try
        {conn = connectivity (arg0);}
      catch (invalid_connectivity& e)
        {
          error ("conndef: CONN %s", e.what ());
          return octave_value ();
        }
    }
  else
    {
      const std::string type = args(1).string_value ();
      if (error_state)
        {
          error ("conndef: TYPE must be a string");
          return octave_value ();
        }
      try
        {conn = connectivity (arg0, type);}
      catch (invalid_connectivity& e)
        {
          error ("conndef: TYPE %s", e.what ());
          return octave_value ();
        }
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
%!error <must be a positive integer> conndef (-2, "minimal")
%!error conndef (char (2), "minimal")
%!error conndef ("minimal", 3)
%!error <TYPE must be "maximal" or "minimal"> conndef (3, "invalid")
%!error <CONN must be in the set> conndef (10)

%!assert (conndef (2, "minimal"), conndef (4))
%!assert (conndef (2, "maximal"), conndef (8))
%!assert (conndef (3, "minimal"), conndef (6))
%!assert (conndef (3, "maximal"), conndef (26))

%!assert (conndef (18), reshape ([0 1 0 1 1 1 0 1 0
%!                                1 1 1 1 1 1 1 1 1
%!                                0 1 0 1 1 1 0 1 0], [3 3 3]))
*/

// PKG_ADD: autoload ("iptcheckconn", which ("conndef"));
// PKG_DEL: autoload ("iptcheckconn", which ("conndef"), "remove");
DEFUN_DLD(iptcheckconn, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {} iptcheckconn (@var{conn}, @var{func}, @var{var})\n\
@deftypefnx {Loadable Function} {} iptcheckconn (@var{conn}, @var{func}, @var{var}, @var{pos})\n\
Check if argument is valid connectivity.\n\
\n\
If @var{conn} is not a valid connectivity argument, gives a properly\n\
formatted error message.  @var{func} is the name of the function to be\n\
used on the error message, @var{var} the name of the argument being\n\
checked (for the error message), and @var{pos} the position of the\n\
argument in the input.\n\
\n\
A valid connectivity argument must be either double or logical.  It must\n\
also be either a scalar from set [4 6 8 18 26], or a symmetric matrix\n\
with all dimensions of size 3, with only 0 or 1 as values, and 1 at its\n\
center.\n\
\n\
@seealso{conndef}\n\
@end deftypefn")
{
  const octave_idx_type nargin = args.length ();
//  const octave_value rv = octave_value ();

  if (nargin < 3 || nargin > 4)
    {
      print_usage ();
      return octave_value ();
    }

  const std::string func = args(1).string_value ();
  if (error_state)
    {
      error ("iptcheckconn: FUNC must be a string");
      return octave_value ();
    }
  const std::string var = args(2).string_value ();
  if (error_state)
    {
      error ("iptcheckconn: VAR must be a string");
      return octave_value ();
    }
  octave_idx_type pos (0);
  if (nargin > 3)
    {
      pos = args(3).idx_type_value (true);
      if (error_state || pos < 1)
        {
          error ("iptcheckconn: POS must be a positive integer");
          return octave_value ();
        }
    }

  try
    {const connectivity conn (args(0));}
  catch (invalid_connectivity& e)
    {
      if (pos == 0)
        error ("%s: %s %s", func.c_str (), var.c_str (), e.what ());
      else
        error ("%s: %s, at pos %i, %s",
               func.c_str (), var.c_str (), pos, e.what ());
    }
  return octave_value ();
}

/*
// the complete error message should be "expected error <.> but got none",
// but how to escape <> within the error message?

%!error <expected error> fail ("iptcheckconn ( 4, 'func', 'var')");
%!error <expected error> fail ("iptcheckconn ( 6, 'func', 'var')");
%!error <expected error> fail ("iptcheckconn ( 8, 'func', 'var')");
%!error <expected error> fail ("iptcheckconn (18, 'func', 'var')");
%!error <expected error> fail ("iptcheckconn (26, 'func', 'var')");

%!error <expected error> fail ("iptcheckconn (1, 'func', 'var')");
%!error <expected error> fail ("iptcheckconn (ones (3, 1), 'func', 'var')");
%!error <expected error> fail ("iptcheckconn (ones (3, 3), 'func', 'var')");
%!error <expected error> fail ("iptcheckconn (ones (3, 3, 3), 'func', 'var')");
%!error <expected error> fail ("iptcheckconn (ones (3, 3, 3, 3), 'func', 'var')");

%!error <VAR must be logical or in> iptcheckconn (3, "func", "VAR");
%!error <VAR center is not true> iptcheckconn ([1 1 1; 1 0 1; 1 1 1], "func", "VAR");
%!error <VAR must be logical or in> iptcheckconn ([1 2 1; 1 1 1; 1 1 1], "func", "VAR");
%!error <VAR is not symmetric relative to its center> iptcheckconn ([0 1 1; 1 1 1; 1 1 1], "func", "VAR");
%!error <VAR is not 3x3x...x3> iptcheckconn (ones (3, 3, 3, 4), "func", "VAR");
*/
