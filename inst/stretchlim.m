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
## @deftypefn  {Function File} {} stretchlim (@var{I})
## @deftypefnx {Function File} {} stretchlim (@var{RGB})
## @deftypefnx {Function File} {} stretchlim (@dots{}, @var{tol})
## Find limits to contrast stretch an image.
##
## Returns a 2 element column vector, @code{[@var{low}; @var{high}]},
## with the pair of intensities to contrast stretch @var{I} which
## saturates at most @var{tol} of the image.  The output of this
## function matches the input expected by @code{imadjust}.
##
## The input argument @var{tol}, controls the fraction of the image to be
## saturated and defaults to @code{[0.01 0.99]}, i.e., a 1% saturation
## on both sides of the image histogram.  It can be specified in two ways:
##
## @itemize
## @item a two element vector with lower and higher fraction of the
## the image to be saturated.  These values must be in the range
## [0 1], the display range of images of floating point class.
##
## @item a scalar value with the fraction of image to be saturated on
## each side; e.g., a @var{tol} with a value of @code{0.05} is equivalent
## to @code{[0.05 0.95]}.  This value must be in the range @code{[0 0.5]}.
##
## @end itemize
##
## A common use case wanting to maximize contrast without causing any
## saturation.  In such case @var{tol} should be 0 (zero).  It is the
## equivalent to @code{[min(@var{I}(:)); max(@var{I}(:))]} for a single
## plane.
##
## The return values are of class double and in the range [0 1] regardless
## of the input image class.  These values are scaled in the image class
## range (see @code{im2double}).
##
## If the input is a RGB image, i.e., the 3rd dimension has length 3, then
## it returns a @code{[2 3]} matrix with separate limits for each colour.
## It will actually do this for each plane, so an input of size,
## @code{[M N P]} will return a @code{[2 P]} matrix.
##
## Note the detail that @var{tol} is the maximum fraction of saturation.
## It is rare that there is a value for that exact saturation.  In such
## case, @code{stretchlim} will always round down and saturate less.
## @var{tol} is the saturation limit.  For example, if @var{tol} is
## @code{0.10}, but there are only values that will lead to 5 or 11%
## saturation, it will return the value for a 5% saturation.
##
## @seealso{brighten, contrast, histeq, imadjust}
## @end deftypefn

function low_high = stretchlim (img, tol = [0.01 0.99])

  if (nargin () <1 || nargin () > 2)
    print_usage ();
  endif

  if (! isimage (img))
    error("stretchlim: I or RGB must be an image");
  endif

  ## Handle tol
  if (nargin > 1)
    if (! isnumeric (tol))
      error ("stretchlim: TOL must be numeric");
    endif

    if (isscalar (tol))
      if (min (tol) < 0 || max (tol) > 0.5)
        error ("stretchlim: TOL must be in the [0 1] range");
      endif
      tol = [tol (1-tol)];

    elseif (isvector (tol))
      if (numel (tol) != 2)
        error ("stretchlim: TOL must be a 2 element vector");
      endif
    endif
  endif

  if (ndims (img) > 3)
    error ("stretchlim: I must can only have 3 dimensions at most");
  endif

  ## tol is about the percentage of values that will be saturated.
  ## So instead of percentages, we convert to the actual number of
  ## pixels that need to be saturated.  After sorting the values in
  ## the image, that number of pixels simply becomes the index for
  ## the limits.
  ##
  ## Note that the actual intensity value that we set the limits to,
  ## is not saturated.  Only the values below or above the lower and
  ## higher limits it will be considered saturated.
  ##
  ## And since most images will have repeated values in the pixels,
  ## chances are that there's not a limit that would cause only the
  ## exact percentage of pixels to be saturated.  In such cases, we
  ## must prefer a limit that would saturate less pixels than the
  ## requested, rather than the opposite.
  ##
  ## We want to compute this for each plane, so we reshape the image
  ## in order to have each plane into a single column, while respecting
  ## any other dimensions beyond the 3rd.

  sz = size (img);
  np = size (img, 3);
  plane_length = sz(1) * sz(2);

  img = reshape (img, plane_length, []);

  lo_idx = floor (tol(1) * plane_length) + 1;
  hi_idx = ceil (tol(2) * plane_length);

  if (lo_idx == 1 && hi_idx == plane_length)
    ## special case, equivalent to tol [0 1], even if tol was not
    ## actually [0 1] but the image size would effectively make it.
    low_high = [min(img, [], 1); max(img, [], 1)];
  else
    lo_hi_idx = [lo_idx; hi_idx] .+ (0:plane_length:(numel(img)-1));
    sorted = sort (img, 1);
    low_high = sorted(lo_hi_idx);
  endif

  low_high = im2double (low_high);
