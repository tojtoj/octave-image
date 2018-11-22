## Copyright (C) 2018 Ricardo Fantin da Costa <ricardofantin@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{angle} =} colorangle (@var{rgb1}, @var{rgb2})
## Compute angle between two RGB colors in degrees.
##
## Each color is represented as a vector and the angle
## between vectors formula is:
##
## @tex
## $$
## cos (ANGLE) = \frac{RGB1 \cdot RGB2}{|RGB1| |RGB2|}
## $$
## @end tex
## @ifnottex
## @example
## @group
##                    dot (@var{rgb1}, @var{rgb2})
## cos (@var{angle}) = ---------------------------
##                norm (@var{rgb1}) * norm (@var{rgb2})
## @end group
## @end example
## @end ifnottex
##
## @end deftypefn

## Author: Ricardo Fantin da Costa
## Created: 2018-03-26

function [angle] = colorangle (rgb1, rgb2)
  if (nargin != 2 || length (rgb1) != 3 || length (rgb2) != 3)
    print_usage ();
  endif
  norm1 = norm (rgb1);
  norm2 = norm (rgb2);
  if (norm1 != 0 && norm2 != 0)
    angle = (180/pi) * acos (dot (rgb1, rgb2) / (norm1 * norm2));
    # [TODO] in the future substitute (180/pi) by rad2deg ()
  else
    angle = NaN;
  endif
endfunction

%!test
%! assert(colorangle ([1 1 1], [1 1 1]), 0, 0.0001)
%! assert(colorangle ([1 0 0], [-1 0 0]), 180, 0.0001)
%! assert(colorangle ([0 0 1], [1 0 0]), 90, 0.0001)
%! assert(colorangle ([0.5 0.61237 -0.61237], [0.86603 0.35355 -0.35355]), 30, 0.0001)
