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
## @deftypefn {Function File} {} @var{rgb_map} = hsv2rgb (@var{hsv_map})
## transform a colormap from the hsv space to the rgb space 
## @end deftypefn
## @seealso{rgb2hsv}

##
## Author:	Kai Habel <kai.habel@gmx.de>

function rgb_map=hsv2rgb(hsv_map)

## each color value x=(r,g,b) is calculated with
## x = (1-s)*v+s*v*f_x(hue)
## where fx(hue) is a piecewise defined function for
## each color with f_r(h-2/3)=f_g(h)=f_b(h-1/3)

  if (is_matrix (hsv_map))
    nc = size (hsv_map, 2);
    if (nc == 3)
      #set values <0 to 0 and >1 to 1
      hsv_map = (hsv_map >= 0 & hsv_map <= 1) .* hsv_map\
              + (hsv_map < 0) .* 0 + (hsv_map > 1);

      #fill rgb map with v*(1-s)
      rgb_map = kron ([1, 1, 1], hsv_map(:, 3) .* (1 - hsv_map(:,2)));

      #red(hue-2/3)=green(hue)=blue(hue-1/3)
      #apply modulo 1 for red and blue 
      hue = [ (hsv_map(:, 1)' - 2/3) - floor(hsv_map(:, 1) - 2/3)';
               hsv_map(:, 1)';
              (hsv_map(:, 1)' - 1/3) - floor(hsv_map(:, 1) - 1/3)'
            ]';
      #factor s*v -> f
      f = kron ([1, 1, 1], hsv_map(:, 2))\
        .* kron ([1, 1, 1], hsv_map(:, 3));

      #add s*v* hue-function to rgb map
      rgb_map = rgb_map +  f .* (6 * (hue < 1/6) .* hue\
              + (hue >= 1/6 & hue < 1/2)\
              + (hue >= 1/2 & hue < 2/3) .* (4 - 6 * hue));
    else
      usage ("hsv2rgb(hsv_map): hsv_map must be a matrix of size nx3");
    endif
  else
    usage ("hsv2rgb(hsv_map): hsv_map must be a matrix of size nx3");
  endif
endfunction
