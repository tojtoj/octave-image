// Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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

// The 'compare' and 'selnth' functions are copied from the 'cordflt2' function
// developed by Teemu Ikonen. This work was released under GPLv2 or later.
//      -- Soren Hauberg, March 21st, 2008

#include <octave/oct.h>

/**
 * Filter functions for ordered filtering.
 */

template <class ET>
inline bool compare (const ET a, const ET b)
{
    if (a > b)
      return 1;
    else
      return 0;
}

template <> inline bool compare<Complex> (const Complex a, const Complex b)
{
    const double anorm2 = a.real () * a.real () + a.imag () * a.imag ();
    const double bnorm2 = b.real () * b.real () + b.imag () * b.imag ();
        
    if (anorm2 > bnorm2)
      return 1;
    else
      return 0;
}

// select nth largest member from the array values
// Partitioning algorithm, see Numerical recipes chap. 8.5
template <class ET, class MT, class ET_OUT>
ET_OUT selnth (MT &vals, octave_idx_type len, int nth)
{
  ET hinge;
  int l, r, mid, i, j;

  l = 0;
  r = len - 1;
  for (;;)
    {
      // if partition size is 1 or two, then sort and return
      if (r <= l+1)
        {
          if (r == l+1 && compare<ET> (vals (l), vals (r)))
            std::swap (vals (l), vals (r));

          return vals (nth);
        }
      else
        {
          mid = (l+r) >> 1;
          std::swap (vals (mid), vals (l+1));

          // choose median of l, mid, r to be the hinge element
          // and set up sentinels in the borders (order l, l+1 and r)
          if (compare<ET> (vals (l), vals (r)))
            std::swap (vals (l), vals (r));
            
          if (compare<ET> (vals (l+1), vals (r)))
            std::swap (vals (l+1), vals (r));
            
          if (compare<ET> (vals (l), vals (l+1)))
            std::swap (vals (l), vals (l+1));
            
          i = l + 1;
          j = r;
          hinge = vals (l+1);
          for (;;)
            {
              do i++; while (compare<ET> (hinge, vals (i)));
              do j--; while (compare<ET> (vals (j), hinge));
              if (i > j) 
                break;
              std::swap (vals (i), vals (j));
            }
          vals (l+1) = vals (j);
          vals (j) = hinge;
          if (j >= nth)
            r = j - 1;
          if (j <= nth)
            l = i;
        }
    }
}

template <class ET, class MT, class ET_OUT>
ET_OUT min_filt (MT &vals, octave_idx_type len, int not_used)
{
  ET_OUT min_val = vals (0);
  for (octave_idx_type i = 1; i < len; i++)
    min_val = compare (min_val, vals (i)) ? vals (i) : min_val;
    
  return min_val;
}

template <class ET, class MT, class ET_OUT>
ET_OUT max_filt (MT &vals, octave_idx_type len, int not_used)
{
  ET_OUT max_val = vals (0);
  for (octave_idx_type i = 1; i < len; i++)
    max_val = compare (max_val, vals (i)) ? max_val : vals (i);
    
  return max_val;
}

/**
 * Filter functions for standard deviation filters
 */

template <class ET> inline
ET square (const ET a)
{
  return a * a;
}

template <class ET, class MT, class ET_OUT>
ET_OUT std_filt (MT &vals, octave_idx_type len, int norm)
{
  // Compute mean
  ET_OUT mean = 0;
  for (octave_idx_type i = 0; i < len; i++)
    mean += (ET_OUT)vals (i);
  mean /= (ET_OUT)len;
  
  // Compute sum of square differences from the mean
  ET_OUT var = 0;
  for (octave_idx_type i = 0; i < len; i++)
    var += square ((ET_OUT)vals (i) - mean);
    
  // Normalise to produce variance
  var /= (ET_OUT)norm;
    
  // Compute std. deviation
  return sqrt (var);
}

/**
 * Functions for the entropy filter.
 */

/* We only need the explicit typed versions */
template <class ET>
void get_entropy_info (ET &add, int &nbins)
{
}

