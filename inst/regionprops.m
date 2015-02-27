## Copyright (C) 2010 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2012 Jordi Gutiérrez Hermoso <jordigh@octave.org>
## Copyright (C) 2015 Hartmut Gimpel <hartmut.gimpel@gmx.net>
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
## @deftypefn  {Function File} {@var{props} = } regionprops (@var{BW})
## @deftypefnx {Function File} {@var{props} = } regionprops (@var{BW}, @var{properties}, @dots{})
## @deftypefnx {Function File} {@var{props} = } regionprops (@var{L}, @var{properties}, @dots{})
## @deftypefnx {Function File} {@var{props} = } regionprops (@dots{}, @var{I}, @var{properties}, @dots{})
## Compute object properties in a binary image.
##
## @code{regionprops} computes various properties of the individual objects (as
## identified by @code{bwlabel}) in the binary image @var{BW}. The result is a
## structure array containing an entry per property per object.
##
## The optional grayscale image @var{I} is used for pixel value measurements
## (MaxIntensity, MinIntensity, MeanIntensity, PixelValues and WeightedCentroid).
##
## The following properties can be computed:
##
## @table @asis
## @item "Area"
## The number of pixels in the object.
##
## @item "BoundingBox"
## @itemx "bounding_box"
## The bounding box of the object. This is represented as a 4-vector where the
## first two entries are the @math{x} and @math{y} coordinates of the upper left
## corner of the bounding box, and the two last entries are the width and the
## height of the box.
##
## @item "Centroid"
## The center coordinate of the object.
##
## @item "Eccentricity"
## A scalar value between o and 1 defining how round the region is.  The
## region is fitted to an ellipse, so this value is the ratio between the
## @code{MajorAxisLength} and @code{MinorAxisLength}.
##
## @item "EulerNumber"
## @itemx "euler_number"
## The Euler number of the object (see @code{bweuler} for details).
##
## @item "Extent"
## The area of the object divided by the area of the bounding box.
##
## @item "FilledArea"
## @itemx "filled_area"
## The area of the object including possible holes.
##
## @item "FilledImage"
## @itemx "filled_image"
## A binary image with the same size as the object's bounding box that contains
## the object with all holes removed.
##
## @item "Image"
## An image with the same size as the bounding box that contains the original
## pixels.
##
## @item "MajorAxisLength"
## The region is fitted to an ellipse so this value represents the length
## of the major axis of the ellipse.
##
## @item "MaxIntensity"
## @itemx "max_intensity"
## The maximum intensity inside the object.
##
## @item "MeanIntensity"
## @itemx "mean_intensity"
## The mean intensity inside the object.
##
## @item "MinIntensity"
## @itemx "min_intensity"
## The minimum intensity inside the object.
##
## @item "MinorAxisLength"
## The region is fitted to an ellipse so this value represents the length
## of the minor axis of the ellipse.
##
## @item "Perimeter"
## The length of the boundary of the object.
##
## @item "PixelIdxList"
## @itemx "pixel_idx_list"
## The indices of the pixels in the object.
##
## @item "Orientation"
## A scalar value between -90 and 90 representing the orientation of the
## ellipse fitted to the region.
##
## @item "PixelList"
## @itemx "pixel_list"
## The actual pixel values inside the object. This is only useful for grey scale
## images.
##
## @item "PixelValues"
## @itemx "pixel_values"
## The pixel values inside the object represented as a vector.
##
## @item "WeightedCentroid"
## @itemx "weighted_centroid"
## The centroid of the object where pixel values are used as weights.
## @end table
##
## The requested properties can either be specified as several input arguments
## or as a cell array of strings. As a short-hand it is also possible to give
## the following strings as arguments.
##
## @table @asis
## @item "basic"
## The following properties are computed: @t{"Area"}, @t{"Centroid"} and
## @t{"BoundingBox"}. This is the default.
##
## @item "all"
## All properties are computed.
## @end table
##
## @seealso{bwlabel, bwperim, bweuler}
## @end deftypefn

