## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2008 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2010 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn  {Function File} {@var{im2} =} imdilate (@var{im}, @var{se})
## @deftypefnx {Function File} {@var{im2} =} imdilate (@var{im}, @var{se}, @var{shape})
## Perform morphological dilation on a given image.
##
## The image @var{im} must be black and white or grayscale image, with any number
## of dimensions.
##
## @var{se} is the structuring element used for the erosion and must be a matrix
## of 0's and 1's.
##
## The size of the result is determined by the optional @var{shape} argument
## which takes the following values:
##
## @table @asis
## @item "same" (default)
## Return image of the same size as input @var{im}.
## 
## @item "full"
## Return the full erosion (image is padded to accomodate @var{se} near the
## borders). Not implemented for grayscale images.
## @end table
##
## The center of @var{SE} is at the indices @code{floor ([size(@var{B})/2] + 1)}.
##
## @seealso{imerode, imopen, imclose}
## @end deftypefn

function im = imdilate (im, se, shape = "same")

  if (nargin < 2 || nargin > 3)
    print_usage();
  elseif (! ischar (shape) || ! any (strcmpi (shape, {"same", "full"})))
    error ("imdilate: SHAPE must be `same' or `full'")
  endif

  if (! isbw (im, "non-logical"))
    error ("imerode: SE must be a matrix of 0's and 1's");
  endif

  cl = class (im);
  if (isbw (im, "non-logical"))
    im = convn (im, se, shape) > 0;
  elseif (isimage (im))
    ## TODO needs to implement the shape option here. Most likely requires a
    ##      to be padded first (padarray), and use of __spatial_filtering__
    ##      directly (that's what ordfiltn does) with the "max" method. The
    ##      same needs to be done for imerode
    im = ordfiltn (im, nnz (se), se, -Inf);
  else
    error ("imdilate: IM must be a grayscale or black and white matrix");
  endif

  ## we return image on same class as input
  im = cast (im, cl);
endfunction

%!demo
%! imdilate(eye(5),ones(2,2))
%! % returns a thick diagonal.

%!assert(imdilate(eye(3),[1]), eye(3));                     # using [1] as a mask returns the same value
%!assert(logical(imdilate(eye(3),[1])), logical(eye(3)));   # same with logical matrix
%!assert(imdilate(eye(3),[1,0,0]), [0,0,0;1,0,0;0,1,0]);                            # check if it works with non-symmetric SE
%!assert(imdilate(logical(eye(3)),logical([1,0,0])), logical([0,0,0;1,0,0;0,1,0])); # same with logical matrix
## test if center is correctly calculated on even masks. There's no right way,

## it all depends what is considered the center of the structuring element. The
## expected answer here is what Matlab does
%!xtest assert(imdilate(eye(5),[1,0,0,0]), [0,0,0,0,0;1,0,0,0,0;0,1,0,0,0;0,0,1,0,0;0,0,0,1,0]);
