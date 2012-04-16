## Copyright (C) 2005 Berge-Gladel
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
## @deftypefn {Function File} rgbplot (@var{map})
## @deftypefnx{Function File} @var{h} = rgbplot (@var{map})
## Plot a given color map.
## The matrix @var{map} must be a @math{M} by 3 matrix. The three columns of the
## colormap matrix are plotted in red, green, and blue lines.
##
## If an output is requested, a graphics handle to the plot is returned.
## @end deftypefn

function h_out = rgbplot(map)
  ## Check input
  if (!ismatrix(map) || ndims(map) != 2 || columns(map) != 3)
    error("rgbplot: input must be a M by 3 matrix");
  endif

  ## Plot
  h = plot(map(:,1), "-r", map(:,2), "g-", map(:,3), "b-");
  if (nargout > 0)
    h_out = h;
  endif
endfunction
