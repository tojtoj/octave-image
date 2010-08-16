## Copyright (C) 2008 Soren Hauberg
## Copyright (C) 2010 Carnë Draug <carandraug+dev@gmail.com>
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

  ## Perform filtering
  ## Filtering must be done with the reflection of the structuring element (they
  ## are not always symmetrical)
  se      = imrotate(se, 180);

  ## If image is binary/logical, try to use filter2 (much faster)
  if (islogical(im))
    # The following line comes from the function dilate, copyright by Josep Mones i Teixidor
    retval  = filter2(se,im)>0;
  else
    retval  = ordfiltn(im, sum(se(:)!=0), se, 0);
  endif

endfunction
