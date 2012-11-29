## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (C) 2012 Pantxo Diribarne <pantxo@dibona>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{board} =} checkerboard ()
## @deftypefnx {Function File} {@var{board} =} checkerboard (@var{side})
## @deftypefnx {Function File} {@var{board} =} checkerboard (@var{side}, @var{size})
## @deftypefnx {Function File} {@var{board} =} checkerboard (@var{side}, @var{M}, @var{N})
## Create checkerboard.
##
## Each tile of the checkerboard is made of four squares @var{side} pixels wide.
## The created checkerboard itself will be @var{size}, or @var{M}x@var{N} tiles
## wide.  Defaults to 4x4 tiles 10 pixels wide.
##
## @seealso{repmat}
## @end deftypefn

function [board] = checkerboard (side = 10, nRows = 4, nCols = nRows)
  if (nargin > 3)
    print_usage ();
  endif
  check_checkerboard (side,  "square side");
  check_checkerboard (nRows, "number of rows");
  check_checkerboard (nCols, "number of columns");

  [xx, yy] = meshgrid (linspace (-1, 1, 2*side));
  tile     = (xx .* yy) < 0;
  board    = double (repmat (tile, nRows, nCols));
  board(:, (end/2+1):end) *= .7; # matlab compatible

endfunction

function check_checkerboard (in, name)
  ## isindex makes easy to check if it's a positive integer but also returns
  ## true for a logical matrix. Hence the use for islogical
  if (! isscalar (in) || ! isindex (in) || islogical (in))
    error ("checkerboard: %s must be a positive integer.", name)
  endif
endfunction
