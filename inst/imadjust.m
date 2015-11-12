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
## @code{J=imadjust(I)} adjusts intensity image @var{I} values so that
## 1% of data on lower and higher values (2% in total) of the image is
## saturated; choosing for that the corresponding lower and higher
## bounds (using @code{stretchlim}) and mapping them to 0 and 1. @var{J}
## is an image of the same size as @var{I} which contains mapped values.
## This is equivalent to @code{imadjust(I,stretchlim(I))}.
##
## @code{J=imadjust(I,[low_in;high_in])} behaves as described but uses
## @var{low_in} and @var{high_in} values instead of calculating them. It
## maps those values to 0 and 1; saturates values lower than first limit
## to 0 and values higher than second to 1; and finally maps all values
## between limits linearly to a value between 0 and 1. If @code{[]} is
## passes as @code{[low_in;high_in]} value, then @code{[0;1]} is taken
## as a default value.
##
## @code{J=imadjust(I,[low_in;high_in],[low_out;high_out])} behaves as
## described but maps output values between @var{low_out} and
## @var{high_out} instead of 0 and 1. A default value @code{[]} can also
## be used for this parameter, which is taken as @code{[0;1]}.
##
## @code{J=imadjust(@dots{},gamma)} takes, in addition of 3 parameters
## explained above, an extra parameter @var{gamma}, which specifies the
## shape of the mapping curve between input elements and output
## elements, which is linear (as taken if this parameter is omitted). If
## @var{gamma} is above 1, then function is weighted towards lower
## values, and if below 1, towards higher values.
##
## @code{newmap=imadjust(map,@dots{})} applies a transformation to a
## colormap @var{map}, which output is @var{newmap}. This transformation
## is the same as explained above, just using a map instead of an image.
## @var{low_in}, @var{high_in}, @var{low_out}, @var{high_out} and
## @var{gamma} can be scalars, in which case the same values are applied
## for all three color components of a map; or it can be 1-by-3
## vectors, to define unique mappings for each component.
##
## @code{RGB_out=imadjust(RGB,@dots{})} adjust RGB image @var{RGB} (a
## M-by-N-by-3 array) the same way as specified in images and colormaps.
## Here too @var{low_in}, @var{high_in}, @var{low_out}, @var{high_out} and
## @var{gamma} can be scalars or 1-by-3 matrices, to specify the same
## mapping for all planes, or unique mappings for each.
##
## The formula used to realize the mapping (if we omit saturation) is:
##
## @code{J = low_out + (high_out - low_out) .* ((I - low_in) / (high_in - low_in)) .^ gamma;}
##
## @strong{Compatibility notes:}
##
## @itemize @bullet
## @item
## Prior versions of imadjust allowed @code{[low_in; high_in]} and
## @code{[low_out; high_out]} to be row vectors. Compatibility with this
## behaviour has been kept, although preferred form is vertical vector
## (since it extends nicely to 2-by-3 matrices for RGB images and
## colormaps).
## @item
## Previous version of imadjust, if @code{low_in>high_in} it "negated" output.
## Now it is negated if @code{low_out>high_out}, for compatibility with
## MATLAB.
## @item
## Class of @var{I} is not considered, so limit values are not
## modified depending on class of the image, just treated "as is". When
## Octave 2.1.58 is out, limits will be multiplied by 255 for uint8
## images and by 65535 for uint16 as in MATLAB.
## @end itemize
## 
## @seealso{stretchlim, brighten}
## @end deftypefn

function adj = imadjust (img, in, out = [0; 1], gamma = 1)

  if (nargin () < 1 || nargin () > 4)
    print_usage ();
  endif

  if (! isimage (img))
    error ("imadjust: I, RGB, or CMAP must be an image or a colormap");
  endif

  sz = size (img);
  if (numel (sz) == 2 && sz(2) == 3 && isa (img, "double"))
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
%!assert (sum (abs ((imadjust (linspace (0, 1, 100),[1/99; 98/99])
%!                   - [0 linspace(0, 1, 98) 1])(:))) < 1e-10)

## a test with input and output args
%!assert (imadjust ([1:100], [50; 90],[-50; -30]),
%!       [-50*ones(1,49), linspace(-50,-30,90-50+1), -30*ones(1,10)])

