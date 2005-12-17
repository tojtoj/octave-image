/*
 * conv2: 2D convolution for octave
 *
 * $Id$
 * 
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2, or (at your option) any
 * later version.
 * 
 * This software is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 * 
## 2000-05-17: Paul Kienzle
##    * change argument to vector conversion to work for 2.1 series octave
##      as well as 2.0 series
## 2001-02-05: Paul Kienzle
##    * accept complex arguments

 */

#include <octave/oct.h>
using namespace std;

#define MAX(a,b) ((a) > (b) ? (a) : (b))

enum Shape { SHAPE_FULL, SHAPE_SAME, SHAPE_VALID };

#if !defined (CXX_NEW_FRIEND_TEMPLATE_DECL)
extern MArray2<double>
conv2 (MArray<double>&, MArray<double>&, MArray2<double>&, Shape);

extern MArray2<Complex>
conv2 (MArray<Complex>&, MArray<Complex>&, MArray2<Complex>&, Shape);
#endif

template <class T>
MArray2<T>
conv2 (MArray<T>& R, MArray<T>& C, MArray2<T>& A, Shape ishape)
{
  int  Rn=  R.length();
  int  Cm=  C.length();
  int  Am = A.rows();
  int  An = A.columns();

/*
 *  Calculate the size of the output matrix:
 *  in order to stay Matlab compatible, it is based
 *  on the third parameter if it's separable, and the
 *  first if it's not
 */
  int outM=0,
      outN=0,
      edgM=0,
      edgN=0;

  switch (ishape)
    {
      case SHAPE_FULL:
        outM= Am + Cm - 1;
        outN= An + Rn - 1;
        edgM= Cm - 1;
        edgN= Rn - 1;
        break;

      case SHAPE_SAME:
        outM= Am;
        outN= An;
        // Follow the Matlab convention (ie + instead of -)
        edgM= ( Cm - 1) /2;
        edgN= ( Rn - 1) /2;
        break;

      case SHAPE_VALID:
        outM= Am - Cm + 1;
        outN= An - Rn + 1;
        if (outM < 0) outM = 0;
        if (outN < 0) outN = 0;
        edgM= edgN= 0;
        break;

      default:
        error("conv2: invalid value of parameter ishape");
    }

  MArray2<T> O(outM,outN);
/*
 * X accumulates the 1-D conv for each row, before calculating
 *    the convolution in the other direction
 * There is no efficiency advantage to doing it in either direction
 *     first
 */

  MArray<T> X( An );

  for( int oi=0; oi < outM; oi++ )
    {
      for( int oj=0; oj < An; oj++ )
        {
           T sum=0;

           int      ci= Cm - 1 - MAX(0, edgM-oi);
           int      ai= MAX(0, oi-edgM) ; 
           const T* Ad= A.data() + ai + Am*oj;
           const T* Cd= C.data() + ci;
           for( ; ci >= 0 && ai < Am;
                  ci--,
                  Cd--,
                  ai++,
                  Ad++)
             {
               sum+= (*Ad) * (*Cd);
             }

             X(oj)= sum;

        }

      for( int oj=0; oj < outN; oj++ )
        {
          T sum=0;
          
          int      rj= Rn - 1 - MAX(0, edgN-oj);
          int      aj= MAX(0, oj-edgN) ; 
          const T* Xd= X.data() + aj;
          const T* Rd= R.data() + rj;
          
          for( ; rj >= 0 && aj < An;
                 rj--,
                 Rd--,
                 aj++,
                 Xd++)
            {
              sum+= (*Xd) * (*Rd);
            }
          
          O(oi,oj)= sum;
        }
    }

  return O;
}

#if !defined (CXX_NEW_FRIEND_TEMPLATE_DECL)
extern MArray2<double>
conv2 (MArray2<double>&, MArray2<double>&, Shape);

extern MArray2<Complex>
conv2 (MArray2<Complex>&, MArray2<Complex>&, Shape);
#endif

template <class T>
MArray2<T>
conv2 (MArray2<T>&A, MArray2<T>&B, Shape ishape)
{
/* Convolution works fastest if we choose the A matrix to be
 *  the largest.
 *
 * Here we calculate the size of the output matrix,
 *  in order to stay Matlab compatible, it is based
 *  on the third parameter if it's separable, and the
 *  first if it's not
 *
 * NOTE in order to be Matlab compatible, we give argueably
 *  wrong sizes for 'valid' if the smallest matrix is first
 */

  int Am = A.rows();
  int An = A.columns();
  int Bm = B.rows();
  int Bn = B.columns();

  int outM=0,
      outN=0,
      edgM=0,
      edgN=0;

  switch (ishape)
    {
      case SHAPE_FULL:
        outM= Am + Bm - 1;
        outN= An + Bn - 1;
        edgM= Bm - 1;
        edgN= Bn - 1;
        break;

      case SHAPE_SAME:
        outM= Am;
        outN= An;
        edgM= ( Bm - 1) /2;
        edgN= ( Bn - 1) /2;
        break;

      case SHAPE_VALID:
        outM= Am - Bm + 1;
        outN= An - Bn + 1;
	if (outM < 0) outM = 0;
	if (outN < 0) outN = 0;
        edgM= edgN= 0;
        break;
    }

  MArray2<T> O(outM,outN);

  for( int oi=0; oi < outM; oi++ )
    {
      for( int oj=0; oj < outN; oj++ )
        {
          T sum=0;

          for( int bj= Bn - 1 - MAX(0, edgN-oj),
                   aj= MAX(0, oj-edgN);
                   bj >= 0 && aj < An;
                   bj--,
                   aj++)
            {
              int      bi= Bm - 1 - MAX(0, edgM-oi);
              int      ai= MAX(0, oi-edgM); 
              const T* Ad= A.data() + ai + Am*aj;
              const T* Bd= B.data() + bi + Bm*bj;

              for( ; bi >= 0 && ai < Am;
                     bi--,
                     Bd--,
                     ai++,
                     Ad++)
                {
                  sum+= (*Ad) * (*Bd);
                 /* Comment: it seems to be 2.5 x faster than this:
                  *        sum+= A(ai,aj) * B(bi,bj);
                  */
                }
            }

          O(oi,oj)= sum;
        }
    }

  return O;
}