endfunction

%!error (stretchlim ());
%!error (stretchlim ("bad parameter"));
%!error (stretchlim (zeros (10, 10, 3, 2)));
%!error (stretchlim (zeros (10, 10), "bad parameter"));
%!error (stretchlim (zeros (10, 10), 0.01, 2));

## default parameters
%!assert (stretchlim (0.01:.01:1), [0.02; 0.99])
%!assert (stretchlim (0.01:.01:1), stretchlim (0.01:.01:1, [0.01 0.99]))

## use scalar for tol
%!assert (stretchlim (0.01:.01:1, 0.15), stretchlim (0.01:.01:1, [0.15 0.85]))

## this is different than Matlab but it looks like it's a Matlab bug
## (Matlab returns [0.018997482261387; 0.951003280689708])
## We actually have differences from Matlab which sometimes returns
## values that are not present in the image.
%!assert (stretchlim (0.01:.01:1, [0.01,0.95]), [0.02; 0.95], eps)

## corner case of zero tolerance
%!assert (stretchlim (0.01:.01:1, 0), [0.01; 1])

%!test
%! im = rand (5);
%! assert (stretchlim (im, 0), [min(im(:)); max(im(:))])

%!test
%! im = rand (5, 5, 3);
%! assert (stretchlim (im, 0),
%!         [min(im(:,:,1)(:)) min(im(:,:,2)(:)) min(im(:,:,3)(:));
%!          max(im(:,:,1)(:)) max(im(:,:,2)(:)) max(im(:,:,3)(:))])


## corner case where tol is not zero but the image is so small that
## it might as well be.
%!test
%! im = rand (5);
%! assert (stretchlim (im, 0.03), [min(im(:)); max(im(:))])
%! assert (stretchlim (im, 0.0399), [min(im(:)); max(im(:))])


## Test with non double data-types
%!assert (stretchlim (uint8 (1:100)), im2double (uint8 ([2; 99])))
%!assert (stretchlim (uint8 (1:100), .25), im2double (uint8 ([26; 75])))
%!assert (stretchlim (uint16  (1:1000)), im2double (uint16 ([11; 990])))

%!assert (stretchlim (int16 (-100:100)), im2double (int16 ([-98; 98])))
%!assert (stretchlim (single (0.01:.01:1)),
%!         double (single (0.01:.01:1)([2; 99])).')


## non uniform histogram tests
%!assert (stretchlim (uint8 ([1 repmat(2, [1, 90]) 92:100]), 0.05),
%!        im2double (uint8 ([2; 95])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 4]) 6:100]), 0.05),
%!        im2double (uint8 ([6; 95])))

## test limit rounding (actually, lack of rounding, we always round down)
## Note that this tests were different in the image package before v2.6.
## Back then we performed rounding of the fraction that was saturated.
%!assert (stretchlim (uint8 ([1 repmat(2, [1 5]) 7:100]), 0.05),
%!        im2double (uint8 ([2; 95])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 6]) 8:100]), 0.05),
%!        im2double (uint8 ([2; 95])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 7]) 9:100]), 0.05),
%!        im2double (uint8 ([2; 95])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 8]) 10:100]), 0.05),
%!        im2double (uint8 ([2; 95])))

