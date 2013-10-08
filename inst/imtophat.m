## Copyright (C) 2005 Carvalho-Mariel
## Copyright (C) 2010-2013 Carnë Draug <carandraug@octave.org>
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
## @deftypefn {Function File} @var{B} = imtophat (@var{A}, @var{se})
## Perform morphological top hat filtering.
##
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element. Both must have the same class, e.g., if @var{A} is a
## logical matrix, @var{se} must also be logical.
##
## A 'black', or 'closing', top-hat transform is also known as bottom-hat
## transform and so that is the same @code{imbothat}.
##
## @seealso{imerode, imdilate, imopen, imclose, imbothat, mmgradm}
## @end deftypefn

function retval = imtophat (im, se)

  ## Checkinput
  if (nargin != 2)
    print_usage ();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imtophat: first input argument must be a real matrix");
  elseif (!ismatrix(se) || !isreal(se))
    error("imtophat: second input argument must be a real matrix");
  elseif ( !strcmp(class(im), class(se)) )
    error("imtophat: image and structuring element must have the same class");
  endif

  ## Perform filtering
  ## Note that in case that the transform is to applied to a logical image,
  ## subtraction must be handled in a different way (x & !y) instead of (x - y)
  ## or it will return a double precision matrix
  if (islogical(im))
    retval = im & !imopen(im,se);
  else
    retval = im - imopen(im, se);
  endif

endfunction

%!test
%! I = [1 1 1; 1 1 1; 1 1 1;];
%! se = [1 1; 0 1;];
%! ## class of input should be the same as the output
%! result = imtophat(logical(I), logical(se));
%! expected = 0.5 < [0 0 1; 0 0 1; 1 1 1];
%! assert(expected, result);
%! result = imtophat((I), (se));
%! expected = [0 0 1; 0 0 1; 1 1 1];
%! assert(expected, result);
