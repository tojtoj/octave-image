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
## @deftypefn {Function File} {@var{out} =} imdivide (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{out} =} imdivide (@var{a}, @var{b}, @var{class})
## Divide image by another image or constant.
##
## If @var{a} and @var{b} are two images of same size and class, @var{a} is divided
## by @var{b}. Alternatively, if @var{b} is a floating-point scalar, @var{a} is divided
## by it.
##
## The class of @var{out} will be the same as @var{a} unless @var{a} is logical
## in which case @var{out} will be double. Alternatively, the class can be
## specified with @var{class}.
##
## @emph{Note}: the values are truncated to the mininum value of the output
## class.
## @seealso{imadd, imsubtract}
## @end deftypefn

function img = imdivide (img, val, out_class = class (img))

  if (nargin < 2 || nargin > 3)
    print_usage;
  endif
  [img, val] = imarithmetics ("imdivide", img, val, out_class);

  ## matlab doesn't even gives a warning in this situation, it simply returns
  ## a double precision float
  if (nargin > 2 && strcmpi (out_class, "logical"))
    warning ("Ignoring request to return logical as output of division.");
  endif

  warn = warning ("query", "Octave:divide-by-zero");
  unwind_protect
    img = img ./ val;
  unwind_protect_cleanup
    warning (warn.state, "Octave:divide-by-zero")
  end_unwind_protect

endfunction