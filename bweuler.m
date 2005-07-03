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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{eul} = } bweuler (@var{BW},@var{n})
## Calculates the Euler number of a binary image
##
## eul=bweuler(BW,n) calculates the Euler number @var{eul} of a binary
## image @var{BW}, which is a scalar whose value is the total number of
## objects in an image minus the number of holes.
##
## @var{n} can have the values:
## @table @code
## @item 4
## bweuler will use 4-connected neighbourhood definition.
## @item 8
## bweuler will use 8-connected neighbourhood definition. This is the
## default value.
## @end table
##
## This function uses Bit Quads as described in "Digital Image
## Processing" to calculate euler number.
##
## References:
## W. K. Pratt, "Digital Image Processing", 3rd Edition, pp 593-595
##
## @end deftypefn
## @seealso qtgetblk

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function eul = bweuler(BW, n)
  if(nargin<1 || nargin>2)
    usage("eul=bweuler(BW,n)");
  endif
  if(nargin<2)
    n=8;
  endif

  ## q1lut=makelut(inline("sum(x(:))==1","x"),2);
  ## q3lut=makelut(inline("sum(x(:))==3","x"),2);
  ## qdlut=makelut(inline("all((x==eye(2))(:))||all((x==fliplr(eye(2)))(:))","x"),2);
  ## lut_4=(q1lut-q3lut+2*qdlut)/4;  # everything in one lut will be quicker
  ## lut_8=(q1lut-q3lut-2*qdlut)/4;
  ## we precalculate this...
  if(n==8)
    lut=[0;.25;.25;0;.25;0;-.5;-.25;.25;-.5;0;-.25;0;-.25;-.25;0];
  elseif(n==4)
    lut=[0;.25;.25;0;.25;0;.5;-.25;.25;.5;0;-.25;0;-.25;-.25;0];
  else
    error("bweuler: n can only be 4 or 8.");
  endif
  
  eul=sum(applylut(BW,lut)(:));
endfunction

%!demo
%! A=zeros(9,10);
%! A([2,5,8],2:9)=1;
%! A(2:8,[2,9])=1
%! bweuler(A)
%! # Euler number (objects minus holes) is 1-2=-1 in an 8-like object

%!test
%! A=zeros(10,10);
%! A(2:9,3:8)=1;
%! A(4,4)=0;
%! A(8,8)=0; # not a hole
%! A(6,6)=0;
%! assert(bweuler(A),-1);

%!# This will test if n=4 and n=8 behave differently
%!test
%! A=zeros(10,10);
%! A(2:4,2:4)=1;
%! A(5:8,5:8)=1;
%! assert(bweuler(A,4),2);
%! assert(bweuler(A,8),1);
%! assert(bweuler(A),1);

% $Log$
% Revision 1.2  2005/07/03 01:10:19  pkienzle
% Try to correct for missing newline at the end of the file
%
% Revision 1.1  2004/08/15 19:33:20  jmones
% bweuler: Calculates the Euler number of a binary image
