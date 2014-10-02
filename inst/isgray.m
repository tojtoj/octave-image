## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} isgray (@var{img})
## Return true if @var{img} is an indexed image.
##
## A variable can be considered a grayscale image if it is a non-sparse
## matrix of size @nospell{MxNx1xK} and:
##
## @itemize @bullet
## @item is of class double and all values are in the range [0, 1] or NaN;
## @item is of class uint8, uint16 or int16.
## @end itemize
##
## @strong{Note:} despite their suggestive names, the functions isbw,
## isgray, isind, and isrgb, are ambiguous since it is not always possible
## to distinguish between those image types.  For example, an uint8 matrix
## can be both a grayscale and indexed image.  They are good to dismiss
## input as an invalid image type, but not for identification.
##
## @seealso{gray2ind, isbw, isind, isrgb}
## @end deftypefn

function bool = isgray (img)

  if (nargin != 1)
    print_usage ();
  endif

  bool = false;
  if (isimage (img) && ndims (img) < 5 && size (img, 3) == 1)
    switch (class (img))
      case "double"
        bool = ispart (@is_double_image, img);
      case {"uint8", "uint16", "int16"}
        bool = true;
    endswitch
  endif

endfunction

%!test
%! a = rand (100);
%! assert (isgray (a), true);
%! a(50, 50) = 2;
%! assert (isgray (a), false);

%!test
%! a = uint8 (randi (255, 100));
%! assert (isgray (a), true);
%! a = int8 (a);
%! assert (isgray (a), false);

%!test
%! a = rand (100);
%! a(500) = NaN;
%! assert (isgray (a), true);

%!assert (isgray (rand (5, 5, 1, 4)), true);
%!assert (isgray (rand (5, 5, 3, 4)), false);
%!assert (isgray (rand (5, 5, 3)), false);
%!assert (isgray (rand (5, 5, 1, 3, 4)), false);
