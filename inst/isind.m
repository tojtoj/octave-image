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
## @deftypefn {Function File} {} isind (@var{img})
## Return true if @var{img} is an indexed image.
##
## A variable can be considered an indexed image if it is a non-sparse
## matrix of size @nospell{MxNx1xK} and:
##
## @itemize @bullet
## @item is of class double but all values are integers greater than
## or equal to 1;
## @item is of class uint8 or uint16.
## @end itemize
##
## @strong{Note:} despite their suggestive names, the functions isbw,
## isgray, isind, and isrgb, are ambiguous since it is not always possible
## to distinguish between those image types.  For example, an uint8 matrix
## can be both a grayscale and indexed image.  They are good to dismiss
## input as an invalid image type, but not for identification.
##
## @seealso{ind2gray, ind2rgb, isbw, isgray, isindex, isrgb}
## @end deftypefn

function bool = isind (img)

  if (nargin != 1)
    print_usage;
  endif

  bool = false;
  if (isimage (img) && ndims (img) < 5 && size (img, 3) == 1)
    switch (class (img))
      case "double"
        bool = isindex (img);
      case {"uint8", "uint16"}
        bool = true;
    endswitch
  endif

endfunction

%!assert (isind ([]), false);
%!assert (isind (1:10), true);
%!assert (isind (0:10), false);
%!assert (isind (1), true);
%!assert (isind (0), false);
%!assert (isind ([1.3 2.4]), false);
%!assert (isind ([1 2; 3 4]), true);
%!assert (isind (randi(100, 10, 10, 1, 4)), true);
%!assert (isind (randi(100, 10, 10, 3, 4)), false);
%!assert (isind (randi(100, 10, 10, 1, 4, 2)), false);
