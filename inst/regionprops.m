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
## Measures several properties for each region within an image.  Returns
## a struct array, one element per region, whose field names are the
## measured properties.
##
## Individual regions can be defined in three different ways, a binary
## image, a labelled image, or a bwconncomp struct, each providing
## different advantages.
##
## @table @asis
## @item @var{BW}
## A binary image.  Must be of class logical.  Individual regions will be
## the connected component as computed by @code{bwconnmp} using the
## maximal connectivity for the number of dimensions of @var{bw} (see
## @code{conndef} for details).  For alternative connectivities, call
## @code{bwconncomp} directly and use its output instead.
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
## The properties to be measured can be defined via a cell array or a
## comma separated list or strings.  Some of the properties are only
## supported if the matching grayscale image @var{I} is also supplied.
## Others are only supported for 2 dimensional images.  See the list
## below for details on each property limitation.  If none is specified,
## it defaults to the @qcode{"basic"} set of properties.
##
## @table @asis
## @item @qcode{"Area"}
## The number of pixels in the region.  Note that this differs from
## @code{bwarea} where each pixel has different weights.
##
## @item @qcode{"BoundingBox"}
## The smalles rectangle that encloses the region.  This is represented
## as a row vector such as
## @code{[x y z @dots{} x_length y_length z_length @dots{}]}.
##
## The first half corresponds to the lower coordinates of each dimension
## while the second half, to the length in that dimension.  For the two
## dimensional case, the first 2 elements correspond to the coordinates
## of the upper left corner of the bounding box, while the two last entries
## are the width and the height of the box.
##
## @item @qcode{"Centroid"}
## The coordinates for the region centre of mass.  This is a row vector
## with one element per dimension, such as @code{[x y z @dots{}]}.
##
## @item @qcode{"Eccentricity"}
## The eccentricity of the ellipse that has the same normalized
## second central moments as the region (value between 0 and 1).
##
## @item @qcode{"EquivDiameter"}
## The diameter of a circle with the same area as the object.
##
## @item @qcode{"EulerNumber"}
## The Euler number of the region (see @code{bweuler} for details).
##
## @item @qcode{"Extent"}
## The area of the object divided by the area of the bounding box.
##
## @item @qcode{"Extrema"}
## Returns an 8-by-2 matrix with the extrema points of the object.
## The first column holds the returned x- and the second column the y-values.
## The order of the 8 points is: top-left, top-right, right-top, right-bottom,
## bottom-right, bottom-left, left-bottom, left-top.
##
## @item @qcode{"FilledArea"}
## The area of the object including possible holes.
##
## @item @qcode{"FilledImage"}
## A binary image with the same size as the object's bounding box that contains
## the object with all holes removed.
##
## @item @qcode{"Image"}
## An image with the same size as the bounding box that contains the original
## pixels.
##
## @item @qcode{"MajorAxisLength"}
## The length of the major axis of the ellipse that has the same
## normalized second central moments as the object.
##
## @item @qcode{"MaxIntensity"}
## The maximum intensity value inside each region.
## Requires a grayscale image @var{I}.
##
## @item @qcode{"MeanIntensity"}
## The mean intensity value inside each region.
## Requires a grayscale image @var{I}.
##
## @item @qcode{"MinIntensity"}
## The minimum intensity value inside each region.
## Requires a grayscale image @var{I}.
##
## @item @qcode{"MinorAxisLength"}
## The length of the minor axis of the ellipse that has the same
## normalized second central moments as the object.
##
## @item @qcode{"Orientation"}
## The angle between the x-axis and the major axis of the ellipse that
## has the same normalized second central moments as the object
## (value in degrees between -90 and 90).
##
## @item @qcode{"Perimeter"}
## The length of the boundary of the object.
##
## @item @qcode{"PixelIdxList"}
## The linear indices for the elements of each region in a column vector.
##
## @item @qcode{"PixelList"}
## The subscript indices for the elements of each region.  This is a p-by-Q
## matrix where p is the number of elements and Q is the number of
## dimensions.  Each row is of the form @qcode{[x y z @dots{}]}.
##
## @item @qcode{"PixelValues"}
## The actual pixel values inside each region in a column vector.
## Requires a grayscale image @var{I}.
##
## @item @qcode{"WeightedCentroid"}
## The coordinates for the region centre of mass when using the intensity
## of each element as weight.  This is a row vector with one element per
## dimension, such as @code{[x y z @dots{}]}.
## Requires a grayscale image @var{I}.
##
## @end table
##
## In addition, the strings @qcode{"basic"} and @qcode{"all"} can be
## used to select a subset of the properties:
##
## @table @asis
## @item @qcode{"basic"} (default)
## Compute @qcode{"Area"}, @qcode{"Centroid"}, and @qcode{"BoundingBox"}.
##
## @item @qcode{"all"}
## Computes all possible properties for the image, i.e., it will not
## compute properties that require grayscale unless the grayscale image
## is available, and it will not compute properties that are limited to
## 2 dimensions, unless the image is 2 dimensions.
##
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
    n_obj = max (bw(:));
    cc = struct ("ImageSize", size (bw), "NumObjects", n_obj,
                 "PixelIdxList", {accumarray(bw(l_idx)(:), l_idx, [1 n_obj],
                                             @(x) {x})});
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

  ## Some properties require the value of others.  In addition, most
  ## properties have common code.  Ideally, to avoid repeating
  ## computations, we would make use not only of the already measured
  ## properties. but also of their intermediary steps.  We handle this
  ## with a stack of properties that need to be measured and we push
  ## dependencies into it as we find them.  A scalar struct keeps all
  ## values whose fields are the properties and intermediary steps names.
  ##
  ## Note that we do not want to fill the return value just yet.  The
  ## reason is that props is a struct array.  Since the computation of
  ## the properties is vectorized, it would require a constant back and
  ## forth conversion between cell arrays and numeric arrays.  So we
  ## keep everything in a numeric array and everything is much faster.
  ## At the end, we put everything in place in a struct array.

  dependencies = struct (
    "area",             {{}},
    "accum_subs",       {{"area"}},
    "accum_subs_nd",    {{"accum_subs"}},
    "boundingbox",      {{"pixellist", "accum_subs_nd"}},
    "centroid",         {{"accum_subs_nd", "pixellist", "area"}},
    "filledarea",       {{}},
    "filledimage",      {{}},
    "image",            {{}},
    "pixelidxlist",     {{}},
    "pixellist",        {{"pixelidxlist"}},
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
    "maxintensity",     {{"accum_subs", "pixelidxlist"}},
    "meanintensity",    {{"total_intensity", "area"}},
    "minintensity",     {{"accum_subs", "pixelidxlist"}},
    "pixelvalues",      {{"pixelidxlist"}},
    "total_intensity",  {{"accum_subs", "pixelidxlist"}},
    "weightedcentroid", {{"accum_subs_nd", "total_intensity", "pixellist", "pixelidxlist", "area"}}
  );

  to_measure = properties;
  values = struct ();

  ## There's too many indirectly dependent on "area", and even if not
  ## required, it will be required later to create the struct array.
  values.area = rp_area (cc);

  while (! isempty (to_measure))
    pname = to_measure{end};

    ## Already computed. Pop it and move on.
    if (isfield (values, pname))
      to_measure(end) = [];
      continue
    endif

    ## There's missing dependencies. Push them and start again.
    deps = dependencies.(pname);
    missing = deps(! isfield (values, deps));
    if (! isempty (missing))
      to_measure(end+1:end+numel(missing)) = missing;
      continue
    endif

    to_measure(end) = [];
    switch (pname)
      case "area"
        values.area = rp_area (cc);
      case "accum_subs"
        values.accum_subs = rp_accum_subs (cc, values.area);
      case "accum_subs_nd"
        values.accum_subs_nd = rp_accum_subs_nd (cc, values.accum_subs);
      case "boundingbox"
        values.boundingbox = rp_bounding_box (cc, values.pixellist,
                                              values.accum_subs_nd);
      case "centroid"
        values.centroid = rp_centroid (cc, values.pixellist, values.area,
                                       values.accum_subs_nd);
      case "filledarea"
      case "filledimage"
      case "image"
      case "pixelidxlist"
        values.pixelidxlist = rp_pixel_idx_list (cc);
      case "pixellist"
        values.pixellist = rp_pixel_list (cc, values.pixelidxlist);
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
        values.maxintensity = rp_max_intensity (cc, img,
                                                values.pixelidxlist,
                                                values.accum_subs);
      case "meanintensity"
        values.meanintensity = rp_mean_intensity (cc, values.total_intensity,
                                                  values.area);

      case "minintensity"
        values.minintensity = rp_min_intensity (cc, img,
                                                values.pixelidxlist,
                                                values.accum_subs);
      case "pixelvalues"
        values.pixelvalues = rp_pixel_values (cc, img, values.pixelidxlist);
      case "total_intensity"
        values.total_intensity = rp_total_intensity (cc, img,
                                                     values.pixelidxlist,
                                                     values.accum_subs);
      case "weightedcentroid"
        values.weightedcentroid = rp_weighted_centroid (cc, img,
                                                        values.pixellist,
                                                        values.pixelidxlist,
                                                        values.total_intensity,
                                                        values.accum_subs_nd,
                                                        values.area);
      otherwise
        error ("regionprops: unknown property `%s'", pname);
    endswitch
  endwhile


  ## After we have made all the measurements, we need to pack everything
  ## into struct arrays.

  Area = values.area;
  props = repmat (struct (), cc.NumObjects, 1);
  for ip = 1:numel (properties)
    switch (properties{ip})
      case "area"
        [props.Area] = num2cell (Area){:};
      case "boundingbox"
        [props.BoundingBox] = mat2cell (values.boundingbox,
                                        ones (cc.NumObjects, 1)){:};
      case "centroid"
        [props.Centroid] = mat2cell (values.centroid,
                                     ones (cc.NumObjects, 1)){:};
      case "filledarea"
      case "filledimage"
      case "image"
      case "pixelidxlist"
        [props.PixelIdxList] = mat2cell (values.pixelidxlist, Area){:};
      case "pixellist"
        [props.PixelList] = mat2cell (values.pixellist, Area){:};
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
        [props.MaxIntensity] = num2cell (values.maxintensity){:};
      case "meanintensity"
        [props.MeanIntensity] = num2cell (values.meanintensity){:};
      case "minintensity"
        [props.MinIntensity] = num2cell (values.minintensity){:};
      case "pixelvalues"
        [props.PixelValues] = mat2cell (values.pixelvalues, Area){:};
      case "weightedcentroid"
        [props.WeightedCentroid] = mat2cell (values.weightedcentroid,
                                             ones (cc.NumObjects, 1)){:};
      otherwise
        error ("regionprops: unknown property `%s'", pname);
    endswitch
  endfor

