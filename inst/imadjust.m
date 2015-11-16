## Copyright (C) 1999,2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2004 Josep Monés i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2015 Carnë Draug <carandraug@octave.org>
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
## @deftypefn  {Function File} {} imadjust (@var{I})
## @deftypefnx {Function File} {} imadjust (@var{I}, [@var{low_in}; @var{high_in}])
## @deftypefnx {Function File} {} imadjust (@var{I}, [@var{low_in}; @var{high_in}],[@var{low_out}; @var{high_out}])
## @deftypefnx {Function File} {} imadjust (@dots{}, @var{gamma})
## @deftypefnx {Function File} {} imadjust (@var{cmap}, @dots{})
## @deftypefnx {Function File} {} imadjust (@var{RGB}, @dots{})
## Adjust image or colormap intensity (values).
##
## Returns an image of equal dimensions to @var{I}, @var{cmap}, or
## @var{RGB}, with its intensity values adjusted, usually for the
## purpose of increasing the image contrast.
##
## The values are rescaled according to the input and output limits,
## @var{low_in} and @var{high_in}, and @var{low_out} and @var{high_out}
## respectively.  The first pair sets the lower and upper limits
## on the input image, values above and below them being clipped.
## The second pair sets the lower and upper limits for the output
## image, the interval to which the image will be scaled after
## clipping the input limits.
##
## For example:
##
## @example
## imadjust (img, [0.2; 0.9], [0; 1])
## @end example
##
## will clip all values in @var{img} outside the range [0.2 0.9],
## and then rescale them linearly into the range [0 1].
##
## The input and output limits must be defined as arrays of 2 rows
## with values in the [0 1] range.  Each 2 rows column corresponds
## to a single plane in the input image (or each column of a
## colormap), thus supporting images with any number of dimensions.
## If the limits have only 2 elements, the same limits are on all planes.
## This format is matched to @code{stretchlim} which is designed
## to create the input limits for @code{imadjust}.
##
## By default, the limits are adjusted to maximize the contrast, using
## the whole range of values in the image class; and cause a 2%
## saturation (1% on the lower and upper end of the image).  It is
## equivalent to:
##
## @example
## imadjust (@var{I}, stretchlim (@var{I}, 0.01), [0; 1])
## @end example
##
## For sake of @sc{Matab} compatibility, an empty array in any of
## the limits is interpreted as @code{[0; 1]}.
##
## If @var{low_out} is higher than @var{high_out}, the output image
## will be reversed (image negative or complement).
##
## The @var{gamma} value shapes the mapping curve between the input
## and output elements.  It defaults to 1, a linear mapping.  Higher
## values of @var{gamma} will curve the mapping downwards and to the right,
## increasing the contrast in the brighter (higher) values of the
## input image.  Lower values of @var{gamma} will curve the mapping
## upwards and to the left, increasing the contrast in the darker (lower)
## values of the input image.
##
## As with the limits, @var{gamma} can have different values for each
## plane, a 1 row column per plane, thus supporting input images with
## any number of dimensions.  If only a scalar, the same value is used
## in all planes.
##
## The formula used to perform the mapping (omitting saturation) is:
##
## @example
## low_out + (high_out - low_out) .* ((I - low_in) / (high_in - low_in)) .^ gamma
## @end example
##
## @seealso{brighten, contrast, histeq, stretchlim}
## @end deftypefn

