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
  if (columns(rgb) == 3)

    ## get the max and min
    s = min (rgb')';
    v = max (rgb')';
    h = zeros(size(v));

    ## no hue
    notgray = (s != v);
    s(!notgray) = 0;
    
    ## blue hue
    idx = (v == rgb(:,3) & notgray);
    if any(idx)
      h(idx) = 2/3 + 1/6 * (rgb(idx,1)-rgb(idx,2)) ./ (v(idx) - s(idx));
    endif
	      
    ## green hue
    idx = (v == rgb(:,2) & notgray);
    if any(idx)
      h(idx) = 1/3 + 1/6 * (rgb(idx,3)-rgb(idx,1)) ./ (v(idx) - s(idx));
    endif

    ## red hue
    idx = (v == rgb(:,1) & notgray); 
    if any(idx)
      h(idx) =       1/6 * (rgb(idx,2)-rgb(idx,3)) ./ (v(idx) - s(idx));
    endif

    ## correct for negative red
    idx = (h < 0);
    h(idx) = 1+h(idx);

    ## set the saturation
    s(notgray) = 1 - s(notgray) ./ v(notgray);

    hsval = [h, s, v];

  else
    usage ("rgb2hsv(rgb_map): rgb_map must be a matrix of size nx3");
  endif

endfunction
