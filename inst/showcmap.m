## Copyright (c) 2012 Juan Pablo Carbajal
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
## @deftypefn {Function File} {@var{h} =} showcmap (@var{cmap})
##  Shows a colormap in the current figure
##
## @var{cmap} is a string with the name of the colormap or a matrix
## representing a colormap.
## The function returns the current colormap in @var{h}.
##
## @seealso{colormap}
## @end deftypefn

## Author: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>

function h = showcmap (cmap)

  if (nargin != 1)
    print_usage ();
  endif


  if ischar (cmap)

    if !compare_versions (version,"3.7.0",">=")
      error ("Octave:version", ...
             ["showcmap: string arguments are supported with " ...
              "GNU Octave 3.7.0 or higher."]);
    endif

    if !ismember (cmap, colormap ("list"))
    error ("Octave:invalid-input-arg",
      "showcmap: input must be the name of a exisiting colormap");
    endif

    N = 64;
    image (1:N, linspace (0, 1, N), repmat ((1:N)', 1, N));
    axis ([1, N, 0, 1], "ticy", "xy");
    eval (["colormap (" cmap "(N))"]);

  else

    if !iscolormap (cmap)
      error ("Octave:invalid-input-arg",
        "showcmap: input must be a valid colormap");
    endif

    N = size (cmap,1);
    image (1:N, linspace (0, 1, N), repmat ((1:N)', 1, N));
    axis ([1, N, 0, 1], "ticy", "xy");
    colormap (cmap);

  endif

  h = get (gcf, "colormap");

endfunction

%!error showcmap ("showcmap")
%!error showcmap ([1 2 3 4])

%!demo
%! showcmap ("hot")
%! figure ()
%! showcmap (hot(6))