## a test with input and output args in a row vector (Compatibility behaviour)
%!assert (imadjust ([1:100], [50; 90],[-50; -30]),
%!        [repmat(-50, [1 49]) linspace(-50, -30, 90-50+1) repmat(-30, [1 10])])

## the previous test, "negated"
%!assert (imadjust ([1:100], [50; 90],[-30; -50]),
%!        [repmat(-30, [1 49]) linspace(-30, -50, 90-50+1) repmat(-50, [1 10])])

%!shared cm,cmn
%! cm = [[1:10]' [2:11]' [3:12]'];
%! cmn = ([[1:10]' [2:11]' [3:12]'] -1)/11;

## a colormap
%!assert (imadjust (cmn, [0; 1], [10; 11]), cmn+10)

## a colormap with params in row (Compatibility behaviour)
%!assert (imadjust (cmn, [0 1], [10 11]), cmn+10)

## a colormap, different output on each
%!assert (imadjust (cmn, [0; 1], [10 20 30; 11 21 31]),
%!        cmn + repmat ([10 20 30], 10, 1))

## a colormap, different input on each
%!assert (imadjust (cm, [2 4 6; 7 9 11], [0; 1]),
%!       [[0 linspace(0, 1, 6) 1 1 1]' ...
%!        [0 0 linspace(0, 1, 6) 1 1]' ...
%!        [0 0 0 linspace(0, 1, 6) 1]'], eps)

## a colormap, different input and output on each
%!assert (imadjust (cm, [2 4 6; 7 9 11], [0 1 2; 1 2 3]),
%!        [[0 linspace(0, 1, 6) 1 1 1]' ...
%!         [0 0 linspace(0, 1, 6) 1 1]'+1 ...
%!         [0 0 0 linspace(0, 1, 6) 1]'+2], eps)

## a colormap, different gamma, input and output on each
%!assert (imadjust (cm, [2 4 6; 7 9 11], [0 1 2; 1 2 3], [1 2 3]),
%!        [[0 linspace(0, 1, 6) 1 1 1]' ...
%!         [0 0 linspace(0, 1, 6).^2 1 1]'+1 ...
%!         [0 0 0 linspace(0, 1, 6).^3 1]'+2], eps)

%!shared iRGB,iRGBn,oRGB
%! iRGB = zeros (10 ,1, 3);
%! iRGB(:,:,1) = [1:10]';
%! iRGB(:,:,2) = [2:11]';
%! iRGB(:,:,3) = [3:12]';
%! iRGBn = (iRGB-1) /11;
%! oRGB = zeros (10, 1, 3);
%! oRGB(:,:,1) = [0 linspace(0,1,6) 1 1 1]';
%! oRGB(:,:,2) = [0 0 linspace(0,1,6) 1 1]';
%! oRGB(:,:,3) = [0 0 0 linspace(0,1,6) 1]';

## a RGB image
%!assert (imadjust (iRGBn, [0; 1], [10; 11]), iRGBn+10)

## a RGB image, params in row (compatibility behaviour)
%!assert (imadjust (iRGBn, [0 1], [10 11]), iRGBn+10)

## a RGB, different output on each
%!test
%! t = iRGBn;
%! t(:,:,1) += 10;
%! t(:,:,2) += 20;
%! t(:,:,3) += 30;
%! assert (imadjust (iRGBn, [0; 1], [10 20 30; 11 21 31]), t)

## a RGB, different input on each, we need increased tolerance for this test
%!assert (imadjust (iRGB, [2 4 6; 7 9 11], [0; 1]), oRGB, eps)

## a RGB, different input and output on each
%!test
%! t = oRGB;
%! t(:,:,2) += 1;
%! t(:,:,3) += 2;
%! assert (imadjust (iRGB, [2 4 6; 7 9 11], [0 1 2;1 2 3]), t, eps)

## a RGB, different gamma, input and output on each
%!test
%! t = oRGB;
%! t(:,:,2) = t(:,:,2).^2+1;
%! t(:,:,3) = t(:,:,3).^3+2;
%! assert (imadjust (iRGB, [2 4 6; 7 9 11], [0 1 2; 1 2 3], [1 2 3]), t, eps)

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