#define ENTROPY_INFO(TYPE, ADD, NBINS) \
  template <> \
  void get_entropy_info<TYPE> (TYPE &add, int &nbins) \
  { \
    add = ADD; \
    if (nbins <= 0) \
      nbins = NBINS; \
  }
  
ENTROPY_INFO (bool, 0, 2)
ENTROPY_INFO (octave_int8, 128, 256)
//ENTROPY_INFO (octave_int16, 32768, 65536)
ENTROPY_INFO (octave_uint8, 0, 256)
//ENTROPY_INFO (octave_uint16, 0, 65536)

#undef ENTROPY_INFO

template <class ET, class MT, class ET_OUT>
ET_OUT entropy_filt (MT &vals, octave_idx_type len, int nbins)
{
  ET add;
  get_entropy_info<ET> (add, nbins);
  
  // Compute histogram from values
  ColumnVector hist (nbins, 0);
  for (octave_idx_type i = 0; i < len; i++)
    hist (vals (i) + add) ++;
  for (octave_idx_type i = 0; i < len; i++)
    hist (vals (i) + add) /= (double)len;
    
  // Compute entropy
  double entropy = 0;
  for (octave_idx_type i = 0; i < nbins; i++)
    {
      const double p = hist (i);
      if (p > 0)
        entropy -= p * xlog2 (p);
    }

  return entropy;
}

/**
 * The function for the range filter
 */
template <class ET, class MT, class ET_OUT>
ET_OUT range_filt (MT &vals, octave_idx_type len, int not_used)
{
  const ET_OUT min_val = min_filt<ET, MT, ET_OUT> (vals, len, not_used);
  const ET_OUT max_val = max_filt<ET, MT, ET_OUT> (vals, len, not_used);

  return max_val - min_val;
}

/**
 * The general function for doing the filtering.
 */
 
template <class MT, class ET, class MTout, class ETout> 
octave_value_list do_filtering (const MT &A, const boolNDArray &dom,
   ETout (*filter_function) (MT&, octave_idx_type, int), const MT &S, int arg4)
{
  octave_value_list retval;

  const int ndims = dom.ndims ();
  const octave_idx_type dom_numel = dom.numel ();
  const dim_vector dom_size = dom.dims ();
  const dim_vector A_size = A.dims ();

  octave_idx_type len = 0;
  for (octave_idx_type i = 0; i < dom_numel; i++)
    len += dom (i);

  // Allocate output
  dim_vector out_size (dom_size);
  for (int i = 0; i < ndims; i++)
    out_size (i) = A_size (i) - dom_size (i) + 1;

  MTout out = MTout (out_size);
  const octave_idx_type out_numel = out.numel ();

  // Iterate over every element of 'out'.
  dim_vector idx_dim (ndims, 1);
  Array<octave_idx_type> dom_idx (idx_dim);
  Array<octave_idx_type> A_idx (idx_dim);
  Array<octave_idx_type> out_idx (idx_dim, 0);
  
  dim_vector values_size (1, len);
  MT values (values_size);
  
  for (octave_idx_type i = 0; i < out_numel; i++)
    {
      // For each neighbour
      int l = 0;
      for (int n = 0; n < ndims; n++)
        dom_idx (n) = 0;
   
      for (octave_idx_type j = 0; j < dom_numel; j++)
        {
          for (int n = 0; n < ndims; n++)
            A_idx (n) = out_idx (n) + dom_idx (n);
       
          if (dom (dom_idx))
            values (l++) = A (A_idx) + S (dom_idx);
       
          dom.increment_index (dom_idx, dom_size);
        }
            
      // Compute filter result
      out (out_idx) = filter_function (values, len, arg4);

      // Prepare for next iteration
      out.increment_index (out_idx, out_size);
       
      OCTAVE_QUIT;
    }
    
  retval (0) = octave_value (out);
    
  return retval;
}

/**
 * The Octave function
 */
 