endfunction

function area = rp_area (cc)
  area = cellfun (@numel, cc.PixelIdxList(:));
endfunction

function centroid = rp_centroid (cc, pixel_list, area, subs_nd)
  nd = numel (cc.ImageSize);
  no = cc.NumObjects;
  weighted_sub = pixel_list ./ vec (repelems (area, [1:no; vec(area, 2)]));
  centroid = accumarray (subs_nd, weighted_sub(:), [no nd]);
endfunction

function bounding_box = rp_bounding_box (cc, pixel_list, subs_nd)
  nd = numel (cc.ImageSize);
  no = cc.NumObjects;
  init_corner = accumarray (subs_nd, pixel_list(:), [no nd], @min) - 0.5;
  end_corner  = accumarray (subs_nd, pixel_list(:), [no nd], @max) + 0.5;
  bounding_box = [(init_corner) (end_corner - init_corner)];
endfunction

function idx = rp_pixel_idx_list (cc)
  idx = cell2mat (cc.PixelIdxList(:));
endfunction

function pixel_list = rp_pixel_list (cc, idx)
  nd = numel (cc.ImageSize);
  pixel_list = cell2mat (nthargout (1:nd, @ind2sub, cc.ImageSize, idx));
  pixel_list(:,[1 2]) = pixel_list(:,[2 1]);
