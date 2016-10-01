## Copyright (C) 2016 Hartmut Gimpel <hg_code@gmx.de>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
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
## @deftypefn  {Function File} {@var{bw2} =} imfill (@var{bw}, "holes")
## @deftypefnx {Function File} {@var{bw2} =} imfill (@var{bw}, @var{conn}, "holes")
## @deftypefnx {Function File} {@var{bw2} =} imfill (@var{bw}, @var{locations})
## @deftypefnx {Function File} {@var{bw2} =} imfill (@var{bw}, @var{locations}, @var{conn})
## @deftypefnx {Function File} {@var{I2} =} imfill (@var{I})
## @deftypefnx {Function File} {@var{I2} =} imfill (@var{I}, @var{conn})
## Fill holes in binary images @var{bw} and grayscale images @var{I}.
##
## @var{bw} is a 2d binary input image. With the option "holes" all its
## holes will be filled. (I.e. all 0-value pixel regions fully enclosed
## by 1-value pixels will be filled with 1s). Alternativly all
## @var{locations}  where holes shall be filled, can be given as a n-by-1
## vector of linear pixel indices, or as a n-by-2 matrix of pixel indices.
## The used @var{connectivity} (of the background pixel regions)
## for this filling operation can be specified as 4 (default)
## or 8 (or any other valid connectivity specification).
##
## @var{I} is a 2d grayscale input image. Without any options all its holes
## will be filled. (I.e. all darker pixel regions fully enclosed by lighter
## pixels will be filled with lighter pixel values).  The used
## @var{connectivity} (of the background pixel regions)  for this filling
## operation  can be specified as 4 (default) or 8 (or any other valid
## connectivity specification).
##
## The imfill function uses an algorithm based on morphological reconstruction.
##
## (The following Matlab functionality of imfill is not yet supported:
## Nd images, interactive usage.)
##
## @seealso{bwfill, imreconstruct, iptcheckconn}
## @end deftypefn

