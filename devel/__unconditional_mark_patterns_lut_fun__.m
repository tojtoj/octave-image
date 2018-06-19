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
## @deftypefn {Function File} {@var{g} = } __unconditional_mark_patterns_lut_fun__ (@var{X},@var{op})
## Calculates unconditional mark patterns for shrink and thin
##
## g=__conditional_mark_patterns_lut_fun__(X, op) evaluates a 3-by-3 BW matrix
## neighbourhood according to rules in Pratt's book as a stage for
## shrink and thin morphological operations to create a LUT using makelut.
##
## @var{X} contains a 3-by-3 matrix to be evaluated, and @var{op} can be
## "S" (shrink), "T" (thin) or "K" (skel).
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
## W. K. Pratt, "Digital Image Processing", 3rd Edition, pp 415,420
## @end deftypefn
## @seealso{bwmorph}

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function m=__unconditional_mark_patterns_lut_fun__(X, op)
  if(nargin!=2)
    usage("m=__unconditional_mark_patterns_lut_fun__(X, op)");
  endif
  if(!strcmp(op,"S") && !strcmp(op,"T") && !strcmp(op,"K"))
    error("op can only be 'S', 'T' or 'K'.")
  endif
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

  if (any(op=='ST'))
    ## spur
    m|=all((X==[0,0,1;0,1,0;0,0,0])(:));
    m|=all((X==[1,0,0;0,1,0;0,0,0])(:));
  
    ## single 4-connection
    m|=all((X==[0,0,0;0,1,0;0,1,0])(:));
    m|=all((X==[0,0,0;0,1,1;0,0,0])(:));

    if (op=='T')
      ## L cluster
      m|=all((X==[0,0,1;0,1,1;0,0,0])(:));
      m|=all((X==[0,1,1;0,1,0;0,0,0])(:));
      m|=all((X==[1,1,0;0,1,0;0,0,0])(:));
      m|=all((X==[1,0,0;1,1,0;0,0,0])(:));
      m|=all((X==[0,0,0;1,1,0;1,0,0])(:));
      m|=all((X==[0,0,0;0,1,0;1,1,0])(:));
      m|=all((X==[0,0,0;0,1,0;0,1,1])(:));
      m|=all((X==[0,0,0;0,1,1;0,0,1])(:));
    endif

    ## 4-connected offset
    m|=all((X==[0,1,1;1,1,0;0,0,0])(:));
    m|=all((X==[1,1,0;0,1,1;0,0,0])(:));
    m|=all((X==[0,1,0;0,1,1;0,0,1])(:));
    m|=all((X==[0,0,1;0,1,1;0,1,0])(:));

    ## spur corner cluster
    m|=all(((X&[1,0,1;1,1,0;1,1,1])==fliplr(eye(3)))(:))&&(x0||x2);
    m|=all(((X&[1,0,1;0,1,1;1,1,1])==eye(3))(:))&&(x2||x4);
    m|=all(((X&[1,1,1;0,1,1;1,0,1])==fliplr(eye(3)))(:))&&(x4||x6);
    m|=all(((X&[1,1,1;1,1,0;1,0,1])==eye(3))(:))&&(x0||x6);

    ## corner cluster
    m|=all((X(1:2,1:2)==ones(2,2))(:));
    
    ## tee branch
    m|=all(((X&[0,1,1;1,1,1;0,1,1])==[0,1,0;1,1,1;0,0,0])(:));
    m|=all(((X&[1,1,0;1,1,1;1,1,0])==[0,1,0;1,1,1;0,0,0])(:));
    m|=all(((X&[1,1,0;1,1,1;1,1,0])==[0,0,0;1,1,1;0,1,0])(:));
    m|=all(((X&[0,1,1;1,1,1;0,1,1])==[0,0,0;1,1,1;0,1,0])(:));
    m|=all(((X&[0,1,0;1,1,1;1,1,1])==[0,1,0;1,1,0;0,1,0])(:));
    m|=all(((X&[1,1,1;1,1,1;0,1,0])==[0,1,0;1,1,0;0,1,0])(:));
    m|=all(((X&[1,1,1;1,1,1;0,1,0])==[0,1,0;0,1,1;0,1,0])(:));
    m|=all(((X&[0,1,0;1,1,1;1,1,1])==[0,1,0;0,1,1;0,1,0])(:));

    ## vee branch
    m|=all(((X(1:2,1:3)&[1,0,1;0,1,0])==[1,0,1;0,1,0])(:))&&any(X(3,:));
    m|=all(((X(1:3,1:2)&[1,0;0,1;1,0])==[1,0;0,1;1,0])(:))&&any(X(:,3));
    m|=all(((X(2:3,1:3)&[0,1,0;1,0,1])==[0,1,0;1,0,1])(:))&&any(X(1,:));
    m|=all(((X(1:3,2:3)&[0,1;1,0;0,1])==[0,1;1,0;0,1])(:))&&any(X(:,1));

    ## diagonal branch
    m|=all(((X&[0,1,1;1,1,1;1,1,0])==[0,1,0;0,1,1;1,0,0])(:));
    m|=all(((X&[1,1,0;1,1,1;0,1,1])==[0,1,0;1,1,0;0,0,1])(:));
    m|=all(((X&[0,1,1;1,1,1;1,1,0])==[0,0,1;1,1,0;0,1,0])(:));
    m|=all(((X&[1,1,0;1,1,1;0,1,1])==[1,0,0;0,1,1;0,1,0])(:));

  elseif(any(op=='K'))
    ## spur
    m|=all((X==[0,0,0;0,1,0;0,0,1])(:));
    m|=all((X==[0,0,0;0,1,0;1,0,0])(:));
    m|=all((X==[0,0,1;0,1,0;0,0,0])(:));
    m|=all((X==[1,0,0;0,1,0;0,0,0])(:));

    ## single 4-connection
    m|=all((X==[0,0,0;0,1,0;0,1,0])(:));
    m|=all((X==[0,0,0;0,1,1;0,0,0])(:));
    m|=all((X==[0,0,0;1,1,0;0,0,0])(:));
    m|=all((X==[0,1,0;0,1,0;0,0,0])(:));

    ## L corner
    m|=all((X==[0,1,0;0,1,1;0,0,0])(:));
    m|=all((X==[0,1,0;1,1,0;0,0,0])(:));
    m|=all((X==[0,0,0;0,1,1;0,1,0])(:));
    m|=all((X==[0,0,0;1,1,0;0,1,0])(:));

    ## corner cluster
    m|=all((X(1:2,2:3)==ones(2,2))(:));
    m|=all((X(2:3,1:2)==ones(2,2))(:));
    m|=all((X(1:2,1:2)==ones(2,2))(:));
    m|=all((X(2:3,2:3)==ones(2,2))(:));

    ## tee branch
    m|=all(((X&[0,1,0;1,1,1;0,1,1])==[0,1,0;1,1,1;0,0,0])(:));
    m|=all(((X&[0,1,0;1,1,0;0,1,0])==[0,1,0;1,1,0;0,1,0])(:));
    m|=all(((X&[0,0,0;1,1,1;0,1,0])==[0,0,0;1,1,1;0,1,0])(:));
    m|=all(((X&[0,1,0;0,1,1;0,1,0])==[0,1,0;0,1,1;0,1,0])(:));

    ## vee branch (equal to ST version)
    m|=all(((X(1:2,1:3)&[1,0,1;0,1,0])==[1,0,1;0,1,0])(:))&&any(X(3,:));
    m|=all(((X(1:3,1:2)&[1,0;0,1;1,0])==[1,0;0,1;1,0])(:))&&any(X(:,3));
    m|=all(((X(2:3,1:3)&[0,1,0;1,0,1])==[0,1,0;1,0,1])(:))&&any(X(1,:));
    m|=all(((X(1:3,2:3)&[0,1;1,0;0,1])==[0,1;1,0;0,1])(:))&&any(X(:,1));

    ## diagonal branch (equal to ST version)
    m|=all(((X&[0,1,1;1,1,1;1,1,0])==[0,1,0;0,1,1;1,0,0])(:));
    m|=all(((X&[1,1,0;1,1,1;0,1,1])==[0,1,0;1,1,0;0,0,1])(:));
    m|=all(((X&[0,1,1;1,1,1;1,1,0])==[0,0,1;1,1,0;0,1,0])(:));
    m|=all(((X&[1,1,0;1,1,1;0,1,1])==[1,0,0;0,1,1;0,1,0])(:));
    
  endif
    
endfunction


## Pratt's book says there are 157 patterns from spur corner cluster to
## the end (page 411). spur, single 4-connection and 4-connected offset
## have no duplicate cases with other patterns. So:
%!assert(sum(makelut("__unconditional_mark_patterns_lut_fun__",3,'S')),157+8);


%
% $Log$
% Revision 1.2  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.1  2004/08/16 14:42:02  jmones
% Functions used to code bwmorph
%
%