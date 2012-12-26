## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{im2} =} imerode (@var{im}, @var{se})
## Perform morphological erosion on image.
##
## The image @var{im} must be a black and white image.
##
## @var{se} is the structuring element used for the erosion.  It can be a single
## strel object, a cell array of strel objects as returned by
## @code{@@strel/getsequence}, or a matrix of 0's and 1's.
##
## The center of @var{SE} is calculated using floor((size(@var{SE})+1)/2).
##
## Pixels outside the image are considered to be 0.
##
## @seealso{imdilate, imopen, imclose, strel}
## @end deftypefn

## TODO: we need to get grayscale erosion working again.

function im = imerode (im, se)

  if (nargin != 2)
    print_usage();
  endif

  ## it's easier to just get the sequence of strel objects now than to have a
  ## bunch of conditions later on
  if (! (iscell (se) && all (cellfun ("isclass", se, "strel"))))
    if (ismatrix (se))
      se = strel ("arbitrary", se);
    elseif (! isa (se, "strel"))
      error("imerode: SE must a strel object, or a matrix of 0's and 1's");
    endif
    se = getsequence (se);
  endif

  cl = class (im);
  if (isbw (im, "non-logical"))

    ## once we do implement getsequence for strel objects we should do
    ## something like:
    for k = 1:numel (se)
      if (isflat (se{k}))
        nhood = getnhood (se{k});
      else
        nhood = getheight (se{k});
      endif
      ## this call to rotdim is the same as nhood(end:-1:1, end:-1:1) but should
      ## work for any number of dimensions since the SE needs to be reversed for
      ## the convolution
      nhood = rotdim (nhood, 2, [1 ndims(nhood)]);
      im    = convn (im, nhood, "same") == nnz (nhood);
    endfor

  elseif (isgray (im))
    error ("imerode: grayscale erosion not yet implemented");
    ## the following code used to do this but is incorrect (checked with ImageJ)
    ## im = ordfiltn (im, 1, se, 0);
  else
    error("imerode: IM must be a grayscale or black and white matrix");
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
