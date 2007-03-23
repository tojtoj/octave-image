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
## @deftypefn {Function File} {} hsv (@var{n})
## Create color colormap. 
## (red through yellow, green, cyan,blue,magenta to red)
## The argument @var{n} should be a scalar.  If it
## is omitted, the length of the current colormap or 64 is assumed.
## @seealso{colormap}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function map = hsv (number)

  if (nargin == 0)
    number = rows (colormap);
  elseif (nargin == 1)
    if (! is_scalar (number))
      error ("hsv: argument must be a scalar");
    endif
  else
    usage ("hsv (number)");
  endif

  if (number == 1)
    map = [1, 0, 0];  
  elseif (number > 1)
    h = linspace (0, 1, number)';
    map = hsv2rgb ([h, ones(number, 1), ones(number, 1)]);
  else
    map = [];
  endif

endfunction
