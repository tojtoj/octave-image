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

function SE = strel (varargin)

  % Check minimum number of arguments
  switch (nargin)
    case 0
      print_usage();

    case 1
      a = varargin{1}
      if (isnumeric(varargin{1}))
        SE = strel('arbitrary', varargin{1});
      else
        print_usage();
      endif

    otherwise
      if (isnumeric(varargin{1}) && isnumeric(varargin{2}))
        SE = strel('arbitrary', varargin{1}, varargin{2});
      else
        shape = varargin{1};
      endif
  endswitch

  % Not yet implemented, sorry (a complete version won't have this switch)
  switch (shape)
    case {'octagon', 'line', 'periodicline', 'ball', 'arbitrary'}
      error ("strel: shape '%s' not yet implemented", shape);

    otherwise % Just for completeness
  endswitch


  % Get shape parameters in arg1, arg2, etc...
  switch (shape)
    case {'diamond', 'octagon', 'pair', 'rectangle', 'square'}
      if (nargin == 2)
        arg1 = varargin{nargin};
      else
        error ("strel: shape '%s' needs 1 parameter", shape);
      endif

    case {'line', 'periodicline'}
      if (nargin == 3)
        arg1 = varargin{nargin - 1};
        arg2 = varargin{nargin};
      else
        error ("strel: shape '%s' needs 2 parameters", shape);
      endif

    case 'ball'
      if (nargin == 4)
        arg1 = varargin{nargin - 2};
        arg2 = varargin{nargin - 1};
        arg3 = varargin{nargin};
      else
        error ("strel: shape '%s' needs 3 parameters", shape);
      endif

    case {'arbitrary', 'disk'}
      if (nargin == 2)
        arg1 = varargin{nargin};
      elseif (nargin == 3)
        arg1 = varargin{nargin - 1};
        arg2 = varargin{nargin};
      else
        error ("strel: shape '%s' needs 2 or 3 parameters", shape);
      endif

    otherwise
      error ("strel: unknown shape '%s'", shape);
  endswitch


  % Compute structure element
  switch (shape)
    case 'square'
      if (isscalar(arg1) && isnumeric(arg1) && arg1 > 0 && fix (arg1) == arg1)
        SE.height = zeros([arg1 arg1], 'double');
        SE.nhood = true (arg1);
        SE.flat = true;
        SE = class (SE, "strel");
      else
        error ("strel: square EDGE must be a positive integer");
      endif

    case 'rectangle'
      if (!isscalar(arg1) && isvector(arg1) && isnumeric(arg1) && prod(size(arg1)) == 2 && arg1(1) > 0 && arg1(2) > 0 && fix (arg1) == arg1)
        SE.height = zeros(arg1, 'double');
        SE.nhood = true (arg1);
        SE.flat = true;
        SE = class (SE, "strel");
      else
        error("strel: rectangle DIMENSIONS must be a positive integer vector with two elements");
      endif

    case 'diamond'
      if (isscalar(arg1) && isnumeric(arg1) && arg1 > 0 && fix (arg1) == arg1)
        n = int32(2*arg1 + 1);
        c = (n + 1)/2;

        SE.height = zeros([arg1 arg1], 'double');
        SE.nhood = false (arg1);
        SE.flat = true;
        SE = class (SE, "strel");

        for i = 1:n
          m = n - abs (2*(i - c));
          for j = (c - m/2 + 1):(c + m/2 - 1)
            SE.nhood(i, j) = 1;
          endfor
        endfor
      else
        error("strel: diamond RADIUS must be a positive integer");
      endif

    case 'pair'
      if (!isscalar(arg1) && isvector(arg1) && isnumeric(arg1) && prod(size(arg1)) == 2 && arg1(1) > 0 && arg1(2) > 0 && fix (arg1) == arg1)
        m = abs(2*arg1(1)) + 1;
        n = abs(2*arg1(2)) + 1;

        SE.height = zeros([m n], 'double');
        SE.nhood = false ([m n]);
        SE.flat = true;
        SE = class (SE, "strel");

        cy = (m + 1)/2;
        cx = (n + 1)/2;
        SE.nhood(cy, cx) = 1;
        SE.nhood(cy + arg1(1), cx + arg1(2) ) = 1;
      else
        error("strel: pair OFFSET must be a positive integer vector with two elements");
      endif

    case 'disk'
      if (isscalar(arg1) && isnumeric(arg1) && arg1 > 0 && fix (arg1) == arg1)
        % Default value of N
        if (nargin <= 2)
          arg2 = 4;
        else
          allowed_n = [0 4 6 8];
          if (isscalar(arg2) && isnumeric(arg2) && sum(allowed_n(:) == arg2) == 1 && fix(arg2) == arg2)
            warning("strel: disk N (number of periodic lines to approximate disk) is ignored");
          else
            error("strel: disk N (number of periodic lines to approximate disk) may assume only values: 0, 4, 6 or 8");
          endif
        endif

        % Compute disk
        switch (arg2)
          % This should be only case 0
          case {0, 4, 6, 8}
            radius = arg1;
            n = 2*radius + 1;

            SE.height = zeros([n n], 'double');
            SE.nhood = false (n);
            SE.flat = true;
            SE = class (SE, "strel");

            radius2 = radius^2;
            for i = 1:n
              for j = 1:n
                pitagora = (i - radius - 1)^2 + (j - radius - 1)^2;
                if (pitagora <= radius2)
                  SE.nhood(i, j) = 1;
                endif
              endfor
            endfor

          otherwise
            error("strel: bug - execution should never reach this line. Please report this bug");
        endswitch
      else
        error("strel: disk RADIUS must be a positive integer");
      endif
  endswitch

endfunction

%!demo
%!assert(gethnood(strel('disk',3)))==[0,0,0,1,0,0,0;0,1,1,1,1,1,0;0,1,1,1,1,1,0;1,1,1,1,1,1,1;0,1,1,1,1,1,0;0,1,1,1,1,1,0;0,0,0,1,0,0,0]);

%!error strel()
%!error strel('rectangle', 2)
