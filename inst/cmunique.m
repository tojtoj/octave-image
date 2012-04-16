## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
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
## @deftypefn {Function File} {[@var{Y}, @var{newmap}] =} cmunique (@var{X}, @var{map})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} cmunique (@var{RGB})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} cmunique (@var{I})
## Finds colormap with unique colors and corresponding image.
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
## @strong{Notes:}
##
## @var{newmap} is always a @var{m}-by-3 matrix, even if input image is
## a intensity grey-scale image @var{I} (all three RGB planes are
## assigned the same value).
##
## @var{newmap} is always of class double. If we use a RGB or intensity
## image of class uint8 or uint16, the colors in the colormap will be of
## class double in the range [0,1] (they are divided by intmax("uint8")
## and intmax("uint16") respectively.
##
## @end deftypefn

function [Y, newmap] = cmunique (P1, P2)
  if (nargin<1 || nargin>2)
    print_usage;
  endif
  

  if(nargin==2)
    ## (X, map) case
    [newmap,i,j]=unique(P2,'rows');                 ## calculate unique colormap
    if(isa(P1,"double"))
      Y=j(P1);                                      ## find new indices
    else
      Y=j(double(P1)+1);                            ## find new indices
    endif
  else
    switch(size(P1,3))
      case(1)
        ## I case
        [newmap,i,j]=unique(P1);                        ## calculate unique colormap
        newmap=repmat(newmap,1,3);                      ## get a RGB colormap
        Y=reshape(j,rows(P1),columns(P1));              ## Y is j reshaped
      case(3)
        ## RGB case
        map=[P1(:,:,1)(:), P1(:,:,2)(:), P1(:,:,3)(:)]; ## build a map with all values
        [newmap,i,j]=unique(map, 'rows');               ## calculate unique colormap
        Y=reshape(j,rows(P1),columns(P1));              ## Y is j reshaped
      otherwise
        error("cmunique: first parameter is invalid.");
    endswitch
    
    ## if image was uint8 or uint16 we have to convert newmap to [0,1] range
    if(!isa(P1,"double"))
      newmap=double(newmap)/double(intmax(class(P1)));
    endif
  endif

  if(rows(newmap)<=256)
    ## convert Y to uint8 (0-based indices then)
    Y=uint8(Y-1);
  endif
  
endfunction

%!demo
%! [Y,newmap]=cmunique([1:4;5:8],[hot(4);hot(4)])
%! # Both rows are equal since map maps colors to the same value
%! # cmunique will give the same indices to both

%!# This triggers invalid first parameter
%!error(cmunique(zeros(3,3,2)));

%!# Check that output is uint8 in short colormaps
%!test
%! [Y,newmap]=cmunique([1:4;5:8], [hot(4);hot(4)]);
%! assert(Y,uint8([0:3;0:3]));
%! assert(newmap,hot(4));

%!# Check that output is double in bigger
%!test
%! [Y,newmap]=cmunique([1:300;301:600], [hot(300);hot(300)]);
%! assert(Y,[1:300;1:300]);
%! assert(newmap,hot(300));

%!# Check boundary case 256
%!test
%! [Y,newmap]=cmunique([1:256;257:512], [hot(256);hot(256)]);
%! assert(Y,uint8([0:255;0:255]));
%! assert(newmap,hot(256));

%!# Check boundary case 257
%!test
%! [Y,newmap]=cmunique([1:257;258:514], [hot(257);hot(257)]);
%! assert(Y,[1:257;1:257]);
%! assert(newmap,hot(257));

%!# Random RGB image
%!test
%! RGB=rand(10,10,3);
%! [Y,newmap]=cmunique(RGB);
%! assert(RGB(:,:,1),newmap(:,1)(Y+1));
%! assert(RGB(:,:,2),newmap(:,2)(Y+1));
%! assert(RGB(:,:,3),newmap(:,3)(Y+1));

%!# Random uint8 RGB image
%!test
%! RGB=uint8(rand(10,10,3)*255);
%! RGBd=double(RGB)/255;
%! [Y,newmap]=cmunique(RGB);
%! assert(RGBd(:,:,1),newmap(:,1)(Y+1));
%! assert(RGBd(:,:,2),newmap(:,2)(Y+1));
%! assert(RGBd(:,:,3),newmap(:,3)(Y+1));

%!# Random uint16 RGB image
%!test
%! RGB=uint16(rand(10,10,3)*65535);
%! RGBd=double(RGB)/65535;
%! [Y,newmap]=cmunique(RGB);
%! assert(RGBd(:,:,1),newmap(:,1)(Y+1));
%! assert(RGBd(:,:,2),newmap(:,2)(Y+1));
%! assert(RGBd(:,:,3),newmap(:,3)(Y+1));

%!# Random I image
%!test
%! I=rand(10,10);
%! [Y,newmap]=cmunique(I);
%! assert(I,newmap(:,1)(Y+1));
%! assert(I,newmap(:,2)(Y+1));
%! assert(I,newmap(:,3)(Y+1));

%!# Random uint8 I image
%!test
%! I=uint8(rand(10,10)*256);
%! Id=double(I)/255;
%! [Y,newmap]=cmunique(I);
%! assert(Id,newmap(:,1)(Y+1));
%! assert(Id,newmap(:,2)(Y+1));
%! assert(Id,newmap(:,3)(Y+1));

%!# Random uint16 I image
%!test
%! I=uint16(rand(10,10)*65535);
%! Id=double(I)/65535;
%! [Y,newmap]=cmunique(I);
%! assert(Id,newmap(:,1)(Y+1));
%! assert(Id,newmap(:,2)(Y+1));
%! assert(Id,newmap(:,3)(Y+1));
