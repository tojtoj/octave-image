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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{B}= imresize (@var{A}, @var{m})
## Scales the image @var{A} by a factor @var{m} using nearest neighbour
## interpolation. If @var{m} is less than 1 the image size will be reduced,
## and if @var{m} is greater than 1 the image will be enlarged. If the image
## is being enlarged the it will be convolved with a 11x11 Gaussian FIR filter
## to reduce aliasing. See below on how to alter this behavior.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, @var{m}, @var{interp})
## Same as above except @var{interp} interpolation is performed instead of
## using nearest neighbour. @var{interp} can be any interpolation method supported by interp2.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, [@var{mrow} @var{mcol}])
## Scales the image @var{A} to be of size @var{mrow}x@var{mcol} using nearest
## neighbour interpolation. If the image is being enlarged it will be convolved
## with a lowpass FIR filter as described above.
##
## @deftypefnx {Function File} @var{B}= imresize (@var{A}, [@var{mrow} @var{mcol}], @var{interp})
## Same as above except @var{interp} interpolation is performed instead of using
## nearest neighbour. @var{interp} can be any interpolation method supported by interp2.
##
## @deftypefnx {Function File} @var{B}= imresize (..., @var{interp}, @var{fsize})
## If the image the image is being reduced it will usually be convolved with
## a 11x11 Gaussian FIR filter. By setting @var{fsize} to 0 this will be turned
## off, and if @var{fsize} > 0 the image will be convolved with a @var{fsize}
## by @var{fsize} Gaussian FIR filter.
##
## @deftypefnx {Function File} @var{B}= imresize (..., @var{interp}, @var{filter})
## If the image size is being reduced and the @var{filter} argument is passed to
## imresize the image will be convolved with @var{filter} before the resizing
## takes place.
##
## @seealso{imremap, imrotate, interp2}
## @end deftypefn

function ret = imresize(im, m, interp = "nearest", filter = 11)
  if (nargin < 2)
    error("imresize: not enough input arguments");
  endif
  
  [row, col, num_planes, tmp] = size(im);
  if (tmp != 1 || (num_planes != 1 && num_planes != 3))
    error("imresize: the first argument has must be an image");
  endif

  ## Handle the argument that describes the size of the result
  if (length(m) == 1)
    new_row = round(row*m);
    new_col = round(col*m);
  elseif (length(m) == 2)
    new_row = m(1);
    new_col = m(2);
    m = min( new_row/row, new_col/col );
  else
    error("imresize: second argument mest be a scalar or a 2-vector");
  end

  ## Handle the method argument
  if (!any(strcmpi(interp, {"nearest", "linear", "bilinear", "cubic", "bicubic", "pchip"})))
    error("imresize: unsupported interpolation method");
  endif

  ## Handle the filter argument
  if (!strcmp(interp, "nearest") && m < 1)
    if (isscalar(filter) && filter > 0)
      ## If the image is being reduced and filter > 0 then
      ## convolve the image with a filter*filter gaussian.
      mu = (filter/2);
      sigma = mu/3;
      x = 1:filter;
      gauss = 1/sqrt(2*pi*sigma^2) * exp( (-(x-mu).^2)/(2*sigma^2) );
      for i = 1:num_planes
          im(:,:,i) = conv2(gauss, gauss, im(:,:,i), "same");
      endfor
    elseif (nargin >= 4 && ismatrix(filter) && ndims(filter) == 2)
      ## If the image size is being reduced and a fourth argument
      ## is given, use it as a FIR filter.
      for i = 1:num_planes
        im(:,:,i) = conv2(im(:,:,i), filter, "same");
      endfor
    endif
  endif
  
  ## Perform the actual resizing
  [XI, YI] = meshgrid( linspace(1,col,new_col), linspace(1,row,new_row) );
  ret = imremap(im, XI, YI, interp);

endfunction
