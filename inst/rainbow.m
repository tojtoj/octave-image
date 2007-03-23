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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} rainbow (@var{n})
## Create color colormap. 
## (red through orange, yellow, green, blue to violet)
## The argument @var{n} should be a scalar.  If it
## is omitted, the length of the current colormap or 64 is assumed.
## @seealso{colormap}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function map = rainbow (number)
## this colormap is not part of matlab, it is like the prism
## colormap map but with a continuous map

  if (nargin == 0)
    number = rows (colormap);
  elseif (nargin == 1)
    if (! is_scalar (number))
      error ("rainbow: argument must be a scalar");
    endif
  else
    usage ("rainbow (number)");
  endif

  if (number == 1)
    map = [1, 0, 0];  
  elseif (number > 1)
    x = linspace (0, 1, number)';
    r = (x < 2/5) + (x >= 2/5 & x < 3/5) .* (-5 * x + 3)\
      + (x >= 4/5) .* (10/3 * x - 8/3);
    g = (x < 2/5) .* (5/2 * x) + (x >= 2/5 & x < 3/5)\
      + (x >= 3/5 & x < 4/5) .* (-5 * x + 4);
    b = (x >= 3/5 & x < 4/5) .* (5 * x - 3) + (x >= 4/5);
    map = [r, g, b];
  else
    map = [];
  endif

endfunction
