## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2012, 2013 Carnë Draug <carandraug@octave.org>
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
## @deftypefn  {Function File} {} im2bw (@var{img}, threshold)
## @deftypefnx {Function File} {} im2bw (@var{X}, @var{cmap}, threshold)
## Convert image to binary, black and white, by threshold.
##
## The input image @var{img} can either be a grayscale or RGB image.  In the later
## case, @var{img} is first converted to grayscale with @code{rgb2gray}.  Input
## can also be an indexed image @var{X} in which case the colormap @var{cmap}
## needs to be specified.
##
## The value of @var{threshold} should be in the range [0,1] independently of the
## class of @var{img}.  Values from other classes can be converted to the correct
## value with @code{im2double} for example.  For an automatic threshold, consider
## using @code{graythresh}.
##
## @example
## @group
## bw = im2bw (img, graythresh (img));
## @end group
## @end example
##
## @seealso{graythresh, ind2gray, rgb2gray}
## @end deftypefn

function BW = im2bw (img, cmap, thres = 0.5)

  if (nargin < 1 || nargin > 3)
    print_usage ();
  elseif (nargin == 3 && ! isind (img))
    error ("im2bw: IMG must be an indexed image when are 3 input arguments");
  elseif (nargin == 3 && ! iscolormap (cmap))
    error ("im2bw: CMAP must be a colormap");
  elseif (nargin == 2)
    thres = cmap;
  endif

  if (! isimage (img))
    error ("im2bw: IMG must be an image");
  elseif (! isnumeric (thres) || ! isscalar (thres) || ! isreal (thres) ||
      thres < 0 || thres > 1)
    error ("im2bw: THRESHOLD must be a scalar in the interval [0, 1]");
  endif

  if (islogical (img))
    warning ("im2bw: IMG is already binary so nothing is done");
    tmp = img;

  else
    ## Convert img to gray scale
    if (nargin == 3)
      ## indexed image (we already checked that is indeed indexed earlier)
      img = ind2gray (img, cmap);
    elseif (isrgb (img))
      img = rgb2gray (img);
    else
      ## Everything else, we do nothing, no matter how many dimensions
    endif

    ## Convert the threshold value to same image class to do the thresholding which
    ## is faster than converting the image to double and keep the threshold value
    switch (class (img))
      case {"double", "single", "logical"}
        ## do nothing
      case {"uint8"}
        thres = im2uint8 (thres);
      case {"uint16"}
        thres = im2uint16 (thres);
      case {"int16"}
        thres = im2int16 (thres);
      otherwise
        ## we should have never got here in the first place anyway
        error("im2bw: unsupported image class");
    endswitch

    tmp = (img > thres); # matlab compatible (not "greater than or equal")
  endif

  if (nargout > 0)
    BW = tmp;
  else
    imshow (tmp);
  endif

endfunction

%!assert(im2bw ([0 0.4 0.5 0.6 1], 0.5), logical([0 0 0 1 1])); # basic usage
%!assert(im2bw (uint8 ([0 100 255]), 0.5), logical([0 0 1]));   # with a uint8 input

## This will issue a warning
%!assert (im2bw (logical ([0 1 0])),    logical ([0 1 0]))
%!assert (im2bw (logical ([0 1 0]), 0), logical ([0 1 0]))
%!assert (im2bw (logical ([0 1 0]), 1), logical ([0 1 0]))
