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
## @deftypefn {Function File} @var{J}= histeq (@var{I}, @var{n})
## Histogram equalization of a gray-scale image. The histogram contains
## @var{n} bins, which defaults to 64.
## @seealso{imhist}
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	08. August 2000

function J = histeq (I, n)
  if (nargin == 0)
    print_usage();
  elseif (nargin == 1)
    n = 64;
  endif

  [r,c] = size (I); 
  [X,map] = gray2ind(I);
  [nn,xx] = imhist(I);
  Icdf = ceil (n * cumsum (1/prod(size(I)) * nn));
  J = reshape(Icdf(X),r,c);
  plot(Icdf,'b;;');
endfunction
