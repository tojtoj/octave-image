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
## @deftypefn {Function File} {} flag (@var{n})
## Create color colormap. 
## (cycling through red, white, blue and black)
## The argument @var{n} should be a scalar.  If it
## is omitted, the length of the current colormap or 64 is assumed.
## @seealso{colormap}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

## flag(number) gives a colormap consists of red, white, blue and black
## changing with each index

function map = flag (number)

  if (nargin == 0)
    number = rows (colormap);
  elseif (nargin == 1)
    if (! is_scalar (number))
      error ("flag: argument must be a scalar");
    endif
  else
    usage ("flag (number)");
  endif

  p = [1, 0, 0; 1, 1, 1; 0, 0, 1; 0, 0, 0];
  if (rem(number,4) == 0)
    map=kron (ones (number / 4, 1), p);
  else
    map=[kron(ones (fix (number / 4), 1), p); p(1:rem (number, 4), :)];
  endif

endfunction
