## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {} iscolormap (@var{cm})
## Return true if @var{cm} is a colormap.
##
## A colormap is an @var{n} row by 3 column matrix.  The columns contain red,
## green, and blue intensities respectively.  All entries should be between 0
## and 1 inclusive.
##
## @seealso{colormap}
## @end deftypefn

function bool = iscolormap (cm)

  if (nargin != 1)
    print_usage;
  endif

  bool = false;
  if (ismatrix (cm) && isreal (cm) && isnumeric (cm) && columns(cm) == 3 &&
      ndims (cm) == 2 && strcmp (class (cm), "double") &&
      min (cm(:)) >= 0 && max (cm(:)) <= 1)
    bool = true;
  endif

endfunction
