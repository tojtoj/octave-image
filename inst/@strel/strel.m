## Copyright (C) 2012 Roberto Metere <roberto@metere.it>
## Copyright (C) 2012 Carnë Draug <carandraug@octave.org>
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
## @deftypefn {Function File} {} strel (@var{shape}, @var{parameters})
## Generate a morphological structuring element.
##
## @code{strel} creates a logical matrix/array with the shape @var{shape} tuned
## with parameters @var{parameters}.
## Available shapes at the moment are: 'square', 'rectangle', 'diamond', 'pair',
## 'disk' (partially)
##
## Argument @var{shape} can be = 'diamond', 'octagon', 'pair', 'rectangle', 'square', 'line',
## 'periodicline', 'ball', 'arbitrary', 'disk'
## Argument @var{parameters} may vary for number, type and meaning, depending on @var{shape}.
##           'diamond' - RADIUS = integer radius greater than 0
##           'octagon' - NYI
##           'pair' - OFFSET = 2-element positive integer vector [X Y] or [X; Y]
##           'rectangle' - DIMENSIONS = 2-element positive integer vector [X Y] or [X; Y]
##           'square' - EDGE = integer edge greater than 0
##           'line' - NYI
##           'periodicline' - NYI
##           'ball' - NYI
##           'arbitrary' - NYI
##           'disk' - RADIUS = integer radius greater than 0
##                  - N = use 0, 4, 6 or 8 periodic lines (default 0) (NYI)
##                        (default will be 4, for now 0: it works 'slower')
##
## @seealso{imdilate, imerode}
## @end deftypefn

function SE = strel (shape, varargin)

  if (nargin < 1 || nargin > 4 || (! ischar (shape) && ! ismatrix (shape)))
    print_usage;
  endif

  if (! ischar (shape))
    varargin(2:end+1) = varargin(:);
    varargin(1) = shape;
    shape = "arbitrary";
  endif

  SE        = struct;
  SE.shape  = tolower (shape);

  switch (SE.shape)
    case "arbitrary"
      if (numel (varargin) == 1)
        nhood = varargin{1};
      else
        ## TODO implement nonflat arbitrary (will take 2 arguments)
        error ("strel: an arbitrary shape only takes 1 argument");
      endif
      if (! isbw (nhood, "non-logical"))
        error ("strel: NHOOD must be a matrix with only 0 and 1 values")
      endif
      SE.nhood = logical (nhood);
      SE.flat  = false;

#    case "ball"
      ## TODO implement ball shape

    case "diamond"
      if (numel (varargin) == 1)
        radius = varargin{1};
      else
        error ("strel: no RADIUS specified for diamond shape");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      endif

      [xx, yy]  = meshgrid (-radius:radius);
      SE.nhood  = (abs (xx) + abs (yy)) <= radius;
      SE.flat   = true;

    case "disk"
      if (numel (varargin) == 1)
        radius = varargin{1};
      else
        ## TODO implement second option for number of periodic lines
        error ("strel: no RADIUS specified for disk shape");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      endif

      SE.nhood = fspecial ("disk", radius) > 0;
      SE.flat  = true;

#    case "line"
      ## TODO implement line shape

#    case "octagon"
      ## TODO implement octagon shape

    case "pair"
      if (numel (varargin) == 1)
        offset = varargin{1};
      else
        error ("strel: no OFFSET specified for pair shape");
      endif
      if (! ismatrix (offset) || numel (offset) != 2 || ! isnumeric (offset))
        error ("strel: OFFSET must be a 2 element vector");
      elseif (any (fix (offset) != offset))
        error ("strel: OFFSET values must be integers");
      endif

      lengths  = abs (2*offset) + 1;
      SE.nhood = false (lengths);
      origin   = (lengths + 1)/2;
      SE.nhood(origin(1), origin(2)) = true;
      SE.nhood(origin(1) + offset(1), origin(2) + offset(2)) = true;

      SE.flat = true;

    case "periodicline"
      ## TODO implement periodicline shape

    case "rectangle"
      if (numel (varargin) == 1)
        dimensions = varargin{1};
      else
        error ("strel: no DIMENSIONS specified for rectangle shape");
      endif
      if (! ismatrix (dimensions) || numel (dimensions) != 2 || ! isnumeric (dimensions))
        error ("strel: DIMENSIONS must be a 2 element vector");
      elseif (! is_positive_integer (dimensions(1)) || ! is_positive_integer (dimensions(2)))
        error ("strel: DIMENSIONS values must be positive integers");
      endif

      SE.nhood = true (dimensions);
      SE.flat  = true;

    case "square"
      if (numel (varargin) == 1)
        edge = varargin{1};
      else
        error ("strel: no EDGE specified for square shape");
      endif
      if (! is_positive_integer (edge))
        error ("strel: EDGE value must be positive integers");
      endif

      SE.nhood = true (edge);
      SE.flat  = true;

    otherwise
      error ("strel: unknown SHAPE `%s'", shape);
  endswitch

  SE = class (SE, "strel");
endfunction

function retval = is_positive_integer (val)
  retval = isscalar(val) && isnumeric(val) && val > 0 && fix (val) == val;
endfunction

%!shared shape
%! shape = [0 0 0 1];
%!assert (getnhood (strel (shape)), logical (shape));
%!assert (getnhood (strel ("arbitrary", shape)), logical (shape));
%! shape = [0 0 0 1 0 0 0
%!          0 0 1 1 1 0 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 0 1 1 1 0 0
%!          0 0 0 1 0 0 0];
%!assert (getnhood (strel ("diamond", 3)), logical (shape));
%! shape = [0 0 0 1 0 0 0
%!          0 1 1 1 1 1 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 1 1 1 1 1 0
%!          0 0 0 1 0 0 0];
%!assert (getnhood (strel ("disk", 3)), logical (shape));
%! shape = [1;1;0];
%!assert (getnhood (strel ("pair", [-1 0])), logical (shape));
%! shape = [1 0 0 0 0 0 0
%!          0 0 0 1 0 0 0
%!          0 0 0 0 0 0 0];
%!assert (getnhood (strel ("pair", [-1 -3])), logical (shape));
%! shape = [0 0 0 0 0 0 0
%!          0 0 0 0 0 0 0
%!          0 0 0 1 0 0 0
%!          0 0 0 0 0 0 0
%!          0 0 0 0 0 0 1];
%!assert (getnhood (strel ("pair", [2 3])), logical (shape));
%!assert (getnhood (strel ("rectangle", [10 5])), true (10, 5));
%!assert (getnhood (strel ("square", 5)), true (5));

## test input validation
%!error strel()
%!error strel("nonmethodthing", 2)
%!error strel("arbitrary", "stuff")
%!error strel("diamond", -3)
%!error strel("disk", -3)
%!error strel("pair", [45 67 90])
%!error strel("rectangle", 2)
%!error strel("rectangle", [2 -5])
%!error strel("square", [34 1-2])
