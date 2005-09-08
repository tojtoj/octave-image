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
## @deftypefn {Function File} {@var{X} =} grayslice (@var{I},@var{n})
## @deftypefnx {Function File} {@var{X} =} grayslice (@var{I},@var{v})
## creates an indexed image @var{X} from an intensitiy image @var{I}
## using multiple threshold levels.
## A scalar integer value @var{n} sets the levels to
## @example
## 
## @group
## 1  2       n-1
## -, -, ..., ---
## n  n        n
## @end group
## @end example
##
## X = grayslice(I,5);
##
## For irregular threshold values a real vector @var{v} can be used.
## The values must be in the range [0,1].
##
## @group
## X = grayslice(I,[0.1,0.33,0.75,0.9])
## @end group
##
## @end deftypefn
## @seealso{im2bw}

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	03. August 2000

function X = grayslice (I, v)

  if (nargin != 2)
    usage ("grayslice(...) number of arguments must be 1 or 2");
  endif

  if (is_scalar(v) && (fix(v) == v))

    v = (1:v - 1) / v;

  elseif (isvector(v))

    if (any (v < 0) || (any (v > 1)))
      error ("slice vector must be in range [0,1]")
    endif
    v = [0,v,1];
  else

    usage("second argument");

  endif

  [r, c] = size (I);
  [m, n] = sort ([v(:); I(:)]);
  lx = length (v);
  o = cumsum (n <= lx);
  idx = o (find(n>lx));
  [m, n] = sort (I(:));
  [m, n] = sort (n);
  X = reshape (idx(n), r, c);

endfunction
