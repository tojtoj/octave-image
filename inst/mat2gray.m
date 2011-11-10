## Copyright (C) 1999,2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {Function File} @var{I}= mat2gray (@var{M},[min max])
## Converts a matrix to a intensity image.
## @seealso{gray2ind, ind2gray, rgb2gray}
## @end deftypefn

function I = mat2gray (M, scale)

  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (!ismatrix (M))
    error ("mat2gray(M,...) M must be a matrix");
  elseif (nargin == 2 && (!isvector (scale) || numel (scale) != 2))
    error ("mat2gray(M,scale) scale must be a vector with 2 elements");
  endif

  ## what if the matrix has more than 2D?
  if (nargin == 1)
    Mmin = min (min (M));
    Mmax = max (max (M));
  else 
    Mmin = min (scale (1), scale (2));
    Mmax = max (scale (1), scale (2));
  endif

  I = (M < Mmin) .* 0;
  I = I + (M >= Mmin & M < Mmax) .* (1 / (Mmax - Mmin) * (M - Mmin));
  I = I + (M >= Mmax);

endfunction
