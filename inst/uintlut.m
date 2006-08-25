## Copyright (C) 2004 Josep Mones i Teixidor
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{B} = } uintlut (@var{A},@var{LUT})
## Computes matrix B by using A as an index to lookup table LUT.
##
## B = uintlut(A, LUT) calculates a matrix B by using @var{LUT} as a
## lookup table indexed by values in @var{A}.
## 
## B class is the same as @var{LUT}. 
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function B = uintlut(A, LUT)
  if (nargin != 2)
    usage("B = uintlut(A, LUT)");
  endif

  ## We convert indexing array A to double since even CVS version of
  ## Octave is unable to use non-double arrays as indexing types. This
  ## won't be needed in the future eventually.
  B=LUT(double(A));
endfunction

%!demo
%! uintlut(uint8([1,2,3,4]),uint8([255:-1:0]));
%! % Returns a uint8 array [255,254,253,252]

%!assert(uintlut(uint8([1,2,3,4]),uint8([255:-1:0])), uint8([255:-1:252]));
%!assert(uintlut(uint16([1,2,3,4]),uint16([255:-1:0])), uint16([255:-1:252]));
%!assert(uintlut(uint32([1,2,3,4]),uint32([255:-1:0])), uint32([255:-1:252]));
%!assert(uintlut(uint64([1,2,3,4]),uint64([255:-1:0])), uint64([255:-1:252]));

%
% $Log$
% Revision 1.1  2006/08/20 12:59:36  hauberg
% Changed the structure to match the package system
%
% Revision 1.2  2004/08/11 15:04:59  pkienzle
% Convert dos line endings to unix line endings
%
% Revision 1.1  2004/08/08 21:20:25  jmones
% uintlut and padarray functions added
%
%