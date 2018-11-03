## Copyright (C) 2018 Martin Janda <janda.martin1@gmail.com>
##
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {} {@var{BW} =} bwunpack (@var{BWP}, @var{m})
## Unpack binary image.
##
## Each row of a packed binary image @var{BWP} represented as a uint32 matrix
## is unpacked into 32 rows of pixels of the original image @var{BW} such that
## the least significant bit of each uint32 element maps to the pixel in the
## first @var{BW} row and the most significant bit to pixel of the 32th row.
##
## @var{BW} is @var{m}xN logical matrix with the same number of dimensions as
## @var{BWP} (possibly more than two).  If @var{m} is not specified, it
## defaults to @code{size(BWP, 1) * 32}.  The number of output rows is always
## @code{min(m, size(BWP, 1) * 32)}.
##
## Implementation note: uses bitunpack internally.
##
## @seealso{bwpack, bitpack, bitunpack}
## @end deftypefn

function BW = bwunpack (BWP, m)
  if (nargin < 1)
    print_usage ();
  endif

  if (! isa (BWP, "uint32"))
    error("Octave:invalid-input-arg", "BWP must be an uint32 matrix");
  endif

  if (exist ("m") && ! (floor(m) == m && m >= 0))
    error("Octave:invalid-input-arg", "m must be a non-negative integer");
  endif

  dim = size (BWP);
  dim(1) = dim(1) * 32;
  BW = reshape (bitunpack (BWP), dim);

  if (! exist ("m"))
    m = size (BWP, 1) * 32;
  endif
  BW(m+1:end, :) = [];
endfunction

## test argument checking
%!error id=Octave:invalid-fun-call bwunpack()
%!error id=Octave:invalid-input-arg bwunpack(uint8(ones(3, 3)))
%!error id=Octave:invalid-input-arg bwunpack(uint32(ones(3, 3)), -1)
%!error id=Octave:invalid-input-arg bwunpack(uint32(ones(3, 3)), 4.2)

## simple cases
%!assert (bwunpack(uint32([])), logical([]))
%!assert (bwunpack(uint32([]), 0), logical([]))
%!assert (bwunpack(uint32(2.^[0:31])), logical(eye(32)))
%!assert (bwunpack(uint32(7 * ones(1, 3, 3, 3)), 3), logical(ones(3, 3, 3, 3)))
