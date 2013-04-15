// Copyright (C) 2009 Stefan Gustavson <stefan.gustavson@gmail.com>
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

// Depends on "edtfunc.c" for the actual computations

#include <octave/oct.h>

#ifdef __cplusplus
extern "C"
{
#endif

#define DIST_EUCLIDEAN(x,y) sqrt((int)(x)*(x) + (y)*(y))
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

DEFUN_DLD (bwdist, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {@var{dist} =} bwdist (@var{bw})\n\
@deftypefnx {Loadable Function} {@var{dist} =} bwdist (@var{bw}, @var{method})\n\
@deftypefnx {Loadable Function} {[@var{dist}, @var{idx}] =} bwdist (@dots{})\n\
Compute distance transform in binary image.\n\
\n\
The image @var{bw} must be a binary matrix  For @sc{matlab} compatibility, no\n\
check is performed, all non-zero values are considered true, or object pixels.\n\
The return value @var{dist}, is the distance of each background pixel to the\n\
closest object pixel.\n\
\n\
@var{idx} is the linear index for the closest object, used to calculate the\n\
distance for each of the pixels.\n\
\n\
The distance can be measured through different @var{method}s:\n\
\n\
@table @asis\n\
@item euclidean (default)\n\
\n\
@item chessboard\n\
\n\
@item cityblock\n\
\n\
@item quasi-euclidean\n\
\n\
@end table\n\
\n\
Currently, only 2D images are supported.\n\
\n\
@end deftypefn")
{
  octave_value_list retval;

  const int nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return retval;
    }

  // for matlab compatibility, we do not actually check if the values are all
  // 0 and 1, any non-zero value is considered true

  // FIXME const boolMatrix bw = args (0).bool_matrix_value();

  const Matrix bw = args (0).matrix_value ();
  if (error_state)
    {
      error ("bwdist: BW must be a matrix");
      return retval;
    }

  std::string method = (nargin > 1) ? args (1).string_value () : "euclidean";
  if (error_state)
    {
      error ("bwdist: METHOD must be a string");
      return retval;
    }
  for (int q = 0; q < method.length (); q++)
    method[q] = tolower (method[q]);

  if (method.length () <= 2) {
    static bool warned = false;
    if (! warned )
      {
        warning ("bwdist: specifying METHOD with abbreviation is deprecated");
        warned = true;
      }
  }

  const int cols  = bw.cols  ();
  const int rows  = bw.rows  ();
  const int numel = bw.numel ();

  // Allocate two arrays for temporary output values
  OCTAVE_LOCAL_BUFFER (short, xdist, numel);
  OCTAVE_LOCAL_BUFFER (short, ydist, numel);

  Matrix dist (rows, cols); // the output distance matrix

  if (! method.compare ("euclidean") || ! method.compare ("e"))
    {
      euclidean (bw, rows, cols, xdist, ydist);
      for (int i = 0; i < numel; i++)
        dist(i) = DIST_EUCLIDEAN (xdist[i], ydist[i]);
    }
  else if (! method.compare ("chessboard") || ! method.compare ("ch"))
    {
      chessboard (bw, rows, cols, xdist, ydist);
      for (int i = 0; i < numel; i++)
        dist(i) = DIST_CHESSBOARD (xdist[i], ydist[i]);
    }
  else if (! method.compare ("cityblock") || ! method.compare ("ci"))
    {
      cityblock (bw, rows, cols, xdist, ydist);
      for (int i = 0; i < numel; i++)
        dist(i) = DIST_CITYBLOCK (xdist[i], ydist[i]);
    }
  else if (! method.compare ("quasi-euclidean") || ! method.compare ("q"))
    {
      quasi_euclidean (bw, rows, cols, xdist, ydist);
      for (int i = 0; i < numel; i++)
        dist(i) = DIST_QUASI_EUCLIDEAN (xdist[i], ydist[i]);
    }
  else
    {
      error ("bwdist: unknown METHOD '%s'", method.c_str ());
    }

  retval(0) = dist;

  if (nargout > 1)  // only compute IDX, if requested
    {
      Matrix idx (rows, cols);
      // Compute optional 'index to closest object pixel'
      for(int i = 0; i < numel; i++)
        idx (i) = i+1 - xdist[i] - ydist[i]*rows;

      retval(1) = idx;
    }

  return retval;
}

/*
%!shared bw, out
%!
%! bw = [0   1   0   1   0   1   1   0
%!       0   0   0   1   1   0   0   0
%!       0   0   0   1   1   0   0   0
%!       0   0   0   1   1   0   0   0
%!       0   0   1   1   1   1   1   1
%!       1   1   1   1   0   0   0   1
%!       1   1   1   0   0   0   1   0
%!       0   0   1   0   0   0   1   1];
%!
%! out = [ 1.00000   0.00000   1.00000   0.00000   1.00000   0.00000   0.00000   1.00000
%!         1.41421   1.00000   1.00000   0.00000   0.00000   1.00000   1.00000   1.41421
%!         2.23607   2.00000   1.00000   0.00000   0.00000   1.00000   2.00000   2.00000
%!         2.00000   1.41421   1.00000   0.00000   0.00000   1.00000   1.00000   1.00000
%!         1.00000   1.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000
%!         0.00000   0.00000   0.00000   0.00000   1.00000   1.00000   1.00000   0.00000
%!         0.00000   0.00000   0.00000   1.00000   1.41421   1.00000   0.00000   1.00000
%!         1.00000   1.00000   0.00000   1.00000   2.00000   1.00000   0.00000   0.00000];
%!
%!assert (bwdist (bw), out, 0.0001);  # default is euclidean
%!assert (bwdist (bw, "euclidean"), out, 0.0001);
%!assert (bwdist (logical (bw), "euclidean"), out, 0.0001);
%!
%! out = [ 1   0   1   0   1   0   0   1
%!         1   1   1   0   0   1   1   1
%!         2   2   1   0   0   1   2   2
%!         2   1   1   0   0   1   1   1
%!         1   1   0   0   0   0   0   0
%!         0   0   0   0   1   1   1   0
%!         0   0   0   1   1   1   0   1
%!         1   1   0   1   2   1   0   0];
%!
%!assert (bwdist (bw, "chessboard"), out);
%!
%! out = [ 1   0   1   0   1   0   0   1
%!         2   1   1   0   0   1   1   2
%!         3   2   1   0   0   1   2   2
%!         2   2   1   0   0   1   1   1
%!         1   1   0   0   0   0   0   0
%!         0   0   0   0   1   1   1   0
%!         0   0   0   1   2   1   0   1
%!         1   1   0   1   2   1   0   0];
%!
%!assert (bwdist (bw, "cityblock"), out);
%!
%! out = [ 1.00000   0.00000   1.00000   0.00000   1.00000   0.00000   0.00000   1.00000
%!         1.41421   1.00000   1.00000   0.00000   0.00000   1.00000   1.00000   1.41421
%!         2.41421   2.00000   1.00000   0.00000   0.00000   1.00000   2.00000   2.00000
%!         2.00000   1.41421   1.00000   0.00000   0.00000   1.00000   1.00000   1.00000
%!         1.00000   1.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000
%!         0.00000   0.00000   0.00000   0.00000   1.00000   1.00000   1.00000   0.00000
%!         0.00000   0.00000   0.00000   1.00000   1.41421   1.00000   0.00000   1.00000
%!         1.00000   1.00000   0.00000   1.00000   2.00000   1.00000   0.00000   0.00000];
%!
%!assert (bwdist (bw, "quasi-euclidean"), out, 0.0001);
%!
%! bw(logical (bw)) = 3; # there is no actual check if matrix is binary or 0 and 1
%!assert (bwdist (bw, "quasi-euclidean"), out, 0.0001);
%!
%!error bwdist (bw, "not a valid method");
*/
