## Copyright (C) 2005 Søren Hauberg
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{B}= imresize (@var{A}, @var{m})
## Scales the image @var{A} by a factor @var{m} using nearest neighbour
## interpolation. If @var{m} is less than 1 the image size will be reduced,
## and if @var{m} is greater than 1 the image will be enlarged. If the image
## is being enlarged the it will be convolved with a 11x11 Gaussian FIR filter
## to reduce aliasing. See below on how to alter this behavior.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, @var{m}, @var{method})
## Same as above except @var{method} interpolation is performed instead of
## using nearest neighbour. @var{method} can be any method supported by interp2.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, [@var{mrow} @var{mcol}])
## Scales the image @var{A} to be of size @var{mrow}x@var{mcol} using nearest
## neighbour interpolation. If the image is being enlarged it will be convolved
## with a lowpass FIR filter as described above.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, [@var{mrow} @var{mcol}], @var{method})
## Same as above except @var{method} interpolation is performed instead of using
## nearest neighbour. @var{method} can be any method supported by interp2.
##
## @deftypefnx {Function File} @var{B}= imresize (..., @var{method}, @var{fsize})
## If the image the image is being enlarged it will usually be convolved with
## a 11x11 Gaussian FIR filter. By setting @var{fsize} to 0 this will be turned
## off, and if @var{fsize} > 0 the image will be convolved with a @var{fsize}
## by @var{fsize} Gaussian FIR filter.
##
## @deftypefnx {Function File} @var{B}= imresize (..., @var{method}, @var{filter})
## If the image size is being reduced and the @var{filter} argument is passed to 
## imresize the image will be convolved with @var{filter} before the resizing
## takes place.
##
## @seealso{interp2}
## @end deftypefn

## Author: Søren Hauberg <hauberg at gmail dot com>
## 
## 2005-04-14 Søren Hauberg <hauberg at gmail dot com>
## * Initial revision

function [ ret ] = imresize (im, m, method, filter)
  if (!isgray(im))
    error("The first argument has to be a gray-scale image.");
  endif
  [row col] = size(im);

  # Handle the argument that describes the size of the result
  if (length(m) == 1)
    new_row = round(row*m);
    new_col = round(col*m);
  elseif (length(m) == 2)
    new_row = m(1);
    new_col = m(2);
    m = min( new_row/row, new_col/col );
  else
    error("Bad second argument");
  end

  # Handle the method argument
  if (nargin < 3)
    method = "nearest";
  endif

  # Handle the filterargument
  if (!strcmp(method, "nearest"))
    if (nargin < 4)
      filter = 11;
    endif
    if (m > 1 & filter > 0)
      # If the image is being enlarged and filter > 0 then
      # convolve the image with a filter*filter gaussian.
      mu = round(filter/2);
      sigma = mu/3;
      x = 1:filter;
      gauss = 1/sqrt(2*pi*sigma^2) * exp( (-(x-mu).^2)/(2*sigma^2) );
      im = conv2(gauss, gauss, im, "same");
    elseif (m < 1 & nargin == 4)
      # If the image size is being reduced and a fourth argument
      # is given, use it as a FIR filter.
      im = conv2(im, filter, "same");
    endif
  endif
  
  # Perform the actual resizing
  [XI YI] = meshgrid( linspace(1,col,new_col), linspace(1,row,new_row) );
  ret = interp2(im, XI, YI, method);

endfunction