endfunction

function pixel_values = rp_pixel_values (cc, img, idx)
  pixel_values = img(idx);
endfunction

function max_intensity = rp_max_intensity (cc, img, idx, subs)
  max_intensity = accumarray (subs, img(idx), [cc.NumObjects 1], @max);
endfunction

function mean_intensity = rp_mean_intensity (cc, totals, area)
  mean_intensity = totals ./ area;
endfunction

function min_intensity = rp_min_intensity (cc, img, idx, subs)
  min_intensity = accumarray (subs, img(idx), [cc.NumObjects 1], @min);
endfunction

function weighted_centroid = rp_weighted_centroid (cc, img, pixel_list,
                                                   pixel_idx_list, totals,
                                                   subs_nd, area)
  no = cc.NumObjects;
  nd = numel (cc.ImageSize);
  rep_totals = vec (repelems (totals, [1:no; vec(area, 2)]));

  vals = img(pixel_idx_list);
  weighted_pixel_list = pixel_list .* (double (vals) ./ rep_totals);
  weighted_centroid = accumarray (subs_nd, weighted_pixel_list(:), [no nd]);
endfunction


##
## Intermediary steps -- no match to specific property
##

## Creates subscripts for use with accumarray, when computing a column vector.
function subs = rp_accum_subs (cc, area)
  rn = 1:cc.NumObjects;
  R  = [rn; vec(area, 2)];
  subs = vec (repelems (rn, R));
