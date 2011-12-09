## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{out} =} imadd (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{out} =} imadd (@var{a}, @var{b}, @var{class})
## Add image or constant to an image.
##
## If @var{a} and @var{b} are two images of same size and class, the images are
## added. Alternatively, if @var{b} is a floating-point scalar, its value is added
## to the image @var{a}.
##
## The class of @var{out} will be the same as @var{a} unless @var{a} is logical
## in which case @var{out} will be double. Alternatively, the class can be
## specified with @var{class}.
##
## Note that the values are truncated to the maximum value of the output class.
## @end deftypefn

function img = imadd (img, val, out_class = class (img))

  if (nargin < 2 || nargin > 3)
    print_usage;
  elseif ((!isnumeric (img) && !islogical (img)) || isempty (img) || issparse (img) || !isreal (img))
    error ("first argument must be a numeric or logical, non-empty, non-sparse real matrix")
  elseif ((!isnumeric (val) && !islogical (val)) || isempty (val) || issparse (val) || !isreal (val))
    error ("second argument must be a numeric, non-empty, non-sparse real matrix")
  elseif (!ischar (out_class))
    error ("third argument must be a string that specifies the output class")
  endif

  img_class = class (img);
  if (all (size (img) == size (val)) && strcmpi (img_class, class (val)))
    [img, val] = convert (out_class, img, val);
  elseif (isscalar (val) && isfloat (val))
    ## according to matlab's documentation, if val is not an image of same size
    ## and class as img, then it must be a double scalar. But why not also support
    ## a single scalar and use isfloat?
    img = convert (out_class, img);
  else
    error ("second argument must either be of same class and size of the first or a floating point scalar")
  end

  ## output class is the same as input img, unless img is logical in which case
  ## it should be double. In that case, I'm assuming that if both images are
  ## logical, the addition is made as if they were doubles.
  ## should ask someone to test the following in matlab:
  ## a = logical([1 0 1 1]); b = logical([1 0 0 0]); c = imadd (a, b);
  ## a = logical([1 0 1 1]); b = logical([1 0 1 1]); c = imadd (a, b, "logical");
  ## what's important to check is:
  ##    (1) is c(1) == 2 on the first example? Then addition is done img + val.
  ##    (2) output class. If it is logical on the second example
  ## also the following
  ## a = uint16(round(rand(5)*300)); b = uint16(round(rand(5)*300)); c = imadd (a, b, "uint8")
  ##  what happens when the request output class does not take even the values
  ## of the input image? Is the requested for the class also honored?
  img = img + val;

endfunction

function [a, b] = convert (out_class, a, b = 0)
  ## in the case that we only want to convert one matrix, this subfunction is called
  ## with 2 arguments only. Then, b takes the value of zero so that the call to the
  ## functions that change the class is insignificant
  if (!strcmpi (class (a), out_class))
    switch tolower (out_class)
      case {"logical"}  a = logical (a); b = logical (b);
      case {"uint8"}    a = uint8   (a); b = uint8   (b);
      case {"uint16"}   a = uint16  (a); b = uint16  (b);
      case {"uint32"}   a = uint32  (a); b = uint32  (b);
      case {"double"}   a = double  (a); b = double  (b);
      case {"single"}   a = single  (a); b = single  (b);
      otherwise
        error ("requested class '%s' for output is not supported")
    endswitch
  endif
endfunction
