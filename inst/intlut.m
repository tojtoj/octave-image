## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
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
## @deftypefn {Function File} {} intlut (@var{A}, @var{LUT})
## Convert matrix from look up table (LUT).
##
## Replaces the values from the matrix @var{A} with the corresponding value
## from the look up table @var{LUT} (this is the grayscale equivalent to an
## indexed image).
##
## @var{A} and @var{LUT} must be of the same class, and uint8, uint16, or int16.
## @var{LUT} must have exactly 256 elements for class uint8, and 65536 for
## classes uint16 and int16.  Output is of same class as @var{LUT}.
##
## @seealso{ind2gray, ind2rgb, rgb2ind}
## @end deftypefn

function B = intlut (A, LUT)
  if (nargin != 2)
    print_usage ();
  elseif (! strcmp (class (A), class (LUT)))
    error ("intlut: A and LUT must be of same class");
  elseif (! isvector (LUT))
    error ("intlut: LUT must be a vector");
  endif

  cl= class (A);
  switch (cl)
    case {"uint8"},           max_numel = 256;
    case {"int16", "uint16"}, max_numel = 65536;
    otherwise
      error ("intlut: A must be of class uint8, uint16, or int16");
  endswitch
  if (max_numel != numel (LUT))
    error ("intlut: LUT must have %d elements for class %s", max_numel, cl);
  endif

  ## We need to convert to double in case of the values in A is
  ## equal to intmax (class (A))
  A = double (A);
  if (strcmp ("int16", cl))
    A += 32769;
  else
    A += 1;
  endif

  B = LUT(A);
endfunction

%!demo
%! ## Returns an uint8 array [254 253 252 251]
%! intlut (uint8 ([1 2 3 4]), uint8 ([255:-1:0]));

%!assert (intlut (uint8  (1:4), uint8  (  255:-1:0)), uint8  (254:-1:251));
%!assert (intlut (uint16 (1:4), uint16 (65535:-1:0)), uint16 (65534:-1:65531));
%!assert (intlut (int16  (1:4), int16  (32767:-1:-32768)), int16 (-2:-1:-5));

%!assert (intlut (uint8 (255), uint8 (0:255)), uint8 (255));
%!assert (intlut (uint16 (65535), uint16 (0:65535)), uint16 (65535));
%!assert (intlut (int16 (32767), int16 (-32768:32767)), int16 (32767));

%!error intlut ()
%!error intlut ("text")
%!error <class> intlut (1:20, uint8(0:255));
%!error <class> intlut (uint16(1:20), uint8(0:255));
%!error <have 256 elements> intlut (uint8 (1:20), uint8 (0:200));
