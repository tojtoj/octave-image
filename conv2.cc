/*
 * conv2: 2D convolution for octave
 *
 * Copyright (C) 1999 Andy Adler
 * This code has no warrany whatsoever.
 * Do what you like with this code as long as you
 *     leave this copyright in place.
 *
 * $Id$

## 2000-05-17: Paul Kienzle
##    * change argument to vector conversion to work for 2.1 series octave
##      as well as 2.0 series
## 2001-02-05: Paul Kienzle
##    * accept complex arguments

 */

#include <octave/oct.h>
using namespace std;

#define MAX(a,b) ((a) > (b) ? (a) : (b))

#define SHAPE_FULL 1
#define SHAPE_SAME 2
#define SHAPE_VALID 3

#if !defined (CXX_NEW_FRIEND_TEMPLATE_DECL)
extern MArray2<double>
conv2 (MArray<double>&, MArray<double>&, MArray2<double>&, int);

extern MArray2<Complex>
conv2 (MArray<Complex>&, MArray<Complex>&, MArray2<Complex>&, int);
#endif

template <class T>
MArray2<T>
conv2 (MArray<T>& R, MArray<T>& C, MArray2<T>& A, int ishape)
{
      int          Rn=  R.length();
      int          Cm=  C.length();
      int          Am = A.rows();
      int          An = A.columns();

/*
 * Here we calculate the size of the output matrix,
 *  in order to stay Matlab compatible, it is based
 *  on the third parameter if its separable, and the
 *  first if it's not
 */
      int outM, outN, edgM, edgN;
      if ( ishape == SHAPE_FULL ) {
         outM= Am + Cm - 1;
         outN= An + Rn - 1;
         edgM= Cm - 1;
         edgN= Rn - 1;
      } else if ( ishape == SHAPE_SAME ) {
         outM= Am;
         outN= An;
// Matlab seems to arbitrarily choose this convention for
// 'same' with even length R, C
         edgM= ( Cm - 1) /2;
         edgN= ( Rn - 1) /2;
      } else if ( ishape == SHAPE_VALID ) {
         outM= Am - Cm + 1;
         outN= An - Rn + 1;
         edgM= edgN= 0;
      }

//    printf("A(%d,%d) C(%d) R(%d) O(%d,%d) E(%d,%d)\n",
//       Am,An, Cm,Rn, outM, outN, edgM, edgN);
      MArray2<T> O(outM,outN);
/*
 * T accumulated the 1-D conv for each row, before calculating
 *    the convolution in the other direction
 * There is no efficiency advantage to doing it in either direction
 *     first
 */

      MArray<T> X( An );

      for( int oi=0; oi < outM; oi++ ) {
         for( int oj=0; oj < An; oj++ ) {
            T sum=0;

            int           ci= Cm - 1 - MAX(0, edgM-oi);
            int           ai= MAX(0, oi-edgM) ; 
            const T* Ad= A.data() + ai + Am*oj;
            const T* Cd= C.data() + ci;
            for( ; ci >= 0 && ai < Am;
                   ci--, Cd--, ai++, Ad++) {
               sum+= (*Ad) * (*Cd);
            } // for( int ci=

            X(oj)= sum;
         } // for( int oj=0

         for( int oj=0; oj < outN; oj++ ) {
            T sum=0;

            int           rj= Rn - 1 - MAX(0, edgN-oj);
            int           aj= MAX(0, oj-edgN) ; 
            const T* Xd= X.data() + aj;
            const T* Rd= R.data() + rj;

            for( ; rj >= 0 && aj < An;
                   rj--, Rd--, aj++, Xd++) {
               sum+= (*Xd) * (*Rd);
            } //for( int rj= 

            O(oi,oj)= sum;
         } // for( int oj=0
      } // for( int oi=0

      return O;
}

#if !defined (CXX_NEW_FRIEND_TEMPLATE_DECL)
extern MArray2<double>
conv2 (MArray2<double>&, MArray2<double>&, int);

extern MArray2<Complex>
conv2 (MArray2<Complex>&, MArray2<Complex>&, int);
#endif

