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
## @deftypefn {Function File} @var{m}= mean2 (@var{I})
## returns the mean value for a 2d real type matrix.
## Uses @code{mean(I(:))}
## @end deftypefn
## @seealso{std2,mean}


## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	01/08/2000

function m = mean2 (I)

  if !(nargin == 1)
    usage ("mean2(I)");
  endif

  if !(is_matrix(I) && isreal(I))
	error("argument must be a real type matrix");
  endif

  m = mean (I(:));
endfunction
