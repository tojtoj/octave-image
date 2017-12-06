## Copyright (C) 2017 Hartmut Gimpel <hg_code@gmx.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn   {Function File} {@var{centers} =} @ imfindcircles (@var{im}, @var{radius})
## @deftypefnx {Function File} {[@var{centers}, @var{radii}] =} @ imfindcircles (@var{im}, @var{RadiusRange})
## @deftypefnx {Function File} {[@var{centers}, @var{radii}, @var{strengths}] =} @ imfindcircles (@dots{})
## @deftypefnx  {Function File} {[@dots{}] =} @ imfindcircles (@dots{}, @var{property}, @var{value}, @dots{})
## Find circles in an image using the circular Hough transform.
##
## This function finds circles in a given 2d image @var{im}.
## The image data can be grayscale, rgb color or binary.
## The search is done only for circular shapes of approximatly
## the given @var{radius} (single value) or @var{RadiusRange}
## (a two element vector [r_min, r_max]).
##
## The output @var{centers} is a two column matrix,
## where each row contains the (fractional) x and y coordinates of
## the center of one found circle. The output rows are ordered
## according the @var{strengths} of the circles, the strongest
## circle first.
##
## The output @var{radii} is a column vector of the (fractional)
## radii of the found circles, in the same order as the circle centers.
## The output @var{strengths} is a measure of how "strong"
## the corresponding circle is. (A sharp, smooth and full circle gives
## roughly a value of one. The minimum value is zero.)
##
## Additionally the following optional property-value-pairs can be used:
## @table @var
## @item ObjectPolarity
## Either "bright" circles on darker background can be searched (default),
## or "dark" circles on brighter background.
##
## @item Method
## The default method "PhaseCode" is faster as the
## (currently unimplemented) method "TwoStage".
## For literature and details on the algorithm, see  comments
## in the code.
##
## @item Sensitivity
## A value between 0 and 1 to say how strong
## a circle must be in order to be found. With a value
## of 1 no circles are discarded, default value is 0.85.
## (Use bigger values of Sensitivity if your circles are
## not properly found, until unwanted "ghost" circles
## start to appear.)
##
## @item EdgeThreshold
## A value between 0 and 1 to say how strong
## an edge point of the image must be, to be
## considered as a possible point on a circle circumference.
## With a value of 0 all possible
## edge points are considered, with a value of 1 only the
## edge point with the stronges gradient will be considered.
## As default value the output of @code{graythresh} (Otsu's threshold)
## of the gradient image is taken.
## @end table
##
## Notes:
## @itemize @bullet
## @item
## Only center points inside the image region can be found.
## @item
## For concentric cirles the output is unpredictable.
## @item
## For optimal speed, keep the radius range and the image size
## as small as possible.
## @item
## For radius values above 100 pixels the sensitivity and accuracy
## of this algorithm starts to decrease.
## @item
## For big radius ranges the sensitivity decreases. Try to keep
## r_max < 3 * r_min .
## @item
## RGB color images will automatically be converted to grayscale
## using the @code{rgb2gray} function.
## @item
## Binary images will automatically be converted to grayscale
## and be slightly smoothed before processing.
## @end itemize
##
## Compatibility note: The @var{centers} and @var{radii} outputs
## have good compatibility to the Matlab outputs. The @var{strengths}
## outputs differ a bit, but have mostly the same ordering.
## Currently only the (default) Matlab algorithm "PhaseCode" is implemented
## in Octave.
##
## @seealso{hough, hough_circle}
## @end deftypefn

## Algorithm:
## The following papers and books were used for the
## implementation of this function:
##
## [1] (for general information on the circle Hough transform
##       and the basic algorithmic approach)
##       E. R. Davies: "Computer & Machine Vision"
##       Academic Press (2012), 4th edition
##       chapter 12 "Circle and Ellipse Detection"
## [2] (for the 'phase code' algorithm to search for a radius range
##        with just a 2-dimensional accumulator array)
##       T. J. Artherton and D. J. Kerbyson:
##       "Size invariant circle detection"
##       Image and Vision Computing 17 (1999), p. 795-803.
## [3] (for 'state of the art' peak finding in the circular Hough
##        transform accumulator array)
##       C. Zhang, F. Huber, M. Knop, F. A.  Hamprecht:
##       "Yest cell detection and segmentation in bright field microscopy"
##       IEEE Int. Symp. Biomed. Imag. (ISBI), April 2014, p. 1267-1270.
##
## A more detailed description of the individual steps of the
## algorithm is given in the following code itself.


