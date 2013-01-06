## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
## Copyright (C) 2011-2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn  {Function File} {@var{im2} =} imerode (@var{im}, @var{se})
## @deftypefnx {Function File} {@var{im2} =} imerode (@var{im}, @var{se}, @var{shape})
## Perform morphological erosion on image.
##
## The image @var{im} must be black and white or grayscale image.  The erosion
## is performed with the structuring element @var{se} which can be a:
##
## @itemize @bullet
## @item strel object;
## @item cell array of strel objects as returned by @code{@@strel/getsequence};
## @item matrix of 0's and 1's.
## @end itemize
##
## The erosion is performed in all dimensions, and both @var{im} and @var{se}
## can have any number of dimensions.
##
## To perform a non-flat erosion, @var{se} must be a strel object.
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
## borders).
## @end table
##
## The center of @var{SE} is at the indices @code{floor ([size(@var{B})/2] + 1)}.
##
## @seealso{imdilate, imopen, imclose, strel}
## @end deftypefn

function im = imerode (im, se, shape = "same")

  if (nargin < 2 || nargin > 3)
    print_usage();
  elseif (! ischar (shape) || ! any (strcmpi (shape, {"same", "full"})))
    error ("imerode: SHAPE must be `same' or `full'")
  elseif (any (strcmpi (shape, {"ispacked", "notpacked"})))
    error ("imerode: packed images are not yet implemented. See http://www.octave.org/missing.html")
  endif

  ## it's easier to just get the sequence of strel objects now than to have a
  ## bunch of conditions later on
  if (! (iscell (se) && all (cellfun ("isclass", se, "strel"))))
    if (ismatrix (se))
      se = strel ("arbitrary", se);
    elseif (! isa (se, "strel"))
      error ("imerode: SE must a strel object, or a matrix of 0's and 1's");
    endif
    seq = getsequence (se);
  endif

  cl = class (im);
  if (isbw (im, "non-logical"))
    for k = 1:numel (seq)
      nhood = getnhood (seq{k});
      nhood = reshape (nhood(end:-1:1), size (nhood)); # N-dimensional rotation
      im    = convn (im, nhood, shape) == nnz (nhood);
    endfor

  elseif (isimage (im))
    ## this is just like a minimum filter so we need to have the outside of
    ## the image above all possible values (hence Inf)
    im = pad_for_spatial_filter (im, getnhood (se), Inf)
    ## TODO we should implement the shape options in the __spatial_filtering__
    ##      code. The alternative is to perform the padding twice (ugly hack).
    ##      It also means we can't use SE decomposition...
    if (strcmpi (shape, "full"))
      im = pad_for_spatial_filter (im, getnhood (se), Inf)
    endif
    im = __spatial_filtering__ (im, logical (getnhood (se)), "min", getheight (se));
  else
    error ("imerode: IM must be a grayscale or black and white matrix");
  endif

  ## we return image on same class as input
  im = cast (im, cl);
endfunction

%!demo
%! imerode(ones(5,5),ones(3,3))
%! % creates a zeros border around ones.

%!assert (imerode (eye (3), [1]), eye (3)); # using [1] as a mask returns the same value
%!assert (imerode ([0 1 0; 1 1 1;0 1 0], [0 0 0; 0 0 1; 0 1 1]), [1 0 0; 0 0 0; 0 0 0]);

%!shared im, se, out
%! im = [0 0 0 0 0 0 0
%!       0 0 1 0 1 0 0
%!       0 0 1 1 0 1 0
%!       0 0 1 1 1 0 0
%!       0 0 0 0 0 0 0];
%! se = [0 0 0
%!       0 1 0
%!       0 1 1];
%! out = [0 0 0 0 0 0 0
%!        0 0 1 0 0 0 0
%!        0 0 1 1 0 0 0
%!        0 0 0 0 0 0 0
%!        0 0 0 0 0 0 0];
%!assert (imerode (im, se), out);
%!assert (imerode (logical (im), se), logical (out));
%!assert (imerode (im, logical (se)), out);
%!assert (imerode (logical (im), logical (se)), logical (out));

%!error imerode (ones (10), "some text")
%!error imerode (ones (10), 45)
%!error imerode (ones (10), {23, 45})
