// Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
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

#include <octave/oct.h>

// Pads the matrix MT with PADVAL, so it has the correct size to perform a
// spatial filtering with SE, for the requested SHAPE. The SHAPE argument
// is the same as in convn().
template <class T>
static T
pad_matrix (const T& mt,
            const boolNDArray& se,
            const double& padval,
            const std::string shape)
{
  // If the shape is valid, we can return the input matrix.
  octave_idx_type pad_times;
  if (shape == "valid")
    return mt;
  else if (shape == "same")
    pad_times = 1;
  else if (shape == "full")
    pad_times = 2;
  else
    {
      error ("invalid SHAPE");
      return T ();
    }
  const octave_idx_type ndims = mt.ndims ();
  const dim_vector mt_size    = mt.dims ();
  const dim_vector se_size    = se.dims ().redim (ndims);

  // The final size of the output matrix will be the size of the input
  // matrix, plus the size of the SE, less its center. If the shape is
  // "full", then we add the double.
  dim_vector out_size (mt_size);
  for (octave_idx_type i = 0; i < ndims; i++)
    out_size(i) += (se_size(i) -1) * pad_times;
  T out (out_size, padval);

  // How much should the input matrix be shifted. This will be the start
  // coordinates on the output matrix where we will place the origin of
  // the input matrix.
  Array<octave_idx_type> shift (dim_vector (1, ndims));
  for (octave_idx_type i = 0; i < ndims; i++)
    shift(i) = (floor (float (se_size(i) - 1) / 2)) * pad_times;

  out.insert (mt, shift);
  return out;
}

// For erosion we initialize the matrix with true, and change to false
// if we find a false. For dilation we do the opposite.
static boolNDArray
erode_binary (const boolNDArray& in, const boolNDArray& se)
{
  octave_value_list retval;

  const octave_idx_type ndims     = in.ndims ();
  const octave_idx_type se_nnz    = se.nnz ();
  const dim_vector se_size        = se.dims ().redim (ndims);
  const dim_vector in_size        = in.dims ();

  // Create output matrix
  dim_vector out_size (in_size);
  for (octave_idx_type i = 0; i < ndims; i++)
    out_size (i) = in_size (i) - se_size (i) + 1;
  boolNDArray out (out_size, true);

  // Erosion:  initialize output matrix with true, change when finds a false
  // Dilation: initialize output matrix with false, change when finds a true
  //
  // We will loop for all elements of the output matrix. On each iteration
  // we look at the values from the input matrix as marked by the nnz in
  // the SE. As soon as we find a false (erosion) or true (dilation), we
  // change its value on the output matrix.
  //
  // Basically, dilation and erosion are maximum and minimum filters,
  // and since this is for binary matrices, we can stop as soon as we see
  // a true or false value, no need to check all of the values like in the
  // other cases.
  //
  // Using dim_vector's and increment_index() allows us to support matrices
  // with any number of dimensions.

  // Create a 2D array with the subscript indices for each of the
  // true elements on the SE. Each column has the subscripts for
  // each true elements, and the rows are the dimensions.
  Array<octave_idx_type> se_sub  (dim_vector (ndims, 1), 0);
  Array<octave_idx_type> nnz_sub (dim_vector (ndims, se_nnz));
  for (octave_idx_type i = 0, found = 0; found < se_nnz; i++)
    {
      if (se(se_sub))
        // insert the coordinate vectors on the next column
        nnz_sub.insert (se_sub, 0, found++);
      boolNDArray::increment_index (se_sub, se_size);
    }

  // Create array with subscript indexes for the elements being
  // evaluated at any given time. We will be using linear indexes
  // later but need the subscripts to add them.
  Array<octave_idx_type> in_sub  (dim_vector (ndims, 1));
  Array<octave_idx_type> out_sub (dim_vector (ndims, 1), 0);

  bool* out_fvec                = out.fortran_vec ();
  octave_idx_type* in_sub_fvec  = in_sub.fortran_vec ();
  octave_idx_type* out_sub_fvec = out_sub.fortran_vec ();
  octave_idx_type* nnz_sub_fvec = nnz_sub.fortran_vec ();

  const octave_idx_type out_numel = out.numel ();
  for (octave_idx_type out_ind = 0; out_ind < out_numel; out_ind++)
    {
      // On each iteration we get the subscript indexes for the output
      // matrix (obtained with increment_index), and add to it the
      // subscript indexes of each of the nnz elements in the SE. These
      // are the subscript indexes for the elements in input matrix that
      // need to be evaluated for that element in the output matrix
      octave_idx_type nnz_sub_ind = 0;
      for (octave_idx_type se_ind = 0; se_ind < se_nnz; se_ind++)
        {
          nnz_sub_ind = se_ind * ndims; // move to the next column
          // get subcript indexes for the input matrix
          for (octave_idx_type n = 0; n < ndims; n++)
            in_sub_fvec[n] = out_sub_fvec[n] + nnz_sub_fvec[nnz_sub_ind++];
          if (! in(in_sub))
            {
              out_fvec[out_ind] = false;
              break;
            }
        }
      // Prepare for next iteration
      boolNDArray::increment_index (out_sub, out_size);
      OCTAVE_QUIT;
    }

  return out;
}

DEFUN_DLD(imerode, args, , "\
-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {} imerode (@var{img}, @var{se})\n\
@deftypefnx {Loadable Function} {} imerode (@var{img}, @var{se}, @var{shape})\n\
Perform dilation.\n\
\n\
@end deftypefn\n\
")
{
  octave_value_list retval;
  const octave_idx_type nargin = args.length ();
  if (nargin < 2 || nargin > 4)
    {
      print_usage ();
      return retval;
    }

  const boolNDArray im = args(0).bool_array_value ();

  const boolNDArray se = args(1).bool_array_value ();
  if (error_state)
    {
      error ("imdilate: SE must be a logical matrix");
      return retval;
    }
  const std::string shape = args(2).string_value ();

  const boolNDArray padded_im = pad_matrix<boolNDArray> (im, se, true, shape);
  const boolNDArray out = erode_binary (padded_im, se);

  retval(0) = out;
  return retval;
}
