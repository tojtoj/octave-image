// Copyright (C) 2008 Soren Hauberg
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 3
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.

// The 'compare' and 'selnth' functions are copied from the 'cordflt2' function
// developed by Teemu Ikonen. This work was released under GPLv2 or later.
//      -- Soren Hauberg, March 21st, 2008

#include <octave/oct.h>

#define SWAP(a, b) { SWAP_temp = (a); (a)=(b); (b) = SWAP_temp; }

// Template function for comparison
// ET is the type of the matrix element
template <class ET>
inline bool compare(const ET a, const ET b)
{
    if(a > b)
      return 1;
    else
      return 0;
}

// Explicit template function for complex compare
template <> inline bool compare<Complex>(const Complex a, const Complex b)
{
    const double anorm2 = a.real() * a.real() + a.imag() * a.imag();
    const double bnorm2 = b.real() * b.real() + b.imag() * b.imag();
        
    if( anorm2 > bnorm2 ) {
      return 1;
    } else {
      return 0;
    }
}

// select nth largest member from the array values
// Partitioning algorithm, see Numerical recipes chap. 8.5
template <class ET>
ET selnth(ET *vals, int len, int nth)
{
    ET SWAP_temp;
    ET hinge;
    int l, r, mid, i, j;

    l = 0;
    r = len - 1;
    for(;;) {
	// if partition size is 1 or two, then sort and return
	if(r <= l+1) {
	    if(r == l+1 && compare<ET>(vals[l], vals[r])) {
		SWAP(vals[l], vals[r]);
	    }
	    return vals[nth];
	} else {
	    mid = (l+r) >> 1;
	    SWAP(vals[mid], vals[l+1]);
	    // choose median of l, mid, r to be the hinge element
	    // and set up sentinels in the borders (order l, l+1 and r)
	    if(compare<ET>(vals[l], vals[r])) {
		SWAP(vals[l], vals[r]);
	    }
	    if(compare<ET>(vals[l+1], vals[r])) {
		SWAP(vals[l+1], vals[r]);
	    }
	    if(compare<ET>(vals[l], vals[l+1])) {
		SWAP(vals[l], vals[l+1]);
	    }
	    i = l+1;
	    j = r;
	    hinge = vals[l+1];
	    for(;;) {
		do i++; while(compare<ET>(hinge, vals[i]));
		do j--; while(compare<ET>(vals[j], hinge));
		if(i > j) 
		    break;
		SWAP(vals[i], vals[j]);
	    }
	    vals[l+1] = vals[j];
	    vals[j] = hinge;
	    if(j >= nth)
		r = j - 1;
	    if(j <= nth)
		l = i;
	}
    }
}

// Template function for doing the actual filtering
// MT is the type of the matrix to be filtered (Matrix or ComplexMatrix)
// ET is the type of the element of the matrix (double or Complex)
template <class MT, class ET> 
octave_value_list do_filtering(MT A, int nth, const boolNDArray dom, MT S)
{
    const octave_idx_type ndims = dom.ndims();
    const octave_idx_type dom_numel = dom.numel();
    const dim_vector dom_size = dom.dims();
    const dim_vector A_size = A.dims();

    octave_idx_type len = 0;
    for (octave_idx_type i = 0; i < dom_numel; i++) len += dom(i);
    if (nth > len - 1) {
	warning("__cordfltn__: nth should be less than number of non-zero values "
	        "in domain setting nth to largest possible value");
	nth = len - 1;
    }
    if (nth < 0) {
	warning("__cordfltn__: nth should be non-negative, setting to 1");
	nth = 0; // nth is a c-index
    }

    dim_vector dim_offset(dom_size);
    for (octave_idx_type i = 0; i < ndims; i++) { dim_offset(i) = (dom_size(i)+1)/2 -1; }

    // Allocate output
    octave_value_list retval;
    dim_vector out_size(dom_size);
    for (octave_idx_type i = 0; i < ndims; i++) { out_size(i) = A_size(i) - dom_size(i) + 1; }
    MT out = MT(out_size);
    const octave_idx_type out_numel = out.numel();

    // Iterate over every element of 'out'.
    dim_vector idx_dim(ndims);
    Array<octave_idx_type> dom_idx(idx_dim);
    Array<octave_idx_type> A_idx(idx_dim);
    Array<octave_idx_type> out_idx(idx_dim, 0);
    for (octave_idx_type i = 0; i < out_numel; i++) {
        // For each neighbour
        ET values[len];
        int l = 0;
        for (int n = 0; n < ndims; n++) dom_idx(n) = 0;
        for (int j = 0; j < dom_numel; j++) {
            for (int n = 0; n < ndims; n++) A_idx(n) = out_idx(n) + dom_idx(n);
            if (dom(dom_idx)) values[l++] = A(A_idx) + S(dom_idx);
            dom.increment_index(dom_idx, dom_size);
        }
            
        // Compute filter result
        out(out_idx) = selnth(values, len, nth);

        // Prepare for next iteration
        out.increment_index(out_idx, out_size);
    }
    
    retval(0) = octave_value(out);
    
    return retval;
}

