## Copyright (C) 2010 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2012 Jordi Gutiérrez Hermoso <jordigh@octave.org>
## Copyright (C) 2015 Hartmut Gimpel <hg_code@gmx.de>
## Copyright (C) 2015 Carnë Draug <carandraug@octave.org>
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
## @deftypefn  {Function File} {} regionprops (@var{BW})
## @deftypefnx {Function File} {} regionprops (@var{L})
## @deftypefnx {Function File} {} regionprops (@var{CC})
## @deftypefnx {Function File} {} regionprops (@dots{}, @var{properties})
## @deftypefnx {Function File} {} regionprops (@dots{}, @var{I}, @var{properties})
## Compute properties of image regions.
##
## Individual regions can be defined in three different ways, depending on
## the type of the first argument:
##
## @table @asis
## @item @var{BW}
## A binary image.  Must be of class logical.  Individual regions will be
## the connected component as computed by @code{bwconnmp()} using the
## maximal connectivity for the number of dimensions of @var{bw} (see
## @code{conndef()} for details).
##
## @var{bw} must really be of class logical.  If not, even if it is a
## numeric array of 0's and 1's, it will be treated as a labelled image
## with a single discontinuous region.  For example:
##
## @example
## ## Handled as binary image with 3 regions
## bw = logical ([
##   1 0 1 0 1
##   1 0 1 0 1
## ]);
##
## ## Handled as labelled image with 1 region
## bw = [
##   1 0 1 0 1
##   1 0 1 0 1
## ];
## @end example
##
## @item @var{L}
## A labelled image.  Each region is the collection of all positive
## elements with the same value.  This allows computing properties of
## regions that would otherwise be considered separate or connected.
## For example:
##
## @example
## ## Recognizes 4 regions
## l = [
##   1 2 3 4
##   1 2 3 4
## ];
##
## ## Recognizes 2 (discontinuous) regions
## l = [
##   1 2 1 2
##   1 2 1 2
## ];
## @end example
##
## @item @var{CC}
## A @code{bwconnmp()} structure.  This is a struct with the following
## 4 fields: Connectivity, ImageSize, NumObjects, and PixelIdxList.  See
## @code{bwconncomp} for details.
##
## @end table
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
## The eccentricity of the ellipse that has the same normalized
## second central moments as the object (value between 0 and 1).
##
## @item "EquivDiameter"
## @itemx "equiv_diameter"
## The diameter of a circle with the same area as the object.
##
## @item "EulerNumber"
## @itemx "euler_number"
## The Euler number of the object (see @code{bweuler} for details).
##
## @item "Extent"
## The area of the object divided by the area of the bounding box.
##
## @item "Extrema"
## Returns an 8-by-2 matrix with the extrema points of the object.
## The first column holds the returned x- and the second column the y-values. 
## The order of the 8 points is: top-left, top-right, right-top, right-bottom, bottom-right, bottom-left, left-bottom, left-top.
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
## @itemx "major_axis_length"
## The length of the major axis of the ellipse that has the same
## normalized second central moments as the object.
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
## @itemx "minor_axis_length"
## The length of the minor axis of the ellipse that has the same
## normalized second central moments as the object.
##
## @item "Perimeter"
## The length of the boundary of the object.
##
## @item "PixelIdxList"
## @itemx "pixel_idx_list"
## The indices of the pixels in the object.
##
## @item "Orientation"
## The angle between the x-axis and the major axis of the ellipse that
## has the same normalized second central moments as the object
## (value in degrees between -90 and 90).
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

