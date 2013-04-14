// Copyright (C) 2008 Søren Hauberg <soren@hauberg.org>
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
//      -- Søren Hauberg, March 21st, 2008

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
      error ("__spatial_filtering__: A must be a matrix");
      return retval;
    }

  octave_idx_type len = 0;
  for (octave_idx_type i = 0; i < dom.numel (); i++)
    len += dom (i);

  const int ndims = dom.ndims ();
  const int args0_ndims = args (0).ndims ();
  if (args0_ndims != ndims || args (3).ndims () != ndims)
    {
      error ("__spatial_filtering__: A and S must have the same dimensions");
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

/*
%!shared a, domain, s, out
%! a = [ 82    2   97   43   79   43   41   65   51   11
%!       60   65   21   56   94   77   36   38   75   39
%!       32   68   78    1   16   75   76   90   81   56
%!       43   90   82   41   36    1   87   19   18   63
%!       63   64    2   48   18   43   38   25   22   99
%!       12   46   90   79    3   92   39   79   10   22
%!       38   98   11   10   40   90   88   38    4   76
%!       54   37    9    4   33   98   36   47   53   57
%!       38   76   82   50   14   74   64   99    7   33
%!       88   96   41   62   84   89   97   23   41    3];
%!
%! domain = ones  (3);
%! s      = zeros (3);
%!
%! out = [  2    1    1    1   16   36   36   11
%!         21    1    1    1    1    1   18   18
%!          2    1    1    1    1    1   18   18
%!          2    2    2    1    1    1   10   10
%!          2    2    2    3    3   25    4    4
%!          9    4    3    3    3   36    4    4
%!          9    4    4    4   14   36    4    4
%!          9    4    4    4   14   23    7    3];
%!assert (__spatial_filtering__ (a, domain, "min", s), out);
%!assert (__spatial_filtering__ (a, domain, "ordered", s, 1), out);
%!
%! out = [ 97   97   97   94   94   90   90   90
%!         90   90   94   94   94   90   90   90
%!         90   90   82   75   87   90   90   99
%!         90   90   90   92   92   92   87   99
%!         98   98   90   92   92   92   88   99
%!         98   98   90   98   98   98   88   79
%!         98   98   82   98   98   99   99   99
%!         96   96   84   98   98   99   99   99];
%!assert (__spatial_filtering__ (a, domain, "max", s), out);
%!assert (__spatial_filtering__ (a, domain, "ordered", s, nnz (domain)), out);
%!
%! out = [ 60   43   43   43   43   43   51   51
%!         60   56   36   36   36   38   38   39
%!         63   48   18   18   36   38   25   25
%!         46   48   36   36   36   38   22   22
%!         38   46   11   40   39   39   25   22
%!         37   11   10   33   39   47   38   38
%!         38   11   11   33   40   64   38   38
%!         41   41   33   50   64   64   41   33];
%!assert (__spatial_filtering__ (a, domain, "ordered", s, 4), out);
%!
%! out = [ 31.223   33.788   35.561   31.011   26.096   20.630   20.403   24.712
%!         23.428   29.613   32.376   34.002   33.593   32.470   29.605   26.333
%!         27.834   32.890   29.903   24.207   30.083   32.497   31.898   32.600
%!         32.027   28.995   33.530   31.002   32.241   32.004   27.501   32.070
%!         34.682   36.030   33.046   33.745   32.509   27.352   28.607   34.180
%!         32.709   37.690   32.992   40.036   34.456   26.656   27.685   26.863
%!         30.971   36.227   25.775   34.873   29.917   25.269   32.292   30.410
%!         29.135   31.626   30.056   33.594   30.814   28.853   30.917   29.120];
%!assert (__spatial_filtering__ (a, domain, "std", s), out, 0.001);
%!
%! out = [ 95   96   96   93   78   54   54   79
%!         69   89   93   93   93   89   72   72
%!         88   89   81   74   86   89   72   81
%!         88   88   88   91   91   91   77   89
%!         96   96   88   89   89   67   84   95
%!         89   94   87   95   95   62   84   75
%!         89   94   78   94   84   63   95   95
%!         87   92   80   94   84   76   92   96];
%!assert (__spatial_filtering__ (a, domain, "range", s), out);
%!
%! domain = [ 1 1 0
%!            0 1 1
%!            0 1 0];
%!
%! out = [  2    2    1   16   36   36   38   39
%!         60    1    1   16    1   36   19   18
%!         32    2    1    1    1   19   18   18
%!          2    2   18    3    1    1   19   10
%!         46    2    2    3   18   38   10    4
%!         11    9    4    3    3   36    4    4
%!          9    4    4   10   36   36   38    4
%!         37    9    4    4   33   36    7    7];
%!assert (__spatial_filtering__ (a, domain, "min", s), out);
%!assert (__spatial_filtering__ (a, domain, "ordered", s, 1), out);
%!
%! out = [ 82   97   97   94   79   76   90   81
%!         90   82   56   94   94   90   90   81
%!         90   82   78   36   87   87   90   90
%!         90   90   82   43   92   87   87   99
%!         98   90   79   92   92   88   79   25
%!         98   90   90   90   98   92   79   79
%!         98   98   50   98   98   90   99   57
%!         96   82   62   84   98   99   99   53];
%!assert (__spatial_filtering__ (a, domain, "max", s), out);
%!assert (__spatial_filtering__ (a, domain, "ordered", s, nnz (domain)), out);
%!
%! out = [ 68   78   94   79   77   43   75   75
%!         78   78   41   75   77   87   81   75
%!         82   78   48   18   75   76   76   81
%!         64   90   79   41   43   39   79   22
%!         90   79   48   48   90   79   38   22
%!         46   46   79   79   92   88   47   76
%!         76   82   33   40   90   88   88   53
%!         82   50   50   74   89   98   47   47];
%!assert (__spatial_filtering__ (a, domain, "ordered", s, 4), out);
%!
%! out = [ 34.2389   39.2772   39.6699   31.6812   20.7364   16.5439   22.2419   17.2395
%!         11.9248   36.3084   21.6217   30.8350   36.4047   21.6726   30.9144   26.1017
%!         22.2980   33.2746   27.5808   14.5017   36.8890   29.0259   34.6020   33.2521
%!         32.2490   37.9579   26.9685   17.1959   32.5346   31.3847   33.5976   36.8280
%!         21.3354   40.1833   34.0044   33.9882   32.9894   24.1102   25.6613    9.0995
%!         35.4641   35.3794   39.0871   35.4753   39.9775   28.7193   26.7451   35.6553
%!         35.2179   45.3398   19.3210   35.2987   28.4042   24.0832   26.8421   25.0539
%!         23.4307   26.2812   26.3287   35.6959   25.2646   28.1016   34.9829   17.9221];
%!assert (__spatial_filtering__ (a, domain, "std", s), out, 0.001);
%!
%! out = [ 80   95   96   78   43   40   52   42
%!         30   81   55   78   93   54   71   63
%!         58   80   77   35   86   68   72   72
%!         88   88   64   40   91   86   68   89
%!         52   88   77   89   74   50   69   21
%!         87   81   86   87   95   56   75   75
%!         89   94   46   88   62   54   61   53
%!         59   73   58   80   65   63   92   46];
%!assert (__spatial_filtering__ (a, domain, "range", s), out);
%!
%! s = [  1  -3   4
%!        6  -7   2
%!       -1   3  -5];
%!
%! out = [ -1    3    4   19   38   29   31   41
%!         61    3   -6    9    4   33   22   21
%!         33    5   -2    2   -6   21   12   11
%!          4   -5   20    6   -2    2   16   13
%!         39   -1    3   -4   19   32   12    3
%!         13    4    3    0    4   36    6   -3
%!         11    2   -3   11   38   29   35    1
%!         34    6    1    5   34   33    9    0];
%!assert (__spatial_filtering__ (a, domain, "min", s), out);
%!assert (__spatial_filtering__ (a, domain, "ordered", s, 1), out);
%!
%! out = [  83    94    98    87    80    79    93    84
%!          93    85    53    91    95    92    83    74
%!          84    75    79    29    89    80    87    91
%!          87    93    83    45    95    84    88   101
%!         101    83    72    94    93    91    72    26
%!          91    87    91    92   101    93    76    80
%!          95    99    53   100    91    91   102    59
%!          99    75    65    87    95   101    92    50];
%!assert (__spatial_filtering__ (a, domain, "max", s), out);
%!assert (__spatial_filtering__ (a, domain, "ordered", s, nnz (domain)), out);
%!
%! out = [  71    81    96    79    78    44    77    68
%!          80    71    44    77    78    90    83    72
%!          83    75    51    21    72    76    77    78
%!          57    91    82    42    40    42    82    20
%!          92    81    45    49    85    81    41    24
%!          43    47    76    80    90    81    50    78
%!          79    85    35    37    87    85    89    46
%!          84    52    43    76    92   100    44    48];
%!assert (__spatial_filtering__ (a, domain, "ordered", s, 4), out);
%!
%! out = [ 34.903   40.206   39.885   28.627   20.620   19.248   25.209   17.111
%!         14.536   35.865   23.221   32.230   34.903   23.923   28.879   22.621
%!         20.635   30.113   29.351   11.610   38.863   25.936   34.608   34.482
%!         29.811   40.998   28.279   17.897   34.666   29.978   36.150   38.213
%!         25.066   39.240   30.013   37.300   31.856   27.428   22.884   10.281
%!         31.890   34.761   39.645   37.526   39.336   27.031   25.648   39.285
%!         35.017   47.776   22.764   35.912   25.460   25.636   29.861   24.566
%!         25.213   25.000   26.391   38.451   24.631   31.305   31.118   20.611];
%!assert (__spatial_filtering__ (a, domain, "std", s), out, 0.001);
%!
%! out = [ 84   91   94   68   42   50   62   43
%!         32   82   59   82   91   59   61   53
%!         51   70   81   27   95   59   75   80
%!         83   98   63   39   97   82   72   88
%!         62   84   69   98   74   59   60   23
%!         78   83   88   92   97   57   70   83
%!         84   97   56   89   53   62   67   58
%!         65   69   64   82   61   68   83   50];
%!assert (__spatial_filtering__ (a, domain, "range", s), out);
*/
