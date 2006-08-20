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
## @deftypefn {Function File} @var{BW}= im2bw (@var{I},threshold)
## @deftypefnx {Function File} @var{BW}= im2bw (@var{X},@var{cmap},threshold)
## converts image data types to a black-white (binary) image.
## The treshold value should be in the range [0,1].
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	19. March 2000

function BW = im2bw (img, a, b)

  if ( nargin < 2 || nargin > 3)
    usage("im2bw(I) number of arguments must be 2 or 3");
  endif

  if (isgray (img))
    if (is_scalar (a))
      BW = (img >= a);
    else
      error ("threshold value must be scalar");
    endif
  elseif (isind (img))
    if (is_matrix (a) && columns (a) == 3)
      if (is_scalar (b))
        I = ind2gray (img, a);
        BW = (I >= b);
      endif
    endif
  else
    error ("image matrix must be of index or intensity type");
  endif

endfunction