%!assert (stretchlim (uint8 ([1 repmat(2, [1 5]) repmat(3, [1 5]) 9:100]), 0.04),
%!        im2double (uint8 ([2; 96])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 5]) repmat(3, [1 5]) 9:100]), 0.05),
%!        im2double (uint8 ([2; 95])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 5]) repmat(3, [1 5]) 9:100]), 0.06),
%!        im2double (uint8 ([3; 94])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 5]) repmat(3, [1 5]) 9:100]), 0.07),
%!        im2double (uint8 ([3; 93])))
%!assert (stretchlim (uint8 ([1 repmat(2, [1 5]) repmat(3, [1 5]) 9:100]), 0.08),
%!        im2double (uint8 ([3; 92])))

## test RGB
%!test
%! RGB = zeros (100, 1, 3, "uint16");
%! RGB(:,:,1) = [1:1:100];
%! RGB(:,:,2) = [2:2:200];
%! RGB(:,:,3) = [4:4:400];
%! assert (stretchlim (RGB) , im2double (uint16 ([2 4 8; 99 198 396])))

## test other 3D lengths
%!test
%! im6c = zeros (100, 1, 6, "uint16");
%! im6c(:,:,1) = [1:1:100];
%! im6c(:,:,2) = [2:2:200];
%! im6c(:,:,3) = [4:4:400];
%! im6c(:,:,4) = [8:8:800];
%! im6c(:,:,5) = [16:16:1600];
%! im6c(:,:,6) = [32:32:3200];
%! assert (stretchlim (im6c) ,
%!         im2double (uint16 ([2 4 8 16 32 64; 99 198 396 792 1584 3168])))

%!test
%! im = [0 0 .1 .1 .1 .1 .2 .2 .2 .4 .4 .6 .6 .7 .7 .9 .9 .9 1 1];
%!
%! assert (stretchlim (im), [0; 1])
%!
%! ## Consider the returned lower limit in this test.  A lower limit
%! ## of 0.1 will saturate two elements (10%), while 0.2 will saturate
%! ## 6 elements (30%).  Both have the same distance to 20% but returning
%! ## 0.1 is Matlab compatible.
%! ## Now looking at the higher limit.  A limit of .9 will saturate
%! ## 2 elements (10%), while a limit of 0.7 will saturate 5 elements (25%).
%! ## However, for Matlab compatibility we must return .9 even though
%! ## 25% would be closer to 20%.
%! ## Basically, it's not just rounded.
%! assert (stretchlim (im, .2),  [0.1; 0.9])
%!
%! assert (stretchlim (im, .15), [0.1; 0.9])
%! assert (stretchlim (im, .1),  [0.1; 0.9])
%! assert (stretchlim (im, .25), [0.1; 0.7])
%!
%! ## Reorder the vector of values (real images don't have the values
%! ## already sorted), just to be sure it all works.
%! im([6 3 16 11 7 17 14 8 5 19 15 1 2 4 18 13 9 20 10 12]) = im;
%! assert (stretchlim (im, .2),  [0.1; 0.9])
%! assert (stretchlim (im, .15), [0.1; 0.9])
%! assert (stretchlim (im, .1),  [0.1; 0.9])
%! assert (stretchlim (im, .25), [0.1; 0.7])

## odd length images to test rounding of saturated fraction.  With a 1%
## fraction to be saturated and 991 elements, that's 9.91 pixels.  Since
## TOL is the limit, we must saturate the top and bottom 9 pixels (not 10).
%!assert (stretchlim (0.01:.001:1), [0.019; 0.991], eps)
%!assert (stretchlim (0.01:.001:1, [0.01,0.95]), [0.019; 0.951], eps)
%!assert (stretchlim (0.01:.001:1, 0), [0.01; 1])
%!assert (stretchlim (single (0.01:.001:1)),
%!         double (single (0.01:.001:1)([10; 982])).')
