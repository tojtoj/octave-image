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
## @deftypefn {Function File} {[@var{Y}, @var{newmap}] = } cmpermute (@var{X},@var{map})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] = } cmpermute (@var{X},@var{map},@var{index})
## Reorders colors in a colormap
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
  newmap=map(index);

  ## build reverse index
  rindex=zeros(length(index),1);
  for i=1:length(index)
    rindex(index(i))=i;
  endfor
 
  ## readapt indices
  Y=rindex(X);
endfunction


%!demo
%! [Y,newmap]=cmpermute([1:4],hot(4),4:-1:1)
%! # colormap will be arranged in reverse order (so will image)

%!shared X, map, Y, newmap, Y2, newmap2
%! X=rand(10,10);
%! [X,map]=cmunique(X);
%! [Y,newmap]=cmpermute(X,map);
%! [Y2,newmap2]=cmpermute(X,map,rows(map):-1:1);

%!# test we didn't lose colors
%!assert(sort(map),sort(newmap)); 

%!# test if images are equal
%!assert(map(X),newmap(Y));

%!# we expect a reversed colormap
%!assert(newmap2(rows(newmap2):-1:1,:),map);

%!# we expect reversed indices in image
%!assert(X,max(Y2(:))+1-Y2);


%
% $Log$
% Revision 1.1  2004/08/17 19:18:42  jmones
% cmpermute added: Reorders colors in a colormap
%
%
