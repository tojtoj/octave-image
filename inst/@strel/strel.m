## Copyright (C) 2012,2013 Roberto Metere <roberto@metere.it>
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
## Create a strel (structuring element) object for morphology operations.
##
## The structuring element can have any type of shape as specified by
## @var{shape}, each one with its @var{parameters}.
##
## @deftypefnx {Function File} {} strel ("arbitrary", @var{nhood})
## @deftypefnx {Function File} {} strel ("arbitrary", @var{nhood}, @var{height})
## Create arbitrary shaped structuring elements.
##
## @var{nhood} must be a matrix of 0's and 1's.  Any number with of dimensions
## are possible.  To create a non-flat SE, the @var{height} can be specified.
## See individual functions that use the strel object for an interpretation of
## non-flat SEs.
##
## Note that if an arbitrary shape is used, it will not be possible to perform
## structuring element decomposition which may have a performance hit in some
## cases.  See for example the difference for a square shape:
## @example
## @group
## im = randp (5, 2000) > 15;
## se = strel ("square", 20);
## t = cputime (); imdilate (im, se); cputime () - t
##     @result{} 0.77605
## se = strel (ones (20));
## t = cputime (); imdilate (im, se); cputime () - t
##     @result{} 2.9082
## @end group
## @end example
##
## @deftypefnx {Function File} {} strel ("ball", @var{radius}, @var{height})
## Create ball shaped @var{nonflat} structuring element.  @var{radius} must be a
## nonnegative integer that specifies the ray of a circle in X-Y plane.  @var{height}
## is a real number that specifies the height of the center of the circle.
##
## @deftypefnx {Function File} {} strel ("cube", @var{edge})
## Create cube shaped @var{flat} structuring element.  @var{edge} must be a
## positive integer that specifies the length of its edges.  This shape meant to
## perform morphology operations in volumes, see the square shape for 2
## dimensional images.
##
## @deftypefnx {Function File} {} strel ("diamond", @var{radius})
## Create diamond shaped flat structuring element.  @var{radius} must be a
## positive integer.
##
## @deftypefnx {Function File} {} strel ("disk", @var{radius})
## Create disk shaped flat structuring element.  @var{radius} must be a positive
## integer.
##
## @deftypefnx {Function File} {} strel ("line", @var{len}, @var{deg})
## Create line shaped flat structuring element.  @var{len} must be a positive
## real number.  @var{deg} must be a 1 or 2 elements real number, for a line in
## in 2D or 3D space.  The first element of @var{deg} is the angle from X-axis
## to X-Y projection of the line while the second is the angle from Z-axis to
## the line.
##
## @deftypefnx {Function File} {} strel ("octagon", @var{apothem})
## Create octagon shaped flat structuring element.  @var{apothem} must be a
## positive integer that specifies the distance from the origin to the sides of
## the octagon.
##
## @deftypefnx {Function File} {} strel ("pair", @var{offset})
## Creates a flat structuring element with two members.  One member is placed
## at the origin while the other is placed with @var{offset} in relation to the
## origin.  @var{offset} must then be a 2 element vector for the coordinates.
##
## @deftypefnx {Function File} {} strel ("periodicline", @var{p}, @var{v})
## Create periodic line shaped flat structuring element.  A periodic line will
## be built with 2*@var{p}+1 points around the origin included. These points will
## be displaced in accordance with the offset @var{v} at distances: 1*@var{v},
## -1*@var{v}, 2*@var{v}, -2*@var{v}, ..., @var{p}*@var{v}, -@var{p}*@var{v}.
##   Therefore @var{v} must be a 2 element vector for the coordinates.
##
## @deftypefnx {Function File} {} strel ("rectangle", @var{dimensions})
## Creates a rectangular shaped flat structuring element.  @var{dimensions} must
## be a two element vector of positive integers with the number of rows and
## columns of the rectangle.
##
## @deftypefnx {Function File} {} strel ("square", @var{edge})
## Create square shaped flat structuring element.  @var{edge} must be a positive
## integer that specifies the length of its edges.  For use in volumes, see the
## cube shape.
##
## The actual structuring element neighborhood, the logical matrix used for the
## operations, can be accessed with the @code{getnhood} method.  However, most
## morphology functions in the image package will have an improved performance
## if the actual strel object is used, and not its element neighborhood.
##
## @example
## @group
## se = strel ("square", 5);
## getnhood (se)
##     @result{}
##         1  1  1  1  1
##         1  1  1  1  1
##         1  1  1  1  1
##         1  1  1  1  1
##         1  1  1  1  1
## @end group
## @end example
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

  ## because the order that these are created matters, we make them all here
  SE        = struct;
  SE.shape  = tolower (shape);
  SE.nhood  = false;
  SE.flat   = true;
  SE.height = [];
  SE.seq    = cell;
  SE.opt    = struct;

  switch (SE.shape)
    case "arbitrary"
      if (numel (varargin) == 1)
        nhood   = varargin{1};
        SE.flat = true;
      elseif (numel (varargin) == 2)
        nhood     = varargin{1};
        SE.height = varargin{2};
        SE.flat   = false;
      else
        error ("strel: an arbitrary shape takes 1 or 2 arguments");
      endif
      if (! isbw (nhood, "non-logical"))
        error ("strel: NHOOD must be a matrix with only 0 and 1 values")
      endif

      SE.nhood = logical (nhood); # we need this as logical for the height tests

      if (! SE.flat && ! (isnumeric (SE.height) && isreal (SE.height) &&
                          ndims (SE.height) == ndims (nhood)          &&
                          all (size (SE.height) == size (nhood))      &&
                          all (isfinite (SE.height(:)))))
        error ("strel: HEIGHT must be a finite real matrix of the same size as NHOOD");
      endif

    case "ball"
      if (numel (varargin) == 2)
        radius = varargin{1};
        height = varargin{2};
      else
        ## TODO implement third option for number of periodic lines approximation
        error ("strel: a ball shape needs 2 arguments");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      elseif (! (isscalar (height) && isnumeric (height)))
        error ("strel: HEIGHT must be a real number");
      endif

      # Ellipsoid: (x/radius)^2 + (y/radius)^2 + (z/height)^2 = 1
      # We need only the 1 cells of SE.nhood
      [x, y] = meshgrid (-radius:radius, -radius:radius);
      SE.nhood = ((x.^2 + y.^2) <= radius^2); # X-Y circle
      SE.height = height / radius * SE.nhood .* sqrt (radius^2 - x .^2 - y.^2);
      SE.flat = false;

    case "cube"
      if (numel (varargin) == 1)
        SE.opt.edge = varargin{1};
      else
        error ("strel: no EDGE specified for cube shape");
      endif
      if (! is_positive_integer (SE.opt.edge))
        error ("strel: EDGE value must be a positive integer");
      endif

      SE.nhood = true (SE.opt.edge, SE.opt.edge, SE.opt.edge);
      SE.flat  = true;

    case "diamond"
      if (numel (varargin) == 1)
        radius = varargin{1};
      else
        error ("strel: no RADIUS specified for diamond shape");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      endif

      corner   = tril (true (radius+1, radius), -1);
      SE.nhood = [rot90(tril(true(radius+1))) corner;
                  corner' rot90(triu(true(radius),1))];
      SE.flat  = true;

    case "disk"
      if (numel (varargin) == 1)
        radius = varargin{1};
      else
        ## TODO implement second option for number of periodic lines approximation
        error ("strel: no RADIUS specified for disk shape");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      endif

      SE.nhood = fspecial ("disk", radius) > 0;
      SE.flat  = true;

    case "line"
      if (numel (varargin) == 2)
        linelen = varargin{1};
        degrees = varargin{2};
      else
        error ("strel: a line shape needs 2 arguments");
      endif
      if (! (isscalar (linelen) && isnumeric (linelen) && linelen > 0))
        error ("strel: LEN must be a positive real number");
      elseif (! isnumeric (degrees))
        error ("strel: DEG must be numeric");
      endif
      ## 2d or 3d line
      dimens = numel (degrees) +1;
      if (dimens == 2)
        degrees = degrees(1);
      elseif (dimens == 3)
        alpha = degrees(1);
        phi   = degrees(2);
      else
        error ("strel: DEG must be a 1 or 2 elements matrix");
      endif

      ## TODO this was the 3dline and line options, which have separate code
      ##      but a proper merge should be made.

      if (dimens == 2)
        ## Line length are always odd, to center strel at the middle of the line.
        ## We look it as a diameter of a circle with given slope
        # It computes only lines with angles between 0 and 44.9999
        deg90 = mod (degrees, 90);
        if (deg90 > 45)
          alpha = pi * (90 - deg90) / 180;
        else
          alpha = pi * deg90 / 180;
        endif
        ray = (linelen - 1)/2;

        ## We are interested only in the discrete rectangle which contains the diameter
        ## However we focus our attention to the bottom left quarter of the circle,
        ## because of the central symmetry.
        c = round (ray * cos (alpha)) + 1;
        r = round (ray * sin (alpha)) + 1;

        ## Line rasterization
        line = false (r, c);
        m = tan (alpha);
        x = [1:c];
        y = r - fix (m .* (x - 0.5));
        indexes = sub2ind ([r c], y, x);
        line(indexes) = true;

        ## We view the result as 9 blocks.
        # Preparing blocks
        linestrip = line(1, 1:c - 1);
        linerest = line(2:r, 1:c - 1);
        z = false (r - 1, c);

        # Assemblying blocks
        SE.nhood =  vertcat (
                      horzcat (z, linerest(end:-1:1,end:-1:1)),
                      horzcat (linestrip, true, linestrip(end:-1:1,end:-1:1)),
                      horzcat (linerest, z(end:-1:1,end:-1:1))
                    );

        # Rotate/transpose/flip?
        sect = fix (mod (degrees, 180) / 45);
        switch (sect)
          case 1, SE.nhood = transpose (SE.nhood);
          case 2, SE.nhood = rot90 (SE.nhood, 1);
          case 3, SE.nhood = fliplr (SE.nhood);
          otherwise, # do nothing
        endswitch

      elseif (dimens == 3)
        ## This is a first implementation
        ## Stroke line from cells (x1, y1, z1) to (x2, y2, z2)
        alpha *= pi / 180;
        phi *= pi / 180;
        x1 = y1 = z1 = 0;
        x2 = round (linelen * sin (phi) * cos (alpha));
        y2 = round (linelen * sin (phi) * sin (alpha));
        z2 = round (linelen * cos (phi));
        # Adjust x2, y2, z2 to have one central cell
        x2 += (! mod (x2, 2)) * sign0positive (x2);
        y2 += (! mod (y2, 2)) * sign0positive (y2);
        z2 += (! mod (z2, 2)) * sign0positive (z2);
        # Invert x
        x2 = -x2;

        # Tanslate parallelepiped to be in positive quadrant
        if (x2 < 0)
          x1 -= x2;
          x2 -= x2;
        endif
        if (y2 < 0)
          y1 -= y2;
          y2 -= y2;
        endif
        if (z2 < 0)
          z1 -= z2;
          z2 -= z2;
        endif

        # Compute index2es
        dim = abs ([(x2 - x1) (y2 - y1) (z2 - z1)]);
        m = max (dim);
        base = meshgrid (0:m - 1,1) .+ 0.5;
        a = floor ((x2 - x1)/m .* base);
        b = floor ((y2 - y1)/m .* base);
        c = floor ((z2 - z1)/m .* base);
        # Adjust indexes to be valid
        a -= min (a) - 1;
        b -= min (b) - 1;
        c -= min (c) - 1;
        indexes = sub2ind (dim, a, b, c);

        SE.nhood = false (dim);
        SE.nhood(indexes) = true;
      endif

      SE.flat = true;

    case "octagon"
      if (numel (varargin) == 1)
        apothem = varargin{1};
      else
        error ("strel: no APOTHEM specified for octagon shape");
      endif
      if (! is_positive_integer (apothem) || mod (apothem, 3) != 0)
        error ("strel: APOTHEM must be a positive integer multiple of 3");
      endif

      ## we look at it as 9 blocks. North AND South are the same and West TO
      ## East as well. We make the corner for NorthEast and rotate it for the
      ## other corners
      cwide    = apothem/3*2 + 1;
      iwide    = apothem/3*2 - 1;
      N_and_S  = true ([cwide iwide]);
      corner   = tril (true (cwide));
      SE.nhood = [rotdim(corner), N_and_S, corner;
                  true([iwide (2*apothem + 1)]);
                  transpose(corner), N_and_S, rotdim(corner, -1)];
      SE.flat  = true;

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
      if (numel (varargin) == 2)
        p = varargin{1};
        v = varargin{2};
      else
        error ("strel: a periodic line shape needs 2 arguments");
      endif
      if (! is_positive_integer (p))
        error ("strel: P must be a positive integer");
      elseif (! ismatrix (v) || numel (v) != 2 || ! isnumeric (v))
        error ("strel: V must be a 2 element vector");
      elseif (any (fix (v) != v))
        error ("strel: values of V must be integers");
      endif

      lengths  = abs (2*p*v) + 1;
      SE.nhood = false (lengths);
      origin   = (lengths + 1)/2;
      for i = -p:p
        point = i*v + origin;
        SE.nhood(point(1), point(2)) = true;
      endfor

    case "rectangle"
      if (numel (varargin) == 1)
        SE.opt.dimensions = varargin{1};
      else
        error ("strel: no DIMENSIONS specified for rectangle shape");
      endif
      if (! ismatrix (SE.opt.dimensions) || numel (SE.opt.dimensions) != 2 ||
          ! isnumeric (SE.opt.dimensions))
        error ("strel: DIMENSIONS must be a 2 element vector");
      elseif (! is_positive_integer (SE.opt.dimensions(1)) ||
              ! is_positive_integer (SE.opt.dimensions(2)))
        error ("strel: DIMENSIONS values must be positive integers");
      endif

      SE.nhood = true (SE.opt.dimensions);
      SE.flat  = true;

    case "square"
      if (numel (varargin) == 1)
        SE.opt.edge = varargin{1};
      else
        error ("strel: no EDGE specified for square shape");
      endif
      if (! is_positive_integer (SE.opt.edge))
        error ("strel: EDGE value must be positive integers");
      endif

      SE.nhood = true (SE.opt.edge);
      SE.flat  = true;

    otherwise
      error ("strel: unknown SHAPE `%s'", shape);
  endswitch

  SE = class (SE, "strel");
endfunction

function retval = is_positive_integer (val)
  retval = isscalar (val) && isnumeric (val) && val > 0 && fix (val) == val;
endfunction

function retval = sign0positive (val)
  if (sign (val) == -1)
    retval = -1;
  else
    retval = 1;
  endif
endfunction

%!shared shape, height
%! shape  = [0 0 0 1];
%!assert (getnhood (strel (shape)), logical (shape));
%!assert (getnhood (strel ("arbitrary", shape)), logical (shape));
%! height = [0 0 0 3];
%!assert (getnhood (strel ("arbitrary", shape, height)), logical (shape));
%!assert (getheight (strel ("arbitrary", shape, height)), height);
%! shape = [0 0 1];
%! height = [-2 1 3];  ## this works for matlab compatibility
%!assert (getnhood (strel ("arbitrary", shape, height)), logical (shape));
%!assert (getheight (strel ("arbitrary", shape, height)), height);
%! shape = [0 0 0 1 0 0 0
%!          0 1 1 1 1 1 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 1 1 1 1 1 0
%!          0 0 0 1 0 0 0];
%! height = [ 0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000
%!            0.00000   0.33333   0.66667   0.74536   0.66667   0.33333   0.00000
%!            0.00000   0.66667   0.88192   0.94281   0.88192   0.66667   0.00000
%!            0.00000   0.74536   0.94281   1.00000   0.94281   0.74536   0.00000
%!            0.00000   0.66667   0.88192   0.94281   0.88192   0.66667   0.00000
%!            0.00000   0.33333   0.66667   0.74536   0.66667   0.33333   0.00000
%!            0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000]
%!assert (getnhood (strel ("ball", 3, 1)), logical (shape));
%!assert (getheight (strel ("ball", 3, 1)), height);
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
%! shape = [1 1 1];
%!assert (getnhood (strel ("line", 3.9, 20.17)), logical (shape));
%! shape = [0 0 1
%!          0 1 0
%!          1 0 0];
%!assert (getnhood (strel ("line", 3.9, 20.18)), logical (shape));
%! shape = [1 0 0 0 0 0 0 0 0
%!          0 1 0 0 0 0 0 0 0
%!          0 0 1 0 0 0 0 0 0
%!          0 0 1 0 0 0 0 0 0
%!          0 0 0 1 0 0 0 0 0
%!          0 0 0 0 1 0 0 0 0
%!          0 0 0 0 0 1 0 0 0
%!          0 0 0 0 0 0 1 0 0
%!          0 0 0 0 0 0 1 0 0
%!          0 0 0 0 0 0 0 1 0
%!          0 0 0 0 0 0 0 0 1];
%!assert (getnhood (strel ("line", 14, 130)), logical (shape));
%! shape = [0 0 1 1 1 0 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          1 1 1 1 1 1 1
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 0 1 1 1 0 0];
%!assert (getnhood (strel ("octagon", 3)), logical (shape));
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

## test how @strel/getsequence and indexing works fine
%!shared se, seq
%! se = strel ("square", 5);
%! seq = getsequence (se);
%!assert (class (se(1)),  "strel")
%!assert (class (se(1,1)),"strel")
%!assert (class (seq),    "strel")
%!assert (class (seq(1)), "strel")
%!assert (class (seq(2)), "strel")
%!assert (numel (se), 1)
%!assert (numel (seq), 2)
%!error se(2);
%!error seq(3);

## test reflection
%!shared se, ref
%! se = strel ("arbitrary", [1 0 0; 1 1 0; 0 1 0], [2 0 0; 3 1 0; 0 3 0]);
%! ref = reflect (se);
%!assert (getnhood (ref), logical([0 1 0; 0 1 1; 0 0 1]));
%!assert (getheight (ref), [0 3 0; 0 1 3; 0 0 2]);

## test input validation
%!error strel()
%!error strel("nonmethodthing", 2)
%!error strel("arbitrary", "stuff")
%!error strel("arbitrary", [0 0 1], [2 0 1; 4 5 1])
%!error strel("arbitrary", [0 0 1], "stuff")
%!error strel("ball", -3, 1)
%!error strel("diamond", -3)
%!error strel("disk", -3)
%!error strel("line", 0, 45)
%!error strel("octagon", 4)
%!error strel("pair", [45 67 90])
%!error strel("rectangle", 2)
%!error strel("rectangle", [2 -5])
%!error strel("square", [34 1-2])