function props = regionprops (bw, varargin)
  if (nargin < 1)
    print_usage ();
  endif

  if (isstruct (bw))
    if (! isempty (setxor (fieldnames (bw), {"Connectivity", "ImageSize", ...
                                             "NumObjects", "PixelIdxList"})))
      error ("regionprops: CC is an invalid bwconnmp() struct");
    endif
    cc = bw;
  elseif (islogical (bw))
    cc = bwconncomp (bw);
  elseif (isnumeric (bw))
    if (isinteger (bw))
      if (intmin (class (bw)) < 0 && any (bw < 0))
        error ("regionprops: L must be non-negative integers only");
      endif
    else
      if (any (bw < 0) || any (fix (bw) != bw))
        error ("regionprops: L must be non-negative integers only");
      endif
    endif
    l_idx = find (bw);
    cc = struct ("ImageSize", size (bw), "NumObjects", max (bw(:)),
                 "PixelIdxList", accumarray (bw(l_idx), l_idx, [], @(x) {x}));
  else
    error ("regionprops: no valid BW, CC, or L input");
  endif
  is_2d = numel (cc.ImageSize) == 2;

  next_idx = 1;
  has_gray = false;
  if (numel (varargin) && isnumeric (varargin{1}))
    next_idx++;
    has_gray = true;
    img = varargin{1};
    sz  = size (img);
    if (! size_equal (sz, cc.ImageSize) || any (sz != cc.ImageSize))
      error ("regionprops: BW and I sizes must be equal");
    endif
  endif

  if (numel (varargin) >= next_idx)
    if (iscell (varargin{next_idx}))
      properties = varargin{next_idx++};
      if (numel (varargin) >= next_idx)
        print_usage ();
      endif
    else
      properties = varargin(next_idx++:end);
    endif
    if (! iscellstr (properties))
      error ("regionprops: PROPERTIES must be a string or a cell array of strings");
    endif
    properties = tolower (strrep (properties, "_", ""));
  else
    properties = {"basic"};
  endif

  if (any (strcmp ("basic", properties)))
    properties(end+1:end+3) = {"area", "centroid", "boundingbox"};
  endif
  if (any (strcmp ("all", properties)))
    properties(end+1:end+9) = {
      "area",
      "boundingbox",
      "centroid",
      "filledarea",
      "filledimage",
      "image",
      "pixelidxlist",
      "pixellist",
      "subarrayidx",
    };
    if (is_2d)
      properties(end+1:end+13) = {
        "convexarea",
        "convexhull",
        "conveximage",
        "eccentricity",
        "equivdiameter",
        "eulernumber",
        "extent",
        "extrema",
        "majoraxislength",
        "minoraxislength",
        "orientation",
        "perimeter",
        "solidity",
      };
    endif
    if (has_gray)
      properties(end+1:end+5) = {
        "maxintensity",
        "meanintensity",
        "minintensity",
        "pixelvalues",
        "weightedcentroid",
      };
    endif
  endif
  properties(strcmp ("basic", properties) | strcmp ("all", properties)) = [];

  dependencies = struct (
    "area",             {{}},
    "boundingbox",      {{}},
    "centroid",         {{}},
    "filledarea",       {{}},
    "filledimage",      {{}},
    "image",            {{}},
    "pixelidxlist",     {{}},
    "pixellist",        {{}},
    "subarrayidx",      {{}},
    "convexarea",       {{}},
    "convexhull",       {{}},
    "conveximage",      {{}},
    "eccentricity",     {{}},
    "equivdiameter",    {{}},
    "eulernumber",      {{}},
    "extent",           {{}},
    "extrema",          {{}},
    "majoraxislength",  {{}},
    "minoraxislength",  {{}},
    "orientation",      {{}},
    "perimeter",        {{}},
    "solidity",         {{}},
    "maxintensity",     {{}},
    "meanintensity",    {{}},
    "minintensity",     {{}},
    "pixelvalues",      {{}},
    "weightedcentroid", {{}}
  );

  props = repmat (struct (), cc.NumObjects, 1)

  while (! isempty (properties))
    pname = properties{end};
    deps = dependencies.(pname);
    missing_deps = deps(! isfield (props, deps));
    if (! isempty (missing_deps))
      properties(end+1:end+numel(missing_deps)) = missing_deps;
    elseif (isfield (props, pname))
      properties( end) = [];
    else
      properties(end) = [];
      switch (pname)
        case "area"
          props.area = regionprops_area (cc);
        case "boundingbox"
          props.boundingbox = regionprops_bounding_box (cc);
        case "centroid"
          props.centroid = regionprops_centroid (cc);
        case "filledarea"
        case "filledimage"
        case "image"
        case "pixelidxlist"
        case "pixellist"
          props.pixellist = regionprops_pixellist (cc);
        case "subarrayidx"
        case "convexarea"
        case "convexhull"
        case "conveximage"
        case "eccentricity"
        case "equivdiameter"
        case "eulernumber"
        case "extent"
        case "extrema"
        case "majoraxislength"
        case "minoraxislength"
        case "orientation"
        case "perimeter"
        case "solidity"
        case "maxintensity"
          props.maxintensity = regionprops_max_intensity (cc, img);
        case "meanintensity"
        case "minintensity"
          props.minintensity = regionprops_min_intensity (cc, img);
        case "pixelvalues"
        case "weightedcentroid"
          props.weightedcentroid = regionprops_weighted_centroid (cc, img);
        otherwise
          error ("regionprops: unknown property `%s'", pname);
      endswitch
    endif
  endwhile

