## Copyright (C) 2006  Søren Hauberg
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details. 
## 
## You should have received a copy of the GNU General Public License
## along with this file.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{d} = bwdist(@var{bw}, @var{method})
## Computes the distance transform of the binary image @var{bw}.
## The result @var{d} is a matrix of the same size as @var{bw}, where
## each value is the shortest distance to a non-zero pixel in @var{bw}.
## 
## @var{method} changes the used distance function. Currently
## the Euclidian distance is the only supported distance function.
## @end deftypefn

function D = bwdist(bw, method = "euclidian")
  ## Check input
  if (nargin == 0)
    print_usage();
  endif
  
  if (!ismatrix(bw) || ndims(bw) != 2)
    error("bwdist: input must be a 2-dimensional matrix");
  endif
  
  if (!ischar(method))
    error("bwdist: method name must be a string");
  endif

  ## Do the work
  bw = (bw != 0);
  switch (lower(method(1)))
    case "e" 
      ## Euclidian distance transform
      D = __bwdist(bw);
      D = sqrt(D);
    otherwise
      error("bwdist: unsupported method '%s'", method);
  endswitch
endfunction
