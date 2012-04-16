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

/*
 * edtfunc.c - Euclidean distance transform of a binary image
 *
 * This is a sweep-and-update Euclidean distance transform of
 * a binary image. All positive pixels are considered object
 * pixels, zero or negative pixels are treated as background.
 *
 * By Stefan Gustavson (stefan.gustavson@gmail.com).
 *
 * Originally written in 1994, based on paper-only descriptions
 * of the SSED8 algorithm, invented by Per-Erik Danielsson
 * and improved by Ingemar Ragnemalm. This is a classic algorithm
 * with roots in the 1980s, still very good for the 2D case.
 *
 * Updated in 2004 to treat pixels at image edges correctly,
 * and to improve code readability.
 *
 * Edited in 2009 to form the foundation for Octave BWDIST:
 * added #define-configurable distance measure and function name
 *
 */

#ifndef DIST
#define DIST(x,y) ((int)(x) * (x) + (y) * (y))
#endif

#ifndef FUNCNAME
#define FUNCNAME edt
#endif

void FUNCNAME(const Matrix &img, int w, int h, short *distx, short *disty)
{
  int x, y, i;
  int offset_u, offset_ur, offset_r, offset_rd,
  offset_d, offset_dl, offset_l, offset_lu;
  double olddist2, newdist2, newdistx, newdisty;
  int changed;

  /* Initialize index offsets for the current image width */
  offset_u = -w;
  offset_ur = -w+1;
  offset_r = 1;
  offset_rd = w+1;
  offset_d = w;
  offset_dl = w-1;
  offset_l = -1;
  offset_lu = -w-1;

  /* Initialize the distance images to be all large values */
  for(i=0; i<w*h; i++)
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

  /* Perform the transformation */
  do
    {
      changed = 0;

      /* Scan rows, except first row */
      for(y=1; y<h; y++)
        {

          /* move index to leftmost pixel of current row */
          i = y*w; 

          /* scan right, propagate distances from above & left */

          /* Leftmost pixel is special, has no left neighbors */
          olddist2 = DIST(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_ur]-1;
              newdisty = disty[i+offset_ur]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = 1;
                }
            }
          i++;

          /* Middle pixels have all neighbors */
          for(x=1; x<w-1; x++, i++)
            {
              olddist2 = DIST(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_lu]+1;
              newdisty = disty[i+offset_lu]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_ur]-1;
              newdisty = disty[i+offset_ur]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = 1;
                }
            }

          /* Rightmost pixel of row is special, has no right neighbors */
          olddist2 = DIST(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_lu]+1;
              newdisty = disty[i+offset_lu]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_u];
              newdisty = disty[i+offset_u]+1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }
            }

          /* Move index to second rightmost pixel of current row. */
          /* Rightmost pixel is skipped, it has no right neighbor. */
          i = y*w + w-2;

          /* scan left, propagate distance from right */
          for(x=w-2; x>=0; x--, i--)
            {
              olddist2 = DIST(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance
              
              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = 1;
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
          olddist2 = DIST(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_dl]+1;
              newdisty = disty[i+offset_dl]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = 1;
                }
            }
          i--;

          /* Middle pixels have all neighbors */
          for(x=w-2; x>0; x--, i--)
            {
              olddist2 = DIST(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_rd]-1;
              newdisty = disty[i+offset_rd]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_dl]+1;
              newdisty = disty[i+offset_dl]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = 1;
                }
            }
          /* Leftmost pixel is special, has no left neighbors */
          olddist2 = DIST(distx[i], disty[i]);
          if(olddist2 > 0) // If not already zero distance
            {
              newdistx = distx[i+offset_r]-1;
              newdisty = disty[i+offset_r];
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_rd]-1;
              newdisty = disty[i+offset_rd]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }

              newdistx = distx[i+offset_d];
              newdisty = disty[i+offset_d]-1;
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  olddist2=newdist2;
                  changed = 1;
                }
            }

          /* Move index to second leftmost pixel of current row. */
          /* Leftmost pixel is skipped, it has no left neighbor. */
          i = y*w + 1;
          for(x=1; x<w; x++, i++)
            {
              /* scan right, propagate distance from left */
              olddist2 = DIST(distx[i], disty[i]);
              if(olddist2 == 0) continue; // Already zero distance

              newdistx = distx[i+offset_l]+1;
              newdisty = disty[i+offset_l];
              newdist2 = DIST(newdistx, newdisty);
              if(newdist2 < olddist2)
                {
                  distx[i]=newdistx;
                  disty[i]=newdisty;
                  changed = 1;
                }
            }
        }
    }
  while(changed); // Sweep until no more updates are made

  /* The transformation is completed. */

}
