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

#include <vector>

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
 
 Edited in 2013 for C++, removed the #define stuff, and other
 fixes for matlab compatibility.
 */

void edtfunc (float (*func)(short int, short int),
              const boolNDArray &img,
              short *distx,
              short *disty)
{
  const int w     = img.cols  ();
  const int h     = img.rows  ();
  const int numel = img.numel ();

  // Initialize the distance images to be all large values
  const bool* elem = img.fortran_vec ();
  for (octave_idx_type i = 0; i < numel; i++)
    {
      if(elem[i])
        {
          distx[i] = 0;
          disty[i] = 0;
        }
      else
        {
          distx[i] = 32000; // Large but still representable in a short, and
          disty[i] = 32000; // 32000^2 + 32000^2 does not overflow an int
        }
    }

  double olddist2, newdist2, newdistx, newdisty;
  bool changed;

  // Initialize index offsets for the current image width
  const int offset_u  = -h;
  const int offset_ur = -h+1;
  const int offset_r  = 1;
  const int offset_rd = h+1;
  const int offset_d  = h;
  const int offset_dl = h-1;
  const int offset_l  = -1;
  const int offset_lu = -h-1;

  // Perform the transformation
  int x, y, i;
  do
    {
      changed = false;

      // Scan rows, except first row
      for (y = 1; y < w; y++)
        {
          OCTAVE_QUIT;
          // move index to leftmost pixel of current row
          octave_idx_type i = y*h;

          /* scan right, propagate distances from above & left */

          /* Leftmost pixel is special, has no left neighbors */
          olddist2 = (*func)(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_ur]-1;
              newdisty = disty[i+offset_ur]+1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
          i++;

          /* Middle pixels have all neighbors */
          for(x=1; x<h-1; x++, i++)
            {
              olddist2 = (*func)(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_lu]+1;
              newdisty = disty[i+offset_lu]+1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_ur]-1;
              newdisty = disty[i+offset_ur]+1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }

          /* Rightmost pixel of row is special, has no right neighbors */
          olddist2 = (*func)(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_lu]+1;
              newdisty = disty[i+offset_lu]+1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = (*func)(newdistx, newdisty);
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
          i = y*h + h-2;

          /* scan left, propagate distance from right */
          for(x=h-2; x>=0; x--, i--)
            {
              olddist2 = (*func)(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance
              
              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
        }
      
      /* Scan rows in reverse order, except last row */
      for(y=w-2; y>=0; y--)
        {
          OCTAVE_QUIT;
          /* move index to rightmost pixel of current row */
          i = y*h + h-1;

          /* Scan left, propagate distances from below & right */

          /* Rightmost pixel is special, has no right neighbors */
          olddist2 = (*func)(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_dl]+1;
              newdisty = disty[i+offset_dl]-1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
          i--;

          /* Middle pixels have all neighbors */
          for(x=h-2; x>0; x--, i--)
            {
              olddist2 = (*func)(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_rd]-1;
              newdisty = disty[i+offset_rd]-1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_dl]+1;
              newdisty = disty[i+offset_dl]-1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = true;
                }
            }
          /* Leftmost pixel is special, has no left neighbors */
          olddist2 = (*func)(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_rd]-1;
              newdisty = disty[i+offset_rd]-1;
              newdist2 = (*func)(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = true;
                }

              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = (*func)(newdistx, newdisty);
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
          i = y*h + 1;
          for(x=1; x<h; x++, i++)
            {
              /* scan right, propagate distance from left */
              olddist2 = (*func)(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = (*func)(newdistx, newdisty);
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
static float
euclidean (short x, short y)
{
  // the actual euclidean distance, is the square root of this. But
  // squaring does not change the order of the distances, so we can
  // do it in the end and only in the values that matter
  return ((int)(x)*(x) + (y)*(y));
}

static float
chessboard (short x, short y)
{ return std::max (abs (y), abs (x)); }

static float
cityblock (short x, short y)
{ return abs (x) + abs (y); }

static float
quasi_euclidean (short x, short y)
{
  static const float sqrt2_1 = sqrt (2) - 1;
  return abs(x)>abs(y) ? (abs(x) + sqrt2_1 * abs(y)) :
                         (sqrt2_1 * abs(x) + abs(y)) ;
}

static FloatMatrix
calc_distances (float (*func)(short, short), const boolNDArray& bw,
                short *xdist, short *ydist)
{
  FloatMatrix dist (bw.dims ());
  edtfunc (func, bw, xdist, ydist);
  const int numel = dist.numel ();
  float* dist_vec = dist.fortran_vec ();
  for (int i = 0; i < numel; i++)
    dist_vec[i] = (*func)(xdist[i], ydist[i]);
  return dist;
}

template <class T>
T calc_index (const boolNDArray& bw, const short *xdist, const short *ydist)
{
  typedef typename T::element_type P;

  T idx (bw.dims ());
  const int numel = bw.numel ();
  const int rows  = bw.rows ();

  P* idx_vec = idx.fortran_vec ();
  for(int i = 0; i < numel; i++)
    idx_vec[i] = i+1 - xdist[i] - ydist[i]*rows;

  return idx;
}

DEFUN_DLD (bwdist, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {@var{dist} =} bwdist (@var{bw})\n\
@deftypefnx {Loadable Function} {@var{dist} =} bwdist (@var{bw}, @var{method})\n\
@deftypefnx {Loadable Function} {[@var{dist}, @var{idx}] =} bwdist (@dots{})\n\
Compute distance transform in binary image.\n\
\n\
The image @var{bw} must be a binary matrix  For @sc{matlab} compatibility, no\n\
check is performed, all non-zero values are considered object pixels.\n\
The return value @var{dist}, is the distance of each background pixel to the\n\
closest object pixel in a matrix of class @code{single}.\n\
\n\
@var{idx} is the linear index for the closest object, used to calculate the\n\
distance for each of the pixels.  Its class is dependent on the number of\n\
elements in @var{bw}, @code{uint64} if less than 2^32 elements, @code{uint32}\n\
otherwise.\n\
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
  const boolNDArray bw = args (0).bool_array_value ();
  if (error_state)
    {
      error ("bwdist: BW must be a logical matrix");
      return retval;
    }

  std::string method = (nargin > 1) ? args (1).string_value () : "euclidean";
  if (error_state)
    {
      error ("bwdist: METHOD must be a string");
      return retval;
    }
  for (octave_idx_type q = 0; q < octave_idx_type (method.length ()); q++)
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
  std::vector<short> xdist (numel);
  std::vector<short> ydist (numel);

  FloatMatrix dist;
  if (method == "euclidean")
    {
      dist = calc_distances (euclidean, bw, xdist.data (), ydist.data ());
      const Array<octave_idx_type> positions = (!bw).find ();
      const int zpos = positions.numel();
      const octave_idx_type* pos_vec = positions.fortran_vec ();
      float* dist_vec = dist.fortran_vec ();
      for (int i = 0; i < zpos; i++)
        dist_vec[pos_vec[i]] = sqrt (dist_vec[pos_vec[i]]);
    }
  else if (method == "chessboard")
    dist = calc_distances (chessboard,      bw, xdist.data (), ydist.data ());
  else if (method == "cityblock")
    dist = calc_distances (cityblock,       bw, xdist.data (), ydist.data ());
  else if (method == "quasi-euclidean")
    dist = calc_distances (quasi_euclidean, bw, xdist.data (), ydist.data ());
  else
    error ("bwdist: unknown METHOD '%s'", method.c_str ());

  retval(0) = dist;

  // Compute optional 'index to closest object pixel', only if requested
  if (nargout > 1)
    {
      if (numel >= pow (2, 32))
        retval(1) = calc_index<uint64NDArray> (bw, xdist.data (), ydist.data ());
      else
        retval(1) = calc_index<uint32NDArray> (bw, xdist.data (), ydist.data ());
    }

  return retval;
}

/*
%!shared bw
%!
%! bw = [0   1   0   1   0   1   1   0
%!       0   0   0   1   1   0   0   0
%!       0   0   0   1   1   0   0   0
%!       0   0   0   1   1   0   0   0
%!       0   0   1   1   1   1   1   1
%!       1   1   1   1   0   0   0   1
%!       1   1   1   0   0   0   1   0
%!       0   0   1   0   0   0   1   1];

%!test
%! out = [ 1.00000   0.00000   1.00000   0.00000   1.00000   0.00000   0.00000   1.00000
%!         1.41421   1.00000   1.00000   0.00000   0.00000   1.00000   1.00000   1.41421
%!         2.23607   2.00000   1.00000   0.00000   0.00000   1.00000   2.00000   2.00000
%!         2.00000   1.41421   1.00000   0.00000   0.00000   1.00000   1.00000   1.00000
%!         1.00000   1.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000
%!         0.00000   0.00000   0.00000   0.00000   1.00000   1.00000   1.00000   0.00000
%!         0.00000   0.00000   0.00000   1.00000   1.41421   1.00000   0.00000   1.00000
%!         1.00000   1.00000   0.00000   1.00000   2.00000   1.00000   0.00000   0.00000];
%! out = single (out);
%!
%! assert (bwdist (bw), out, 0.0001);  # default is euclidean
%! assert (bwdist (bw, "euclidean"), out, 0.0001);
%! assert (bwdist (logical (bw), "euclidean"), out, 0.0001);

%!test
%! out = [ 1   0   1   0   1   0   0   1
%!         1   1   1   0   0   1   1   1
%!         2   2   1   0   0   1   2   2
%!         2   1   1   0   0   1   1   1
%!         1   1   0   0   0   0   0   0
%!         0   0   0   0   1   1   1   0
%!         0   0   0   1   1   1   0   1
%!         1   1   0   1   2   1   0   0];
%! out = single (out);
%!
%! assert (bwdist (bw, "chessboard"), out);

%!test
%! out = [ 1   0   1   0   1   0   0   1
%!         2   1   1   0   0   1   1   2
%!         3   2   1   0   0   1   2   2
%!         2   2   1   0   0   1   1   1
%!         1   1   0   0   0   0   0   0
%!         0   0   0   0   1   1   1   0
%!         0   0   0   1   2   1   0   1
%!         1   1   0   1   2   1   0   0];
%! out = single (out);
%!
%! assert (bwdist (bw, "cityblock"), out);

%!test
%! out = [ 1.00000   0.00000   1.00000   0.00000   1.00000   0.00000   0.00000   1.00000
%!         1.41421   1.00000   1.00000   0.00000   0.00000   1.00000   1.00000   1.41421
%!         2.41421   2.00000   1.00000   0.00000   0.00000   1.00000   2.00000   2.00000
%!         2.00000   1.41421   1.00000   0.00000   0.00000   1.00000   1.00000   1.00000
%!         1.00000   1.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000
%!         0.00000   0.00000   0.00000   0.00000   1.00000   1.00000   1.00000   0.00000
%!         0.00000   0.00000   0.00000   1.00000   1.41421   1.00000   0.00000   1.00000
%!         1.00000   1.00000   0.00000   1.00000   2.00000   1.00000   0.00000   0.00000];
%! out = single (out);
%!
%! assert (bwdist (bw, "quasi-euclidean"), out, 0.0001);
%!
%! bw(logical (bw)) = 3; # there is no actual check if matrix is binary or 0 and 1
%! assert (bwdist (bw, "quasi-euclidean"), out, 0.0001);
%!
%! bw(logical (bw)) = -2; # anything non-zero is considered object
%! assert (bwdist (bw, "quasi-euclidean"), out, 0.0001);

%!test
%! bw =    [  1   1   1   1   0   1   1   1   1
%!            1   1   1   1   0   1   1   1   1
%!            1   1   0   1   1   1   1   1   1
%!            0   1   1   1   1   1   1   1   1];
%!
%! dist = [   0   0   0   0   1   0   0   0   0
%!            0   0   0   0   1   0   0   0   0
%!            0   0   1   0   0   0   0   0   0
%!            1   0   0   0   0   0   0   0   0];
%! dist = single (dist);
%!
%! c =    [   1   5   9  13  13  21  25  29  33
%!            2   6  10  14  14  22  26  30  34
%!            3   7  10  15  19  23  27  31  35
%!            8   8  12  16  20  24  28  32  36];
%! c = uint32 (c);
%!
%! [dout, cout] = bwdist (bw, "euclidean");
%! assert (dout, dist)
%! assert (cout, c)

## The quasi-euclidean method is apparently sensitive to a machine precision
## error that happens in x86 systems only. This test will cause an endless
## loop in case of a regression.
%!test
%! bw = [  0   1   1   0   0   0   1   0
%!         0   0   0   0   0   0   0   0
%!         1   1   0   0   0   0   0   0
%!         0   0   0   0   0   0   1   0
%!         0   0   0   0   1   0   0   1
%!         0   0   0   0   0   0   0   0
%!         1   0   0   0   0   0   0   0
%!         0   0   1   0   0   1   1   0];
%! out = single ([
%! 1.00000   0.00000   0.00000   1.00000   2.00000   1.00000   0.00000   1.00000
%! 1.00000   1.00000   1.00000   sqrt(2)   sqrt(2)+1 sqrt(2)   1.00000   sqrt(2)
%! 0.00000   0.00000   1.00000   2.00000   2.00000   sqrt(2)   1.00000   sqrt(2)
%! 1.00000   1.00000   sqrt(2)   sqrt(2)   1.00000   1.00000   0.00000   1.00000
%! 2.00000   2.00000   2.00000   1.00000   0.00000   1.00000   1.00000   0.00000
%! 1.00000   sqrt(2)   2.00000   sqrt(2)   1.00000   sqrt(2)   sqrt(2)   1.00000
%! 0.00000   1.00000   1.00000   sqrt(2)   sqrt(2)   1.00000   1.00000   sqrt(2)
%! 1.00000   1.00000   0.00000   1.00000   1.00000   0.00000   0.00000   1.00000
%! ]);
%! assert (bwdist (bw, "quasi-euclidean"), out);

%!error <unknown METHOD> bwdist (bw, "not a valid method");
*/
