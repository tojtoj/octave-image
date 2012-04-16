## Copyright (C) 2005 Søren Hauberg <soren@hauberg.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{total}= bwarea(@var{bw})
## Estimates the area of the "on" pixels of @var{bw}.
## If @var{bw} is a binary image "on" pixels are defined as pixels
## valued 1. If @var{bw} is a grayscale image "on" pixels is defined
## as pixels with values larger than zero.
## This algorithm is not the same as counting the number of "on"
## pixels as it tries to estimate the area of the original object
## and not the image object.
## @end deftypefn

function total = bwarea(bw)
  if (isgray(bw))
    bw = (bw > 0);
  endif

  if (!isbw(bw))
    error("input image muste be either binary or gray scale.\n");
  endif
  
  four = ones(2);
  two  = diag([1 1]);

  fours = conv2(bw, four);
  twos  = conv2(bw, two);

  nQ1 = sum(fours(:) == 1);
  nQ3 = sum(fours(:) == 3);
  nQ4 = sum(fours(:) == 4);
  nQD = sum(fours(:) == 2 & twos(:) != 1);
  nQ2 = sum(fours(:) == 2 & twos(:) == 1);

  total = 0.25*nQ1 + 0.5*nQ2 + 0.875*nQ3 + nQ4 + 0.75*nQD;
  
endfunction
