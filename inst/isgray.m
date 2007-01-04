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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool}= isgray (@var{I})
## Returns true for an gray-scale intensity image. An variable is a gray scale image
## if it is 2-dimensional matrix, and
## @itemize @bullet
## @item is of class double and all values are in the range [0, 1], or
## @item is of class uint8 or uint16.
## @end itemize
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	20/03/2000

function bool = isgray (I)

  if (nargin != 1)
    print_usage ();
  endif

  bool = false;
  if (ismatrix(I) && ndims(I) == 2)
    switch(class(I))
    case "double"
      bool = all(I(:) >= 0 && I(:) <= 1);
    case {"uint8", "uint16"}
      bool = true;
    endswitch
  endif

endfunction
