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
## @deftypefn {Function File} {@var{flag} = } isrgb (@var{A})
## Returns true if parameter is a RGB image
##
## @code{flag=isrgb(A)} returns 1 if @var{A} is a RGB image and 0 if
## not.
##
## To the decide @code{isrgb} uses the follow algorithm:
## @itemize @bullet
## @item
## If @var{A} is of class double then it checks if all values are
## between 0 and 1, and if size is m-by-n-by-3.
## @item
## If @var{A} is of class uint16, uint8 or logical then it checks is m-by-n-by-3.
## @end itemize
##
## @strong{Compatibility notes:}
##
## Information needed on whether MATLAB accepts logical arrays as RGB
## images (now this functions accepts them if they are m-by-n-by-3 arrays.
##
## @end deftypefn

## TODO: Check if logical arrays should be considered RGB

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function flag = isrgb(A)
  if (nargin!=1)
    usage("flag=isrgb(A)");
  endif
  
  if(ismatrix(A))
    flag=1;
    s=size(A);
    if(length(s)!=3 || s(3)!=3)
      flag=0; ## false if not m-by-n-by-3
    elseif(strcmp(typeinfo(A),"matrix") && (any(A(:)<0) || any(A(:)>1)))
      flag=0; ## false if class double but items are <0 or >1
    endif
  else
    flag=0;
  endif
endfunction


%!demo
%! isrgb(rand(1,2,3))
%! # A 1-by-2-by-3 double matrix with elements between 0 and 1 is a RGB image.


%!# Non-matrix
%!assert(isrgb("this is not a RGB image"),0);

%!# Double matrix tests
%!assert(isrgb(rand(5,5)),0);
%!assert(isrgb(rand(5,5,1,5)),0);
%!assert(isrgb(rand(5,5,3,5)),0);
%!assert(isrgb(rand(5,5,3)),1);
%!assert(isrgb(ones(5,5,3)),1);
%!assert(isrgb(ones(5,5,3)+.0001),0);
%!assert(isrgb(zeros(5,5,3)-.0001),0);

%!# Logical
%!assert(isrgb(logical(round(rand(5,5,3)))),1);
