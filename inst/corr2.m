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
## @deftypefn {Function File} @var{r} = corr2 (@var{I},@var{J})
## Returns the correlation coefficient between @var{I} and @var{j}.
## @var{I}, @var{J} must be real type matrices or vectors of same size.
## @seealso{cov, std2}
## @end deftypefn


## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	01/08/2000

function r = corr2 (I, J)

  if (nargin != 2)
    print_usage ();
  endif

  if !(is_matrix(I) && isreal(I) && is_matrix(J) && isreal(J))
	error("corr2: argument must be a real type matrix");
  endif

  if (size (I) != size (J))
    error("corr2: arguments must be of same size")
  endif
  
  r = cov (I, J) / (std2(I)*std2(J));    
endfunction