function retval = regionprops (bw, varargin)
  ## Check input
  if (nargin < 1)
    error ("regionprops: not enough input arguments");
  endif

  prop_start = 1;
  if (numel (varargin) >= 1 && isnumeric (varargin{1}))
    if (size_equal (bw, varargin{1}))
      I = varargin{1};
      varargin(1) = [];
    else
      error ("regionprops: I must have the same size as BW");
    endif
  else
    I = bw;
  endif
  if (numel (varargin) == 0)
    properties = {"basic"};
  elseif (numel (varargin) == 1 && iscellstr (varargin{1}))
      properties = varargin{1};
  elseif (iscellstr (varargin))
    properties = varargin;
  else
    error ("regionprops: properties must be a cell array of strings");
  endif

  properties = lower (properties);

  all_props = {"Area", "EulerNumber", "BoundingBox", "Extent", "Perimeter",...
               "Centroid", "PixelIdxList", "FilledArea", "PixelList",...
               "FilledImage", "Image", "MaxIntensity", "MinIntensity",...
               "WeightedCentroid", "MeanIntensity", "PixelValues",...
               "Orientation", "Eccentricity", "MajorAxisLength", ...
               "MinorAxisLength"};

  if (ismember ("basic", properties))
    properties = union (properties, {"Area", "Centroid", "BoundingBox"});
    properties = setdiff (properties, "basic");
  endif

  if (ismember ("all", properties))
    properties = all_props;
  endif

  if (!iscellstr (properties))
    error ("%s %s", "regionprops: properties must be specified as a list of",
           "strings or a cell array of strings");
  endif

  ## Fix capitalisation, underscores of user-supplied properties...
  for k = 1:numel (properties)
    property = lower (strrep(properties{k}, "_", ""));
    [~, idx] = ismember (property, lower (all_props));
    if (!idx)
      error ("regionprops: unsupported property: %s", property);
    endif
    properties(k) = all_props{idx};
  endfor

  N = ndims (bw);

  ## Get a labelled image
  if (!islogical (bw) && all (bw >= 0) && all (bw == round (bw)))
    L = bw; # the image was already labelled
    num_labels = max (L (:));
  elseif (N > 2)
    [L, num_labels] = bwlabeln (bw);
  else
    [L, num_labels] = bwlabel (bw);
  endif

  ## Return an empty struct with specified properties if there are no labels
  if num_labels == 0
    retval = struct ([properties; repmat({{}}, size(properties))]{:});
    return;
  endif

  ## Compute the properties
  retval = struct ();
  for property = lower(properties)
    property = property{:};
    switch (property)
      case "area"
        for k = 1:num_labels
          retval (k).Area = local_area (L == k);
        endfor

      case "eulernumber"
        for k = 1:num_labels
          retval (k).EulerNumber = bweuler (L == k);
        endfor

      case "boundingbox"
        for k = 1:num_labels
          retval (k).BoundingBox = local_boundingbox (L == k);
        endfor

      case "extent"
        for k = 1:num_labels
          bb = local_boundingbox (L == k);
          area = local_area (L == k);
          idx = length (bb)/2 + 1;
          retval (k).Extent = area / prod (bb(idx:end));
        endfor

      case "perimeter"
        if (N > 2)
          warning ("regionprops: skipping perimeter for Nd image");
        else
          for k = 1:num_labels
            retval (k).Perimeter = sum (bwperim (L == k) (:));
          endfor
        endif

      case "centroid"
        for k = 1:num_labels
          C = all_coords (L == k, true);
          retval (k).Centroid = [mean(C)];
        endfor

      case "pixelidxlist"
        for k = 1:num_labels
          retval (k).PixelIdxList = find (L == k);
        endfor

      case "filledarea"
        for k = 1:num_labels
          retval (k).FilledArea = sum (bwfill (L == k, "holes") (:));
        endfor

      case "pixellist"
        for k = 1:num_labels
          C = all_coords (L == k, true, true);
          retval (k).PixelList = C;
        endfor

      case "filledimage"
        for k = 1:num_labels
          retval (k).FilledImage = bwfill (L == k, "holes");
        endfor

      case "image"
        for k = 1:num_labels
          tmp = (L == k);
          C = all_coords (tmp, false);
          idx = arrayfun (@(x,y) x:y, min (C), max (C), "unif", 0);
          idx = substruct ("()", idx);
          retval (k).Image = subsref (tmp, idx);
        endfor

      case "maxintensity"
        for k = 1:num_labels
          retval (k).MaxIntensity = max (I(L == k)(:));
        endfor

      case "minintensity"
        for k = 1:num_labels
          retval (k).MinIntensity = min (I(L == k)(:));
        endfor

      case "weightedcentroid"
        for k = 1:num_labels
          C = all_coords (L == k, true, true);
          vals = I(L == k)(:);
          vals /= sum (vals);
          retval (k).WeightedCentroid = [dot(C, repmat(vals, 1, columns(C)), 1)];
        endfor

      case "meanintensity"
        for k = 1:num_labels
          retval (k).MeanIntensity = mean (I(L == k)(:));
        endfor

      case "pixelvalues"
        for k = 1:num_labels
          retval (k).PixelValues = I(L == k)(:);
        endfor

      case "majoraxislength"
        if (N > 2)
          warning ("regionprops: skipping majoraxislength for ND image");
          break
        endif

        for k = 1:num_labels
          [Y, X] = find (L == k);

          if (numel (Y) > 1)
            ## calculate (centralised) second moment of region
            C = cov ([X(:), Y(:)], 1);    # option 1 for normalisation with n instead of n-1
            C = C + 1/12 .* eye (rows (C)); # centralised second moment of 1 pixel is 1/12
            lambda = eig (C);
            retval(k).MajorAxisLength = 4 * sqrt (max (lambda));
          else
            retval(k).MajorAxisLength = 1;
          endif
        endfor

      case "minoraxislength"
        if (N > 2)
          warning ("regionprops: skipping minoraxislength for ND image");
          break
        endif

        for k = 1:num_labels
          [Y, X] = find (L == k);
          if (numel (Y) > 1)
            ## see case majoraxislength for explanations
            C = cov ([X(:), Y(:)], 1);
            C = C + 1/12 .* eye (rows (C));
            lambda = eig (C);
            retval(k).MinorAxisLength = 4 * sqrt (min (lambda));
          else
            retval(k).MinorAxisLength = 1;
          endif
        endfor

      case "eccentricity"
        if (N > 2)
          warning ("regionprops: skipping eccentricity for ND image");
          break
        endif

        for k = 1:num_labels
          [Y, X] = find (L == k);
          if (numel (Y) > 1)
            ## see case majoraxislength for explanations
            C = cov ([X(:), Y(:)], 1);
            C = C + 1/12 .* eye (rows (C));
            lambda = eig (C);
            major =  2 * sqrt (max (lambda));
            minor =  2 * sqrt (min (lambda));
            retval(k).Eccentricity = sqrt (1- (minor/major)^2);
          else
            retval(k).Eccentricity = 0; # a circle has 0 eccentricity
          endif
        endfor

      case "orientation"
        if (N > 2)
          warning ("regionprops: skipping orientation for ND image");
          break
        endif

        for k = 1:num_labels
          [Y, X] = find (L == k);
          if (numel (Y) > 1)
            ## see case majoraxislength for explanations
            C = cov ([X(:), Y(:)], 1);
            C = C + 1/12 .* eye (rows (C));
            [V, lambda] = eig (C);
            [max_val, max_idx] = max (diag (lambda));
            max_vec = V(:, max_idx);
            retval(k).Orientation = -(180/pi) * atan (max_vec(2) / max_vec(1));
          else
            retval(k).Orientation = 0;
          endif
        endfor

      #case "extrema"
      #case "convexarea"
      #case "convexhull"
      #case "solidity"
      #case "conveximage"
      #case "subarrayidx"
      #case "equivdiameter"

      otherwise
        error ("regionprops: unsupported property '%s'", property);
    endswitch
  endfor
  ## Matlab returns a column vector struct array.
  retval = retval(:);
