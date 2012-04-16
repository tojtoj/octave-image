## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{BW} =} im2bw (@var{I}, threshold)
## @deftypefnx {Function File} {@var{BW} =} im2bw (@var{X}, @var{cmap}, threshold)
## Converts image data types to a black-white (binary) image.
## The treshold value should be in the range [0,1].
## @end deftypefn

function BW = im2bw (img, a, b)
  if (nargin < 2 || nargin > 3)
    print_usage;
  endif
  
  ## Convert img to gray scale
  if (isrgb(img))
    img = rgb2gray(img);
    if (nargin != 2)
      error("im2bw: two input arguments must be given when the image is a color image");
    endif
    t = a;
  elseif (isind (img) && ismatrix(a) && columns (a) == 3)
    img = ind2gray (img, a);
    if (nargin != 3)
      error("im2bw: three input arguments must be given when the image is indexed");
    endif
    t = b;
  elseif (isgray(img))
    if (nargin != 2)
      error("im2bw: two input arguments must be given when the image is gray scale");
    endif
    t = a;
  else
    error ("im2bw: first input argument must be an image");
  endif

  ## Do the thresholding
  if (isscalar (t))
    if (t < 0 || t > 1)
      error("im2bw: threshold must be in the interval [0, 1]");
    endif
    switch (class(img))
      case {"double", "single"}
        BW = (img >= t);
      case {"uint8"}
        BW = (img >= 255*t);
      case {"uint16"}
        BW = (img >= 65535*t);
      otherwise
        error("im2bw: unsupport image class");
    endswitch
  else
    error ("im2bw: threshold value must be scalar");
  endif

endfunction