endfunction

function area = regionprops_area (cc)
  area = cellfun (@numel, cc.PixelIdxList);
endfunction

function centroid = regionprops_centroid (cc)
  nd = numel (cc.ImageSize);
  idx = cell2mat (cc.PixelIdxList(:));
  sub = cell2mat (nthargout (1:nd, @ind2sub, cc.ImageSize, idx));
  sub(:,[1 2]) = sub(:,[2 1]); # swap x y coordinates

  no = cc.NumObjects;
  rn = 1:no;
  weighted_sub = sub ./ vec (repelems (area, [rn; area]));
  centroid = accumarray (accum_subs(:), weighted_sub(:), [no nd])
endfunction

function bounding_box = regionprops_bounding_box (cc)
  nd = numel (cc.ImageSize);
  idx = cell2mat (cc.PixelIdxList(:));
  sub = cell2mat (nthargout (1:nd, @ind2sub, cc.ImageSize, idx));
  sub(:,[1 2]) = sub(:,[2 1]); # swap x y coordinates

  no = cc.NumObjects;
  rn = 1:no;
  area = cellfun (@numel, cc.PixelIdxList);
  accum_subs = vec (repelems (rn, [rn; area])) .+ [0:no:(no*nd-1)];

  init_corner = accumarray (accum_subs(:) , sub(:), [no nd], @min);
  end_corner  = accumarray (accum_subs(:) , sub(:), [no nd], @max);
  bounding_box = [(init_corner - 0.5) (end_corner - init_corner)];
endfunction

function pixel_list = regionprops_pixellist (cc)
  nd = numel (cc.ImageSize);
  idx = cell2mat (cc.PixelIdxList(:));
  sub = cell2mat (nthargout (1:nd, @ind2sub, cc.ImageSize, idx));
  sub(:,[1 2]) = sub(:,[2 1]); # swap x y coordinates

  pixel_list = mat2cell (sub, cellfun (@numel, cc.PixelIdxList));
endfunction

function max_intensity = regionprops_max_intensity (cc, img)
  Area = cellfun (@numel, cc.PixelIdxList);
  all_ind = cell2mat (cc.PixelIdxList(:));
  no = cc.NumObjects;
  rn = 1:no;
  subs = vec (repelems (rn, [rn; Area]));
  max_intensity = accumarray (subs, img(all_ind), [no 1], @max);
endfunction

function min_intensity = regionprops_min_intensity (cc, img)
  Area = cellfun (@numel, cc.PixelIdxList);
  all_ind = cell2mat (cc.PixelIdxList(:));
  no = cc.NumObjects;
  rn = 1:no;
  subs = vec (repelems (rn, [rn; Area]));
  min_intensity = accumarray (subs, img(all_ind), [no 1], @min);
endfunction