function filled = imfill (img, varargin)

  if (nargin < 1 || nargin > 3)
    print_usage ();
  endif

  if (! isimage (img) || ndims (img) > 2)
    error ("imfill: first argument must be a 2D logical or gray-scale image");
  endif

  ## Default parameter values
  conn = 4;
  fill_holes = false;

  if (nargin () == 1)
    if (islogical (img))
      ## imfill (BW)
      error ("imfill: interactive usage is not yet supported");
    else
      ## syntax: imfill (img)
      fill_holes = true;
    endif

  elseif (nargin () == 2)
    opt2 = varargin{1};
    if (ischar (opt2))
      ## syntax: imfill (BW, "holes") or imfill (IMG, "holes")
      validatestring (opt2, {"holes"}, "imfill", "OPTION");
      fill_holes = true;
    elseif (! islogical (img))
      ## syntax: imfill (BW, CONN) or imfill (IMG, CONN)
      fill_holes = true;
      iptcheckconn (opt2, "imfill", "CONN");
      conn = opt2;
    elseif (islogical (img) && isnumeric (opt2) && isindex (opt2)
            && ndims (opt2) <= 2)
      ## syntax: imfill (BW, LOCATIONS)
      locations = check_loc (opt2, size (img));
    else
      error ("imfill: second argument must be 'holes', a connectivity specification, or an index array");
    endif

  elseif (nargin () == 3)
    opt2 = varargin{1};
    opt3 = varargin{2};
    if (ischar (opt3))
      ## syntax: imfill (BW, CONN, "holes") or imfill (IMG, CONN, "holes")
      validatestring (opt3, {"holes"}, "imfill", "OPTION");
      iptcheckconn (opt2, "imfill", "CONN");
      conn = opt2;
      fill_holes = true;
    elseif (islogical (img) && isnumeric (opt2) && isindex (opt2)
            && ndims (opt2) <= 2)
      ## syntax: imfill (BW, LOCATIONS, CONN)
      iptcheckconn(opt3, "imfill", "CONN");
      conn = opt3;
      locations = check_loc (opt2, size (img));
    elseif (islogical (img) && (opt2 == 0))
        ## syntax: imfill (BW, 0, CONN)
        error ("imfill: interactive usage is not yet supported");
    else
      print_usage ();
    endif
  endif


  if (fill_holes)
    ##  "Hole filling" algorithm taken from the book
    ##   Gonzalez & Woods "Digital Image Processing" (3rd Edition)
    ##   in chapter 9.5.9 "Morphological Reconstruction", section
    ##   "Filling holes"
    ##   formula 9.5-28 and 9.5.29, explained with image IMG
    ##   and generalized to grayscale images:
    ##      * (1-IMG) -> complement(IMG),
    ##      * 0-value -> -Inf value
    ##   and change of border treatment to make unusual connectivity
    ##   specs work:
    ##      * define marker as complement(IMG) on border of IMG and
    ##        as -Inf otherwise
    ##          -> define marker as -Inf on all of IMG and then pad it
    ##             with +Inf all around (and remove this padding after
    ##             the following operations)
    ##      * define the mask as complement of IMG
    ##          -> define the mask as complement of IMG, and then pad it
    ##             with +Inf all around
    ##
    ##   step 1: define the mask as complement of IMG, then pad it with
    ##           +Inf all around
    ##   step 2: define marker as -Inf an all of IMG, then pad it with
    ##           +Inf all around
    ##   step 3: do morphological reconstruction of marker by mask
    ##   step 4: complement the result and remove border padding

    mask = imcomplement (img);
    if (islogical (img))
      mask = padarray (mask, [1 1], true, "both");
    else
      mask = padarray (mask, [1 1], +Inf, "both");
    endif

    marker = mask;
    if (islogical (img))
      marker(2:end-1, 2:end-1) = false;
    else
      marker(2:end-1, 2:end-1) = -Inf;
    endif

    filled = imreconstruct (marker, mask, conn);

    filled = imcomplement (filled(2:end-1, 2:end-1));

  else
    ## Using explicitly given marker pixels instead of "holes" option
    ## should only be used for logical images
    ## no border padding necessary in this case

    mask = imcomplement (img);

    marker = false (size (img));
    marker (locations) = mask (locations);

    filled = imreconstruct (marker, mask, conn);

    ## Adjusted step 4: add the filled hole(s) FILLED to the original image IMG
    filled = img | filled;
  endif

endfunction

## Helper function for LOCATIONS input checking.
## Drops locations outside of the image and proceeds with a warning.
## Additionally transforms matrix indices to linear indices.
function loc_lin_idx = check_loc (loc, im_size)
  if (size (loc, 2) == 1)  # linear indices given
    idx_outside = loc > prod (im_size);
    loc(idx_outside) = [];
    loc_lin_idx = loc;
  elseif (size (loc, 2) == 2)  # subscript indices given
    idx_outside_x = loc(:, 1) > im_size(1);
    idx_outside_y = loc(:, 2) > im_size(2);
    idx_outside = idx_outside_x | idx_outside_y;
    loc(idx_outside,:) = [];
    loc_lin_idx = sub2ind (im_size, loc(:,1), loc(:,2));
  else
    error ("imfill: LOCATION must be a n-by-1 vector or n-by-2 sized index array");
  endif

  if (any (idx_outside))
    warning ("imfill: dropped LOCATIONs outside of given image");
  endif
endfunction

