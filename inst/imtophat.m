## Copyright (C) 2005  Carvalho-Mariel
## 
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## -*- texinfo -*-
## @deftypefn {Function File} @var{B} = imtophat (@var{A}, @var{se})
## Perform morphological top hat filtering.
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element.
## @end deftypefn

function retval = imtophat(im, se)
  ## Checkinput
  if (nargin != 2)
    print_usage();
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imtophat: first input argument must be a real matrix");
  endif
  if (!ismatrix(se) || !isreal(se))
    error("imtophat: second input argument must be a real matrix");
  endif
  
  ## Perform filtering
  retval = im & !imopen(im, SE);

endfunction
