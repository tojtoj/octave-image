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
#include "connectivity.h"

using namespace octave::image;

connectivity::connectivity ()
{
}

connectivity::connectivity (const octave_value& val)
{
  try
    {ctor (double_value (val));}
  catch (invalid_conversion& e)
    {
      try
        {ctor (bool_array_value (val));}
      catch (invalid_connectivity& e)
        {throw;} // so it does not get caught by the parent invalid_conversion
      catch (invalid_conversion& e)
        {throw invalid_connectivity ("must be logical or in [4 6 8 18 26]");}
    }
  return;
}

connectivity::connectivity (const boolNDArray& mask_arg)
{
  ctor (mask_arg);
  return;
}

void
connectivity::ctor (const boolNDArray& mask_arg)
{
  mask = mask_arg;

  // Must be 1x1, 3x1, or 3x3x3x...x3
  const octave_idx_type numel = mask.numel ();
  const octave_idx_type ndims = mask.ndims ();
  const dim_vector      dims  = mask.dims ();

  if (ndims == 2)
    {
      // Don't forget 1x1, and 3x1 which are valid but arrays always
      // have at least 2d
      if (   (dims(0) != 3 && dims(1) != 3)
          && (dims(0) != 3 && dims(1) != 1)
          && (dims(0) != 1 && dims(1) != 1))
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
  const double conn = val.double_value ();
  // Check is_scalar_type because the warning Octave:array-to-scalar
  // is off by default and we will get the first element only.
  if (error_state || ! val.is_scalar_type ())
    throw invalid_conversion ("no conversion to double value");
  return conn;
}

boolNDArray
connectivity::bool_array_value (const octave_value& val)
{
  const boolNDArray mask = val.bool_array_value ();
  // bool_array_value converts anything other than 0 to true, which will
  // then validate as conn array, hence any_element_not_one_or_zero()
  if (val.array_value ().any_element_not_one_or_zero ())
    throw invalid_conversion ("no conversion to bool array value");
  return mask;
}

