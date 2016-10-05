## Copyright (C) 2012-2015 Carnë Draug
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## FIXME: remove once the image package is dependent on Octave 4.2 or
##        later.  We need a version of iscolormap that accepts values
##        outside [0 1] for colourspace conversion, see patch #8713.
##        So we copied this from Octave core (cset 31b4b614ed55).

## Author: Carnë Draug <carandraug+dev@gmail.com>

function retval = iscolormap (cmap)

  if (nargin != 1)
    print_usage;
  endif

  retval = (isnumeric (cmap) && isreal (cmap)
            && ndims (cmap) == 2 && columns (cmap) == 3
            && isfloat (cmap));

endfunction


%!assert (iscolormap (jet (64)))
%!assert (iscolormap ({0 1 0}), false)
%!assert (iscolormap ([0 1i 0]), false)
%!assert (iscolormap (ones (3,3,3)), false)
%!assert (iscolormap (ones (3,4)), false)