endfunction

## Creates subscripts for use with accumarray, when computing something
## with a column per number of dimensions
function subs_nd = rp_accum_subs_nd (cc, subs)
  nd = numel (cc.ImageSize);
  no = cc.NumObjects;
  subs_nd = vec (subs .+ [0:no:(no*nd-1)]);
endfunction

## Total/Integrated density of each region.
function totals = rp_total_intensity (cc, img, idx, subs)
  totals = accumarray (subs, img(idx), [cc.NumObjects 1]);
endfunction

function retval = old_regionprops (bw, varargin)

  ## Compute the properties
  retval = struct ();
  for property = lower(properties)
    property = property{:};
    switch (property)
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

      case "filledarea"
        for k = 1:num_labels
          retval (k).FilledArea = sum (bwfill (L == k, "holes") (:));
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

      otherwise
        error ("regionprops: unsupported property '%s'", property);
    endswitch
  endfor
  ## Matlab returns a column vector struct array.
  retval = retval(:);
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

%!shared bw2d, gray2d
%! bw2d = logical ([
%!  0 1 0 1 1 0
%!  0 1 1 0 1 1
%!  0 1 0 0 0 0
%!  0 0 0 1 1 1
%!  0 0 1 1 0 1]);
%!
%! gray2d = [
%!  2 4 0 7 5 2
%!  3 0 4 9 3 7
%!  0 5 3 4 8 1
%!  9 2 0 5 8 6
%!  8 9 7 2 2 5];