## test the possible INPUT IMAGE TYPES
%!test
%! I = uint8 (5.*[1 1 1; 1 0 1; 1 1 1]);
%! bw = logical ([1 1 1; 1 0 1; 1 1 1]);
%! I2 = uint8 (5.*ones (3));
%! bw2 = logical (ones (3));
%!
%! assert (imfill (int8 (I)), int8 (I2))
%! assert (imfill (int16 (I)), int16 (I2))
%! assert (imfill (int32 (I)), int32 (I2))
%! assert (imfill (int64 (I)), int64 (I2))
%! assert (imfill (uint8 (I)), uint8 (I2))
%! assert (imfill (uint16 (I)), uint16 (I2))
%! assert (imfill (uint32 (I)), uint32 (I2))
%! assert (imfill (uint64 (I)), uint64 (I2))
%! assert (imfill (single (I)), single (I2))
%! assert (imfill (double (I)), double (I2))
%! assert (imfill (bw, "holes"), bw2)
%! assert (imfill (uint8 (bw)), uint8 (bw2))

## test the INPUT CHECKS
%!error <must be a 2D logical or gray-scale>
%!  imfill (ones (3, 3, 3));                 # Nd-image input

%!error <must be a 2D logical or gray-scale>
%!  imfill (i + ones (3, 3));                 # complex input

%!error <must be a 2D logical or gray-scale>
%!  imfill (sparse (double (I)));   # sparse input

%!error
%!  imfill ();

%!error
%! imfill (true (3), 4, "holes", 5)

%!error <LOCATION must be a n-by-1 vector or n-by-2 sized index array>
%! imfill (false (3), ones (2, 3))

%!error <second argument must be 'holes', a connectivity specification, or an index array>
%! imfill (false (3), ones (2, 2, 2))

%!error <LOCATION must be a n-by-1 vector or n-by-2 sized index array>
%! imfill (false (3), ones (2, 3), 4)

%!error <interactive usage is not yet supported>
%! imfill (false (3))

%!error <interactive usage is not yet supported>
%! imfill (false (3), 0, 4)

## test dealing with locations out of image
%!warning <dropped LOCATIONs outside>
%! imfill (logical (ones (3)), 10);

%!warning
%! ## use "!warning" here instead of "!test" to silence expected warnings
%! bw = logical ([1 1 1; 1 0 1; 1 1 1]);
%! assert (imfill (bw, [5 5]), bw)
%! assert (imfill (bw, 15), bw)

## test BINARY hole filling and binary filling from starting point
%!test
%! bw = logical ([1 0 0 0 0 0 0 0
%!                1 1 1 1 1 0 0 0
%!                1 0 0 0 1 0 1 0
%!                1 0 0 0 1 1 1 0
%!                1 1 1 1 0 1 1 1
%!                1 0 0 1 1 0 1 0
%!                1 0 0 0 1 0 1 0
%!                1 0 0 0 1 1 1 0]);
%! bw2 = logical ([1 0 0 0 0 0 0 0
%!                 1 1 1 1 1 0 0 0
%!                 1 1 1 1 1 0 1 0
%!                 1 1 1 1 1 1 1 0
%!                 1 1 1 1 1 1 1 1
%!                 1 0 0 1 1 1 1 0
%!                 1 0 0 0 1 1 1 0
%!                 1 0 0 0 1 1 1 0]);
%! bw3 = logical ([1 0 0 0 0 0 0 0
%!                 1 1 1 1 1 0 0 0
%!                 1 1 1 1 1 0 1 0
%!                 1 1 1 1 1 1 1 0
%!                 1 1 1 1 0 1 1 1
%!                 1 0 0 1 1 0 1 0
%!                 1 0 0 0 1 0 1 0
%!                 1 0 0 0 1 1 1 0]);
%! assert (imfill (bw, "holes"), bw2)
%! assert (imfill (bw, 8, "holes"), bw2)
%! assert (imfill (bw, 4, "holes"), bw2)
%! assert (imfill (bw, [3 3]), bw3)
%! assert (imfill (bw, 19), bw3)
%! assert (imfill (bw, [3 3], 4), bw3)
%! assert (imfill (bw, 19, 4), bw3)
%! assert (imfill (bw, [3 3], 8), bw2)
%! assert (imfill (bw, 19, 8), bw2)
%! assert (imfill (bw, [19; 20]), bw3)
%! assert (imfill (bw, [19; 20], 4), bw3)
%! assert (imfill (bw, [19; 20], 8), bw2)

