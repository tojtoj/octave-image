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
## @deftypefn {Function File} {@var{BW2} = } erode (@var{BW1},@var{SE})
## @deftypefnx {Function File} {@var{BW2} = } erode (@var{BW1},@var{SE},@var{alg})
## @deftypefnx {Function File} {@var{BW2} = } erode (@var{BW1},@var{SE},...,@var{n})
## Perform an erosion morphological operation on a binary image.
##
## BW2 = erosion(BW1, SE) returns a binary image with the result of an erosion
## operation on @var{BW1} using neighbour mask @var{SE}.
##
## For each point in @var{BW1}, erode searchs its neighbours (which are
## defined by setting to 1 their in @var{SE}). If all neighbours
## are on (1), then pixel is set to 1. If any is off (0) then it is set to 0.
##
## Center of @var{SE} is calculated using floor((size(@var{SE})+1)/2).
##
## Pixels outside the image are considered to be 0.
##
## BW2 = erode(BW1, SE, alg) returns the result of a erosion operation 
## using algorithm @var{alg}. Only 'spatial' is implemented at the moment.
##
## BW2 = erosion(BW1, SE, ..., n) returns the result of @var{n} erosion
## operations on @var{BW1}.
##
## @seealso{dilate}
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function BW2 = erode(BW1, SE, a, b)
  alg='spatial';
  n=1;
  if (nargin < 1 || nargin > 4)
    usage ("BW2 = erode(BW1, SE [, alg] [, n])");
  endif
  if nargin ==  4
    alg=a;
    n=b;
  elseif nargin == 3
    if ischar(a)
      alg=a;
    else
      n=a;
    endif
  endif

  if !strcmp(alg, 'spatial')
    error("erode: alg not implemented.");
  endif

  # count ones in mask
  thr=sum(SE(:));

  # "Binarize" BW1, just in case image is not [1,0]
  BW1=BW1!=0;

  for i=1:n
    # create result matrix
    BW1=filter2(SE,BW1) == thr;
  endfor

  BW2=BW1;
endfunction

%!demo
%! erode(ones(5,5),ones(3,3))
%! % creates a zeros border around ones.



%!assert(erode([0,1,0;1,1,1;0,1,0],[0,0,0;0,0,1;0,1,1])==[1,0,0;0,0,0;0,0,0]);
%!assert(erode([0,1,0;1,1,1;0,1,0],[0,1;1,1])==[1,0,0;0,0,0;0,0,0]);