DEFUN_DLD(__spatial_filtering__, args, , "\
-*- texinfo -*-\n\
@deftypefn {Loadable Function} __spatial_filtering__(@var{A}, @var{domain},\
@var{method}, @var{S}, @var{arg})\n\
Implementation of two-dimensional spatial filtering. In general this function\n\
should NOT be used -- user interfaces are available in other functions.\n\
The function computes local characteristics of the image @var{A} in the domain\n\
@var{domain}. The following values of @var{method} are supported.\n\
\n\
@table @asis\n\
@item \"ordered\"\n\
Perform ordered filtering. The output in a pixel is the @math{n}th value of a\n\
sorted list containing the elements of the neighbourhood. The value of @math{n}\n\
is given in the @var{arg} argument. The corresponding user interface is available\n\
in @code{ordfilt2} and @code{ordfiltn}.\n\
@item \"std\"\n\
Compute the local standard deviation. The corresponding user interface is available\n\
in @code{stdfilt}.\n\
@item \"entropy\"\n\
Compute the local entropy. The corresponding user interface is available\n\
in @code{entropyfilt}.\n\
@item \"range\"\n\
Compute the local range of the data. The corresponding user interface is\n\
available in @code{rangefilt}.\n\
@item \"min\"\n\
Computes the smallest value in a local neighbourheed.\n\
@item \"max\"\n\
Computes the largest value in a local neighbourheed.\n\
@item \"encoded sign of difference\"\n\
NOT IMPLEMENTED (local binary patterns style)\n\
@end table\n\
@seealso{ordfilt2}\n\
@end deftypefn\n\
")
{
  octave_value_list retval;
  const int nargin = args.length ();
  if (nargin < 4)
    {
        print_usage ();
        return retval;
    }
    
  const boolNDArray dom = args (1).bool_array_value ();
  if (error_state)
    {
      error ("__spatial_filtering__: invalid input");
      return retval;
    }
    
  octave_idx_type len = 0;
  for (octave_idx_type i = 0; i < dom.numel (); i++)
    len += dom (i);

  const int ndims = dom.ndims ();
  const int args0_ndims = args (0).ndims ();
  if (args0_ndims != ndims || args (3).ndims () != ndims)
    {
      error ("__spatial_filtering__: input must be of the same dimension");
      return retval;
    }
  
  
  int arg4 = (nargin == 4) ? 0 : args (4).int_value ();

  const std::string method = args (2).string_value ();
  if (error_state)
    {
      error ("__spatial_filtering__: method must be a string");
      return retval;
    }
  
  #define GENERAL_ACTION(MT, FUN, ET, MT_OUT, ET_OUT, FILTER_FUN) \
    { \
      const MT A = args (0).FUN (); \
      const MT S = args (3).FUN (); \
      if (error_state) \
        error ("__spatial_filtering__: invalid input"); \
      else \
        retval = do_filtering<MT, ET, MT_OUT, ET_OUT> (A, dom, FILTER_FUN<ET, MT, ET_OUT>, S, arg4); \
    }

  if (method == "ordered")
    {
      // Handle input
      arg4 -= 1; // convert arg to zero-based index
      if (arg4 > len - 1)
        {
          warning ("__spatial_filtering__: nth should be less than number of non-zero "
                   "values in domain setting nth to largest possible value");
          arg4 = len - 1;
        }
      if (arg4 < 0)
        {
          warning ("__spatial_filtering__: nth should be non-negative, setting to 1");
          arg4 = 0;
        }

      // Do the real work
      #define ACTION(MT, FUN, ET) \
              GENERAL_ACTION(MT, FUN, ET, MT, ET, selnth)
      if (args (0).is_real_matrix ())
        ACTION (NDArray, array_value, double)
      else if (args (0).is_complex_matrix ())
        ACTION (ComplexNDArray, complex_array_value, Complex)
      else if (args (0).is_bool_matrix ())
        ACTION (boolNDArray, bool_array_value, bool)
      else if (args (0).is_int8_type ())
        ACTION (int8NDArray, int8_array_value, octave_int8)
      else if (args (0).is_int16_type ())
        ACTION (int16NDArray, int16_array_value, octave_int16)
      else if (args (0).is_int32_type ())
        ACTION (int32NDArray, int32_array_value, octave_int32)
      else if (args (0).is_int64_type ())
        ACTION (int64NDArray, int64_array_value, octave_int64)
      else if (args (0).is_uint8_type ())
        ACTION (uint8NDArray, uint8_array_value, octave_uint8)
      else if (args (0).is_uint16_type ())
        ACTION (uint16NDArray, uint16_array_value, octave_uint16)
      else if (args (0).is_uint32_type ())
        ACTION (uint32NDArray, uint32_array_value, octave_uint32)
      else if (args (0).is_uint64_type ())
        ACTION (uint64NDArray, uint64_array_value, octave_uint64)
      else
        error ("__spatial_filtering__: first input should be a real, complex, or integer array");
        
      #undef ACTION
    }
  else if (method == "min")
    {
      // Do the real work
      #define ACTION(MT, FUN, ET) \
              GENERAL_ACTION(MT, FUN, ET, MT, ET, min_filt)
      if (args (0).is_real_matrix ())
        ACTION (NDArray, array_value, double)
      else if (args (0).is_complex_matrix ())
        ACTION (ComplexNDArray, complex_array_value, Complex)
      else if (args (0).is_bool_matrix ())
        ACTION (boolNDArray, bool_array_value, bool)
      else if (args (0).is_int8_type ())
        ACTION (int8NDArray, int8_array_value, octave_int8)
      else if (args (0).is_int16_type ())
        ACTION (int16NDArray, int16_array_value, octave_int16)
      else if (args (0).is_int32_type ())
        ACTION (int32NDArray, int32_array_value, octave_int32)
      else if (args (0).is_int64_type ())
        ACTION (int64NDArray, int64_array_value, octave_int64)
      else if (args (0).is_uint8_type ())
        ACTION (uint8NDArray, uint8_array_value, octave_uint8)
      else if (args (0).is_uint16_type ())
        ACTION (uint16NDArray, uint16_array_value, octave_uint16)
      else if (args (0).is_uint32_type ())
        ACTION (uint32NDArray, uint32_array_value, octave_uint32)
      else if (args (0).is_uint64_type ())
        ACTION (uint64NDArray, uint64_array_value, octave_uint64)
      else
        error ("__spatial_filtering__: first input should be a real, complex, or integer array");
        
      #undef ACTION
    }
  else if (method == "max")
    {
      // Do the real work
      #define ACTION(MT, FUN, ET) \
              GENERAL_ACTION(MT, FUN, ET, MT, ET, max_filt)
      if (args (0).is_real_matrix ())
        ACTION (NDArray, array_value, double)
      else if (args (0).is_complex_matrix ())
        ACTION (ComplexNDArray, complex_array_value, Complex)
      else if (args (0).is_bool_matrix ())
        ACTION (boolNDArray, bool_array_value, bool)
      else if (args (0).is_int8_type ())
        ACTION (int8NDArray, int8_array_value, octave_int8)
      else if (args (0).is_int16_type ())
        ACTION (int16NDArray, int16_array_value, octave_int16)
      else if (args (0).is_int32_type ())
        ACTION (int32NDArray, int32_array_value, octave_int32)
      else if (args (0).is_int64_type ())
        ACTION (int64NDArray, int64_array_value, octave_int64)
      else if (args (0).is_uint8_type ())
        ACTION (uint8NDArray, uint8_array_value, octave_uint8)
      else if (args (0).is_uint16_type ())
        ACTION (uint16NDArray, uint16_array_value, octave_uint16)
      else if (args (0).is_uint32_type ())
        ACTION (uint32NDArray, uint32_array_value, octave_uint32)
      else if (args (0).is_uint64_type ())
        ACTION (uint64NDArray, uint64_array_value, octave_uint64)
      else
        error ("__spatial_filtering__: first input should be a real, complex, or integer array");
        
      #undef ACTION
    }
  else if (method == "range")
    {
      // Do the real work
      #define ACTION(MT, FUN, ET) \
              GENERAL_ACTION(MT, FUN, ET, MT, ET, range_filt)
      if (args (0).is_real_matrix ())
        ACTION (NDArray, array_value, double)
      else if (args (0).is_complex_matrix ())
        ACTION (ComplexNDArray, complex_array_value, Complex)
      else if (args (0).is_bool_matrix ())
        ACTION (boolNDArray, bool_array_value, bool)
      else if (args (0).is_int8_type ())
        ACTION (int8NDArray, int8_array_value, octave_int8)
      else if (args (0).is_int16_type ())
        ACTION (int16NDArray, int16_array_value, octave_int16)
      else if (args (0).is_int32_type ())
        ACTION (int32NDArray, int32_array_value, octave_int32)
      else if (args (0).is_int64_type ())
        ACTION (int64NDArray, int64_array_value, octave_int64)
      else if (args (0).is_uint8_type ())
        ACTION (uint8NDArray, uint8_array_value, octave_uint8)
      else if (args (0).is_uint16_type ())
        ACTION (uint16NDArray, uint16_array_value, octave_uint16)
      else if (args (0).is_uint32_type ())
        ACTION (uint32NDArray, uint32_array_value, octave_uint32)
      else if (args (0).is_uint64_type ())
        ACTION (uint64NDArray, uint64_array_value, octave_uint64)
      else
        error ("__spatial_filtering__: first input should be a real, complex, or integer array");
        
      #undef ACTION
    }
  else if (method == "std")
    {
      // Compute normalisation factor
      if (arg4 == 0)
        arg4 = len - 1; // unbiased
      else
        arg4 = len; // max. likelihood
      
      // Do the real work
      #define ACTION(MT, FUN, ET) \
              GENERAL_ACTION(MT, FUN, ET, NDArray, double, std_filt)
      if (args (0).is_real_matrix ())
        ACTION (NDArray, array_value, double)
      else if (args (0).is_bool_matrix ())
        ACTION (boolNDArray, bool_array_value, bool)
      else if (args (0).is_int8_type ())
        ACTION (int8NDArray, int8_array_value, octave_int8)
      else if (args (0).is_int16_type ())
        ACTION (int16NDArray, int16_array_value, octave_int16)
      else if (args (0).is_int32_type ())
        ACTION (int32NDArray, int32_array_value, octave_int32)
      else if (args (0).is_int64_type ())
        ACTION (int64NDArray, int64_array_value, octave_int64)
      else if (args (0).is_uint8_type ())
        ACTION (uint8NDArray, uint8_array_value, octave_uint8)
      else if (args (0).is_uint16_type ())
        ACTION (uint16NDArray, uint16_array_value, octave_uint16)
      else if (args (0).is_uint32_type ())
        ACTION (uint32NDArray, uint32_array_value, octave_uint32)
      else if (args (0).is_uint64_type ())
        ACTION (uint64NDArray, uint64_array_value, octave_uint64)
      else
        error ("__spatial_filtering__: first input should be a real, complex, or integer array");
        
      #undef ACTION
    }
  else if (method == "entropy")
    {
      // Do the real work
      #define ACTION(MT, FUN, ET) \
              GENERAL_ACTION(MT, FUN, ET, NDArray, double, entropy_filt)
      if (args (0).is_bool_matrix ())
        ACTION (boolNDArray, bool_array_value, bool)
      else if (args (0).is_int8_type ())
        ACTION (int8NDArray, int8_array_value, octave_int8)
      else if (args (0).is_uint8_type ())
        ACTION (uint8NDArray, uint8_array_value, octave_uint8)
      else
        error ("__spatial_filtering__: first input should be a real, complex, or integer array");
        
      #undef ACTION
    }
  else
    {
      error ("__spatial_filtering__: unknown method '%s'.", method.c_str ());
    }

  return retval;
}
