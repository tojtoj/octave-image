## Copyright (C) 2000, 2001  Kai Habel
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
## @deftypefn {Function File} @var{I}= rgb2gray (@var{M})
## converts a color map to a gray map. 
## The RGB map is converted into the YIQ space of ntsc. The luminance
## value (Y) is taken to create a gray color map.
## R = G = B = Y
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	19. March 2000

function graymap = rgb2gray (rgb)

  if (nargin != 1)
    usage ("graymap = rgb2gray (map)");
  endif

  msg = "rgb2gray: argument must be a matrix of size n x 3";
  if (! is_matrix (rgb))
    error (msg);
  endif

  nc = columns (rgb);
  if (nc != 3)
    error (msg);
  endif

  ntscmap = rgb2ntsc (rgb);

  graymap = ntscmap (:, 1) * ones (1, 3);
endfunction
