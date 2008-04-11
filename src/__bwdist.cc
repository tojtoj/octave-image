/*
Copyright (C) 2006 Pedro Felzenszwalb

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>.
*/

/* 
 * Remark by Søren Hauberg, december 28th 2006.
 *
 * This code was mainly written by Pedro Felzenszwalb and published
 * on http://people.cs.uchicago.edu/~pff/dt/
 * Pedro kindly released his code under the GPL and I ported it to
 * Octave.
 */

#include <octave/oct.h>

#define INF 1E20

template <class T>
inline T square(const T &x) { return x*x; };

/* dt of 1d function using squared distance */
static float* dt (float *f, int n)
{
  float *d = new float[n];
  int *v = new int[n];
  float *z = new float[n+1];
  int k = 0;
  v[0] = 0;
  z[0] = -INF;
  z[1] = +INF;
  for (int q = 1; q <= n-1; q++)
    {
      float s  = ((f[q] + square (q)) - (f[v[k]] + square (v[k])))/(2*q-2*v[k]);
      while (s <= z[k])
        {
          k--;
          s  = ((f[q] + square (q)) - (f[v[k]] + square (v[k])))/(2*q-2*v[k]);
        }
      k++;
      v[k] = q;
      z[k] = s;
      z[k+1] = +INF;
    }

  k = 0;
  for (int q = 0; q <= n-1; q++)
    {
      while (z[k+1] < q)
        k++;
      d[q] = square (q-v[k]) + f[v[k]];
    }

  delete [] v;
  delete [] z;
  return d;
}

/* dt of 2d function using squared distance */
static void dt (NDArray &im)
{
  const int width = im.dim1 ();
  const int height = im.dim2 ();
  float *f = new float[std::max(width,height)];

  // transform along columns
  for (int x = 0; x < width; x++)
    {
      for (int y = 0; y < height; y++)
        {
          f[y] = im (x, y);
        }
      float *d = dt (f, height);
      for (int y = 0; y < height; y++)
        {
          im (x, y) = d[y];
        }
      delete [] d;
    }

    // transform along rows
    for (int y = 0; y < height; y++)
      {
        for (int x = 0; x < width; x++)
          {
            f[x] = im (x, y);
          }
        float *d = dt (f, width);
        for (int x = 0; x < width; x++)
          {
            im (x, y) = d[x];
          }
        delete [] d;
      }

    delete [] f;
}


/* dt of binary image using squared distance */
void dt (const boolNDArray &im, NDArray &out)
{
  const int width = im.dim1 ();
  const int height = im.dim2 ();

  for (int y = 0; y < height; y++)
    {
      for (int x = 0; x < width; x++)
        {
          if (im (x, y))
            out (x, y) = 0;
          else
            out (x, y) = INF;
        }
    }

  dt (out);
}

DEFUN_DLD (__bwdist, args, nargout, "\
-*- texinfo -*-\n\
@deftypefn {Function File} __bwdist (@var{bw})\n\
Computes the Euclidian Distance Transform for a binary image @var{bw}.\n\
You should not call this function directly, instead call 'bwdist'.\n\
@seealso{bwdist}\n\
@end deftypefn\n\
")
{
  octave_value_list retval;
  
  const boolNDArray bw = args(0).bool_array_value ();
  if (error_state)
    {
      error ("__bwdist: input must be a boolean matrix");
      return retval;
    }
  
  const dim_vector dims = bw.dims ();
  if (dims.length () != 2)
    {
      error ("__bwdist: currently only binary images are supported");
      return retval;
    }
  
  NDArray out (dims);
  
  dt (bw, out);
  
  retval.append (out);
  return retval;
}