%!function c = get_2d_centroid_for (idx)
%!  subs = ind2sub ([5 6], idx);
%!  m = false ([5 6]);
%!  m(idx) = true;
%!  y = sum ((1:5)' .* sum (m, 2) /sum (m(:)));
%!  x = sum ((1:6)  .* sum (m, 1) /sum (m(:)));
%!  c = [x y];
%!endfunction

%!assert (regionprops (bw2d, "Area"), struct ("Area", {8; 6}))
%!assert (regionprops (double (bw2d), "Area"), struct ("Area", {14}))
%!assert (regionprops (bwlabel (bw2d, 4), "Area"), struct ("Area", {4; 6; 4}))

## These are different from Matlab because the indices in PixelIdxList
## do not appear sorted.  This is because we get them from bwconncomp()
## which does not sort them (it seems bwconncomp in Matlab returns them
## sorted but that's undocumented, just like the order here is undocumented)
%!assert (regionprops (bw2d, "PixelIdxList"),
%!        struct ("PixelIdxList", {[6; 7; 12; 8; 16; 21; 22; 27]
%!                                 [15; 19; 20; 24; 29; 30]}))
%!assert (regionprops (bwlabel (bw2d, 4), "PixelIdxList"),
%!        struct ("PixelIdxList", {[6; 7; 8; 12]
%!                                 [15; 19; 20; 24; 29; 30]
%!                                 [16; 21; 22; 27]}))
%!assert (regionprops (bw2d, "PixelList"),
%!        struct ("PixelList", {[2 1; 2 2; 3 2; 2 3; 4 1; 5 1; 5 2; 6 2]
%!                              [3 5; 4 4; 4 5; 5 4; 6 4; 6 5]}))
%!assert (regionprops (bwlabel (bw2d, 4), "PixelList"),
%!        struct ("PixelList", {[2 1; 2 2; 2 3; 3 2]
%!                              [3 5; 4 4; 4 5; 5 4; 6 4; 6 5]
%!                              [4 1; 5 1; 5 2; 6 2]}))

## Also different from Matlab because we do not sort the values by index
%!assert (regionprops (bw2d, gray2d, "PixelValues"),
%!        struct ("PixelValues", {[4; 0; 4; 5; 7; 5; 3; 7]
%!                                [7; 5; 2; 8; 6; 5]}))

%!assert (regionprops (bw2d, gray2d, "MaxIntensity"),
%!        struct ("MaxIntensity", {7; 8}))
%!assert (regionprops (bw2d, gray2d, "MinIntensity"),
%!        struct ("MinIntensity", {0; 2}))

%!assert (regionprops (bw2d, "BoundingBox"),
%!        struct ("BoundingBox", {[1.5 0.5 5 3]; [2.5 3.5 4 2]}))

%!assert (regionprops (bw2d, "Centroid"),
%!        struct ("Centroid", {get_2d_centroid_for([6 7 8 12 16 21 22 27])
%!                             get_2d_centroid_for([15 19 20 24 29 30])}))

%!test
%! props = struct ("Area", {8; 6},
%!                 "Centroid", {get_2d_centroid_for([6 7 8 12 16 21 22 27])
%!                              get_2d_centroid_for([15 19 20 24 29 30])},
%!                 "BoundingBox", {[1.5 0.5 5 3]; [2.5 3.5 4 2]});
%! assert (regionprops (bw2d, "basic"), props)
%! assert (regionprops (bwconncomp (bw2d, 8), "basic"), props)
%! assert (regionprops (bwlabeln (bw2d, 8), "basic"), props)

%!test
%! props = struct ("Area", {4; 6; 4},
%!                 "Centroid", {get_2d_centroid_for([6 7 8 12])
%!                              get_2d_centroid_for([15 19 20 24 29 30])
%!                              get_2d_centroid_for([16 21 22 27])},
%!                 "BoundingBox", {[1.5 0.5 2 3]; [2.5 3.5 4 2]; [3.5 0.5 3 2]});
%! assert (regionprops (bwconncomp (bw2d, 4), "basic"), props)
%! assert (regionprops (bwlabeln (bw2d, 4), "basic"), props)

## This it is treated as labeled image with a single discontiguous region.
%!assert (regionprops (double (bw2d), "basic"),
%!        struct ("Area", 14,
%!                "Centroid", get_2d_centroid_for (find (bw2d)),
%!                "BoundingBox", [1.5 0.5 5 5]), eps*1000)

%!assert (regionprops ([0 0 1], "Centroid").Centroid, [3 1])
%!assert (regionprops ([0 0 1; 0 0 0], "Centroid").Centroid, [3 1])

## bug #39701
%!assert (regionprops ([0 1 1], "Centroid").Centroid, [2.5 1])
%!assert (regionprops ([0 1 1; 0 0 0], "Centroid").Centroid, [2.5 1])

%!test
%! a = zeros (2, 3, 3);
%! a(:, :, 1) = [0 1 0; 0 0 0];
%! a(:, :, 3) = a(:, :, 1);
%! c = regionprops (a, "centroid");
%! assert (c.Centroid, [2 1 2])

%!test
%! d1=2; d2=4; d3=6;
%! a = ones (d1, d2, d3);
%! c = regionprops (a, "centroid");
%! assert (c.Centroid, [mean(1:d2), mean(1:d1), mean(1:d3)], eps*1000)

%!test
%! a = [0 0 2 2; 3 3 0 0; 0 1 0 1];
%! c = regionprops (a, "centroid");
%! assert (c(1).Centroid, [3 3])
%! assert (c(2).Centroid, [3.5 1])
%! assert (c(3).Centroid, [1.5 2])

%!test
%!assert (regionprops (bw2d, gray2d, "WeightedCentroid"),
%!                     struct ("WeightedCentroid",
%!                             {sum([2 1; 2 2; 3 2; 2 3; 4 1; 5 1; 5 2; 6 2]
%!                              .* ([4; 0; 4; 5; 7; 5; 3; 7] / 35))
%!                              sum([3 5; 4 4; 4 5; 5 4; 6 4; 6 5]
%!                                  .* ([7; 5; 2; 8; 6; 5] / 33))}))

%!test
%! img = zeros (3, 9);
%! img(2, 1:9) = 0:0.1:0.8;
%! bw = im2bw (img, 0.5);
%! props = regionprops (bw, img, "WeightedCentroid");
%! ix = 7:9;
%! x = sum (img(2,ix) .* (ix)) / sum (img(2,ix));
%! assert (props(1).WeightedCentroid(1), x, 10*eps)
%! assert (props(1).WeightedCentroid(2), 2, 10*eps)

%!assert (regionprops (bw2d, gray2d, "MeanIntensity"),
%!        struct ("MeanIntensity", {mean([4 0 5 4 7 5 3 7])
%!                                  mean([7 5 2 8 6 5])}))

%!assert (regionprops (bwlabel (bw2d, 4), gray2d, "MeanIntensity"),
%!        struct ("MeanIntensity", {mean([4 0 5 4])
%!                                  mean([7 5 2 8 6 5])
%!                                  mean([7 5 3 7])}))

## Test dimensionality of struct array
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