function weighted_centroid = regionprops_weighted_centroid (cc, img)
  Area = cellfun (@numel, cc.PixelIdxList);

  no = cc.NumObjects;
  sz = cc.ImageSize;
  nd = numel (sz);
  rn = 1:no;
  R = [rn; Area];

  idx = cell2mat (cc.PixelIdxList(:));
  sub = cell2mat (nthargout (1:nd, @ind2sub, sz, idx));

  vals = im(idx);
  subs = vec (repelems (rn, R));

  totals = repelems (accumarray (subs, vals), R);
  weighted_sub = sub .* (double (vals) ./ vec (totals));
  weighted_centroid = accumarray (vec (repmat (subs, [1 nd]) .+ [0:no:(no*nd-1)]),
                                  vec (weighted_sub), [no nd]);

  ## Swap X and Y coordinates for Matlab compatibility
  weighted_centroid(:,[1 2]) = weighted_centroid(:,[2 1]);
endfunction

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

  all_props = {"Area", "EquivDiameter", "EulerNumber", ...
               "BoundingBox", "Extent", "Perimeter",...
               "Centroid", "PixelIdxList", "FilledArea", "PixelList",...
               "FilledImage", "Image", "MaxIntensity", "MinIntensity",...
               "WeightedCentroid", "MeanIntensity", "PixelValues",...
               "Orientation", "Eccentricity", "MajorAxisLength", ...
               "MinorAxisLength", "Extrema"};

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

      case "equivdiameter"
        if (N > 2)
          warning ("regionprops: skipping equivdiameter for Nd image");
        else
          for k = 1:num_labels
            area = local_area (L == k);
            retval (k).EquivDiameter = sqrt (4*area/pi);
          endfor
        endif

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
            [major, ~, ~] = local_ellipsefit (X, Y);
            retval(k).MajorAxisLength = major;
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
            [~, minor, ~] = local_ellipsefit (X, Y);
            retval(k).MinorAxisLength = minor;
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
            [major, minor, ~] = local_ellipsefit (X, Y);
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
            [~, ~, major_vec] = local_ellipsefit (X, Y);
            retval(k).Orientation = -(180/pi) * atan (major_vec(2) / major_vec(1));
          else
            retval(k).Orientation = 0;
          endif
        endfor

      case "extrema"
        if (N > 2)
          warning ("regionprops: skipping extrema for Nd image");
        else
          for k = 1:num_labels
            pixelidxlist =  find (L == k);
            if length(pixelidxlist) == 0
              retval (k).Extrema = repmat (0.5, [8 2]); # for ML compatibility
            else
              [pixel_R, pixel_C] = ind2sub (size (L), pixelidxlist);

              top_r = min (pixel_R); # small "r" and "c" for scalars and capital "R" and "C" for vectors
              top_R = pixel_C (pixel_R == top_r);
              top_left_c = min (top_R) - 0.5; # add/substract 0.5 to all values for corner of pixles (as in ML)
              top_right_c = max (top_R) + 0.5;
              top_r = top_r - 0.5;

              right_c = max (pixel_C);
              right_C = pixel_R (pixel_C == right_c);
              right_top_r = min (right_C) - 0.5;
              right_bottom_r = max (right_C) + 0.5;
              right_c = right_c + 0.5;

              bottom_r = max (pixel_R);
              bottom_R = pixel_C (pixel_R == bottom_r);
              bottom_right_c = max (bottom_R) + 0.5;
              bottom_left_c = min (bottom_R) - 0.5;
              bottom_r = bottom_r + 0.5;

              left_c = min (pixel_C);
              left_C = pixel_R (pixel_C == left_c);
              left_bottom_r = max (left_C) + 0.5;
              left_top_r = min (left_C) - 0.5;
              left_c = left_c - 0.5;

              # return 8x2 matrix with x-values in first column and y-values in second column
              retval(k).Extrema = [top_left_c top_r; top_right_c top_r; ...
                right_c right_top_r; right_c right_bottom_r; ...
                bottom_right_c bottom_r; bottom_left_c bottom_r; ...
                left_c left_bottom_r; left_c left_top_r];                
            endif
          endfor
        endif

      #case "convexarea"
      #case "convexhull"
      #case "solidity"
      #case "conveximage"
      #case "subarrayidx"

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

