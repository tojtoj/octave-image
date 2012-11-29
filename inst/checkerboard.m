## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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

  square = zeros (side * 2);
  square(1:side, side+1:end) = 1;
  square(side+1:end, 1:side) = 1;

  greyvalue = 0.7; # matlab compatible

  if (mod (nCols, 2))
    ## odd number of columns, the central square needs to be split into 2
    board = repmat (square, [nRows (nCols-1)/2]);
    board = [board repmat(square(:,1:side), [nRows 1])];
    square(logical (square)) = greyvalue;
    board = [board repmat(square(:,side+1:end), [nRows 1])];
    board = [board repmat(square, [nRows (nCols-1)/2])];
  else
    ## even number, it's simpler
    board = repmat (square, [nRows nCols/2]);
    square(logical (square)) = greyvalue;
    board = [board repmat(square, [nRows nCols/2])];
  endif

endfunction

function check_checkerboard (in, name)
  ## isindex makes easy to check if it's a positive integer but also returns
  ## true for a logical matrix. Hence the use for islogical
  if (! isscalar (in) || ! isindex (in) || islogical (in))
    error ("checkerboard: %s must be a positive integer.", name)
  endif
endfunction