endfunction

function retval = local_area (bw)
  retval = sum (bw (:));
endfunction

function retval = local_boundingbox (bw)
  C = all_coords (bw);
  retval = [min(C) - 0.5, max(C) - min(C) + 1];
endfunction

function C = all_coords (bw, flip = true, singleton = false)
  N = ndims (bw);
  idx = find (bw);
  C = cell2mat (nthargout (1:N, @ind2sub, size(bw), idx(:)));

  ## Coordinate convention for 2d images is to flip the X and Y axes
  ## relative to matrix indexing. Nd images inherit this for the first
  ## two dimensions.
  if (flip)
    [C(:, 2), C(:, 1)] = deal (C(:, 1), C(:, 2));
  endif

  ## Some functions above expect to work columnwise, so don't return a
  ## vector
  if (rows (C) == 1 && !singleton)
    C = [C; C];
  endif
endfunction

%!test
%! c = regionprops ([0 0 1], 'centroid');
%! assert (c.Centroid, [3 1])

%!test
%! c = regionprops ([0 0 1; 0 0 0], 'centroid');
%! assert (c.Centroid, [3 1])

%!test
%! c = regionprops ([0 1 1], 'centroid'); #bug 39701
%! assert (c.Centroid, [2.5 1])

%!test
%! c = regionprops([0 1 1; 0 0 0], 'centroid'); #bug 39701
%! assert (c.Centroid, [2.5 1])