template <class T>
MArray2<T>
conv2 (MArray2<T>&A, MArray2<T>&B, int ishape)
{
/* Convolution works fastest if we choose the A matrix to be
 *  the largest.
 *
 * Here we calculate the size of the output matrix,
 *  in order to stay Matlab compatible, it is based
 *  on the third parameter if its separable, and the
 *  first if it's not
 *
 * NOTE in order to be Matlab compatible, we give
 *  wrong sizes for 'valid' if the smallest matrix is first
 */

      int     Am = A.rows();
      int     An = A.columns();
      int     Bm = B.rows();
      int     Bn = B.columns();

      int outM, outN, edgM, edgN;
      if ( ishape == SHAPE_FULL ) {
         outM= Am + Bm - 1;
         outN= An + Bn - 1;
         edgM= Bm - 1;
         edgN= Bn - 1;
      } else if ( ishape == SHAPE_SAME ) {
         outM= Am;
         outN= An;
// Matlab seems to arbitrarily choose this convention for
// 'same' with even length R, C
         edgM= ( Bm - 1) /2;
         edgN= ( Bn - 1) /2;
      } else if ( ishape == SHAPE_VALID ) {
         outM= Am - Bm + 1;
         outN= An - Bn + 1;
         edgM= edgN= 0;
      }

//    printf("A(%d,%d) B(%d,%d) O(%d,%d) E(%d,%d)\n",
//       Am,An, Bm,Bn, outM, outN, edgM, edgN);
      MArray2<T> O(outM,outN);

      for( int oi=0; oi < outM; oi++ ) {
         for( int oj=0; oj < outN; oj++ ) {
            T sum=0;

            for( int bj= Bn - 1 - MAX(0, edgN-oj),
                     aj= MAX(0, oj-edgN);
                     bj >= 0 && aj < An;
                     bj--, aj++) {
               int           bi= Bm - 1 - MAX(0, edgM-oi);
               int           ai= MAX(0, oi-edgM); 
               const T* Ad= A.data() + ai + Am*aj;
               const T* Bd= B.data() + bi + Bm*bj;

               for( ; bi >= 0 && ai < Am;
                      bi--, Bd--, ai++, Ad++) {
                  sum+= (*Ad) * (*Bd);
/* 
 * It seems to be about 2.5 times faster to use pointers than
 *    to do this
 *                sum+= A(ai,aj) * B(bi,bj);
 */
               } // for( int bi=
            } //for( int bj=

            O(oi,oj)= sum;
         } // for( int oj=
      } // for( int oi=
      return O;
}

DEFUN_DLD (conv2, args, ,
  "[...] = conv2 (...)
CONV2: do 2 dimensional convolution

  c= conv2(a,b) -> same as c= conv2(a,b,'full')

  c= conv2(a,b,shape) returns 2-D convolution of a and b
      where the size of c is given by
     shape= 'full'  -> returns full 2-D convolution
     shape= 'same'  -> same size as a. 'central' part of convolution
     shape= 'valid' -> only parts which do not include zero-padded edges

  c= conv2(a,b,shape) returns 2-D convolution of a and b

  c= conv2(v1,v2,a) -> same as c= conv2(v1,v2,a,'full') 

  c= conv2(v1,v2,a,shape) returns convolution of a by vector v1
       in the column direction and vector v2 in the row direction ")
{
   octave_value_list retval;
   octave_value tmp;
   int nargin = args.length ();
   string shape= "full";
   bool separable= false;
   int ishape;

   if (nargin < 2 ) {
      print_usage ("conv2");
      return retval;
   } else if (nargin == 3) {
      if ( args(2).is_string() )
         shape= args(2).string_value();
      else
         separable= true;
   } else if (nargin >= 4) {
      separable= true;
      shape= args(3).string_value();
   }
   if ( shape == "full" ) ishape = SHAPE_FULL;
   else if ( shape == "same" ) ishape = SHAPE_SAME;
   else if ( shape == "valid" ) ishape = SHAPE_VALID;
   else { // if ( shape
     error("Shape type not valid");
     print_usage ("conv2");
     return retval;
   }

   if (separable) {
/*
 * Check that the first two parameters are vectors
 *  if we're doing separable
 */
      if ( !( 1== args(0).rows() || 1== args(0).columns() ) ||
           !( 1== args(1).rows() || 1== args(1).columns() ) ) {
         print_usage ("conv2");
         return retval;
      }

      if (args(0).is_complex_type() || args(1).is_complex_type()
	  || args(2).is_complex_type()) {
	ComplexColumnVector v1 (args(0).complex_vector_value());
	ComplexColumnVector v2 (args(1).complex_vector_value());
	ComplexMatrix a (args(2).complex_matrix_value());
	ComplexMatrix c(conv2(v1, v2, a, ishape));
	retval(0) = c;
      } else {
	ColumnVector v1 (args(0).vector_value());
	ColumnVector v2 (args(1).vector_value());
	Matrix a (args(2).matrix_value());
	Matrix c(conv2(v1, v2, a, ishape));
	retval(0) = c;
      }
   } else { // if (separable) 

     if (args(0).is_complex_type() || args(1).is_complex_type()) {
	ComplexMatrix a (args(0).complex_matrix_value());
	ComplexMatrix b (args(1).complex_matrix_value());
	ComplexMatrix c(conv2(a, b, ishape));
	retval(0) = c;
      } else {
	Matrix a (args(0).matrix_value());
	Matrix b (args(1).matrix_value());
	Matrix c(conv2(a, b, ishape));
	retval(0) = c;
      }

   } // if (separable) 
      
   return retval;
}


template MArray2<double>
conv2 (MArray<double>&, MArray<double>&, MArray2<double>&, int);

template MArray2<double>
conv2 (MArray2<double>&, MArray2<double>&, int);

template MArray2<Complex>
conv2 (MArray<Complex>&, MArray<Complex>&, MArray2<Complex>&, int);

template MArray2<Complex>
conv2 (MArray2<Complex>&, MArray2<Complex>&, int);
