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
## @deftypefn {Function File} {[@var{Y}, @var{newmap}] = } cmunique (@var{X},@var{map})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] = } cmunique (@var{RGB})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] = } cmunique (@var{I})
## Finds colormap with unique colors and corresponding image
##
## @code{[Y,newmap]=cmunique(X,map)} returns an indexed image @var{y}
## along with its associated colormap @var{newmap} equivalent (which
## produce the same image) to supplied @var{X} and its colormap
## @var{map}; but eliminating any repeated rows in colormap colors and
## adjusting indices in the image matrix as needed.
##
## @code{[Y,newmap]=cmunique(RGB)} returns an indexed image @var{y}
## along with its associated colormap @var{newmap} computed from a
## true-color image @var{RGB} (a m-by-n-by-3 array), where @var{newmap}
## is the smallest colormap possible (alhough it could be as long as
## number of pixels in image).
##
## @code{[Y,newmap]=cmunique(I)} returns an indexed image @var{y}
## along with its associated colormap @var{newmap} computed from a
## intensity image @var{I}, where @var{newmap} is the smallest
## colormap possible (alhough it could be as long as number of pixels
## in image).
##
## @strong{Compatibility notes:}
##
## @var{Y} and @var{newmap} are always of class double, since support
## for uint types isn't available yet. This will change from Octave
## version 2.1.58 on.
##
## @end deftypefn


## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function [Y, newmap] = cmunique(P1, P2)
  if (nargin<1 || nargin>2)
    usage("[Y, newmap] = cmunique(X, map), [Y, newmap] = cmunique(RGB), [Y, newmap] = cmunique(I)");
  endif
  

  if(nargin==2)
    ## (X, map) case
    [newmap,i,j]=unique(P2,'rows');                 ## calculate unique colormap
    Y=j(P1);                                        ## find new indices
  elseif(length(size(P1))==2)                       ## workaround for size(P1,3)==1
    ## I case
    [newmap,i,j]=unique(P1);                        ## calculate unique colormap
    Y=reshape(j,rows(P1),columns(P1));              ## Y is j reshaped
  elseif(size(P1,3)==3)
    ## RGB case
    map=[P1(:,:,1)(:), P1(:,:,2)(:), P1(:,:,3)(:)]; ## build a map with all values
    [newmap,i,j]=unique(map, 'rows');               ## calculate unique colormap
    Y=reshape(j,rows(P1),columns(P1));              ## Y is j reshaped
  else
    error("cmunique: first parameter is invalid.");
  endif

  ## TODO: handle uint types when available
endfunction


%!demo
%! [Y,newmap]=cmunique([1:4;5:8],[hot(4);hot(4)])
%! # Both rows are equal since map maps colors to the same value
%! # cmunique will give the same indices to both


%!# This triggers invalid first parameter
%!error(cmunique(zeros(3,3,2)));

%!test
%! [Y,newmap]=cmunique([1:4;5:8], [hot(4);hot(4)]);
%! assert(Y,[1:4;1:4]);
%! assert(newmap,hot(4));

%!# Random RGB image
%!test
%! RGB=rand(10,10,3);
%! [Y,newmap]=cmunique(RGB);
%! assert(RGB(:,:,1),newmap(:,1)(Y));
%! assert(RGB(:,:,2),newmap(:,2)(Y));
%! assert(RGB(:,:,3),newmap(:,3)(Y));

%!# Random I image
%!test
%! I=rand(10,10);
%! [Y,newmap]=cmunique(I);
%! assert(I,newmap(Y));


%
% $Log$
% Revision 1.2  2004/08/17 15:48:03  jmones
% Clarified expected data for RGB images in doc
%
% Revision 1.1  2004/08/17 15:45:40  jmones
% cmunique: Finds colormap with unique colors and corresponding image
%
%
	

