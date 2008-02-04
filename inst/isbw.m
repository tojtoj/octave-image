## Copyright (C) 2000  Kai Habel
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool}= isbw (@var{BW})
## Returns true for a black-white (binary) image.
## All values must be either 0 or 1
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	20/03/2000

function bool = isbw (BW)

  bool = 0;	
  if !(nargin == 1)
    usage ("isbw(BW)");
  endif

  if !(is_matrix(BW))
    return;
  endif

  bool = all (all ((BW == 1) + (BW == 0)));

endfunction
