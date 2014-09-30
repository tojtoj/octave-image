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
## @deftypefn  {Function File} {} isbw (@var{img})
## @deftypefnx {Function File} {} isbw (@var{img}, @var{logic})
## Return true if @var{img} is a black and white image.
##
## A variable can be considered a black and white image if it is a
## non-sparse matrix of size @nospell{MxNx1xK}, and depending on the
## string @var{logic}, defined as:
##
## @table @asis
## @item @qcode{"logical"} (default)
## @var{img} must be of class logical.
##
## @item @qcode{"non-logical"}
## all values in @var{img} are either 1 or 0.
## @end table
##
## @strong{Note:} despite their suggestive names, the functions isbw,
## isgray, isind, and isrgb, are ambiguous since it is not always possible
## to distinguish between those image types.  For example, an uint8 matrix
## can be both a grayscale and indexed image.  They are good to dismiss
## input as an invalid image type, but not for identification.
##
## @seealso{im2bw, isgray, isind, islogical, isrgb}
## @end deftypefn

function bool = isbw (BW, logic = "logical")

  if (nargin < 1 || nargin > 2)
    print_usage;
  endif

  bool = false;
  if (isimage (BW) && ndims (BW) < 5 && size (BW, 3) == 1)
    if (strcmpi (logic, "logical"))
      ## this is the matlab compatible way (before they removed the function)
      bool = islogical (BW);

    elseif (strcmpi (logic, "non-logical"))
      bool = islogical (BW) || ispart (@is_bw_nonlogical, BW);

    else
      error ("isbw: LOGIC must be the string 'logical' or 'non-logical'")
    endif
  endif

endfunction

function bool = is_bw_nonlogical (BW)
  bool = ! any ((BW(:) != 1) & (BW(:) != 0));
endfunction

%!test
%! a = round (rand (100));
%! assert (isbw (a, "non-logical"), true);
%! assert (isbw (a, "logical"), false);
%! assert (isbw (logical (a), "logical"), true);
%! assert (isbw (logical (a), "non-logical"), true);
%!
%! ## change when the different value is near the start and then in middle,
%! ## because of the way we test part of the image before the rest
%! a(1, 1) = 2;
%! assert (isbw (a, "non-logical"), false);
%!
%! a( 1,  1) = 1;
%! a(50, 50) = 2;
%! assert (isbw (a, "non-logical"), false);