%!warning
%! ## use "!warning" here instead of "!test" to silence expected warnings
%! bw = logical ([1 1 1 1 1 1 1
%!                1 0 0 0 0 0 1
%!                1 0 1 1 1 0 1
%!                1 0 1 0 1 0 1
%!                1 0 1 1 1 0 1
%!                1 0 0 0 0 0 1
%!                1 1 1 1 1 1 1]);
%! bw44 = logical ([1 1 1 1 1 1 1
%!                  1 0 0 0 0 0 1
%!                  1 0 1 1 1 0 1
%!                  1 0 1 1 1 0 1
%!                  1 0 1 1 1 0 1
%!                  1 0 0 0 0 0 1
%!                  1 1 1 1 1 1 1]);
%! bw9 = logical ([1 1 1 1 1 1 1
%!                 1 1 1 1 1 1 1
%!                 1 1 1 1 1 1 1
%!                 1 1 1 0 1 1 1
%!                 1 1 1 1 1 1 1
%!                 1 1 1 1 1 1 1
%!                 1 1 1 1 1 1 1]);
%! assert (imfill (bw, "holes"), logical (ones (7)))
%! assert (imfill (bw, [4 4]), bw44)
%! assert (imfill (bw, 9), bw9)
%! assert (imfill (bw, [4 4; 10 10]), bw44)

%!test
%! bw = logical ([1 1 0 1 1]);
%! assert (imfill (bw, "holes"), bw)
%! bw = logical([1 1 0 1 1; 1 1 1 1 1]);
%! assert (imfill (bw, "holes"), bw)

## test hole filling with extravagant connectivity definitions
%!test
%! I = zeros (5);
%! I(:, [2 4]) = 1;
%! I2_expected = [0   1   1   1   0
%!                0   1   1   1   0
%!                0   1   1   1   0
%!                0   1   1   1   0
%!                0   1   1   1   0];
%! I2 = imfill (I, [0 0 0; 1 1 1; 0 0 0], "holes");
%! assert (I2, I2_expected)

%!test
%! I = zeros (5);
%! I(:, [2 4]) = 1;
%! I2_expected = I;
%! I2 = imfill (I, [0 1 0; 0 1 0; 0 1 0], "holes");
%! assert (I2, I2_expected)

%!test  # this test is Matlab compatible
%! I = zeros (5);
%! I(:, [2 4]) = 1;
%! I2_expected = inf .* ones (5);
%! I2 =  imfill (I, [0 0 0; 0 1 0; 0 0 0], "holes");
%! assert (I2, I2_expected)

%!test
%! I = false (5);
%! I(:, [2 4]) = true;
%! I2_expected = true (5);
%! I2 = imfill (I, [0 0 0; 0 1 0; 0 0 0], "holes");
%! assert (I2, I2_expected)

## test GRAYSCALE hole filling
%!test
%! I  = uint8 ([10 20 80 85 20
%!              15 90 03 25 88
%!              05 85 02 50 83
%!              90 04 03 80 80
%!             10 81 83 85 30]);
%! I2 = uint8 ([10 20 80 85 20
%!              15 90 80 80 88
%!              05 85 80 80 83
%!              90 80 80 80 80
%!             10 81 83 85 30]);
%! I3  = uint8 ([10 20 80 85 20
%!               15 90 05 25 88
%!               05 85 05 50 83
%!               90 05 05 80 80
%!               10 81 83 85 30]);
%! assert (imfill (I), I2)
%! assert (imfill (I, 4), I2)
%! assert (imfill (I, 4, "holes"), I2)
%! assert (imfill (I, 8), I3)
%! assert (imfill (I, "holes"), I2)