function adj = imadjust (img, in, out = [0; 1], gamma = 1)

  if (nargin () < 1 || nargin () > 4)
    print_usage ();
  endif

  if (! isimage (img))
    error ("imadjust: I, RGB, or CMAP must be an image or a colormap");
  endif

  sz = size (img);
  if (iscolormap (img))
    was_colormap = true;
    img = reshape (img, [sz(1) 1 sz(2)]);
    sz = size (img);
  else
    was_colormap = false;
  endif
  n_planes = prod (sz(3:end));


  if (nargin () < 2)
    in = stretchlim (img, 0.01);
  else
    in = parse_limits (in, sz);
  endif
  out = parse_limits (out, sz);

  if (! isfloat (gamma) || any (gamma < 0))
    error ("imadjust: GAMMA must be a non-negative floating point")
  elseif (isscalar (gamma))
    gamma = repmat (gamma, [1 n_planes]);
  elseif (! isequal (size (gamma)(2:end), sz(3:end)))
    error ("imadjust: GAMMA must be a scalar or 1 row per plane")
  endif

  ## To make the computations in N dimensions, we make heavy use of
  ## broadcasting so reshape to have a single value per plane.
  in = reshape (in, [2 1 sz(3:end)]);
  out = reshape (out, [2 1 sz(3:end)]);
  gamma = reshape (gamma, [1 1 sz(3:end)]);

  lo_idx = [1 repmat({":"}, 1, ndims (in))];
  hi_idx = [2 repmat({":"}, 1, ndims (in))];
  li = in(lo_idx{:});
  hi = in(hi_idx{:});
  lo = out(lo_idx{:});
  ho = out(hi_idx{:});

  ## Image negative is computed if ho < lo although nothing special is
  ## needed, since formula automatically handles it.
  adj = (img < li) .* lo;
  adj += (img >= li & img < hi) .* (lo + (ho - lo) .* ((img - li) ./ (hi - li)) .^ gamma);
  adj += (img >= hi) .* ho;

  if (was_colormap)
    adj = reshape (adj, [sz(1) sz(3)]);
  endif

endfunction

function limits = parse_limits (limits, sz)
  if (isempty (limits))
    limits = repmat ([0; 1], [1 sz(3:end)]);
  else
    if (! isfloat (limits))
      error ("imadjust: IN and OUT must be numeric floating-point arrays");
    elseif (min (limits(:)) < 0 || max (limits(:)) > 1)
      error ("imadjust: IN and OUT must be on the range [0 1]");
    endif
    ## Only reshape back into 2 row column for a single plane.
    ## Require the correct format otherwise.
    if (numel (limits) == 2)
      limits = repmat (limits(:), [1 sz(3:end)]);
    elseif (rows (limits) != 2 || ! isequal (sz(3:end), size (limits)(2:end)))
      error ("imadjust: IN and OUT must be a 2 row column per plane");
    endif
  endif
endfunction


%!error <must be an image or a colormap> imadjust ("bad argument");
%!error <numeric floating-point arrays> imadjust ([1:100], "bad argument", [], 1);
%!error <2 row column per plane> imadjust ([1:100], [0 1 1], [], 1);
%!error <2 row column per plane> imadjust ([1:100], [], [0 1 1], 1);
%!error <scalar or 1 row per plane> imadjust ([1:100], [], [], [0; 1]);
%!error <scalar or 1 row per plane> imadjust (rand (5, 5, 3), [], [], [0 1]);
%!error <non-negative floating point> imadjust ([1:100], [0; 1], [], -1);
%!error <be on the range \[0 1]> imadjust ([1:100], [0; 5], []);
%!error <be on the range \[0 1]> imadjust ([1:100], [-2; 1], []);
%!error <be on the range \[0 1]> imadjust ([1:100], [], [0; 4]);
%!error <be on the range \[0 1]> imadjust ([1:100], [], [-2; 1]);


## Test default values to 1% on each end saturated and [] as [0; 1]
%!test
%! im = [0.01:0.01:1];
%! assert (imadjust (im), [0 linspace(0, 1, 98) 1], eps)
%! assert (imadjust (im), imadjust (im, stretchlim (im, 0.01), [0; 1], 1))
%! assert (imadjust (im, []), imadjust (im, [0; 1], [0; 1], 1))
%! assert (imadjust (im, [], []), imadjust (im, [0; 1], [0; 1], 1))
%! assert (imadjust (im, [], [.25 .75]), imadjust (im, [0; 1], [.25; .75], 1))
%! assert (imadjust (im, [.25; .75], []), imadjust (im, [.25; .75], [0; 1], 1))

%!assert (imadjust (linspace (0, 1), [], [.25 .75]), linspace (.25, .75, 100))

## test with only input arg
%!assert (imadjust (linspace (0, 1, 100),[1/99; 98/99]),
%!        [0 linspace(0, 1, 98) 1], eps)

