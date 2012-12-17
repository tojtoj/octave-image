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
## @deftypefn {Function File} {[@var{offsets}, @var{heights}] =} getneighbors (@var{SE})
## For each neighbor in structuring element, return the relative position and height.
##
## If P is the number of neighbors in SE, @var{offsets} are relative position
## from the center of the structuring element to them, of which heights are
## stored in corresponding columns of the array @var{heights}.
## @var{offsets} is an array with P rows and 2 columns, the first for the row
## offset, the second for the column offset.
##
## @seealso{getnhood, getheight, strel}
## @end deftypefn

function [offsets, heights] = getneighbors (SE)

  error ("getneighbors: not yet implemented");
  P = sum(SE.nhood(:) == 1);

endfunction