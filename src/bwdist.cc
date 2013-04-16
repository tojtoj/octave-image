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

// TODO output Matrix must be single class
//      class of IDX is uint32 for numel () <= 2^32 - 1
//                      uint64 for numel () >= 2^32
//      check for any improvement in using boolean matrix

#include <octave/oct.h>

/*
 edtfunc - Euclidean distance transform of a binary image
 
 This is a sweep-and-update Euclidean distance transform of
 a binary image. All positive pixels are considered object
 pixels, zero or negative pixels are treated as background.
 
 By Stefan Gustavson (stefan.gustavson@gmail.com).
 
 Originally written in 1994, based on paper-only descriptions
 of the SSED8 algorithm, invented by Per-Erik Danielsson
 and improved by Ingemar Ragnemalm. This is a classic algorithm
 with roots in the 1980s, still very good for the 2D case.
 
 Updated in 2004 to treat pixels at image edges correctly,
 and to improve code readability.
 
 Edited in 2009 to form the foundation for Octave BWDIST:
 added #define-configurable distance measure and function name
 
 Edited in 2013 for C++ and removed the #define stuff
 */

/*
  Using template for optimization.
  Because func is called a lot of times in edtfunc, we instantiate edtfunc
  multiple times for each of the different distance measuring functions.
*/

template<typename func>
void edtfunc (const Matrix &img,
              short *distx,
              short *disty)
{
  const int w     = img.cols  ();
  const int h     = img.rows  ();
  const int numel = img.numel ();

  int x, y, i;
  double olddist2, newdist2, newdistx, newdisty;
  bool changed;

  // Initialize index offsets for the current image width
  const int offset_u  = -w;
  const int offset_ur = -w+1;
  const int offset_r  = 1;
  const int offset_rd = w+1;
  const int offset_d  = w;
  const int offset_dl = w-1;
  const int offset_l  = -1;
  const int offset_lu = -w-1;

  // Initialize the distance images to be all large values
  for (i = 0; i < numel; i++)
    {
      if(img(i) <= 0.0)
        {
          distx[i] = 32000; // Large but still representable in a short, and
          disty[i] = 32000; // 32000^2 + 32000^2 does not overflow an int
        }
      else
        {
          distx[i] = 0;
          disty[i] = 0;
        }
    }

  // Perform the transformation
  do
    {
      changed = false;

      // Scan rows, except first row
      for (y = 1; y < h; y++)
        {

          // move index to leftmost pixel of current row
          i = y*w;

          /* scan right, propagate distances from above & left */

          /* Leftmost pixel is special, has no left neighbors */
          olddist2 = func::apply(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_ur]-1;
              newdisty = disty[i+offset_ur]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
          i++;

          /* Middle pixels have all neighbors */
          for(x=1; x<w-1; x++, i++)
            {
              olddist2 = func::apply(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_lu]+1;
              newdisty = disty[i+offset_lu]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_ur]-1;
              newdisty = disty[i+offset_ur]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }

          /* Rightmost pixel of row is special, has no right neighbors */
          olddist2 = func::apply(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_lu]+1;
              newdisty = disty[i+offset_lu]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }
            }

          /* Move index to second rightmost pixel of current row. */
          /* Rightmost pixel is skipped, it has no right neighbor. */
          i = y*w + w-2;

          /* scan left, propagate distance from right */
          for(x=w-2; x>=0; x--, i--)
            {
              olddist2 = func::apply(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance
              
              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
        }
      
      /* Scan rows in reverse order, except last row */
      for(y=h-2; y>=0; y--)
        {
          /* move index to rightmost pixel of current row */
          i = y*w + w-1;

          /* Scan left, propagate distances from below & right */

          /* Rightmost pixel is special, has no right neighbors */
          olddist2 = func::apply(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_dl]+1;
              newdisty = disty[i+offset_dl]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
          i--;

          /* Middle pixels have all neighbors */
          for(x=w-2; x>0; x--, i--)
            {
              olddist2 = func::apply(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_rd]-1;
              newdisty = disty[i+offset_rd]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_dl]+1;
              newdisty = disty[i+offset_dl]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
          /* Leftmost pixel is special, has no left neighbors */
          olddist2 = func::apply(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_rd]-1;
              newdisty = disty[i+offset_rd]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }
            }

          /* Move index to second leftmost pixel of current row. */
          /* Leftmost pixel is skipped, it has no left neighbor. */
          i = y*w + 1;
          for(x=1; x<w; x++, i++)
            {
              /* scan right, propagate distance from left */
              olddist2 = func::apply(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = func::apply(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
        }
    }
  while (changed); // Sweep until no more updates are made
  // The transformation is completed
}

// The different functions used to calculate distance, as a
// class so its typename can be used for edtfunc template
struct euclidean
{
  static double apply(short x, short y)
  { return sqrt ((int)(x)*(x) + (y)*(y)); }
};
struct chessboard
{
  static double apply(short x, short y)
  { return std::max (abs (y), abs (x)); }
};
struct cityblock
{
  static double apply(short x, short y)
  { return abs (x) + abs (y); }
};
struct quasi_euclidean
{
  static double apply(short x, short y)
    {
      static const double sqrt2_1 = sqrt (2) - 1;
      return abs(x)>abs(y) ? (abs(x) + sqrt2_1 * abs(y)) :
                             (sqrt2_1 * abs(x) + abs(y)) ;
    }
};

template<typename func>
void loop_distance (const Matrix &bw,
                    Matrix &dist,
                    short *xdist,
                    short *ydist)
{
  edtfunc<func> (bw, xdist, ydist);
  const int numel = bw.numel ();
  for (int i = 0; i < numel; i++)
    dist(i) = func::apply (xdist[i], ydist[i]);
}

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
    if      (method == "e" ) { method = "euclidean";       }
    else if (method == "ch") { method = "chessboard";      }
    else if (method == "ci") { method = "cityblock";       }
    else if (method == "q" ) { method = "quasi-euclidean"; }
  }

  // Allocate two arrays for temporary output values
  const int numel = bw.numel ();
  OCTAVE_LOCAL_BUFFER (short, xdist, numel);
  OCTAVE_LOCAL_BUFFER (short, ydist, numel);

  Matrix dist (bw.dims ()); // the output distance matrix
  if (method == "euclidean")
    loop_distance<euclidean> (bw, dist, xdist, ydist);
  else if (method == "chessboard")
    loop_distance<chessboard> (bw, dist, xdist, ydist);
  else if (method == "cityblock")
    loop_distance<cityblock> (bw, dist, xdist, ydist);
  else if (method == "quasi-euclidean")
    loop_distance<quasi_euclidean> (bw, dist, xdist, ydist);
  else
    error ("bwdist: unknown METHOD '%s'", method.c_str ());

  retval(0) = dist;

  // Compute optional 'index to closest object pixel', only if requested
  if (nargout > 1)
    {
      Matrix idx (bw.dims ());
      const int rows = bw.rows ();
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
