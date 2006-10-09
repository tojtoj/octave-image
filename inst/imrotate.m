## Copyright (C) 2004-2005 Justus H. Piater
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
##   @var{imgPre}   a gray-level image matrix
##
##   @var{theta}    the rotation angle in degrees counterclockwise
##
##   @var{method}
##     @itemize @w
##       @item "nearest" neighbor: fast, but produces aliasing effects (default).
##       @item "bilinear" interpolation: does anti-aliasing, but is slightly slower.
##       @item "bicubic" interpolation: does anti-aliasing, preserves edges better than bilinear interpolation, but gray levels may slightly overshoot at sharp edges. This is probably the best method for most purposes, but also the slowest.
##       @item "Fourier" uses Fourier interpolation, decomposing the rotation matrix into 3 shears. This method often results in different artifacts than homography-based methods.  Instead of slightly blurry edges, this method can result in ringing artifacts (little waves near high-contrast edges).  However, Fourier interpolation is better at maintaining the image information, so that unrotating will result in an image closer to the original than the other methods.
##     @end itemize
##
##   @var{bbox}
##     @itemize @w
##       @item "loose" grows the image to accommodate the rotated image (default).
##       @item "crop" rotates the image about its center, clipping any part of the image that is moved outside its boundaries.
##     @end itemize
##
## Output parameters:
##
##   @var{imgPost}  the rotated image matrix
##
##   @var{H}        the homography mapping original to rotated pixel
##                   coordinates. To map a coordinate vector c = [x;y] to its
##           rotated location, compute round((@var{H} * [c; 1])(1:2)).
## @end deftypefn

## Author: Justus H. Piater  <Justus.Piater@ULg.ac.be>
## Created: 2004-10-18
## Version: 0.7

