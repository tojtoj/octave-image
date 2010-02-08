// Copyright (C) 2010 Soren Hauberg
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 3
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>

inline int iseven (const int a)
{
  if ((a % 2) == 0)
    return 1;
  else
    return 0;
}

Matrix trace_boundary (const boolMatrix &im, const int N, const octave_idx_type r,
                       const octave_idx_type c)
{
  // Get size information
  const octave_idx_type rows = im.rows ();
  const octave_idx_type cols = im.columns ();

  // Create list of points
  typedef std::pair<int, int> point;
  std::list <point> P;
  
  // Add first point
  const point P0 (r, c); // first list element
  point P1 (-1, -1); // second list element
  point Pn1 (-1, -1); // second last list element
  P.push_back (P0);
  int len = 1;
  
  // Create a simple lookup table that translates 'dir' to a row and column offset
  const int dir2row4 [] = { 0, -1,  0, +1};
  const int dir2col4 [] = {+1,  0, -1,  0};
  const int dir2row8 [] = { 0, -1, -1, -1,  0, +1, +1, +1};
  const int dir2col8 [] = {+1, +1,  0, -1, -1, -1,  0, +1};
  
  // Start searching from there...
  int dir = N - 1;
  int curr_dir = dir; //(N == 4) ? (dir + 3) % N : (dir + 6 + iseven (dir)) % N;
  int delta_r, delta_c;
  octave_idx_type row = r, col = c;
  while (true)
//  for (int z = 0; z < 1000; z++)
    {
      OCTAVE_QUIT;
      
      // Get next search direction
      if (N == 4)
        {
          //curr_dir = (dir + 3) % N;
          delta_r = dir2row4 [curr_dir];
          delta_c = dir2col4 [curr_dir];
        }
      else
        {
          //curr_dir = (dir + 6 + iseven (dir)) % N;
          delta_r = dir2row8 [curr_dir];
          delta_c = dir2col8 [curr_dir];
        }
        
      // Is a pixel available at the search direction
      const octave_idx_type curr_r = row + delta_r;
      const octave_idx_type curr_c = col + delta_c;
/*      std::cerr << " curr_r = " << curr_r
                << " curr_c = " << curr_c
                << " curr_dir = " << curr_dir
                << " row = " << row
                << " colr = " << col
                << std::endl;
*/      
      if (curr_r >= 0 && curr_r < rows && curr_c >= 0 && curr_c < cols && im (curr_r, curr_c))
        {
          // Update 'dir'
          dir = curr_dir;
          curr_dir = (N == 4) ? (dir + 3) % N : (dir + 6 + iseven (dir)) % N;
          
          // Add point to list
          const point Pn (curr_r, curr_c);
          P.push_back (Pn);
          len ++;
          
          // Update 'row' and 'col'
          row = curr_r;
          col = curr_c;
          
          // Save the second element of P for the stop criteria
          if (len == 2)
            {
              P1.first = curr_r;
              P1.second = curr_c;
            }
            
          // Should we stop?
          if (Pn.first ==  P1.first && Pn.second == P1.second &&
              Pn1.first == P0.first && Pn1.second == P0.second)
            break;
            
          // Save current point for next time
          Pn1 = Pn;
        }
      else
        {
          // Update search direction
          curr_dir = (curr_dir+1) % N;
        }
    } // end while

  // Copy data to output matrix
  Matrix out (len-1, 2);
  std::list<point>::const_iterator iter = P.begin ();
  for (int idx = 0; idx < len-2; iter++, idx++)
    {
      out (idx, 0) = iter->second + 1;
      out (idx, 1) = iter->first + 1;
    }
  out (len-2, 0) = P0.second + 1;
  out (len-2, 1) = P0.first + 1;
  
  return out;
}

DEFUN_DLD(__imboundary__, args, , "\
-*- texinfo -*-\n\
@deftypefn {Function File} __imboundary__ (@var{bw}, @var{N}, @var{r}, @var{c})\n\
Undocumented internal function.\n\
User interface is available in @code{bwboundaries}.\n\
@end deftypefn\n\
")
{
  // Handle input
  octave_value_list retval;
  if (args.length () != 4) {
    error ("__imboundary__: not enough input arguments");
    return retval;
  }
    
  const boolMatrix im = args (0).bool_matrix_value ();
  const int N = (int) args (1).scalar_value ();
  const octave_idx_type r = (octave_idx_type) args (2).scalar_value () - 1;
  const octave_idx_type c = (octave_idx_type) args (3).scalar_value () - 1;
  if (error_state || (N != 4)) // && N != 8))
    error ("__imboundary__: invalid input arguments");
  else
    {
      Matrix out = trace_boundary (im, N, r, c);
      retval.append (out);
    }
  return retval;    
}
