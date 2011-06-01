## Copyright (C) 2011 Santiago Reyes González
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.

## -*- texinfo -*-
## @deftypefn {Function File} @var{B} =  rgb2ycbcr(@var{A})
## Perform colour convertion on a given image.
## The image @var{A} must be a image.
## The convertion change the image RGB to YCbCr, i.e.
## @example
## imOut = rgb2ycbcr(imIn);
## @end example
## @seealso{cmunique, cmpermute}
## @end deftypefn

function im_out =  rgb2ycbcr(im)
  dimensiones=size(im);
  if (length(dimensiones) == 3)
    row=dimensiones(1,1);
    column=dimensiones(1,2);
    depth=dimensiones(1,3);
  end
  if (depth == 3)
    im_cal = im2double(im);
    for i=1:row
      for j=1:column
        im_out(i,j,1) = uint8(floor(77*im_cal(i,j,1)+ 150*im_cal(i,j,2) + 29*im_cal(i,j,3)));
        im_out(i,j,2) = uint8(floor(((-44*im_cal(i,j,1) - 87*im_cal(i,j,2) + 131*im_cal(i,j,3))/256 + 0.5)*256));
        im_out(i,j,3) = uint8(floor(((131*im_cal(i,j,1) - 110*im_cal(i,j,2) - 21*im_cal(i,j,3))/256 + 0.5)*256));
      endfor
    endfor
  else
    error ("rgb2ycbcr: the matrix mmust be a NxMx3");
  endif
endfunction
