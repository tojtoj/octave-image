## Copyright (C) 2004 Josep Mones i Teixidor  <jmones@puntbarra.com>
## Copyright (C) 2008 Soren Hauberg
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} @var{B} = imerode (@var{A}, @var{se})
## Perform morphological erosion on a given image.
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element.
## @seealso{imdilate, imopen, imclose}
## @end deftypefn

function retval = imerode(im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imerode: first input argument must be a real matrix");
  endif
  if (!ismatrix(se) ||  !isreal(se))
    error("imerode: second input argument must be a real matrix");
  endif

  ## Perform filtering
  ## If image is binary/logical, try to use filter2 (much faster)
  if (islogical(im))
    thr     = sum(se(:));
    retval  = filter2(se,im) == thr;
  else
    retval  = ordfiltn(im, 1, se, 0);
  endif

endfunction
