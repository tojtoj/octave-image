## Copyright (C) 2005  Carvalho-Mariel
## Copyright (C) 2010  Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefnx{Function File} @var{B} = imtophat (@var{A}, @var{se}, @var{type})
## Perform morphological top hat filtering.
##
## The image @var{A} must be a grayscale or binary image, and @var{se} must be a
## structuring element. Both must have the same class, e.g., if @var{A} is a
## logical matrix, @var{se} must also be logical.
##
## @var{type} defines the type of top hat transform. To perform a white, or
## opening, top-hat transform its value must be @code{open} or @code{white}. To
## perform a black, or closing, top-hat transform its value must be @code{close}
## or @code{black}. If @var{type} is not specified, it performs a white top-hat
## transform.
##
## @seealso{imerode, imdilate, imopen, imclose, mmgradm}
## @end deftypefn

function retval = imtophat(im, se, trans)

  ## Checkinput
  if (nargin <=1 || nargin > 3)
    print_usage();
  elseif (nargin == 2)
    trans = "white";
  endif
  if (!ismatrix(im) || !isreal(im))
    error("imtophat: first input argument must be a real matrix");
  elseif (!ismatrix(se) || !isreal(se))
    error("imtophat: second input argument must be a real matrix");
  elseif ( !strcmp(class(im), class(se)) )
    error("imtophat: image and structuring element must have the same class");
  endif

  ## Perform filtering
  if ( strcmpi(trans, "white") || strcmpi(trans, "open") )
    retval = im - imopen(im, se);
  elseif ( strcmpi(trans, "black") || strcmpi(trans, "close") )
    retval = imclose(im, se) - im;
  else
    error ("Unexpected type of top-hat transform");
  endif

endfunction

%!test
%! I = [1 1 1; 1 1 1; 1 1 1;];
%! se = [1 1; 0 1;];
%! result = logical(imtophat(I, se));
%! expected = 0.5 < [0 0 1; 0 0 1; 1 1 1];
%! assert(expected, result);

