## Copyright (C) 1999,2000  Kai Habel
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
## @deftypefn {Function File} {} @var{hsv_map} = rgb2hsv (@var{rgb_map})
## transform a colormap from the rgb space to the hsv space 
## @end deftypefn
## @seealso{hsv2rgb}

## Author:	Kai Habel <kai.habel@gmx.de>

function hsval = rgb2hsv (rgb)
  if (is_matrix (rgb))
    nc = size (rgb, 2);
    if (nc == 3)
      #get saturation and value
      v = max (rgb');
      s = (v' > 0) .* (1 .- min (rgb') ./ v)';
      #if v==0 set s to 0 too
      s = isnan (s) .* 0;

      #subtract minimum and divide trough maximum
      #to get the bright and saturated colors

      sc = (rgb - kron ([1, 1, 1], min (rgb')'));
      sv = sc ./ kron([1, 1, 1], max (sc')');
      #if r=g=b (gray value) set hue to 0
      sv = isnan (sv) .* 0;

      #hue=f(color) must be splitted into 6 parts 
      #2 for each color

      #h1(green)
      tmp = (sv(:, 1) == 1 & sv(:,3) == 0) .* (1/6 * sv(:,2) + eps);
      #avoid problems with h2(red) since hue(0)==hue(1)
      h = (tmp < 1/6) .* tmp; 
      #h2(green)
      h = h + ((h == 0) & sv(:,1) == 0 & sv(:,3) == 1)\
        .* (-1/6 * sv(:,2) + 2/3 + eps);

      #h1(red)
      h = h + ((h == 0) & sv(:,2) == 1 & sv(:,3) == 0)\
        .* (-1/6 * sv(:,1) + 1/3 + eps);
      #h2(red)
      h = h + ((h == 0) & sv(:,2) == 0 & sv(:,3) == 1)\
        .* (1/6 * sv(:,1) + 2/3 + eps);

      #h1(blue)
      h = h + ((h == 0) & sv(:,1) == 1 & sv(:,2) == 0)\
        .* (-1/6 * sv(:,3) + 1 + eps);
      #h2(blue)
      h = h + ((h == 0) & sv(:,1) == 0 & sv(:,2) == 1)\
        .* (1/6 * sv(:,3) + 1/3);

      hsval = [h, s, v'];

    else
      usage ("rgb2hsv(rgb_map): rgb_map must be a matrix of size nx3");
    endif
  else
    usage ("rgb2hsv(rgb_map): rgb_map must be a matrix of size nx3");
  endif

endfunction
