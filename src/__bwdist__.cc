// Copyright (C) 2009 Stefan Gustavson <stefan.gustavson@gmail.com>
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

// __bwdist__.cc - OCT file, implements the BWDIST function
// Depends on "edtfunc.c" for the actual computations

#include <octave/oct.h>


#ifdef __cplusplus
extern "C"
{
#endif

#define DIST_EUCLIDEAN(x,y) ((int)(x)*(x) + (y)*(y))
#define MAX(x,y) ((x)>(y) ? (x) : (y))
#define DIST_CHESSBOARD(x,y) (MAX(abs(x), abs(y)))
#define DIST_CITYBLOCK(x,y) (abs(x) + abs(y))
#define SQRT2_1 0.4142136536
#define DIST_QUASI_EUCLIDEAN(x,y) (abs(x)>abs(y) ? (abs(x) + SQRT2_1 * abs(y)) : (SQRT2_1 * abs(x) + abs(y)))

#define DIST(x,y) DIST_EUCLIDEAN(x,y)
#define FUNCNAME euclidean
#include "edtfunc.c"
#undef DIST
#undef FUNCNAME

#define DIST(x,y) DIST_CHESSBOARD(x,y)
#define FUNCNAME chessboard
#include "edtfunc.c"
#undef DIST
#undef FUNCNAME

#define DIST(x,y) DIST_CITYBLOCK(x,y)
#define FUNCNAME cityblock
#include "edtfunc.c"
#undef DIST
#undef FUNCNAME

#define DIST(x,y) DIST_QUASI_EUCLIDEAN(x,y)
#define FUNCNAME quasi_euclidean
#include "edtfunc.c"
#undef DIST
#undef FUNCNAME

#ifdef __cplusplus
}  /* end extern "C" */
#endif

DEFUN_DLD ( __bwdist__, args, nargout,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{D} =} __bwdist__(@var{bw})\n\
Computes the distance transform of the image @var{bw}.\n\
@var{bw} should be a binary 2D array, either a Boolean array or a\n\
numeric array containing only the values 0 and 1.\n\
The return value @var{D} is a double matrix of the same size as @var{bw}.\n\
Elements with value 0 are considered background pixels, elements\n\
with value 1 are considered object pixels. The return value\n\
for each background pixel is the distance (according to the chosen\n\
metric) to the closest object pixel. For each object pixel the\n\
return value is 0.\n\
\n\
@deftypefnx{Loadable Function} {@var{D} =} __bwdist__(@var{bw}, @var{method})\n\
\n\
@var{method} is a string to choose the distance metric. Currently\n\
available metrics are 'euclidean', 'chessboard', 'cityblock' and\n\
'quasi-euclidean', which may each be abbreviated\n\
to any string starting with 'e', 'ch', 'ci' and 'q', respectively.\n\
If @var{method} is not specified, 'euclidean' is the default.\n\
\n\
@deftypefnx {Loadable Function} {[@var{D},@var{C}] =} __bwdist__(@var{bw}, @var{method})\n\
\n\
If a second output argument is given, the linear index for the\n\
closest object pixel is returned for each pixel. (For object\n\
pixels, the index points to the pixel itself.) The return value\n\
@var{C} is a matrix the same size as @var{bw}.\n\n\
@end deftypefn")
{
  const int nargin = args.length();
  octave_value_list retval;

  /* Check for proper number of input and output arguments */
  if ((nargin < 1) || (nargin>2)) {
    error ("bwdist accepts only one or two input parameters.");
  }
  else if (nargout > 2) {
    error ("bwdist returns at most 2 output parameters.");
  }
  else {
    /* Make sure input is a matrix */
    const Matrix bw = args(0).matrix_value();
    if (error_state) {
      error ("bwdist input argument must be a matrix");
      return retval;
    }
    /* Warn if input is not a binary image */
    if(bw.any_element_not_one_or_zero()) {
      warning ("bwdist input contains values other than 1 and 0.");
    }

    /* Everything seems to be OK to proceed */
    dim_vector dims = bw.dims();
    int rows = dims(0);
    int cols = dims(1);
    int caseMethod = 0; // Default 0 means Euclidean
    if(nargin > 1) {
      charMatrix method = args(1).char_matrix_value();
      if(method(0) == 'e') caseMethod = 0; // Euclidean;
      else if (method(0) == 'c') {
        if(method(1) == 'h') caseMethod = 1; // chessboard
        else if(method(1) == 'i') caseMethod = 2; // cityblock
      }
      else if(method(0) == 'q') caseMethod = 3; // quasi-Euclidean
      else {
        warning ("unknown metric, using 'euclidean'");
        caseMethod = 0;
      }
    }

    if (!error_state) {
      /* Allocate two arrays for temporary output values */
      OCTAVE_LOCAL_BUFFER (short, xdist, dims.numel());
      OCTAVE_LOCAL_BUFFER (short, ydist, dims.numel());

      /* Create final output array */
      Matrix D (rows, cols);

      /* Call the appropriate C subroutine and compute output */
      switch(caseMethod) {

      case 1:
        chessboard(bw, rows, cols, xdist, ydist);
        for(int i=0; i<rows*cols; i++) {
          D(i) = DIST_CHESSBOARD(xdist[i], ydist[i]);
        }
        break;

      case 2:
        cityblock(bw, rows, cols, xdist, ydist);
        for(int i=0; i<rows*cols; i++) {
          D(i) = DIST_CITYBLOCK(xdist[i], ydist[i]);
        }
        break;

      case 3:
        quasi_euclidean(bw, rows, cols, xdist, ydist);
        for(int i=0; i<rows*cols; i++) {
          D(i) = DIST_QUASI_EUCLIDEAN(xdist[i], ydist[i]);
        }
        break;

      case 0:
      default:
        euclidean(bw, rows, cols, xdist, ydist);
        /* Remember sqrt() for the final output */
        for(int i=0; i<rows*cols; i++) {
          D(i) = sqrt((double)DIST_EUCLIDEAN(xdist[i], ydist[i]));
        }
        break;
      }

      retval(0) = D;

      if(nargout > 1) {
        /* Create a second output array */
        Matrix C (rows, cols);
        /* Compute optional 'index to closest object pixel' */
        for(int i=0; i<rows*cols; i++) {
          C (i) = i+1 - xdist[i] - ydist[i]*rows;
        }
        retval(1) = C;
      }
    }
  }
  return retval;
}
