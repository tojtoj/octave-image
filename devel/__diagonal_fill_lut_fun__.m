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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{g} = } __diagonal_fill_lut_fun__ (@var{X})
## Calculates hit patterns for diagonal fill operation
##
## g=__diagonal_fill_lut_fun__(X) evaluates a 3-by-3 BW matrix
## neighbourhood according to rules in Pratt's book for diagonal fill
## morphological operation to create a LUT using makelut.
##
## @var{X} contains a 3-by-3 matrix to be evaluated. Returns 1 if is a
## "hit" and 0 otherwise.
##
## This function is needed by bwmorph, although it just contains the
## result matrix as a literal inside the code.
##
## This function probably never be needed by itself, but it's useful to
## know how bwmorph was coded.
##
## References:
## W. K. Pratt, "Digital Image Processing"
## @end deftypefn
## @seealso{bwmorph}

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

## Note: no intention has been made to make this quick. The only focus
## is on being clear and similar to Pratt's specification.

function g=__diagonal_fill_lut_fun__(X)
  x=X(2,2);
  x0=X(2,3);
  x1=X(1,3);
  x2=X(1,2);
  x3=X(1,1);
  x4=X(2,1);
  x5=X(3,1);
  x6=X(3,2);
  x7=X(3,3);


  p4=!x&&x6&&!x7&&x0;
  p3=!x&&x4&&!x5&&x6;
  p2=!x&&x2&&!x3&&x4;
  p1=!x&&x0&&!x1&&x2;
  g=x||p1||p2||p3||p4;
endfunction


%
% $Log$
% Revision 1.2  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.1  2004/08/16 14:42:02  jmones
% Functions used to code bwmorph
%
%