function [centers, radii, strengths] = imfindcircles (im, radiusrange, varargin)

  ## retrieve the input parameters and set default values:
  if ((nargin < 2) || (nargin > 10) || any (nargin == [3:2:9]))
    print_usage ();
  endif

  p = inputParser ();
  p.addParamValue ("ObjectPolarity", "bright", @ischar);
  p.addParamValue ("Method", "PhaseCode", @ischar);
  p.addParamValue ("Sensitivity", 0.85, @(x) isnumeric (x) && isreal (x) && isscalar (x));
  p.addParamValue ("EdgeThreshold", [], @(x) isnumeric (x) && isreal (x) && isscalar (x));
  p.parse (varargin{:});
  polarity = p.Results.ObjectPolarity;
  method = p.Results.Method;
  sensitivity = p.Results.Sensitivity;
  edge_thresh = p.Results.EdgeThreshold; # default value for edge_thresh will be set lateron

  ## check input parameters:
  if (! isimage (im) || ! any (ndims (im) == [2, 3]))
    error ("imfindcircles: IM must be a logical or numeric 2d or 3d array");
  endif

  if (ndims (im) == 3)
    if (! size (im, 3) == 3)
      error ("imfindcircles: The 3d image IM must be a RGB image");
    endif
  endif

  if (! isnumeric (radiusrange) ||
       (! isscalar (radiusrange)) && ! all (size (radiusrange) == [1 2]))
    error ("imfindcircles: RADIUS must be a scalar number, or RADIUSRANGE a numeric vector of size 1-by-2");
  endif

  if ((numel (radiusrange) == 2) && (radiusrange(1,1) > radiusrange(1,2)))
    error ("imfindcircles: first value in RADIUSRANGE must be smaller than second value.")
  endif

  if (any (radiusrange <= 0))
    error ("imfindcircles: values of RADIUS or RADIUSRANGE must be positive.")
  endif

  if (! strcmpi(polarity, "bright") && ! strcmpi (polarity, "dark"))
    error ("imfindcirles: unknown value for parameter 'ObjectPolarity'");
  endif
  polarity = tolower (polarity);

  if (! strcmpi(method, "PhaseCode") && ! strcmpi (polarity, "TwoStage"))
    error ("imfindcirles: unknown value for parameter 'Method'");
  endif
  if (strcmpi (method, "TwoStage"))
    error ("imfindcirles: The 'TwoStage' method is not yet implemented. Try 'PhaseCode' instead.");
  endif
  method = tolower  (method);

  if (sensitivity < 0) || (sensitivity > 1))
    error ("imfindcircles: The value for the 'Sensitivity' parameter must be between 0 and 1");
  endif

  if (! isempty (edge_thresh))
    if (edge_thresh < 0) || (edge_thresh > 1))
      error ("imfindcircles: The value for the 'EdgeThreshold' parameter must be between 0 and 1");
    endif
  endif

  ## start the calculation:
  ## prepare the input image:
  if (isinteger (im))
    im = im2double (im);
  endif

  if (size (im, 3) == 3)
    im = rgb2gray (im);
  endif

  ## The Matlab help page mentions "preprocessing" of
  ## binary input images to "improve the accuracy".
  ## Unsure what they do here.
  ## We'll just do a little (carefully rotation symmetrical)
  ## smoothing as grayscale images, because we need
  ## the accurate gradient directions lateron. (This wouldn't
  ## work properly with the binary images itself.)
  if (islogical (im))
    im = im2double (im);
    gauss_filter = fspecial ("gaussian", [9 9], 1.5); # better version of a 3x3 box filter
    im = imfilter (im, gauss_filter, "replicate");
  endif

  ## calculate the gradient images:
  ## (using the Sobel operator, see ref. [1], chapter 12.2)
  ## (we'll always call the first coordinate "x" here)
  sobel_x = fspecial ("sobel");
  sobel_y = sobel_x';
  Gx = imfilter (im, sobel_x, "replicate");
  Gy = imfilter (im, sobel_y, "replicate");
  G = sqrt (Gx.^ 2 + Gy.^ 2); # sqrt is expensive, but yields higher angle precision
  Gmax = max (G(:));

  ## get rid of empty gradient images, they would cause trouble lateron:
  if (Gmax == 0)
    Ex = [];
    Ey = [];
  else

    ## find the edge pixels by thresholding the gradient image:
    # (This default value for EdgeThreshold is according to Matlab's help page.)
    if (isempty (edge_thresh))
      edge_thresh = graythresh (G ./ Gmax);
    endif
    [Ex, Ey] = find (G > (edge_thresh * Gmax)); # vectors with all edge pixel coordinates
  endif # empty G

  ## prepare relevant radius values:
  if (numel (radiusrange) == 1) # single circle radius
    R = radiusrange;
  else                                         # range of circle radii
    r1 = radiusrange(1, 1);
    r2 = radiusrange(1, 2);
    R = [r1:0.5:r2];      # step size of 0.5 covers all integer circle diameters
  endif

  ## code the circle polarity in the radius sign:
  ## (different direction of "spoke", see ref. [1], chapter 12.2)
  if (strcmpi (polarity, "dark"))
    R = -R;
  endif

  ## pre-calculate the phases and (complex) code values for all radii:
  ## We use the "log phase coding", which is best, according to ref. [2].
  ## (equations 8, 5 and 11 of ref. [2], in this order)
  ## (We use abs(R) here to treat negative R values identically.)
  if (numel (R) == 1)
    phase = 0; # phase coding is not useful for a single radius value
  else
    phase = 2 .* pi .* ( (log (abs (R)) - log (r1)) ./ (log (r2) - log (r1)) ); # eq. 8
  endif;
  code = exp ( i .* phase ); # eq. 5
  code = code ./ abs (R);   # eq. 11, radius normalization
  ## -> a full and perfect circle will give a value of 2pi in H

  ## pre-allocate the  accumulator array of the Hough transform
  ## (Matlab help says that circle centers outside the image region
  ##  cannot be found, so make it the same size as the image itself.)
  H = zeros (size (im));

  ## visit all edge pixels and generate
  ## a "spoke" in the circular Hough transform:
  ## A spoke is a line of pixels which are a distance r1 to r2
  ## away from the edge point, this distance is taken in
  ## the edge direction (gradient) of this very edge point.
  ## The resulting points on the spokes are candidates for circle
  ## center points. And each gradient pixel can vote for
  ## one center pixel candidate (for each radius value).
  ## All spoke points are summed up in the accumulator array H.
  ## (see equations 12.3 and 12.4 for xs and ys in ref. [1])
  ind_E = sub2ind (size (H), Ex, Ey);
  Gx0 = Gx(ind_E);
  Gy0 = Gy(ind_E);
  G0 = G(ind_E);
  ## generate stroke pixels (xs, ys):
  ## (This does not involve sin and cos calculations,
  ## which helps for speed, see ref. [1].)
  ## (Use Octave's automatic broadcasting here,
  ##  R is a row vector, the G's are column vectors.)
  xs = Ex - R .* (Gx0./G0);   # eq. 12.3
  ys = Ey - R .* (Gy0./G0);   # eq. 12.4
  codes = repmat (code, length (Ex), 1);
  ## round to integer pixel positions:
  xs = round (xs);
  ys = round (ys);
  ## reshape votes to a vector:
  xs = xs(:);
  ys = ys(:);
  codes = codes(:);
  ## limit pixel position and code values to the image size:
  H_sizex = size (H, 1);
  H_sizey = size (H, 2);
  idx_outside = ( (xs<1) | (xs>H_sizex) | (ys<1) | (ys>H_sizey) );
  xs(idx_outside) = [];
  ys(idx_outside) = [];
  codes(idx_outside) = [];
  ## add the code value of all those spoke pixels
  ## to the corresponding pixel position in H:
  H = H + accumarray([xs, ys], codes, size(H));

  ## Now we need to find local (regional) maximas in H,
  ## because they are the circle center pixels.
  ## This part of the algorithm is taken from ref. [3],
  ## section 2.2 "Detecting cell center candidates".

  ## take the absolute value of the complex H accumulator array
  Habs = abs(H);

  ## do some smoothing before searching for peak positions
  ## use a (rotation symmetric) gaussian filter for this (see ref. [3])
  gauss_filter = fspecial ("gaussian", [9 9], 2);  # a bigger filter might join nearby centers
  Habs = imfilter (Habs, gauss_filter, 0); # introduces small shifts of centers near the edge,
                                                                # but padding "replicate" would be worse

  ## define threshold to suppress smaller peaks in Habs:
  peak_thresh = 1 - sensitivity;
  peak_thresh *= 2*pi; # because a full circle can add up to 2pi in H

  ## use the h-maxima transform to suppress maximas with a too low height:
  Hbig = imhmax (Habs, peak_thresh);

  ## find the regional maxima of those smoothed big peaks in H:

  Hmax_BW = imregionalmax (Hbig./max(Hbig(:)));

  ## Use those maxima as well as their surrounding peak
  ## to calculate a weighted average for the peak position:
  ## (This gives the circle center positions with the necessary
  ## subpixel accuracy.)
  props = regionprops (Hmax_BW, Hbig, "WeightedCentroid");
  centers = cell2mat ({props.WeightedCentroid}');

  ## for the "strength" return value, take the (smoothed) Habs:
  ## (Matlab seems to do this a bit different.)
  centers_ind = sub2ind (size (Habs), round (centers(:,2)), round (centers(:,1)));
  strengths = Habs(centers_ind) ./ (2*pi); % normalize a "full" circle to 1 (as Matlab does)

  ## calculate the circle radius from the complex phase in H:
  ## (i.e. undo the phase coding from above)
  if (numel (R) == 1)
    radii = repmat (R, 1, length (strengths));
  else
    c_phase = arg (H(centers_ind));
    c_phase(c_phase < 0) += (2*pi);
    radii = exp (( c_phase ./ (2*pi) .* (log (r2) - log (r1)) ) + log (r1));
  endif

  ## sort all return values by the strengths value:
  [strengths, idx_sorted] = sort (strengths, "descend");
  radii = radii(idx_sorted);
  centers = centers (idx_sorted, :);

endfunction

%!shared im0, rgb0, im1
%! im0 = [0 0 0 0 0;
%!             0 1 2 1 0;
%!             0 2 5 2 0;
%!             0 1 2 1 0;
%!             0 0 0 0 0];
%! rgb0 = cat (3, im0, 3.*im0, 2.*im0);
%! im1 = zeros (20);
%! im1(2:6, 5:9) = 1;
%! im1(13:19, 13:19) = 1;

%!function image = circlesimage (numx, numy, centersx, centersy, rs, values)
%!  ## create an image with circles of given parameters
%!  num = length (centersx);
%!  image = zeros (numy, numx);
%!  [indy, indx] = meshgrid (1:numx, 1:numy);
%!  for n = 1:num
%!    centerx = centersx(n);
%!    centery = centersy(n);
%!    r = rs(n);
%!    value = values(n);
%!    dist_squared = (indx - centerx).^ 2 + (indy - centery).^ 2;
%!    image(dist_squared <= (r-0.5)^2) = value;
%!  endfor
%!endfunction


## test input syntax:
%!error imfindcircles ()
%!error imfindcircles (im0)
%!assert (imfindcircles (im0, 2))
%!assert (imfindcircles (im0, [1 2]))
%!assert (imfindcircles (logical (im0), 2))
%!assert (imfindcircles (logical (im0), [1 2]))
%!assert (imfindcircles (rgb0, 2))
%!assert (imfindcircles (rgb0, [1 2]))
%!assert (imfindcircles (uint8 (im0), 2))
%!assert (imfindcircles (uint8 (im0), [1 2]))
%!error imfindcircles (im0, [1 2 3])
%!error imfindcircles (im0, -3)
%!error imfindcircles (im0, 4+2*i)
%!error imfindcircles (ones (5,5,4), 2)
%!error imfindcircles (ones (5,5,5,5), 2)
%!error imfindcircles (im0, [2 1])
%!error imfindcircles (im0, 2, "rubbish")
%!error imfindcircles (im0, 2, "more", "rubbish")
%!assert (imfindcircles (im0, 2, "ObjectPolarity", "bright"))
%!assert (imfindcircles (im0, 2, "ObjectPolarity", "dark"))
%!error imfindcircles (im0, 2, "ObjectPolarity", "rubbish")
%!error imfindcircles (im0, 2, "ObjectPolarity", 5)
%!error imfindcircles (im0, 2, "ObjectPolarity")
%!assert (imfindcircles (im0, 2, "Method", "PhaseCode"))
%!error imfindcircles (im0, 2, "Method", "rubbish")
%!error imfindcircles (im0, 2, "Method", 5)
%!error imfindcircles (im0, 2, "Method")
%!assert (imfindcircles (im0, 2, "Sensitivity", 0.5))
%!error imfindcircles (im0, 2, "Sensitivity", "rubbish")
%!error imfindcircles (im0, 2, "Sensitivity")
%!error imfindcircles (im0, 2, "Sensitivity", -0.1)
%!error imfindcircles (im0, 2, "Sensitivity", 1.1)
%!error imfindcircles (im0, 2, "Sensitivity", [0.1 0.2])
%!assert (imfindcircles (im0, 2, "EdgeThreshold", 0.5))
%!error imfindcircles (im0, 2, "EdgeThreshold", "rubbish")
%!error imfindcircles (im0, 2, "EdgeThreshold")
%!error imfindcircles (im0, 2, "EdgeThreshold", -0.1)
%!error imfindcircles (im0, 2, "EdgeThreshold", 1.1)
%!error imfindcircles (im0, 2, "EdgeThreshold", [0.1 0.2])
%!assert (imfindcircles (im0, 2, "ObjectPolarity", "bright", "Method", "PhaseCode"))
%!assert (imfindcircles (im0, 2, "ObjectPolarity", "bright", "Sensitivity", 0.3, "Method", "PhaseCode"))
%!assert (imfindcircles (im0, 2, "EdgeThreshold", 0.1, "ObjectPolarity", "bright", "Sensitivity", 0.3, "Method", "PhaseCode"))
%!error imfindcircles (im0, 2, "EdgeThreshold", 0.1, "ObjectPolarity", "bright", "Sensitivity", 0.3, "Method", "PhaseCode", "more", 1)


## output class, number and shape:
%!test
%! centers = imfindcircles (im1, 2);
%! assert (size (centers, 2), 2)
%! assert (class (centers), "double")

%!test
%! [centers, radii] = imfindcircles (im1, [1 5]);
%! assert (size (centers, 2), 2)
%! assert (size (radii, 2), 1)
%! assert (class (radii), "double")

%!test
%! [centers, radii, strengths] = imfindcircles (im1, [1 5]);
%! assert (size (strengths, 2), 1)
%! assert (class (strengths), "double")

%!error [a b c d] = imfindcircles (im0, 2);


## test calculation results:
%!test   ## sub-pixel accuracy of circle center
%! xs = [95.7];
%! ys = [101.1];
%! rs = [50];
%! vals = [0.5];
%! im = circlesimage (200, 200, xs, ys, rs, vals);
%! filt = ones (3) ./ 9;
%! im = imfilter (im, filt);
%! [centers, radii] = imfindcircles (im, [40 60]);
%! assert (centers, [101.1, 95.7], 0.1);
%! assert (radii, 50, 1);

%!test
%! ## specificity to circular shapes and strengths output value
%! xs = [100 202];
%! ys = [101, 203];
%! rs = [40, 41];
%! vals = [0.8, 0.9];
%! im = circlesimage (300, 300, xs, ys, rs, vals);
%! filt = ones (3) ./ 9;
%! im = imfilter (im, filt);
%! im(30:170, 50:100) = 0;
%! im(20:120, 180:280) = 1;
%! [centers, radii, strengths] = imfindcircles (im, [30 50], 'Sensitivity', 0.9);
%! assert (size (centers), [2 2]);
%! assert (centers, [203, 202; 101, 100], 1.5);
%! assert (radii, [40; 41], 2.5);
%! assert (strengths(1) / strengths(2) > 1.8, true);

%!test
%! ## radius range parameter &  dark circles
%! xs = [50, 420, 180];
%! ys = [80, 100, 200];
%! rs = [35, 30, 40];
%! vals = [0.7, 0.8, 0.9];
%! im = circlesimage (300, 500, xs, ys, rs, vals);
%! filt = ones (3) ./ 9;
%! im = imfilter (im, filt);
%! [centers1, radii1] = imfindcircles (im, [28 36]);
%! [centers2, radii2] = imfindcircles (im, [28 42]);
%! assert (size (centers1), [2 2]);
%! assert (centers1, [100 420; 80 50], 0.2);
%! assert (radii1, [30; 35], 2);
%! assert (size (centers2), [3 2]);
%! im_dark = 1-im;
%! [centers_dark, radii_dark, strengths_dark] = imfindcircles (im_dark, [25 42], "ObjectPolarity", "dark");
%! assert (sortrows (centers_dark), [80 50; 100 420; 200 180], 0.2);
%! assert (sortrows (radii_dark), [30; 35; 40], 1);

%!test
## ability to find circles with big radius
%! xs = [111, 555, 341];
%! ys = [222, 401, 161];
%! rs = [45, 50, 150];
%! vals = [0.6, 0.8, 0.7];
%! im = circlesimage (400, 701, xs, ys, rs, vals);
%! [centers, radii] = imfindcircles (im, [140 160], "Sensitivity", 0.98);
%! assert (centers, [161, 341], 0.2);
%! assert (radii, 150, 1);

%!test       ## overlapping circles
%! xs = [105, 155];
%! ys = [202, 221];
%! rs = [45, 50];
%! vals = [0.5, 0.8];
%! im = circlesimage(385, 422, xs, ys, rs, vals);
%! filt = ones (3) ./ 9;
%! im = imfilter (im, filt);
%! [centers, radii] = imfindcircles (im, [30 80]);
%! assert (centers, [221, 155; 202, 105], 0.5);
%! assert (radii, [50; 45], 1);

%!test     ## overlapping circles, only 10 pixels apart
%! xs = [155, 155];
%! ys = [175, 157];
%! rs = [50, 50];
%! vals = [0.7, 0.8];
%! im = circlesimage (300, 300, xs, ys, rs, vals);
%! filt = ones (3) ./ 9;
%! im = imfilter (im, filt);
%! [centers, radii] = imfindcircles (im, [30 80], "Sensitivity", 0.95);
%! assert (centers, [157, 155; 175, 155], 1);
%! assert (radii, [50; 50], 1);

%!test         ## edge threshold parameter
%! xs = [100 202];
%! ys = [101, 203];
%! rs = [40, 41];
%! vals = [0.1, 0.9];
%! im = circlesimage (300, 300, xs, ys, rs, vals);
%! filt = ones (3) ./ 9;
%! im= imfilter (im, filt);
%! [centers_auto, radii_auto] = imfindcircles (im, [30 50]);
%! [centers_0, radii_0] = imfindcircles (im, [30 50], "EdgeThreshold", 0);
%! [centers_05, radii_05] = imfindcircles (im, [30 50], "EdgeThreshold", 0.5);
%! assert (centers_auto, [203, 202], 0.2);
%! assert (radii_auto, 41, 1);
%! assert (centers_0, [101, 100; 203, 202], 0.2);
%! assert (radii_0, [40; 41], 1);
%! assert (centers_05,  [203, 202], 0.2);
%! assert (radii_05, 41, 1);


## show demo of the functionality:
%!demo
%! ## generate the input image:
%! n=400;
%! im = zeros (n);
%! [indx, indy] = meshgrid (1:n, 1:n);
%! dist_a = sqrt ( (indx - 105).^ 2 + (indy - 122).^ 2 );
%! im(dist_a <= 55) = 0.7;
%! dist_b = sqrt ( (indx - 280).^ 2 + (indy - 300).^ 2 );
%! im(dist_b <= 80) = 0.8;
%! im(370:end,:) = 0;
%! filt = ones (3)./9;
%! im = imfilter (im, filt);
%! for m=50:150
%!   im(m:m+1, round (1.3*m)) = 0.9;
%!   im(n-m:(n-m)+1, round(0.8*(m-20))) = 0.9;
%! endfor
%! im(50:150, 250:350) = 0.9;
%! im = imnoise (im, "salt & pepper");
%! figure, imshow (im);
%! title ("input image");
%!
%! ## search the circles:
%! radius_range = [50, 100];
%! [centers,radii,strengths] = imfindcircles (im, radius_range)
%!
%! ## visualize the found circles in the image:
%! figure;
%! imshow (im);
%! viscircles (centers, radii);
