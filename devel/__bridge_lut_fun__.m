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
## @deftypefn {Function File} {@var{g} = } __bridge_lut_fun__ (@var{X})
## Calculates hit patterns for bridge operation
##
## g=__bridge_lut_fun__(X) evaluates a 3-by-3 BW matrix
## neighbourhood according to rules in Pratt's book for bridge
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

function g=__bridge_lut_fun__(X)
  x=X(2,2);
  x0=X(2,3);
  x1=X(1,3);
  x2=X(1,2);
  x3=X(1,1);
  x4=X(2,1);
  x5=X(3,1);
  x6=X(3,2);
  x7=X(3,3);

  l4=!x&&!x0&&x1&&!x2&&!x3&&!x4&&!x5&&!x6&&x7;
  l3=!x&&!x0&&!x1&&!x2&&!x3&&!x4&&x5&&!x6&&x7;
  l2=!x&&!x0&&!x1&&!x2&&x3&&!x4&&x5&&!x6&&!x7;
  l1=!x&&!x0&&x1&&!x2&&x3&&!x4&&!x5&&!x6&&!x7;
  pq=l1||l2||l3||l4;
  p6=!x4&&!x6&&x5&&(x0||x1||x2);
  p5=!x2&&!x4&&x3&&(x0||x6||x7);
  p4=!x0&&!x2&&x1&&(x4||x5||x6);
  p3=!x0&&!x6&&x7&&(x2||x3||x4);
  p2=!x0&&!x4&&(x1||x2||x3)&&(x5||x6||x7)&&!pq;
  p1=!x2&&!x6&&(x3||x4||x5)&&(x0||x1||x7)&&!pq;
  g=x||p1||p2||p3||p4||p5||p6;
endfunction

%!assert(sum(makelut("__bridge_lut_fun__",3)),256+119);


%
% $Log$
% Revision 1.3  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.2  2004/09/08 15:07:18  pkienzle
% Use new __ name in tests as well.
%
% Revision 1.1  2004/08/16 14:42:02  jmones
% Functions used to code bwmorph
%
%