%!shared cm
%! cm = [[0:8]' [1:9]' [2:10]'] / 10;

## a colormap
%!assert (imadjust (cm, [0; 1], [0.5; 1]), (cm /2) + .5)
## with params in row
%!assert (imadjust (cm, [0 1], [0.5 1]), (cm /2) + .5)

## a colormap, different output adjustment on each channel
%!assert (imadjust (cm, [0; 1], [.1 .2 .3; .7 .8 .9]),
%!        (cm*.6) .+ [.1 .2 .3], eps)

## a colormap, different input adjustment on each channel
%!assert (imadjust (cm, [.2 .4 .6; .7 .8 .9], [0; 1]),
%!       [[0 0 linspace(0, 1, 6) 1]' ...
%!        [0 0 0 linspace(0, 1, 5) 1]' ...
%!        [0 0 0 0 linspace(0, 1, 4) 1]'], eps)

### a colormap, different input and output on each
%!assert (imadjust (cm, [.2 .4 .6; .7 .8 .9], [0 .1 .2; .8 .9 1]),
%!        [[0 0 linspace(0, .8, 6) .8]' ...
%!         [.1 .1 .1 linspace(.1, .9, 5) .9]' ...
%!         [.2 .2 .2 .2 linspace(.2, 1, 4) 1]'], eps)

## a colormap, different gamma, input and output on each
%!assert (imadjust (cm, [.2 .4 .6; .7 .8 .9], [0 .1 .2; .8 .9 1], [0.5 1 2]),
%!        [[0 0 0 (((([.3 .4 .5 .6]-.2)/.5).^.5)*.8) .8 .8]' ...
%!         [.1 .1 .1 linspace(.1, .9, 5) .9]' ...
%!         [.2 .2 .2 .2 .2  ((((([.7 .8]-.6)/.3).^2).*.8)+.2) 1 1]'], eps*10)

## Handling values outside the [0 1] range
%!test
%! im = [-0.4:.1:0.8
%!        0.0:.1:1.2
%!        0.1:.1:1.3
%!       -0.4:.2:2.0];
%!
%! ## just clipping
%! assert (imadjust (im, [0; 1], [0; 1]),
%!         [0 0 0 0 (0:.1:.8)
%!          (0:.1:1) 1 1
%!          (.1:.1:1) 1 1 1
%!          0 0 (0:.2:1) 1 1 1 1 1], eps)
%!
%! ## clipping and invert
%! assert (imadjust (im, [0; 1], [1; 0]),
%!         [1 1 1 1 (1:-.1:.2)
%!          (1:-.1:0) 0 0
%!          (.9:-.1:0) 0 0 0
%!          1 1 (1:-.2:0) 0 0 0 0 0], eps)
%!
%! ## rescale
%! assert (imadjust (im, [.2; .7], [.1; .9]),
%!         [1 1 1 1 1 1 1 2.6 4.2 5.8 7.4 9 9
%!          1 1 1 2.6 4.2 5.8 7.4 9 9 9 9 9 9
%!          1 1 2.6 4.2 5.8 7.4 9 9 9 9 9 9 9
%!          1 1 1 1 4.2 7.4 9 9 9 9 9 9 9]/10, eps)
%!
%! ## rescale and invert
%! assert (imadjust (im, [.2; .7], [.9; .1]),
%!         [9 9 9 9 9 9 9 7.4 5.8 4.2 2.6 1 1
%!          9 9 9 7.4 5.8 4.2 2.6 1 1 1 1 1 1
%!          9 9 7.4 5.8 4.2 2.6 1 1 1 1 1 1 1
%!          9 9 9 9 5.8 2.6 1 1 1 1 1 1 1]/10, eps)


%!shared oRGB
%! oRGB = zeros (10, 1, 3);
%! oRGB(:,:,1) = [0 linspace(0,1,6) 1 1 1]';
%! oRGB(:,:,2) = [0 0 linspace(0,1,6) 1 1]';
%! oRGB(:,:,3) = [0 0 0 linspace(0,1,6) 1]';

%!assert (imadjust (oRGB, [0; 1], [0; 1]), oRGB)

%!assert (imadjust (oRGB, [.2; .8], [0; 1]),
%!        reshape ([[0 0 0 1/3 2/3 1 1 1 1 1]'
%!                  [0 0 0 0 1/3 2/3 1 1 1 1]'
%!                  [0 0 0 0 0 1/3 2/3 1 1 1]'], [10 1 3]), eps)

%!assert (imadjust (oRGB, [.2; .8], [.1; .9]),
%!        reshape ([[.1 .1 .1 (1/3)+(.1/3) (2/3)-(.1/3) .9 .9 .9 .9 .9]'
%!                  [.1 .1 .1 .1 (1/3)+(.1/3) (2/3)-(.1/3) .9 .9 .9 .9]'
%!                  [.1 .1 .1 .1 .1 (1/3)+(.1/3) (2/3)-(.1/3) .9 .9 .9]'],
%!                 [10 1 3]), eps)

%!assert (imadjust (oRGB, [.2; .8], [.2; .8]),
%!        reshape ([[2 2 2 4 6 8 8 8 8 8]'
%!                  [2 2 2 2 4 6 8 8 8 8]'
%!                  [2 2 2 2 2 4 6 8 8 8]']/10, [10 1 3]), eps)

## aRGB, different output for each channel
%!assert (imadjust (oRGB, [0; 1], [.1 .2 .3; .9 .8 .7]),
%!        reshape ([[1 1 2.6 4.2 5.8 7.4 9 9 9 9]'
%!                  [2 2 2 3.2 4.4 5.6 6.8 8 8 8]'
%!                  [3 3 3 3 3.8 4.6 5.4 6.2 7 7]']/10, [10 1 3]), eps)

## a RGB, different input for each channel
%!assert (imadjust (oRGB, [.1 .2 .3; .9 .8 .7], [0; 1]),
%!        reshape ([[0 0 .125 .375 .625 .875 1 1 1 1]'
%!                  [0 0 0 0 1/3 2/3 1 1 1 1]'
%!                  [0 0 0 0 0 .25 .75 1 1 1]'], [10 1 3]), eps*10)

## a RGB, different input and output on each
%!assert (imadjust (oRGB, [.1 .2 .3; .9 .8 .7], [.2 0 .4; .5 1 .7 ]),
%!        reshape ([[.2 .2 .2375 .3125 .3875 .4625 .5 .5 .5 .5]'
%!                  [0 0 0 0 1/3 2/3 1 1 1 1]'
%!                  [.4 .4 .4 .4 .4 .475 .625 .7 .7 .7]'], [10 1 3]), eps)


## Test for ND dimensional images
%!test
%! img = rand (4, 4, 2, 3, 4);
%! adj = zeros (4, 4, 2, 3, 4);
%! for p = 1:2
%!   for q = 1:3
%!     for r = 1:4
%!       adj(:,:,p,q,r) = imadjust (img(:,:,p,q,r));
%!     endfor
%!   endfor
%! endfor
%! assert (imadjust (img), adj)

## Test for ND dimensional images with N dimensional arguments
%!test
%! img = rand (4, 4, 2, 3, 2);
%! adj = zeros (4, 4, 2, 3, 2);
%! in  = reshape ([ 3  5  7  9 11 13 15 17 19 21 23 25;
%!                 97 95 93 91 89 87 85 83 81 79 77 75] / 100, [2 2 3 2]);
%! out = reshape ([ 5  7  9 11 14 15 17 19 21 23 25 27;
%!                 95 93 91 89 87 85 83 81 79 77 75 73] / 100, [2 2 3 2]);
%! gamma = reshape (0.6:.1:1.7, [1 2 3 2]);
%! for p = 1:2
%!   for q = 1:3
%!     for r = 1:2
%!       adj(:,:,p,q,r) = imadjust (img(:,:,p,q,r), in(:,p,q,r),
%!                                  out(:,p,q,r), gamma(1,p,q,r));
%!     endfor
%!   endfor
%! endfor
%! assert (imadjust (img, in, out, gamma), adj)
