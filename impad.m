## Copyright (C) 2000 Teemu Ikonen
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


## -*- texinfo -*-
## @deftypefn {Function File} {} impad(@var{A}, @var{xpad}, @var{ypad}, [@var{padding}, [@var{const}]])
## Pad (augment) a matrix for application of image processing algorithms.
##
## Pads the input image @var{A} with @var{xpad}(1) elements from left, 
## @var{xpad}(2), elements from right, @var{ypad}(1) elements from above 
## and @var{ypad}(2) elements from below.
## Values of padding elements are determined from the optional arguments
## @var{padding} and @var{const}. @var{padding} is one of
##
## @table @samp
## @item "zeros"     
## pad with zeros (default)
##
## @item "ones"      
## pad with ones
##
## @item "constant"  
## pad with a value obtained from the optional fifth argument const
##
## @item "symmetric" 
## pad with values obtained from @var{A} so that the padded image mirrors 
## @var{A} starting from edges of @var{A}
## 
## @item "reflect"   
## same as symmetric, but the edge rows and columns are not used in the padding
##
## @item "replicate" 
## pad with values obtained from A so that the padded image 
## repeates itself in two dimensions
## 
## @end table

## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created: 5.5.2000
## Keywords: padding image processing

## A nice test matrix for padding:
## A = 10*[1:5]' * ones(1,5) + ones(5,1)*[1:5]

function retval = impad(A, xpad, ypad, ...)

empty_list_elements_ok_save = empty_list_elements_ok;
unwind_protect

padding = "zeros";
const = 1;
va_start();
if(nargin > 3)
  padding = va_arg();
  if(nargin > 4)
    const = va_arg();
  endif
endif
  
origx = size(A,2);
origy = size(A,1);
retx = origx + xpad(1) + xpad(2);
rety = origy + ypad(1) + ypad(2);

emptywarn = empty_list_elements_ok;
empty_list_elements_ok = 1;

if(strcmp(padding, "zeros"))
  retval = zeros(rety,retx);
  retval(ypad(1)+1 : ypad(1)+origy, xpad(1)+1 : xpad(1)+origx) = A;
  elseif(strcmp(padding,"ones"))
    retval = ones(rety,retx);
    retval(ypad(1)+1 : ypad(1)+origy, xpad(1)+1 : xpad(1)+origx) = A;
  elseif(strcmp(padding,"constant"))
    retval = const.*ones(rety,retx);
    retval(ypad(1)+1 : ypad(1)+origy, xpad(1)+1 : xpad(1)+origx) = A;
  elseif(strcmp(padding,"replicate"))
    y1 = origy-ypad(1)+1;
    x1 = origx-xpad(1)+1;    
    if(y1 < 1 || x1 < 1 || ypad(2) > origy || xpad(2) > origx)
      error("Too large padding for this padding type");
    else
      yrange1 = y1 : origy;
      yrange2 = 1 : ypad(2);
      xrange1 = x1 : origx;
      xrange2 = 1 : xpad(2);
      retval = [ A(yrange1, xrange1), A(yrange1, :), A(yrange1, xrange2);
                 A(:, xrange1),       A,             A(:, xrange2);
                 A(yrange2, xrange1), A(yrange2, :), A(yrange2, xrange2) ];
    endif                        
  elseif(strcmp(padding,"symmetric"))
    y2 = origy-ypad(2)+1;
    x2 = origx-xpad(2)+1;
    if(ypad(1) > origy || xpad(1) > origx || y2 < 1 || x2 < 1)
      error("Too large padding for this padding type");
    else
      yrange1 = 1 : ypad(1);
      yrange2 = y2 : origy;
      xrange1 = 1 : xpad(1);
      xrange2 = x2 : origx;
      retval = [ fliplr(flipud(A(yrange1, xrange1))), flipud(A(yrange1, :)), fliplr(flipud(A(yrange1, xrange2)));
                 fliplr(A(:, xrange1)), A, fliplr(A(:, xrange2));
                 fliplr(flipud(A(yrange2, xrange1))), flipud(A(yrange2, :)), fliplr(flipud(A(yrange2, xrange2))) ];
    endif      
  elseif(strcmp(padding,"reflect"))
    y2 = origy-ypad(2);
    x2 = origx-xpad(2);
    if(ypad(1)+1 > origy || xpad(1)+1 > origx || y2 < 1 || x2 < 1)
      error("Too large padding for this padding type");
    else
      yrange1 = 2 : ypad(1)+1;
      yrange2 = y2 : origy-1;
      xrange1 = 2 : xpad(1)+1;
      xrange2 = x2 : origx-1;
      retval = [ fliplr(flipud(A(yrange1, xrange1))), flipud(A(yrange1, :)), fliplr(flipud(A(yrange1, xrange2)));
                 fliplr(A(:, xrange1)), A, fliplr(A(:, xrange2));
                 fliplr(flipud(A(yrange2, xrange1))), flipud(A(yrange2, :)), fliplr(flipud(A(yrange2, xrange2))) ];
    endif
  else    
    error("Unknown padding type");
endif

unwind_protect_cleanup
    empty_list_elements_ok = empty_list_elements_ok_save;
end_unwind_protect
      
endfunction
