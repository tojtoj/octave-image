## Copyright (C) 2004 Josep Mones i Teixidor
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{g} = } __conditional_mark_patterns_lut_fun__ (@var{X},@var{op})
## Calculates conditional mark patterns for shrink, skel, thin and thicken
##
## g=__conditional_mark_patterns_lut_fun__(X, op) evaluates a 3-by-3 BW matrix
## neighbourhood according to rules in Pratt's book as a stage for
## shrink, skel, thin and thicken morphological operations to create a
## LUT using makelut.
##
## @var{X} contains a 3-by-3 matrix to be evaluated, and @var{op} can be
## "S", "T" or "K" as defined in Pratt's book.
##
## Returns 1 if is a "hit" and 0 otherwise.
##
## This function is needed by bwmorph, although it just contains the
## result matrix as a literal inside the code.
##
## This function probably never be needed by itself, but it's useful to
## know how bwmorph was coded.
##
## References:
## W. K. Pratt, "Digital Image Processing", 3rd Edition, pp 413-414
## @end deftypefn
## @seealso{bwmorph}

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

## Note: no intention has been made to make this quick. The only focus
## is on being clear and similar to Pratt's specification.

function m=__conditional_mark_patterns_lut_fun__(X, op)
  x=X(2,2);
  x0=X(2,3);
  x1=X(1,3);
  x2=X(1,2);
  x3=X(1,1);
  x4=X(2,1);
  x5=X(3,1);
  x6=X(3,2);
  x7=X(3,3);

  sx=sum(X(:));

  m=0;

  ## all cases need x==1
  if(x==0)
    return;
  endif

  if(any(op=='K'))
    m|=(sx==8)&&( !x5 || !x7 || !x1 || !x3 ); ## bond 11
  endif

  if(any(op=='S'))
    m|=(sx==2)&&(x1||x3||x5||x7); ## bond 1
    m|=(sx==2)&&(x0||x2||x4||x6); ## bond 2
    m|=(sx==3)&&((x0&&(x1||x7))||(x2&&(x1||x3))||(x4&&(x3||x5))||(x6&&(x5||x7))); ## bond 3
  endif

  if(any(op=='ST'))
    m|=(sx==4)&&((x0&&x2&&x3)||(x0&&x2&&x7)||(x1&&x2&&x4)||(x0&&x1&&x6)); ## bond 5
    m|=(sx==4)&&((x0&&x1&&x2)||(x2&&x3&&x4)||(x4&&x5&&x6)||(x6&&x7&&x0)); ## bond 5
    m|=(sx==5)&&((x0&&x2&&x3&&x7)||(x1&&x2&&x4&&x5)); ## bond 6
  endif

  if(any(op=='STK'))
    m|=(sx==4)&&(all(X(:,3))||all(X(1,:))||all(X(:,1))||all(X(3,:))); ## bond 4
    m|=(sx==5)&&( \ ## bond 6
           (all(X(1,:))&&(x0||x4)) || \
           (all(X(:,3))&&(x2||x6)) || \
           (all(X(:,1))&&(x2||x6)) || \
           (all(X(3,:))&&(x0||x4)) );
    m|=(sx==6)&&( !(x4||x5||x6) || !(x6||x7||x0) || !(x0||x1||x2) || \
     !(x2||x3||x4) ); ## bond 7
    m|=(sx==6)&&( !any(X(:,1)) || !any(X(3,:)) || !any(X(:,3)) || \
     !any(X(1,:)) ); ## bond 8
    m|=(sx==7)&&( !(x4||(x3&&x5)) || !(x6||(x5&&x7)) || \
     !(x0||(x7&&x1)) || !(x2||(x1&&x3)) ); ## bond 9
    m|=(sx==8)&&( !x0 || !x2 || !x4 || !x6 ); ## bond 10
  endif

  if(any(op=='TK'))
    ##bond 4
    m|=(sx==3)&&( (x0&&x2) || (x2&&x4) || (x4&&x6) || (x6&&x0) );
  endif

endfunction


%!# We'll only check if number of hits is ok.
%!assert(sum(makelut("__conditional_mark_patterns_lut_fun__",3,"S")), 58);