function [imgPost, H] = imrotate(imgPre, thetaDeg, method, bbox)
  if (nargin < 4)
    bbox = "loose";
    if (nargin < 3)
      method = "nearest";
      if (nargin < 2)
	usage("imrotate(img, angle [, method [, bbox]]");
      endif
    endif
  endif

  thetaDeg = mod(thetaDeg, 360); # some code below relies on positive angles
  theta = thetaDeg * pi/180;

  sizePre = size(imgPre);

  ## We think in x,y coordinates here (rather than row,column), except
  ## for size... variables that follow the usual size() convention. The
  ## coordinate system is aligned with the pixel centers.

  R = [cos(theta) sin(theta); -sin(theta) cos(theta)];

  if (nargin >= 4 && strcmp(bbox, "crop"))
    sizePost = sizePre;
  else
    ## Compute new size by projecting zero-base image corner pixel
    ## coordinates through the rotation:
    corners = [0, 0;
	       (R * [sizePre(2) - 1; 0             ])';
	       (R * [sizePre(2) - 1; sizePre(1) - 1])';
	       (R * [0             ; sizePre(1) - 1])' ];
    sizePost(2) = round(max(corners(:,1)) - min(corners(:,1))) + 1;
    sizePost(1) = round(max(corners(:,2)) - min(corners(:,2))) + 1;
    ## This size computation yields perfect results for 0-degree (mod
    ## 90) rotations and, together with the computation of the center of
    ## rotation below, yields an image whose corresponding region is
    ## identical to "crop". However, we may lose a boundary of a
    ## fractional pixel for general angles.
  endif

  ## Compute the center of rotation and the translational part of the
  ## homography:
  oPre  = ([ sizePre(2);  sizePre(1)] + 1) / 2;
  oPost = ([sizePost(2); sizePost(1)] + 1) / 2;
  T = oPost - R * oPre;		# translation part of the homography

  ## And here is the homography mapping old to new coordinates:
  H = [[R; 0 0] [T; 1]];

  ## Treat trivial rotations specially (multiples of 90 degrees):
  if (mod(thetaDeg, 90) == 0)
    nRot90 = mod(thetaDeg, 360) / 90;
    if (mod(thetaDeg, 180) == 0 || sizePre(1) == sizePre(2) ||
	strcmp(bbox, "loose"))
      imgPost = rot90(imgPre, nRot90);
      return;
    elseif (mod(sizePre(1), 2) == mod(sizePre(2), 2))
      ## Here, bbox is "crop" and the rotation angle is +/- 90 degrees.
      ## This works only if the image dimensions are of equal parity.
      imgRot = rot90(imgPre, nRot90);
      imgPost = zeros(sizePre);
      hw = min(sizePre) / 2 - 0.5;
      imgPost   (round(oPost(2) - hw) : round(oPost(2) + hw),
		 round(oPost(1) - hw) : round(oPost(1) + hw) ) = ...
	  imgRot(round(oPost(1) - hw) : round(oPost(1) + hw),
		 round(oPost(2) - hw) : round(oPost(2) + hw) );
      return;
    else
      ## Here, bbox is "crop", the rotation angle is +/- 90 degrees, and
      ## the image dimensions are of unequal parity. This case cannot
      ## correctly be handled by rot90() because the image square to be
      ## cropped does not align with the pixels - we must interpolate. A
      ## caller who wants to avoid this should ensure that the image
      ## dimensions are of equal parity.
    endif
  end

  ## For better readability of this spaghetti implementation, I keep the
  ## branches pertaining to the various 'method's all at the first
  ## level, even though this causes a slight redundancy in the if
  ## statements.

  imgPost = [];

  if (strcmp(method, "Fourier"))
    imgPost = imrotate_Fourier(imgPre, thetaDeg, method, bbox);
  else
    ## This section pertains to all non-Fourier methods.

    ## "Pre"  variables hold pre -rotation values;
    ## "Post" variables hold post-rotation values.

    ## General rotation: map pixel coordinates back from the Post to the
    ## Pre img
    Hinv = inv(H);

    ## Target coordinates:
    [xPost, yPost] = meshgrid(1:(sizePost(2)), 1:(sizePost(1)));

    ## Compute corresponding source coordinates:
    xPre = Hinv(1,1) * xPost + Hinv(1,2) * yPost + Hinv(1,3);
    yPre = Hinv(2,1) * xPost + Hinv(2,2) * yPost + Hinv(2,3);
    ## zPre is guaranteed to be 1, since the last row of H (and thus of
    ## Hinv) is [0 0 1].
  endif

  ## Now map the image using the coordinates computed in the else branch above:
  if (strcmp(method, "nearest"))
    ## nearest-neighbor: simply round Pre coordinates
    xPre = round(xPre);
    yPre = round(yPre);
    valid = find(1 <= xPre & xPre <= sizePre(2) &
		 1 <= yPre & yPre <= sizePre(1)  );
    if (!length(valid))
      warning("input image too small");
      imgPost = 0;
      return;
    endif
    
    iPre  = sub2ind(sizePre , yPre (valid), xPre (valid));
    iPost = sub2ind(sizePost, yPost(valid), xPost(valid));

    imgPost = zeros(sizePost);
    imgPost(iPost) = imgPre(iPre);
  elseif(!strcmp(method, "Fourier"))
    ## This section pertains to "bilinear" and "bicubic" methods.

    ## With interpolation, one unavoidably loses up to one or two pixel
    ## rows or columns at the image boundaries.

    xPreFloor = floor(xPre);
    xPreCeil  = ceil (xPre);
    yPreFloor = floor(yPre);
    yPreCeil  = ceil (yPre);

    valid = find(1 <= xPreFloor & xPreCeil <= sizePre(2) &
		 1 <= yPreFloor & yPreCeil <= sizePre(1)  );
    if (!length(valid))
      warning("input image too small");
      imgPost = 0;
      return;
    endif

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
  endif

  if (strcmp(method, "bilinear"))
    imgPost = zeros(sizePost);
    ## bilinear interpolation between the four floor and ceiling coordinates
    imgPost(iPost) = (imgPre(iPreFF) .* (1 - xPreFrac) .* (1 - yPreFrac) +
		      imgPre(iPreCF) .*      xPreFrac  .* (1 - yPreFrac) +
		      imgPre(iPreCC) .*      xPreFrac  .*      yPreFrac  +
		      imgPre(iPreFC) .* (1 - xPreFrac) .*      yPreFrac   );
  elseif (strcmp(method, "bicubic"))
    ## bicubic interpolation (see Numerical Recipes)
    ## This code, together with the prerequisites above, is not limited
    ## to this particular use but applies to generic bicubic
    ## interpolation in the following scenario:
    ## - source data are stored in a matrix,
    ## - interpolated coordinates may lie anywhere, no regularity is assumed.

    ## precompute the required derivatives at the source image pixels:
    imgPreDx  = conv2(imgPre  , [ 0.5 0 -0.5] , "same");
    imgPreDy  = conv2(imgPre  , [-0.5 0  0.5]', "same");
    imgPreDxy = conv2(imgPreDx, [-0.5 0  0.5]', "same");

    ## Interpolation is done on a square of pixels and their
    ## derivatives along x, y, and xy. The square is indexed as:
    ##   43                        FF CF
    ##   12  which corresponds to  FC CC

    ## Coefficient matrix W
    ## C11 12         21            31            41                p deriv
    W = [1  0 -3  2    0  0  0  0   -3  0  9 -6    2  0 -6  4    ## 1
	 0  0  0  0    0  0  0  0    3  0 -9  6   -2  0  6 -4	 ## 2
	 0  0  0  0    0  0  0  0    0  0  9 -6    0  0 -6  4	 ## 3
	 0  0  3 -2    0  0  0  0    0  0 -9  6    0  0  6 -4	 ## 4
	 
	 0  0  0  0    1  0 -3  2   -2  0  6 -4    1  0 -3  2	 ## 1 x
	 0  0  0  0    0  0  0  0   -1  0  3 -2    1  0 -3  2	 ## 2 x
	 0  0  0  0    0  0  0  0    0  0 -3  2    0  0  3 -2	 ## 3 x
	 0  0  0  0    0  0  3 -2    0  0 -6  4    0  0  3 -2	 ## 4 x
	 
	 0  1 -2  1    0  0  0  0    0 -3  6 -3    0  2 -4  2	 ## 1 y
	 0  0  0  0    0  0  0  0    0  3 -6  3    0 -2  4 -2	 ## 2 y
	 0  0  0  0    0  0  0  0    0  0 -3  3    0  0  2 -2	 ## 3 y
	 0  0 -1  1    0  0  0  0    0  0  3 -3    0  0 -2  2	 ## 4 y
	 
	 0  0  0  0    0  1 -2  1    0 -2  4 -2    0  1 -2  1	 ## 1 xy
	 0  0  0  0    0  0  0  0    0 -1  2 -1    0  1 -2  1	 ## 2 xy
	 0  0  0  0    0  0  0  0    0  0  1 -1    0  0 -1  1	 ## 3 xy
	 0  0  0  0    0  0 -1  1    0  0  2 -2    0  0 -1  1];  ## 4 xy

    u = 1 - yPreFrac;
    values = zeros(size(valid));
    for ci = 4:-1:1
      ## compute ci'th row of matrix C:

      col = 4*(ci - 1) + 1;
      c{1} = (W( 1,col) * imgPre   (iPreFC) + W( 2,col) * imgPre   (iPreCC) +
	      W( 5,col) * imgPreDx (iPreFC) + W( 6,col) * imgPreDx (iPreCC)  );

      col++;
      c{2} = (W( 9,col) * imgPreDy (iPreFC) + W(10,col) * imgPreDy (iPreCC) +
	      W(13,col) * imgPreDxy(iPreFC) + W(14,col) * imgPreDxy(iPreCC)  );

      for cii = 3:4
	col++;
	c{cii} = ...
	    (W( 1,col) * imgPre   (iPreFC) + W( 2,col) * imgPre   (iPreCC) +
	     W( 3,col) * imgPre   (iPreCF) + W( 4,col) * imgPre   (iPreFF) +
	     W( 5,col) * imgPreDx (iPreFC) + W( 6,col) * imgPreDx (iPreCC) +
	     W( 7,col) * imgPreDx (iPreCF) + W( 8,col) * imgPreDx (iPreFF) +
	     W( 9,col) * imgPreDy (iPreFC) + W(10,col) * imgPreDy (iPreCC) +
	     W(11,col) * imgPreDy (iPreCF) + W(12,col) * imgPreDy (iPreFF) +
	     W(13,col) * imgPreDxy(iPreFC) + W(14,col) * imgPreDxy(iPreCC) +
	     W(15,col) * imgPreDxy(iPreCF) + W(16,col) * imgPreDxy(iPreFF)  );
      endfor

      values .*= xPreFrac;
      values  += ((c{4} .* u + c{3}) .* u + c{2}) .* u + c{1};
    endfor
    imgPost = zeros(sizePost);
    imgPost(iPost) = values;
  endif

  if (!prod(size(imgPost)))
    error(sprintf("Interpolation method %s not implemented", method));
  endif
endfunction

%!test
%! ## Verify minimal loss across six rotations that add up to 360 +/- 1 deg.:
%! methods = { "nearest", "bilinear", "bicubic", "Fourier" };
%! angles     = [ 59  60  61  ];
%! tolerances = [ 7.4 8.5 8.6	  # nearest
%!                3.5 3.1 3.5     # bilinear
%!                2.7 0.1 2.7     # bicubic
%!                2.7 1.6 2.8 ];  # Fourier
%!
%! # This is peaks(50) without the dependency on the plot package
%! x = y = linspace(-3,3,50);
%! [X,Y] = meshgrid(x,y);
%! x = 3*(1-X).^2.*exp(-X.^2 - (Y+1).^2) \
%!      - 10*(X/5 - X.^3 - Y.^5).*exp(-X.^2-Y.^2) \
%!      - 1/3*exp(-(X+1).^2 - Y.^2);
%!
%! x -= min(min(x));	      # Fourier does not handle neg. values well
%! for m = 1:(length(methods))
%!   y = x;
%!   for i = 1:5
%!     y = imrotate(y, 60, methods(m), "crop");
%!   end
%!   for a = 1:(length(angles))
%!     assert(norm((x - imrotate(y, angles(a), methods(m), "crop"))
%!                 (10:40, 10:40)) < tolerances(m,a));
%!   end
%! end


%!test
%! ## Verify exactness of near-90 and 90-degree rotations:
%! X = rand(99);
%! for angle = [90 180 270]
%!   for da = [-0.1 0.1]
%!     Y = imrotate(X,   angle + da , "nearest");
%!     Z = imrotate(Y, -(angle + da), "nearest");
%!     assert(norm(X - Z) == 0); # exact zero-sum rotation
%!     assert(norm(Y - imrotate(X, angle, "nearest")) == 0); # near zero-sum
%!   end
%! end


%!test
%! ## Verify preserved pixel density:
%! methods = { "nearest", "bilinear", "bicubic", "Fourier" };
%! ## This test does not seem to do justice to the Fourier method...:
%! tolerances = [ 4 2.2 2.0 209 ];
%! range = 3:9:100;
%! for m = 1:(length(methods))
%!   t = [];
%!   for n = range
%!     t(end + 1) = sum(imrotate(eye(n), 20, methods(m))(:));
%!   end
%!   assert(t, range, tolerances(m));
%! end

