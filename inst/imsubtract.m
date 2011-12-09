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
## @deftypefn {Function File} {@var{out} =} imsubtract (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{out} =} imsubtract (@var{a}, @var{b}, @var{class})
## Subtract image or constant to an image.
##
## If @var{a} and @var{b} are two images of same size and class, @var{b} is subtracted
## to @var{a}. Alternatively, if @var{b} is a floating-point scalar, its value is subtracted
## to the image @var{a}.
##
## The class of @var{out} will be the same as @var{a} unless @var{a} is logical
## in which case @var{out} will be double. Alternatively, the class can be
## specified with @var{class}.
##
## @emph{Note 1}: you can force output class to be logical by specifying
## @var{class}. This is incompatible with @sc{matlab} which will @emph{not} honour
## request to return a logical matrix.
##
## @emph{Note 2}: the values are truncated to the mininum value of the output
## class.
## @seealso{imadd}
## @end deftypefn

function img = imsubtract (img, val, out_class = class (img))

  if (nargin < 2 || nargin > 3)
    print_usage;
  endif
  [img, val] = imarithmetics ("imsubtract", img, val, out_class);

  ## The following makes the code imcompatible with matlab on certain cases.
  ## This is on purpose. Read comments in imadd source for the reasons
  if (nargin > 2 && strcmpi (out_class, "logical"))
    img = img > val;
  else
    img = img - val;
  endif

endfunction