%!test
%! a = zeros (2, 3, 3);
%! a(:, :, 1) = [0 1 0; 0 0 0];
%! a(:, :, 3) = a(:, :, 1);
%! c = regionprops (a, 'centroid');
%! assert (c.Centroid, [2 1 2])

%!test
%! d1=2; d2=4; d3=6;
%! a = ones (d1, d2, d3);
%! c = regionprops (a, 'centroid');
%! assert (c.Centroid, [mean(1:d2), mean(1:d1), mean(1:d3)], eps)

%!test
%! a = [0 0 2 2; 3 3 0 0; 0 1 0 1];
%! c = regionprops (a, 'centroid');
%! assert (c(1).Centroid, [3 3], eps)
%! assert (c(2).Centroid, [3.5 1], eps)
%! assert (c(3).Centroid, [1.5 2], eps)

%!test
%! img  = zeros (3, 9);
%! img(2, 1:9) = 0:0.1:0.8;
%! bw = im2bw (img, 0.5);
%! props = regionprops(bw, img, "WeightedCentroid");
%! ix = 7:9;
%! x = sum (img(2,ix) .* (ix)) / sum (img(2,ix));
%! assert (props(1).WeightedCentroid(1), x, 10*eps)
%! assert (props(1).WeightedCentroid(2), 2, 10*eps)

%!assert (size (regionprops ([1 0 0; 0 0 2], "Area")), [2, 1])

%!test
%! a = eye (4);
%! t = regionprops (a, "majoraxislength");
%! assert (t.MajorAxisLength, 6.4291, 1e-3);
%! t = regionprops (a, "minoraxislength");
%! assert(t.MinorAxisLength, 1.1547 , 1e-3);
%! t = regionprops (a, "eccentricity");
%! assert (t.Eccentricity, 0.98374 , 1e-3);
%! t = regionprops (a, "orientation");
%! assert (t.Orientation, -45);

%!test
%! b = ones (5);
%! t = regionprops (b, "majoraxislength");
%! assert (t.MajorAxisLength, 5.7735 , 1e-3);
%! t = regionprops (b, "minoraxislength");
%! assert (t.MinorAxisLength, 5.7735 , 1e-3);
%! t = regionprops (b, "eccentricity");
%! assert (t.Eccentricity, 0);
%! t = regionprops (b, "orientation");
%! assert (t.Orientation, 0);

%!test
%! c = [0 0 1; 0 1 1; 1 1 0];
%! t = regionprops (c, "minoraxislength");
%! assert (t.MinorAxisLength, 1.8037 , 1e-3);
%! t = regionprops (c, "majoraxislength");
%! assert (t.MajorAxisLength, 4.1633 , 1e-3);
%! t = regionprops (c, "eccentricity");
%! assert (t.Eccentricity, 0.90128 , 1e-3);
%! t = regionprops (c, "orientation");
%! assert (t.Orientation, 45);

