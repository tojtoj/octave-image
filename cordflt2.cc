// Copyright (C) 2000 Teemu Ikonen
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#include <octave/oct.h>

#ifdef HAVE_OCTAVE_20
typedef Matrix boolMatrix;
#define bool_matrix_value matrix_value
#endif

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
    double anorm2 = a.real() * a.real() + a.imag() * a.imag();
    double bnorm2 = b.real() * b.real() + b.imag() * b.imag();
        
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
octave_value_list do_filtering(MT A, int nth, boolMatrix dom, MT S)
{
    int i, j, c, d;
    
    int len = 0;
    for(j = 0; j < dom.columns(); j++) {
	for(i = 0; i < dom.rows(); i++) {
	    if(dom.elem(i,j)) 
	      len++;
	}
    }
    if(nth > len - 1) {
	warning("nth should be less than number of non-zero values in domain");
	warning("setting nth to largest possible value\n");
	nth = len - 1;
    }
    if(nth < 0) {
	warning("nth should be non-negative, setting to 1\n");
	nth = 0; // nth is a c-index
    }
                
    int rowoffset = (dom.columns() + 1)/2 - 1;
    int coloffset = (dom.rows() + 1)/2 - 1;

    //outputs
    octave_value_list out;
    const int origx = A.columns() - dom.columns()+1;
    const int origy = A.rows() - dom.rows()+1;
    MT retval = MT(origy, origx);

    int *offsets = new int[len];
    ET *values = new ET[len];
    ET *adds = new ET[len];
    
    c = 0;
    d = A.rows();
    for(j = 0; j < dom.columns(); j++) {
	for(i = 0; i < dom.rows(); i++) {
	    if(dom.elem(i,j)) {
		offsets[c] = (i - coloffset) + (j - rowoffset)*d;
		adds[c] = S.elem(i,j);
		c++;
	    }
	}
    }
    
    ET *data = A.fortran_vec();
    int base = coloffset + A.rows()*rowoffset;
    for(j = 0; j < retval.columns(); j++) {
	for(i = 0; i < retval.rows(); i++) {
	    for(c = 0; c < len; c++) {
		values[c] = data[base + offsets[c]] + adds[c];
	    }
	    base++;
	    retval(i, j) = selnth(values, len, nth);
	}
	base += dom.rows() - 1;
    }

    out(0) = octave_value(retval);
    
    return out;
}

// instantiate template functions
template bool compare<double>(const double, const double);
template double selnth(double *, int, int);
template Complex selnth(Complex *, int, int);
template octave_value_list do_filtering<Matrix, double>(Matrix, int, boolMatrix, Matrix);
// g++ is broken, explicit instantiation of specialized template function
// confuses the compiler.
//template int compare<Complex>(const Complex, const Complex);
template octave_value_list do_filtering<ComplexMatrix, Complex>(ComplexMatrix, int, boolMatrix, ComplexMatrix);

DEFUN_DLD(cordflt2, args, ,
"function retval = cordflt2(A, nth, domain, S)\n\
\n\
 Implementation of two-dimensional ordered filtering. User interface\n\
 in ordfilt2.m")
{
    if(args.length() != 4) {
	print_usage ("ordfilt2");
	return octave_value_list();
    }
    
    // nth is an index to an array, thus - 1
    int nth = (int) (args(1).vector_value())(0) - 1;
    boolMatrix dom = args(2).bool_matrix_value();

    octave_value_list retval;
    
    if(args(0).is_real_matrix()) {
	Matrix A = args(0).matrix_value();
	Matrix S = args(3).matrix_value();
	retval = do_filtering<Matrix, double>(A, nth, dom, S);
    } 
    else if(args(0).is_complex_matrix()) {
	ComplexMatrix A = args(0).complex_matrix_value();
	ComplexMatrix S = args(3).complex_matrix_value();
	retval = do_filtering<ComplexMatrix, Complex>(A, nth, dom, S);
    } 
    else {
	error("A should be real or complex matrix\n");
	return octave_value_list();
    }
    
    return retval;
     
}
