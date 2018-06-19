## Copyright (C) 2014 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see
## <http:##www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} grayslice (@var{I})
## @deftypefnx {Function File} {} grayslice (@var{I}, @var{n})
## @deftypefnx {Function File} {} grayslice (@var{I}, @var{v})
## Create indexed image from intensity image using multilevel thresholding.
##
## The intensity image @var{I} will be split into multiple threshold levels.
## For regularly spaced intervals, the number of levels can be specified as the
## numeric scalar @var{n} (defaults to 10), which will use the intervals:
##
## @tex
## \def\frac#1#2{{\begingroup#1\endgroup\over#2}}
## $$ \frac{1}{n}, \frac{2}{n}, \dots{}, \frac{n - 1}{n} $$
## @end tex
## @ifnottex
## @verbatim
## 1  2       n-1
## -, -, ..., ---
## n  n        n
## @end verbatim
## @end ifnottex
##
## For irregularly spaced intervals, the numeric vector @var{v} can be
## specified instead.  The values in @var{v} must be in the range [0 1]
## independently of the class of @var{I}.  These will be adjusted by
## @code{grayslice} according to the image.
##
## The output image will be of class uint8 if the number of levels is
## less than 256, otherwise it will be double.
##
## @seealso{im2bw, gray2ind}
## @end deftypefn

function sliced = grayslice (I, n = 10)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  if (isscalar (n) && isnumeric (n) && (fix (n) == n))
    v = [1:(n-1)] / n;
    n = n-1;
  elseif (isvector (n))
    ## Do NOT check if v is in the [0 1] interval
    v = n(:);
    n = numel (v);
  else
    error ("grayslice: V or N must be numeric vector or scalar respectively");
  endif
  v = imcast (v, class (I));

  sliced_tmp = lookup (v, I);
  if (n <= 256)
    sliced_tmp = uint8 (sliced_tmp);
  else
    ## remember that indexed images of floating point class have indices base 1
    sliced_tmp++;
  endif

  if (nargout < 1)
    imshow (sliced_tmp, jet (n));
  else
    sliced = sliced_tmp;
  endif
endfunction

%!function gs = test_grayslice_vector (I, v)
%!  gs = zeros (size (I));
%!  for idx = 1:numel (v)
%!    gs(I >= v(idx)) = idx;
%!  endfor
%!endfunction

%!function gs = test_grayslice_scalar (I, n)
%!  v = (1:(n-1)) / n;
%!  gs = test_grayslice_vector (I, v);
%!endfunction

%!shared I2d, I3d, I5d, double_corner
%! I2d = rand (10, 10);
%! I3d = rand (10, 10, 3);
%! I5d = rand (10, 10, 4, 3, 5);
%!
%! double_corner = I2d;
%! double_corner(I2d > 0.1 & I2d < 0.3) = -0.2;
%! double_corner(I2d > 0.6 & I2d < 0.7) = 1.3;

%!assert (grayslice (I2d), grayslice (I2d, 10))
%!assert (grayslice (I2d, 10), uint8 (test_grayslice_scalar (I2d, 10)))
%!assert (grayslice (I2d, [0.3 0.5 0.7]),
%!        uint8 (test_grayslice_vector (I2d, [0.3 0.5 0.7])))
%!assert (grayslice (I3d, 10), uint8 (test_grayslice_scalar (I3d, 10)))
%!assert (grayslice (I5d, 300), test_grayslice_scalar (I5d, 300)+1)
%!assert (grayslice (I3d, [0.3 0.5 0.7]),
%!        uint8 (test_grayslice_vector (I3d, [0.3 0.5 0.7])))

### FIXME investigate why this sometimes fails
%!assert (grayslice (im2uint8 (I2d), 3), uint8 (test_grayslice_scalar (I2d, 3)))
%!assert (grayslice (im2uint16 (I2d), 3), uint8 (test_grayslice_scalar (I2d, 3)))

