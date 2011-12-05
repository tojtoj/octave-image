## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool} = isbw (@var{img})
## @deftypefnx {Function File} @var{bool} = isbw (@var{img}, @var{logic})
## Return true if @var{img} is a black-white image.
##
## The optional argument @var{logic} must be the string `logical' or
## `non-logical'. The first defines a black and white image as a logical matrix,
## while the second defines it as a matrix comprised of the values 1 and 0
## only. Defaults to `logical'.
##
## @seealso{isgray, isind, islogical, isrgb}
## @end deftypefn

function bool = isbw (BW, logic = "logical")
  ## this function has been removed from version 7.3 (R2011b) of
  ## matlab's image processing toolbox
  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (!ischar (logic) && any (strcmpi (logic, {"logical", "non-logical"})))
    error ("second argument must either be a string 'logical' or 'non-logical'")
  endif

  ## an image cannot be a sparse matrix
  if (!ismatrix (BW) || issparse (BW))
    bool = false;
  elseif (strcmpi (logic, "logical"))
    ## this is the matlab compatible way (before they removed the function)
    bool = islogical (BW);

    ## the following block is just temporary since we are not being backwards compatible
    if (!islogical (BW) && all (all ((BW == 1) + (BW == 0))))
      persistent warned = false;
      if (! warned)
        warned = true;
        warning ("isbw: image is not logical matrix and therefore not binary but all values are either 0 and 1.")
        warning ("isbw: old versions of the function would return true. Use the call isbw (img, \"non-logical\") instead.")
      endif
    endif

  elseif (strcmpi (logic, "non-logical"))
    bool = all (all ((BW == 1) + (BW == 0)));
  endif
endfunction
