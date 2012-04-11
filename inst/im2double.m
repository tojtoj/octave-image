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
## along with this file.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{im2} = im2double(@var{im1})
## Converts the input image to an image of class double.
##
## If the input image is of class double the output is unchanged.
## If the input is of class uint8 the result will be converted to doubles
## and divided by 255, and if the input is of class uint16 the image will
## be converted to doubles and divided by 65535.
## @seealso{im2bw, im2uint16, im2uint8}
## @end deftypefn

function im2 = im2double(im1)
  ## Input checking
  if (nargin < 1)
    print_usage();
  elseif (!isgray(im1) && !isrgb(im1) && !isbw(im1))
    error("im2double: input must be an image");
  endif

  ## Take action depending on the class of the data
  switch (class(im1))
    case "double"
      im2 = im1;
    case "logical"
      im2 = double(im1);
    case "uint8"
      im2 = double(im1) / 255;
    case "uint16"
      im2 = double(im1) / (pow2(16)-1);
    otherwise
      error("im2double: unsupported image class");
  endswitch
endfunction
