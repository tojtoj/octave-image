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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{BW} = } roicolor (@var{A},@var{low},@var{high})
## @deftypefnx {Function File} {@var{BW} = } roicolor (@var{A},@var{v})
## Select a Region Of Interest of an image based on color.
##
## BW = roicolor(A,low,high) selects a region of interest (ROI) of an
## image @var{A} returning a black and white image in a logical array (1 for
## pixels inside ROI and 0 outside ROI), which is formed by all pixels
## whose values lie within the colormap range specified by [@var{low}
## @var{high}].
##
## BW = roicolor(A,v) selects a region of interest (ROI) formed by all
## pixels that match values in @var{v}.
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function BW = roicolor(A, p1, p2)
  if (nargin < 2 || nargin > 3)
    usage("BW = roicolor(A, low, high), BW = roicolor(A, v)");
  endif

  if (nargin == 2)
    if (!isvector(p1))
      error("BW = roicolor(A, v): v should be a vector.");
    endif
    BW=logical(zeros(size(A)));
    for c=p1
      BW|=(A==c);
    endfor
  elseif (nargin==3)
    if (!isscalar(p1) || !isscalar(p2))
      error("BW = roicolor(A, low, high): low and high must be scalars.");
    endif
    BW=logical((A>=p1)&(A<=p2));
  endif
endfunction

%!demo
%! roicolor([1:10],2,4);
%! % Returns '1' where input values are between 2 and 4 (both included).

%!assert(roicolor([1:10],2,4),logical([0,1,1,1,zeros(1,6)]));
%!assert(roicolor([1,2;3,4],3,3),logical([0,0;1,0]));
%!assert(roicolor([1,2;3,4],[1,4]),logical([1,0;0,1]));

%
% $Log$
% Revision 1.2  2007/03/23 16:14:37  adb014
% Update the FSF address
%
% Revision 1.1  2006/08/20 12:59:35  hauberg
% Changed the structure to match the package system
%
% Revision 1.3  2004/09/15 17:54:59  pkienzle
% test that data type matches during assert
%
% Revision 1.2  2004/08/11 15:04:59  pkienzle
% Convert dos line endings to unix line endings
%
% Revision 1.1  2004/08/08 21:02:44  jmones
% Add roicolor function (selects ROI based on color)
%
%
