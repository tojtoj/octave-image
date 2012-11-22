//Copyright (C) 2002 Jeffrey E. Boyd <boyd@cpsc.ucalgary.ca>
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

#include <oct.h>
#include <algorithm>

#define     NO_OBJECT       0

static int find (int set [], int x)
{
  int r = x;
  while (set [r] != r)
    r = set [r];
  return r;
}

static bool any_bad_argument (const octave_value_list& args)
{
  const int nargin = args.length ();
  if (nargin < 1 || nargin > 2)
    {
      print_usage ();
      return true;
    }

  if (nargin == 2)
    {
      if (!args (1).is_real_scalar ())
        {
          error ("bwlabel: second input argument must be a real scalar");
            return true;
        }
      const int n = args (1).int_value ();
      if (n != 4 && n != 6 && n != 8)
        {
          error ("bwlabel: second input argument bust be either 4, 6 or 8");
          return true;
        }
    }

  return false;
}

DEFUN_DLD(bwlabel, args, , "\
-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{l}, @var{num}] =} bwlabel(@var{bw}, @var{n})\n\
Labels foreground objects in the binary image @var{bw}.\n\
The output @var{l} is a matrix where 0 indicates a background pixel,\n\
1 indicates that the pixel belong to object number 1, 2 that the pixel\n\
belong to object number 2, etc.\n\
The total number of objects is @var{num}.\n\
\n\
To pixels belong to the same object if the are neighbors. By default\n\
the algorithm uses 8-connectivity to define a neighborhood, but this\n\
can be changed through the argument @var{n} that can be either 4, 6, or 8.\n\
\n\
The algorithm is derived from  BKP Horn, Robot Vision, MIT Press,\n\
1986, p 65 - 89\n\
@end deftypefn\n\
")
{
  octave_value_list rval;
  if (any_bad_argument (args))
    return rval;

  // input arguments
  boolMatrix BW = args (0).bool_array_value ();     // the input binary image
  int nr = BW.rows ();
  int nc = BW.columns ();

  // n-hood connectivity
  int n;
  if (args.length () < 2)
    n = 8;
  else
    n = args (1).int_value ();

  // results
  Matrix L (nr, nc);     // the label image
  int nobj;              // number of objects found in image

  // other variables
  int ntable;            // number of elements in the component table/tree

  OCTAVE_LOCAL_BUFFER (int, lset, nr * nc);   // label table/tree
  ntable = 0;
  lset [0] = 0;

  for (int r = 0; r < nr; r++)
    {
      for (int c = 0; c < nc; c++)
        {
          if (BW.elem (r, c)) // if A is an object
            {
              // get the neighboring pixels B, C, D, and E
              int B, C, D, E;
              if (c == 0)
                B = 0;
              else
                B = find (lset, (int)L.elem (r, c-1));

              if (r == 0)
                C = 0;
              else
                C = find (lset, (int)L.elem (r-1, c));

              if (r == 0 || c == 0)
                D = 0;
              else
                D = find (lset, (int)L.elem (r-1, c-1));

              if (r == 0 || c == nc - 1)
                E = 0;
              else
                E = find (lset, (int)L.elem(r-1, c+1));

              if (n == 4)
                {
                  // apply 4 connectedness
                  if (B && C) // B and C are labeled
                    {
                      if ( B == C )
                        {
                          L.elem (r, c) = B;
                        }
                      else
                        {
                          lset [C] = B;
                          L.elem (r, c) = B;
                        }
                      }
                    else if (B) // B is object but C is not
                      {
                        L.elem (r, c) = B;
                      }
                    else if (C) // C is object but B is not
                      {
                        L.elem (r, c) = C;
                      }
                    else // B, C, D not object - new object
                      {
                        // label and put into table
                        ntable ++;
                        L.elem (r, c) = lset [ntable] = ntable;
                      }
                }
              else if (n == 6)
                {
                  // apply 6 connected ness
                  if (D) // D object, copy label and move on
                    {
                      L.elem (r, c) = D;
                    }
                  else if (B && C) // B and C are labeled
                    {
                      if (B == C)
                        {
                          L.elem (r, c) = B;
                        }
                      else
                        {
                          int tlabel = std::min (B, C);
                          lset [B] = tlabel;
                          lset [C] = tlabel;
                          L.elem (r, c) = tlabel;
                        }
                    }
                  else if (B) // B is object but C is not
                    {
                      L.elem (r, c) = B;
                    }
                  else if (C) // C is object but B is not
                    {
                      L.elem (r, c) = C;
                    }
                  else // B, C, D not object - new object
                    {
                      // label and put into table
                      ntable ++;
                      L.elem (r, c) = lset [ntable] = ntable;
                    }
                }
              else if (n == 8)
                {
                  // apply 8 connectedness
                  if (B || C || D || E)
                    {
                      int tlabel = B;
                      if (B)
                        {
                          tlabel = B;
                        }
                      else if (C)
                        {
                          tlabel = C;
                        }
                      else if (D)
                        {
                          tlabel = D;
                        }
                      else if (E)
                        {
                          tlabel = E;
                        }

                      L.elem (r, c) = tlabel;

                      if (B && B != tlabel)
                        lset [B] = tlabel;
                      if (C && C != tlabel)
                        lset [C] = tlabel;
                      if (D && D != tlabel)
                        lset [D] = tlabel;
                      if (E && E != tlabel)
                        lset [E] = tlabel;
                    }
                  else
                    {
                      // label and put into table
                      ntable ++;
                      L.elem (r, c) = lset [ntable] = ntable;
                    }
                }
            }
          else
            {
              L.elem (r, c) = NO_OBJECT; // A is not an object so leave it
            }
        }
    }

  // consolidate component table
  for (int i = 0; i <= ntable; i++)
    lset [i] = find (lset, i);

  // run image through the look-up table
  for (int r = 0; r < nr; r++)
    for (int c = 0; c < nc; c++)
      L.elem (r, c) = lset [(int)L.elem (r, c)];

  // count up the objects in the image
  for (int i = 0; i <= ntable; i++)
    lset [i] = 0;

  for (int r = 0; r < nr; r++)
    for (int c = 0; c < nc; c++)
      lset [(int)L.elem (r, c)] ++;

  // number the objects from 1 through n objects
  nobj = 0;
  lset [0] = 0;
  for (int i = 1; i <= ntable; i++)
    if (lset [i] > 0)
      lset [i] = ++nobj;

  // run through the look-up table again
  for (int r = 0; r < nr; r++)
    for (int c = 0; c < nc; c++)
      L.elem (r, c) = lset [(int)L.elem (r, c)];

  rval (0) = L;
  rval (1) = (double)nobj;
  return rval;
}

/*
%!assert(bwlabel(logical([0 1 0; 0 0 0; 1 0 1])),[0 1 0; 0 0 0; 2 0 3]);
*/
