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
## @deftypefn {} {@var{bwp} =} bwpack (@var{bw})
## Pack binary image.
##
## Packs binary image @var{bw} along the first (vertical) dimension so that
## each column of every 32 rows represents bit values of a single uint32
## integer.  The first row corresponds to the least significant bit and the
## 32th row corresponds to the most significant bit.
##
## The original image is zero-padded if its height isn't an exact multiple
## of 32.  It is thus necessary to remember the height of the original image
## in order to retrieve it from the packed version (e.g. by calling bwunpack).
##
## @var{bw} can be scalar or n-dimensional real matrix so it is possible to
## pack multiple binary 2-D images at once.  Nonzero elements of @var{bw} are
## treated as 1 (true). Outputs uint32 matrix @var{bwp}.
##
## Implementation note: bwpack uses bitpack internally.
##
## @seealso{bwunpack, bitpack, bitunpack}
## @end deftypefn

function bw = bwpack (bw)
  if (nargin != 1)
    print_usage ();
  endif

  if (! isreal (bw))
    error ("Octave:invalid-input-arg", "bwpack: BW must be a real valued matrix");
  endif

  dim = size (bw);
  class_size = 32; # number of pixels packed into a single unsigned int

  ## pad input with zeros if heigh isn't an exact multiple of class_size
  if (dim(1) > 0 && mod (dim(1), class_size) > 0)
    pad_size = class_size - mod (dim(1), class_size);
    bw = padarray (bw, pad_size, "post");
  endif

  bw = logical (bw);
  new_dim = dim;
  new_dim(1) = ceil (dim(1) / class_size);

  bw = reshape (bitpack (bw(:), "uint32"), new_dim);
endfunction

## test argument checking
%!error id=Octave:invalid-fun-call bwpack()
%!error id=Octave:invalid-input-arg bwpack(j * ones(3, 4))

## simple cases
%!assert (bwpack([]), uint32([]))
%!assert (bwpack(eye(5)), uint32([1, 2, 4, 8, 16]))
%!assert (bwpack([eye(8); eye(8); eye(8); eye(8)]), uint32([16843009, 33686018, 67372036, 134744072, 269488144, 538976288, 1077952576, 2155905152]))
%!assert (bwpack(ones(3, 3, 3, 3)), uint32(7 * ones(1, 3, 3, 3)))
