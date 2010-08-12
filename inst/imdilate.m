## Copyright (C) 2008 Soren Hauberg
## 
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## -*- texinfo -*-
## @deftypefn {Function File} @var{B} = imdilate (@var{A}, @var{se})
## Perform morphological dilation on a given image.
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element.
## @seealso{imerode, imopen, imclose}
## @end deftypefn

function retval = imdilate(im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imdilate: first input argument must be a real matrix");
  endif
  if (!ismatrix(se) ||  !isreal(se))
    error("imdilate: second input argument must be a real matrix");
  endif

  if (isinteger(im))
    padding = intmax(class(im));
  elseif (islogical(im))
    padding = logical(1);
  elseif (isreal(im))
    padding = Inf;
  else
    error("Unexpected class for the image. Must be logical, integer ou real matrix")
  endif

  ## Perform filtering
  ## Dilation of A by B is the erosion of A's complement by the reflection of B
  ## Since erosion will be performed in the complement, padding must also be the
  ## complement of zero
  se      = imrotate(se, 180);
  retval  = !ordfiltn(!im, 1, se, padding);

endfunction
