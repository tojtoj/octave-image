## Copyright (C) 2012 Roberto Metere <roberto@metere.it>
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
## @deftypefn {Function File} {@var{SE2} =} reflect (@var{SE})
## Same structuring element as SE, but reflected.
## Reflection is a rotation of 180 degrees around the center.
##
## @seealso{translate, strel}
## @end deftypefn

## TODO:  If SE is an array of structuring element objects, then it reflects
##       each element of SE.

function SE2 = reflect (SE)

  SE2 = SE;
  SE2.nhood = rotdim(SE.nhood, 2);
  if (!SE2.flat)
    SE2.height = rotdim(SE.height, 2);
  endif

endfunction