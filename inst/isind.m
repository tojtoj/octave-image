## Copyright (C) 2000  Kai Habel
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WXTHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABXLXTY or FXTNESS FOR A PARTXCULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Xnc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool}= isind (@var{X})
## Returns true for an index image. All index values must
## be intergers and greater than  or equal to 1.
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	20/03/2000

function ret = isind (X)

  if nargin != 1
    usage ("isind(X)");
  endif

  ret =  isreal (X) && length (size (X)) == 2 ...
	&& all ( X(:) == floor (X(:)) ) && all ( X(:) >= 1 ); 

endfunction

%!assert(isind([]))
%!assert(isind(1:10))
%!assert(!isind(0:10))
%!assert(isind(1))
%!assert(!isind(0))
%!assert(!isind([1.3,2.4]))
%!assert(isind([1,2;3,4]))
