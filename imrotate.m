## Copyright (C) 2004 Justus Piater
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} 
##            imrotate(@var{imgPre}, @var{theta}, @var{method}, @var{bbox})
## Rotation of a 2D matrix about its center.
##
## Input parameters:
##
##   @var{imgPre}   an input image matrix
##
##   @var{theta}    the rotation angle in degrees counterclockwise
##
##   @var{method}   "nearest" neighbor (default; faster, but produces
##                  aliasing effects) or "bilinear" interpolation
##                     (preferred; does anti-aliasing)
##
##   @var{bbox}     "loose" (default) or "crop"
##
## Output parameters:
##
##   @var{imgPos}t  the rotated image matrix
##
##   @var{H}        the homography mapping original to rotated pixel
##                   coordinates. To map a coordinate vector c = [x;y] to its
##           rotated location, compute round((@var{H} * [c; 1])(1:2)).
## @end deftypefn

## Author: Justus H. Piater  <Justus.Piater@ULg.ac.be>
## Created: 2004-10-18
## Version: 0.1

function [imgPost, H] = imrotate(imgPre, theta, method, bbox)
  if (nargin < 2)
    help("imrotate");
    return;
  endif

  theta = theta * pi/180;

  sizePre  = size(imgPre);

  ## We think in x,y coordinates here (rather than row,column).

  R = [cos(theta) sin(theta); -sin(theta) cos(theta)];

  if (nargin == 4 && strcmp(bbox, "crop"))
    sizePost = sizePre;
  else
    ## Compute new size by projecting image corners through the rotation:
    corners = [0, 0;
	       (R * [sizePre(2); 1])';
	       (R * [sizePre(2); sizePre(1)])';
	       (R * [1; sizePre(1)])'          ];
    sizePost(2) = ceil(max(corners(:,1))) - floor(min(corners(:,1)));
    sizePost(1) = ceil(max(corners(:,2))) - floor(min(corners(:,2)));
  endif

  ## Compute the translation part of the homography:
  oPre  = ([sizePre(2) ; sizePre(1) ] + 1) / 2;
  oPost = ([sizePost(2); sizePost(1)] + 1) / 2;
  T = oPost - R * oPre;

  ## And here is the homography mapping old to new coordinates:
  H = [[R; 0 0] [T; 1]];

  Hinv = inv(H);

  ## "Pre"  variables hold pre -rotation values;
  ## "Post" variables hold post-rotation values.

  ## Target coordinates:
  [xPost, yPost] = meshgrid(1:(sizePost(2)), 1:(sizePost(1)));

  ## Compute corresponding source coordinates:
  xPre = Hinv(1,1) * xPost + Hinv(1,2) * yPost + Hinv(1,3);
  yPre = Hinv(2,1) * xPost + Hinv(2,2) * yPost + Hinv(2,3);
  ## zPre is guaranteed to be 1, since the last row of H (and thus of
  ## Hinv) is [0 0 1].

  ## Now map the image, either by nearest neighbor or by bilinear
  ## interpolation:
  if (nargin < 3 || !size(method) || strcmp(method, "nearest"))
    ## nearest-neighbor: simply round Pre coordinates
    xPre = round(xPre);
    yPre = round(yPre);
    valid = find(1 <= xPre & xPre <= sizePre(2) &
		 1 <= yPre & yPre <= sizePre(1)  );
    iPre  = sub2ind(sizePre , yPre (valid), xPre (valid));
    iPost = sub2ind(sizePost, yPost(valid), xPost(valid));

    imgPost = zeros(sizePost);
    imgPost(iPost) = imgPre(iPre);
  else
    ## bilinear interpolation between the four floor and ceiling coordinates
    xPreFloor = floor(xPre);
    xPreCeil  = ceil (xPre);
    yPreFloor = floor(yPre);
    yPreCeil  = ceil (yPre);

    valid = find(1 <= xPreFloor & xPreCeil <= sizePre(2) &
		 1 <= yPreFloor & yPreCeil <= sizePre(1)  );

    xPreFloor = xPreFloor(valid);
    xPreCeil  = xPreCeil (valid);
    yPreFloor = yPreFloor(valid);
    yPreCeil  = yPreCeil (valid);

    ## In the following, FC = floor(x), ceil(y), etc.
    iPreFF = sub2ind(sizePre, yPreFloor, xPreFloor);
    iPreCF = sub2ind(sizePre, yPreFloor, xPreCeil );
    iPreCC = sub2ind(sizePre, yPreCeil , xPreCeil );
    iPreFC = sub2ind(sizePre, yPreCeil , xPreFloor);

    ## We'll have to weight by the fractional part of the coordinates:
    xPreFrac = xPre(valid) - xPreFloor;
    yPreFrac = yPre(valid) - yPreFloor;

    iPost = sub2ind(sizePost, yPost(valid), xPost(valid));

    imgPost = zeros(sizePost);
    imgPost(iPost) = ...
	round(imgPre(iPreFF) .* (1 - xPreFrac) .* (1 - yPreFrac) + ...
	      imgPre(iPreCF) .*      xPreFrac  .* (1 - yPreFrac) + ...
	      imgPre(iPreCC) .*      xPreFrac  .*      yPreFrac  + ...
	      imgPre(iPreFC) .* (1 - xPreFrac) .*      yPreFrac       );
  endif
endfunction