function [major, minor, major_vec] = local_ellipsefit (X, Y)
  ## calculate (centralised) second moment of region with pixels [X, Y]
  C = cov ([X(:), Y(:)], 1);    # option 1 for normalisation with n instead of n-1
  C = C + 1/12 .* eye (rows (C)); # centralised second moment of 1 pixel is 1/12
  [V, lambda] = eig (C);
  lambda_d = 4 .* sqrt (diag (lambda));
  [major, major_idx] = max (lambda_d);
  major_vec = V(:, major_idx);
  minor = min(lambda_d);
endfunction

%!shared bw2d
%! bw2d = logical ([
%!  0 1 0 1 1 0
%!  0 1 1 0 1 1
%!  0 1 0 0 0 0
%!  0 0 0 1 1 1
%!  0 0 1 1 0 1]);

%!function c = get_2d_centroid_for (idx)
%!  subs = ind2sub ([5 6], idx);
%!  m = false ([5 6]);
%!  m(idx) = true;
%!  y = sum ((1:5)' .* sum (m, 2) /sum (m(:)));
%!  x = sum ((1:6)  .* sum (m, 1) /sum (m(:)));
%!  c = [x y];
%!endfunction

%!test
%! props = struct ("Area", {8, 6},
%!                 "Centroid", {get_2d_centroid_for([6 7 8 12 16 21 22 27]), ...
%!                              get_2d_centroid_for([15 19 20 24 29 30])},
%!                 "BoundingBox", {[1.5 0.5 5 3], [2.5 3.5 4 2]});
%!assert (regionprops (bw, "basic"), props)
%!assert (regionprops (bwconncomp (bw, 8), "basic"), props)
%!assert (regionprops (bwlabeln (bw, 8), "basic"), props)

%!test
%! props = struct ("Area", {4, 6, 4},
%!                 "Centroid", {get_2d_centroid_for([6 7 8 12]), ...
%!                              get_2d_centroid_for([15 19 20 24 29 30]), ...
%!                              get_2d_centroid_for([16 21 22 27])},
%!                 "BoundingBox", {[1.5 0.5 2 3] [2.5 3.5 4 2] [2.5 0.5 3 2]});
%!assert (regionprops (bwconncomp (bw, 4), "basic"), props)
%!assert (regionprops (bwlabeln (bw, 4), "basic"), props)

## This it is treated as labeled image with a single discontiguous region.
%!assert (regionprops (double (bw), "basic"),
%!        struct ("Area", 14,
%!                "Centroid", get_2d_centroid_for (find (bw2d)),
%!                "BoundingBox", [1.5 0.5 5 5])

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
%! t = regionprops (a, "equivdiameter");
%! assert (t.EquivDiameter, 2.2568,  1e-3);

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
%! t = regionprops (b, "equivdiameter");
%! assert (t.EquivDiameter, 5.6419,  1e-3);

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
% t = regionprops (c, "equivdiameter");
% assert (t.EquivDiameter, 2.5231,  1e-3);

%!test
%! f = [0 0 0 0; 1 1 1 1; 0 1 1 1; 0 0 0 0];
%! t = regionprops (f, "Extrema");
%! shouldbe = [0.5  1.5; 4.5  1.5; 4.5 1.5; 4.5 3.5; 4.5 3.5; 1.5 3.5; 0.5 2.5; 0.5  1.5];
%! assert (t.Extrema, shouldbe,  eps);

## Test guessing between labelled and binary image
%!assert (regionprops ([1 0 1; 1 0 1], "Area"), struct ("Area", 4))
%!assert (regionprops ([1 0 2; 1 1 2], "Area"), struct ("Area", {3; 2}))

## Test missing labels
%!assert (regionprops ([1 0 3; 1 1 3], "Area"), struct ("Area", {3; 0; 2}))

%!error <L must be non-negative integers> regionprops ([1 -2   0 3])
%!error <L must be non-negative integers> regionprops ([1  1.5 0 3])
