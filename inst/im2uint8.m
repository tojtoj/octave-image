## Copyright (C) 2007  Søren Hauberg
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details. 
## 
## You should have received a copy of the GNU General Public License
## along with this file.  If not, write to the Free Software Foundation,
## 59 Temple Place - Suite 330, Boston, MA 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} @var{im2} = im2uint8(@var{im1})
## Converts the input image to an image of class uint8.
##
## If the input image is of class uint8 the output is unchanged.
## If the input is of class double the result will be multiplied
## by 255 and converted to uint8, and if the input is of class uint16 the
## image will be divided by 257 and converted to uint8.
## @seealso{im2bw, im2uint16, im2double}
## @end deftypefn

function im2 = im2uint8(im1)
  ## Input checking
  if (nargin < 1)
    print_usage();
  endif
  if (!isgray(im1) && !isrgb(im1))
    error("im2uint8: input must be an image");
  endif
  
  ## Take action depending on the class of the data
  switch (class(im1))
    case "double"
      im2 = uint8(255*im1);
    case "uint8"
      im2 = im1;
    case "uint16"
      im2 = uint8(im1/257);
    otherwise
      error("im2uint8: unsupported image class");
  endswitch
endfunction
