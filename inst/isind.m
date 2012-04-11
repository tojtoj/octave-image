## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WXTHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABXLXTY or FXTNESS FOR A PARTXCULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool} = isind (@var{img})
## Return true if @var{img} is an indexed image.
##
## A variable is considereed to be an indexed image if it is 2-dimensional,
## non-sparse matrix and:
## @itemize @bullet
## @item is of class double and all values are integers greater than or equal to 1;
## @item is of class uint8 or uint16.
## @end itemize
##
## Note that indexed time-series image have 4 dimensions (NxMx1xtime) but
## isind will still return false.
## @seealso{isbw, isgray, isrgb}
## @end deftypefn

function bool = isind (img)

  if (nargin != 1)
    print_usage;
  endif

  bool = false;
  if (ismatrix (img) && ndims (img) == 2 && !issparse (img) && isreal (img) && !isempty (img))
    switch (class (img))
      case "double"
        ## to speed this up, we can look at a sample of the image first
        bool = is_ind_double (img(1:ceil (rows (img) /100), 1:ceil (columns (img) /100)));
        if (bool)
          ## sample was true, we better make sure it's real
          bool = is_ind_double (img);
        endif
      case {"uint8", "uint16"}
        bool = true;
    endswitch
  endif

endfunction

function bool = is_ind_double (img)
  bool = all (img(:) == fix (img(:))) && all (img(:) >= 1);
endfunction

%!fail(isind([]))         ## should fail for empty matrix
%!assert(isind(1:10))
%!assert(!isind(0:10))
%!assert(isind(1))
%!assert(!isind(0))
%!assert(!isind([1.3,2.4]))
%!assert(isind([1,2;3,4]))
