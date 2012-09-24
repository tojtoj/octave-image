## Copyright (C) 2000, 2001 Kai Habel <kai.habel@gmx.de>
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
## @deftypefn {Function File} @var{gray}= rgb2gray (@var{rgb})
## Convert RGB image or colormap to a grayscale.
##
## If the input is an RGB image, the conversion to a gray image
## is computed as the mean value of the color channels.
##
## If the input is a color map it is converted into the YIQ space
## of ntsc. The luminance value (Y) is taken to create a gray color map.
## R = G = B = Y
## @end deftypefn

function gray = rgb2gray (rgb)

  if (nargin != 1)
    print_usage();
  endif

  if (iscolormap (rgb))
    ntscmap = rgb2ntsc (rgb);
    gray    = ntscmap (:, 1) * ones (1, 3);
  elseif (isimage (rgb) && ndims(rgb) == 3)
    switch(class(rgb))
    case "double"
      gray = mean(rgb,3);
    case "uint8"
      gray = uint8(mean(rgb,3));
    case "uint16"
      gray = uint16(mean(rgb,3));
    otherwise
      error("rgb2gray: unsupported class %s", class(rgb));
    endswitch
  else
    error("rgb2gray: the input must either be an RGB image or a colormap");
  endif
endfunction
