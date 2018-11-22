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
  if (nargin != 2)
    print_usage ();
  endif

  validateattributes (rgb1, {"numeric"}, {"real", "vector", "numel", 3},
                      "colorangle", "rgb1");
  validateattributes (rgb2, {"numeric"}, {"real", "vector", "numel", 3},
                      "colorangle", "rgb2");

  norm1 = norm (rgb1);
  norm2 = norm (rgb2);
  if (norm1 != 0 && norm2 != 0)
    angle = rad2deg (acos ( dot (rgb1, rgb2) / (norm1 * norm2)));
  else
    angle = 0; # could be NaN but MATLAB outputs 0
  endif
endfunction

%!error id=Octave:invalid-fun-call colorangle ()
%!error id=Octave:invalid-fun-call colorangle (1, 2, 3)
%!error id=Octave:incorrect-numel colorangle (2, 3)
%!error id=Octave:incorrect-numel colorangle ([1, 2], [3, 4])
%!error id=Octave:expected-real colorangle ([1, 2, 3j], [4, 5, 6])
%!error id=Octave:expected-real colorangle ([1, 2, 3], [4j, 5, 6])
%!error id=Octave:invalid-type colorangle ("abc", "def")

%!assert (colorangle ([0 0 0], [0 0 0]), 0, 1e-4)
%!assert (colorangle ([1 1 1], [1 1 1]), 0, 1e-4)
%!assert (colorangle ([1 0 0], [-1 0 0]), 180, 1e-4)
%!assert (colorangle ([0 0 1], [1 0 0]), 90, 1e-4)
%!assert (colorangle ([0; 0; 1], [1 0 0]), 90, 1e-4)
%!assert (colorangle ([0, 0, 1], [1; 0; 0]), 90, 1e-4)
%!assert (colorangle ([0.5 0.61237 -0.61237], [0.86603 0.35355 -0.35355]), 30.000270917, 1e-4)
%!assert (colorangle ([0.1582055390, 0.2722362096, 0.1620813305], [0.0717 0.1472 0.0975]), 5.09209927, 1e-6)
%!assert (colorangle ([0.0659838500, 0.1261619536, 0.0690643667], [0.0717 0.1472 0.0975]), 5.10358588, 1e-6)
%!assert (colorangle ([0.436871170, 0.7794672250, 0.4489702582], [0.0717 0.1472 0.0975]), 5.01339769, 1e-6)