/*
%!test
%! b = [0,1,2,3;1,8,12,12;4,20,24,21;7,22,25,18];
%! assert(conv2([0,1;1,2],[1,2,3;4,5,6;7,8,9]),b);
*/
DEFUN_DLD (conv2, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {y =} conv2 (@var{a}, @var{b}, @var{shape})\n\
@deftypefnx {Loadable Function} {y =} conv2 (@var{v1}, @var{v2}, @var{M}, @var{shape})\n\
\n\
Returns 2D convolution of @var{a} and @var{b} where the size\n\
of @var{c} is given by\n\
\n\
@table @asis\n\
@item @var{shape}= 'full'\n\
returns full 2-D convolution\n\
@item @var{shape}= 'same'\n\
same size as a. 'central' part of convolution\n\
@item @var{shape}= 'valid'\n\
only parts which do not include zero-padded edges\n\
@end table\n\
\n\
By default @var{shape} is 'full'. When the third argument is a matrix\n\
returns the convolution of the matrix @var{M} by the vector @var{v1}\n\
in the column direction and by vector @var{v2} in the row direction\n\
@end deftypefn")
{
  octave_value_list retval;
  octave_value tmp;
  int nargin = args.length ();
  string shape= "full"; //default
  bool separable= false;
  Shape ishape;

  if (nargin < 2 )
    {
     print_usage ("conv2");
     return retval;
    }
  else if (nargin == 3)
    {
      if ( args(2).is_string() )
        shape= args(2).string_value();
      else
        separable= true;
    } 
  else if (nargin >= 4)
    {
      separable= true;
      shape= args(3).string_value();
    }

  if ( shape == "full" )
    ishape = SHAPE_FULL;
  else if ( shape == "same" )
    ishape = SHAPE_SAME;
  else if ( shape == "valid" )
    ishape = SHAPE_VALID;
  else
    {
      error("Shape type not valid");
      print_usage ("conv2");
      return retval;
    }

   if (separable)
     {

     /*
      * If user requests separable, check first two params are vectors
      */
       if (
         !( 1== args(0).rows() || 1== args(0).columns() )
          ||
         !( 1== args(1).rows() || 1== args(1).columns() ) )
         {
          print_usage ("conv2");
          return retval;
         }

       if (  args(0).is_complex_type() ||
             args(1).is_complex_type() ||
             args(2).is_complex_type() )
         {
           ComplexColumnVector v1 (args(0).complex_vector_value());
           ComplexColumnVector v2 (args(1).complex_vector_value());
           ComplexMatrix a (args(2).complex_matrix_value());
           ComplexMatrix c(conv2(v1, v2, a, ishape));
           retval(0) = c;
         }
       else
         {
           ColumnVector v1 (args(0).vector_value());
           ColumnVector v2 (args(1).vector_value());
           Matrix a (args(2).matrix_value());
           Matrix c(conv2(v1, v2, a, ishape));
           retval(0) = c;
         }
     } // if (separable) 
   else
     {

       if ( args(0).is_complex_type() ||
            args(1).is_complex_type())
         {
           ComplexMatrix a (args(0).complex_matrix_value());
           ComplexMatrix b (args(1).complex_matrix_value());
           ComplexMatrix c(conv2(a, b, ishape));
           retval(0) = c;
         }
       else
         {
           Matrix a (args(0).matrix_value());
           Matrix b (args(1).matrix_value());
           Matrix c(conv2(a, b, ishape));
           retval(0) = c;
         }

     } // if (separable) 
      
   return retval;
}


template MArray2<double>
conv2 (MArray<double>&, MArray<double>&, MArray2<double>&, Shape);

template MArray2<double>
conv2 (MArray2<double>&, MArray2<double>&, Shape);

template MArray2<Complex>
conv2 (MArray<Complex>&, MArray<Complex>&, MArray2<Complex>&, Shape);

template MArray2<Complex>
conv2 (MArray2<Complex>&, MArray2<Complex>&, Shape);
