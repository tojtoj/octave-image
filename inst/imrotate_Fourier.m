## Copyright (C) 2002 Jeff Orchard <jorchard@cs.uwaterloo.ca>
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
## @deftypefn {Function File} {} imrotate_Fourier (@var{M}, @var{theta}, @var{method}, @var{bbox})
## Rotation of a 2D matrix.
##
## @emph{This function has been deprecated and will be removed. Instead, use
## @code{imrotate} and select the @code{fourier} method. This function is
## actually just a wrapper to that function.}
##
## @seealso{imrotate}
## @end deftypefn

function fs = imrotate_Fourier (f, theta, method = "fourier", bbox = "loose")

  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("Octave:deprecated-function",
             "`imrotate_Fourier' has been deprecated in favor of `imrotate (M, theta, \"fourier\")'. This function will be removed from future versions of the `image' package");
  endif
  fs = imrotate (f, theta, "fourier", bbox)

endfunction
