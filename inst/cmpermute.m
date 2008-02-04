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
## @deftypefn {Function File} {[@var{Y}, @var{newmap}] = } cmpermute (@var{X},@var{map})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] = } cmpermute (@var{X},@var{map},@var{index})
## Reorders colors in a colormap.
##
## @code{[Y,newmap]=cmpermute(X,map)} rearranges colormap @var{map}
## randomly returning colormap @var{newmap} and generates indexed image
## @var{Y} so that it mantains correspondence between indices and the
## colormap from original indexed image @var{X} (both image and colormap
## pairs produce the same result).
##
## @code{[Y,newmap]=cmpermute(X,map,index)} behaves as described above
## but instead of sorting colors randomly, it uses @var{index} to define
## the order of the colors in the new colormap.
##
## @strong{Note:} @code{index} shouldn't have repeated elements, this
## function won't explicitly check this, but it will fail if it has.
##
## @end deftypefn


## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function [Y, newmap] = cmpermute(X, map, index)
  switch(nargin)
    case(2)
      index=randperm(rows(map));
    case(3)
      if(!isvector(index) || length(index)!=rows(map))
	error("cmpermute: invalid parameter index.");
      endif
    otherwise
      usage("[Y, newmap] = cmpermute(X, map [, index])");
  endswitch

  ## new colormap
  newmap=map(index,:);

  ## build reverse index
  rindex = zeros(size(index));
  rindex(index) = 1:length(index);
 
  ## readapt indices
  if(isa(X,"uint8"))
    rindex=uint8(rindex-1);
    ## 0-based indices
    Y=rindex(double(X)+1);
  else
    Y=rindex(X);
  endif
endfunction


%!demo
%! [Y,newmap]=cmpermute([1:4],hot(4),4:-1:1)
%! # colormap will be arranged in reverse order (so will image)

%!shared X,map
%! X=magic(16);
%! [X,map]=cmunique(X);

%!test # random permutation, 0-based index
%! [Y,newmap]=cmpermute(X,map);
%! # test we didn't lose colors
%! assert(sort(map),sortrows(newmap)); 
%! # test if images are equal
%! assert(map(double(X)+1),newmap(double(Y)+1));

%!test # reverse map, 0-based index
%! [Y,newmap]=cmpermute(X,map,rows(map):-1:1);
%! # we expect a reversed colormap
%! assert(newmap(rows(newmap):-1:1,:),map);
%! # we expect reversed indices in image
%! assert(X,max(Y(:))-Y);

%!shared X,map
%! X=magic(20);
%! [X,map]=cmunique(X);

%!test # random permutation, 1-based index
%! [Y,newmap]=cmpermute(X,map);
%! # test we didn't lose colors
%! assert(sort(map),sortrows(newmap)); 
%! # test if images are equal
%! assert(map(X),newmap(Y));

%!test # reverse map, 1-based index
%! [Y,newmap]=cmpermute(X,map,rows(map):-1:1);
%! # we expect a reversed colormap
%! assert(newmap(rows(newmap):-1:1,:),map);
%! # we expect reversed indices in image
%! assert(X,max(Y(:))+1-Y);

%
% $Log$
% Revision 1.3  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.2  2007/01/04 23:44:22  hauberg
% Minor changes in help text
%
% Revision 1.1  2006/08/20 12:59:32  hauberg
% Changed the structure to match the package system
%
% Revision 1.4  2004/09/08 15:01:28  pkienzle
% Redo tests: reduce # of shared variables; force full range of uint8
%
% Revision 1.3  2004/09/08 14:13:08  jmones
% Synchronized with cmunique. uint8 support added. Tests working for 2.1.58
%
% Revision 1.2  2004/08/18 14:57:42  jmones
% speed improvement suggested by Paul Kienzle
%
% Revision 1.1  2004/08/17 19:18:42  jmones
% cmpermute added: Reorders colors in a colormap
%
%
