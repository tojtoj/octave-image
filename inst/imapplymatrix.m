## Copyright (C) 2018 Martin Janda <janda.martin1@gmail.com>
## 
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{Y} =} imapplymatrix (@var{M}, @var{X})
## @deftypefnx {} {@var{Y} =} imapplymatrix (@var{M}, @var{X}, @var{C})
## @deftypefnx {} {@var{Y} =} imapplymatrix (@dots{}, @var{output_type})
## Linear combination of color channels.
## 
## Computes a linear combination of channels of image @var{X} given a matrix
## of coefficients @var{M} and optionally adding a constant value to
## each output channel.  @var{X} is an image of size @code{[m, n, p, @dots{}]},
## @var{M} is a multiplication matrix of size @code{[q, p]} and @var{C} is a
## vector of constants of length q.  @var{Y} is a matrix of size
## @code{[m, n, q, @dots{}]} with q output channels.  q is in the range [1, p].
##
## @var{Y} is of the same type as @var{X}, unless @var{output_type} is
## specified.
##
## @end deftypefn

function Y = imapplymatrix (M, X, varargin)
  if (nargin < 2 || nargin > 4)
    print_usage ();
  endif

  if (length (size (M)) > 2)
    error ("Octave:invalid-input-arg", "imapplymatrix: M must be a 2-D matrix");
  endif
  
  if (! isempty(X) && isnumeric (M))
    if (size(M, 1) > size (M, 2))
      error ("Octave:invalid-input-arg", ...
      "imapplymatrix: The number of rows of M must be less than or equal to \
the number of its columns");
    endif

    if (size (M, 2) != size (X, 3))
      error ("Octave:invalid-input-arg", ...
      "imapplymatrix: The number of columns in M must match the number of \
image channels");
    endif
  elseif (! isnumeric (M))
    M = nan (1, size (X, 3));
  elseif (isempty (M))
    M = []; # make sure q is zero
  endif

  [C, output_type] = parseVarargin (M, X, varargin{:});
  m = size (X, 1);
  n = size (X, 2);
  p = size (X, 3);
  q = size (M, 1);
  xdims = size (X);
  npix = m * n; # number of pixels
  resh_dims_1 = [npix, max(prod(xdims(3:end)), 1)];
  resh_dims_2 = [sign(npix) * p, prod(xdims) ./ max(p, 1)];
  X = double (X);
  M = double (M);
  ## reshape X for vectorized multiplication with M
  X_reshaped = reshape (reshape (X, resh_dims_1)', resh_dims_2);
  if (! isempty (C))
    C = double (C);
    M = cat(2, C(:), M);
    X_reshaped = cat(1, ones (1, size (X_reshaped, 2)), X_reshaped);
  endif
  ydims = [m, n, q, xdims(4:end)];
  ydims(length (xdims) + 1:end) = [];
  Y = cast (reshape (reshape (M * X_reshaped, ...
  [max(prod(ydims(3:end)), 1), npix])', ydims), output_type);
endfunction

function [C, output_type] = parseVarargin (M, X, varargin)
  if (numel (varargin) == 0)
    C = [];
    output_type = class (X);
  elseif (numel (varargin) == 1)
    if (ischar (varargin{1}))
      C = [];
      output_type = varargin{1};
    elseif (! isValidC (M, varargin{1}))
      error ("Octave:invalid-input-arg", ...
      "imapplymatrix: third argument must be a vector C or output_type");
    else
      C = varargin{1};
      output_type = class (X);
    endif
  elseif (numel (varargin) == 2)
    if (! isValidC (M, varargin{1}))
      error ("Octave:invalid-input-arg", ...
      "imapplymatrix: The length of C must equal the number of rows of M");
    elseif (! ischar (varargin{2}))
      error ("Octave:invalid-input-arg", ...
      "imapplymatrix: output_type must be a valid numeric data type");
    else
      C = varargin{1};
      output_type = varargin{2};
    endif
  endif
endfunction

function TF = isValidC (M, arg)
  TF = isempty (M) || isempty (arg) || (isnumeric (arg) && isvector (arg) ...
  && length (arg) == size (M, 1));
endfunction

## test argument checking
%!error id=Octave:invalid-fun-call imapplymatrix ()
%!error id=Octave:invalid-fun-call imapplymatrix (42)
%!error id=Octave:invalid-input-arg imapplymatrix (ones (2, 2, 2), 42)
%!error id=Octave:invalid-input-arg imapplymatrix ([], ones (2, 2))
%!error id=Octave:invalid-input-arg imapplymatrix (ones (0, 2), ones (2, 2))
%!error id=Octave:invalid-input-arg imapplymatrix (ones (2, 0), ones (2, 2))
%!error id=Octave:invalid-input-arg imapplymatrix (4, 2, [2, 2])
%!error id=Octave:invalid-input-arg imapplymatrix (4, 2, [2, 2], "uint8")
%!error id=Octave:invalid-input-arg imapplymatrix (4, 2, 0, 666)

%!assert (imapplymatrix ([], []), [])
%!assert (imapplymatrix ([], [], "uint16"), uint16 ([]))
%!assert (imapplymatrix (1, 10, []), 10)
%!assert (imapplymatrix (1, 10, ones (0, 5)), 10)
%!assert (imapplymatrix (1, 10, ones (5, 0)), 10)
%!assert (imapplymatrix (ones (0), ones (0), 3), [])
%!assert (imapplymatrix (ones (0), ones (4, 0), 3), zeros (4, 0))
%!assert (imapplymatrix (ones (0), ones (0, 4), 3), zeros (0, 4))
%!assert (imapplymatrix (ones (2, 0), ones (0, 4), 3), zeros (0, 4))
%!assert (imapplymatrix (ones (0, 2), ones (0, 4), 3), zeros (0, 4))
%!assert (imapplymatrix (ones (0, 2), ones (0, 4, 0), 3), zeros (0, 4, 0))
%!assert (imapplymatrix("a", ones(2, 2)), nan (2, 2))
%!assert (imapplymatrix("abc", ones(2, 2)), nan (2, 2))

%!assert (imapplymatrix (1, 10), 10)
%!assert (imapplymatrix (1, 10, 3), 13)
%!assert (imapplymatrix (ones (1), uint8 (10), 3), uint8 (13))
%!assert (imapplymatrix (uint8 (ones (1)), 10, 3), double (13))
%!assert (imapplymatrix (uint8 (ones (1)), uint8 (10), 3), uint8 (13))
%!assert (imapplymatrix (2.6 * ones (1), uint8 (10), 4.7), uint8 (31))

%!assert (imapplymatrix (42, ones (1, 2)), 42 * ones (1, 2))
%!assert (imapplymatrix (42, ones (2, 1)), 42 * ones (2, 1))
%!assert (imapplymatrix (42, ones (2, 2)), 42 * ones (2, 2))
%!assert (imapplymatrix (42, ones (2, 2), 0.5), 42.5 * ones (2, 2))
%!assert (imapplymatrix ([4, 2], ones (2, 2, 2), 0.5), 6.5 * ones (2, 2))
%!assert (imapplymatrix ([4, 2;
%!                        4, 2], ones (2, 2, 2), [0.5, 0.5]), 6.5 * ones (2, 2, 2))
%!assert (imapplymatrix ([4, 2;
%!                        4, 2], ones (2, 2, 2), [0.5; 0.5]), 6.5 * ones (2, 2, 2))

%!assert (imapplymatrix ([1, 2, 3], ones (2, 2, 3)), 6 * ones (2, 2, 1))
%!assert (imapplymatrix ([1, 2, 3], ones (2, 2, 3), 1), 7 * ones (2, 2, 1))

%!test
%! expected = zeros (2, 2, 2, "uint8");
%! expected(:, :, 1) = 7 * ones (2, 2);
%! expected(:, :, 2) = 16 * ones (2, 2);
%! I = uint8 (ones (2, 2, 3));
%! assert (imapplymatrix ([1, 2, 3
%!                         4, 5, 6], I, [1, 1]), expected)

%!test
%! expected = zeros (2, 2, 2, 2, "uint16");
%! expected(:, :, 1, 1) = 7 * ones (2, 2);
%! expected(:, :, 2, 1) = 16 * ones (2, 2);
%! expected(:, :, 1, 2) = 13 * ones (2, 2);
%! expected(:, :, 2, 2) = 31 * ones (2, 2);
%! I(:, :, :, 1) = uint16 (ones (2, 2, 3));
%! I(:, :, :, 2) = 2 * uint16 (ones (2, 2, 3));
%! assert (imapplymatrix ([1, 2, 3;
%!                         4, 5, 6], I, [1, 1]), expected)
