// Copyright (C) 2005 Søren Hauberg <soren@hauberg.org>
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

#include <octave/oct.h>
#include <math.h>
#include <stack>
#include <utility>

static bool any_bad_argument(const octave_value_list& args) {
  /* TODO: We should check that the matrices have the same size. */
  int nargin = args.length();
  if ( (nargin >= 2) && args(0).is_real_matrix() && args(1).is_real_matrix() )
  {
      if (nargin == 2) 
      {
          return false;
      } else if (nargin == 4 && args(2).is_real_scalar() && 
                 args(3).is_real_scalar() )
      {
          return false;
      }
  }
  error("Input arguments must be two 2-dimensional matrices of the same size.");
  return true;
}

DEFUN_DLD(nonmax_supress,args,nargout,"\
-*- texinfo -*-\n\
@deftypefn {Loadable Function} nonmax_supress (@var{Es}, @var{Eo})\n\
Performs non-maximum supression on the given edge data. \
@var{Es} is a matrix containing the edge strength (the length of \
the gradient), and @var{Eo} is the edge normal orientation (the \
direction of the gradient).\n\
\n\
@deftypefnx {Loadable Function} nonmax_supress (@var{Es}, @var{Eo},\
 @var{low}, @var{high} )\n\
Performs non-maximum supression and hysteresis thresholdong, using \
@var{low} and @var{high} as thresholds.\n\
\n\
This function is designed to be used as part of the Canny edge \
detection, and not to be used in general. So if you use this function: \
Beware...\n\
\n\
@seealso{edge}\n\
@end deftypefn\n\
")
{
  octave_value_list retval;
  if (any_bad_argument(args)) {
      return retval;
  }
  std::stack< std::pair<int,int> > S;
  
  /* Neighbourhood directions in radians */
  const double d[4] = {
      0.0,
      M_PI * 45.0  / 180.0,
      M_PI * 90.0  / 180.0,
      M_PI * 135.0 / 180.0
  };

  const Matrix Es = args(0).matrix_value();
  Matrix Eo = args(1).matrix_value();
  double low, high;
  bool hysteresis = (args.length()==4);
  if (hysteresis) {
      low  = args(2).scalar_value();
      high = args(3).scalar_value();
  } else {
      low = high = 0;
  }
  
  const int rows = Es.rows();
  const int cols = Es.columns();
  
  /****************************
   ** Non-maximum supression **
   ****************************/
  Matrix In = Matrix( rows, cols, 0.0 );
  for (int r = 1; r < rows-1; r++) {
      for (int c = 1; c < cols-1; c++) {
          const double orientation = Eo(r,c);
          const double strength = Es(r,c);
          
          int best_d = 0;
          const double dist = fabs( orientation-d[0] );
          for (int i = 1; i < 4; i++) {
              if ( fabs( orientation-d[i] ) < dist ) { best_d = i; }
          }
          Eo(r,c) = best_d;

          switch (best_d) {
              case 0:  // 0 degrees
                  if ( (strength > Es(r,c-1)) && (strength > Es(r,c+1)) )
                      { In(r,c) = strength; }
                  break;
              case 1:  // 45 degrees
                  if ( (strength > Es(r-1,c+1)) && (strength > Es(r+1,c-1)) )
                      { In(r,c) = strength; }
                  break;
              case 2:  // 90 degrees
                  if ( (strength > Es(r-1,c)) && (strength > Es(r+1,c)) )
                      { In(r,c) = strength; }
                  break;
              case 3:  // 135 degrees
                  if ( (strength > Es(r-1,c-1)) && (strength > Es(r+1,c+1)) )
                      { In(r,c) = strength; }
                  break;
          }

          if (hysteresis && In(r,c) > high) {
              S.push( std::pair<int,int>(r,c) );
          }
      }
  }

  if (hysteresis == false) {
      retval.append(In); 
      return retval;
  }

  /**************************
   ** Hysteresis threshold **
   **************************/
  boolMatrix out = boolMatrix( rows, cols, false );
  while (S.empty() == false) {
      std::pair<int, int> p = S.top();
      S.pop();
      const int r = p.first;
      const int c = p.second;
      if (r < 0 || r >= rows || c < 0 || c >= cols || out(r,c) == true)
          { continue; }
      
      out(r,c) = true;
      const int dir = (int)Eo(r,c);
      switch (dir) {
          case 0:  // 0 degrees
              if ( In(r-1,c) > low ) 
                  { S.push(std::pair<int,int>(r-1,c)); }
              if ( In(r+1,c) > low ) 
                  { S.push(std::pair<int,int>(r+1,c)); }
              break;
          case 1:  // 45 degrees
              if ( In(r-1,c-1) > low ) 
                  { S.push(std::pair<int,int>(r-1,c-1)); }
              if ( In(r+1,c+1) > low ) 
                  { S.push(std::pair<int,int>(r+1,c+1)); }
              break;
          case 2:  // 90 degrees
              if ( In(r,c-1) > low ) 
                  { S.push(std::pair<int,int>(r,c-1)); }
              if ( In(r,c+1) > low ) 
                  { S.push(std::pair<int,int>(r,c+1)); }
              break;
          case 3:  // 135 degrees
              if ( In(r-1,c+1) > low ) 
                  { S.push(std::pair<int,int>(r-1,c+1)); }
              if ( In(r+1,c-1) > low ) 
                  { S.push(std::pair<int,int>(r+1,c-1)); }
              break;
      }
  }

  retval.append(out);
  return retval;
}

