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
## @deftypefn {Function File} {@var{h} =} rgbplot (@var{cmap})
## Plot a given color map.
##
## The plot will display 3 lines, red, green and blue, showing the variation of
## RGB values on @var{cmap}.  While input matrix must be a color map (see
## @code{iscolormap}), it can also be used to see a colored line profile
## (intensity values will have to be converted to class double with
## @code{im2double}).
##
## If an output is requested, the graphics handle @var{h} to the plot is returned.
##
## @seealso{colormap, iscolormap}
## @end deftypefn

function h_out = rgbplot(map)

  if (nargin != 1)
    print_usage;
  elseif (!iscolormap (map))
    error("rgbplot: input must be a colormap");
  endif

  h = plot (map(:,1), "-r", map(:,2), "g-", map(:,3), "b-");
  if (nargout > 0)
    h_out = h;
  endif
endfunction

%!demo
%! ## look at the distribution of RGB values for the jet colormap
%! cmap = jet (64);
%! rgbplot (cmap);