// instantiate template functions
//SH template bool compare<double>(const double, const double);
//SH template double selnth(double *, int, int);
//SH template Complex selnth(Complex *, int, int);
//SH template octave_value_list do_filtering<NDArray, double>(NDArray, int, const boolNDArray, NDArray);
// g++ is broken, explicit instantiation of specialized template function
// confuses the compiler.
//template int compare<Complex>(const Complex, const Complex);
//SH template octave_value_list do_filtering<ComplexNDArray, Complex>(ComplexNDArray, int, const boolNDArray, ComplexNDArray);

DEFUN_DLD(__cordfltn__, args, , "\
-*- texinfo -*-\n\
@deftypefn {Loadable Function} __cordfltn__(@var{A}, @var{nth}, @var{domain}, @var{S})\n\
Implementation of two-dimensional ordered filtering. In general this function\n\
should NOT be used. Instead use @code{ordfilt2}.\n\
@seealso{cordflt2, ordfilt2}\n\
@end deftypefn\n\
")
{
    octave_value_list retval;
    if(args.length() != 4) {
	print_usage ();
	return retval;
    }
    
    // nth is an index to an array, thus - 1
    const int nth = (int) args(1).scalar_value() - 1;
    const boolNDArray dom = args(2).bool_array_value();
    if (error_state) {
        error("__cordfltn__: invalid input");
        return retval;
    }
    const int ndims = dom.ndims();
    const int args0_ndims = args(0).ndims();
    if (args0_ndims != ndims || args(3).ndims() != ndims) {
        error("__cordfltn__: input must be of the same dimension");
        return retval;
    }
    
    // Take action depending on input type
    if(args(0).is_real_matrix()) {
        const NDArray A = args(0).array_value();
        const NDArray S = args(3).array_value();
        retval = do_filtering<NDArray, double>(A, nth, dom, S);
    } 
    else if(args(0).is_complex_matrix()) {
        const ComplexNDArray A = args(0).complex_matrix_value();
        const ComplexNDArray S = args(3).complex_matrix_value();
        retval = do_filtering<ComplexNDArray, Complex>(A, nth, dom, S);
    } 
    else if(args(0).is_int8_type()) {
        const int8NDArray A = args(0).int8_array_value();
        const int8NDArray S = args(3).int8_array_value();
        retval = do_filtering<int8NDArray, octave_int8>(A, nth, dom, S);
    } 
    else if(args(0).is_int16_type()) {
        const int16NDArray A = args(0).int16_array_value();
        const int16NDArray S = args(3).int16_array_value();
        retval = do_filtering<int16NDArray, octave_int16>(A, nth, dom, S);
    } 
    else if(args(0).is_int32_type()) {
        const int32NDArray A = args(0).int32_array_value();
        const int32NDArray S = args(3).int32_array_value();
        retval = do_filtering<int32NDArray, octave_int32>(A, nth, dom, S);
    } 
    else if(args(0).is_int64_type()) {
        const int64NDArray A = args(0).int64_array_value();
        const int64NDArray S = args(3).int64_array_value();
        retval = do_filtering<int64NDArray, octave_int64>(A, nth, dom, S);
    } 
    else if(args(0).is_uint8_type()) {
        const uint8NDArray A = args(0).uint8_array_value();
        const uint8NDArray S = args(3).uint8_array_value();
        retval = do_filtering<uint8NDArray, octave_uint8>(A, nth, dom, S);
    } 
    else if(args(0).is_uint16_type()) {
        const uint16NDArray A = args(0).uint16_array_value();
        const uint16NDArray S = args(3).uint16_array_value();
        retval = do_filtering<uint16NDArray, octave_uint16>(A, nth, dom, S);
    } 
    else if(args(0).is_uint32_type()) {
        const uint32NDArray A = args(0).uint32_array_value();
        const uint32NDArray S = args(3).uint32_array_value();
        retval = do_filtering<uint32NDArray, octave_uint32>(A, nth, dom, S);
    } 
    else if(args(0).is_uint64_type()) {
        const uint64NDArray A = args(0).uint64_array_value();
        const uint64NDArray S = args(3).uint64_array_value();
        retval = do_filtering<uint64NDArray, octave_uint64>(A, nth, dom, S);
    } 
    else {
	error("__cordfltn__: first input should be a real, complex, or integer array");
	return retval;
    }
    
    return retval;
}
