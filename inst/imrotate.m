## Copyright (C) 2002 Jeff Orchard <jorchard@cs.uwaterloo.ca>
## Copyright (C) 2004-2005 Justus H. Piater <Justus.Piater@ULg.ac.be>
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
## @deftypefn {Function File} {} imrotate (@var{imgPre}, @var{theta}, @var{method}, @var{bbox}, @var{extrapval})
## Rotate image about its center.
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
##       @item "bicubic" interpolation: does anti-aliasing, preserves edges better
## than bilinear interpolation, but gray levels may slightly overshoot at sharp
## edges. This is probably the best method for most purposes, but also the slowest.
##       @item "Fourier" uses Fourier interpolation, decomposing the rotation
## matrix into 3 shears. This method often results in different artifacts than
## homography-based methods.  Instead of slightly blurry edges, this method can
## result in ringing artifacts (little waves near high-contrast edges).  However,
## Fourier interpolation is better at maintaining the image information, so that
## unrotating will result in an image closer to the original than the other methods.
##     @end itemize
##
##   @var{bbox}
##     @itemize @w
##       @item "loose" grows the image to accommodate the rotated image (default).
##       @item "crop" rotates the image about its center, clipping any part of the image that is moved outside its boundaries.
##     @end itemize
##
##   @var{extrapval} sets the value used for extrapolation. The default value
##      is @code{NA} for images represented using doubles, and 0 otherwise.
##      This argument is ignored of Fourier interpolation is used.
##
## Output parameters:
##
##   @var{imgPost}  the rotated image matrix
##
##   @var{H}        the homography mapping original to rotated pixel
##                   coordinates. To map a coordinate vector c = [x;y] to its
##           rotated location, compute round((@var{H} * [c; 1])(1:2)).
##
##   @var{valid}    a binary matrix describing which pixels are valid,
##                  and which pixels are extrapolated. This output is
##                  not available if Fourier interpolation is used.
## @end deftypefn

function [imgPost, H, valid] = imrotate (imgPre, thetaDeg, interp = "nearest", bbox = "loose", extrapval = NA)

  if (nargin < 2)
    print_usage();
  elseif (! isimage (imgPre) || (! isrgb (imgPre) && ! isgray (imgPre)))
    error ("imrotate: IMGPRE must be a grayscale or RGB image.")
  elseif (! isscalar (thetaDeg))
    error("imrotate: THETA must be a scalar");
  elseif (! ischar (interp))
    error("imrotate: interpolation METHOD must be a character array");
  elseif (! any (strcmpi (interp, {"nearest", "linear", "bilinear", "cubic", "bicubic", "Fourier"})))
    error("imrotate: unsupported METHOD interpolation method");
  elseif (! isscalar (extrapval))
    error("imrotate: EXTRAPVAL must be a scalar");
  endif

  if (any(strcmpi(interp, {"bilinear", "bicubic"})))
    interp = interp(3:end); # Remove "bi"
  endif
  if (!any(strcmpi(bbox, {"loose", "crop"})))
    error("imrotate: bounding box must be either 'loose' or 'crop'");
  endif

  ## Input checking done. Start working
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
  T = oPost - R * oPre;         # translation part of the homography

  ## And here is the homography mapping old to new coordinates:
  H = [[R; 0 0] [T; 1]];

  ## Treat trivial rotations specially (multiples of 90 degrees):
  if (mod(thetaDeg, 90) == 0)
    nRot90 = mod(thetaDeg, 360) / 90;
    if (mod(thetaDeg, 180) == 0 || sizePre(1) == sizePre(2) ||
        strcmpi(bbox, "loose"))
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

  ## Now the actual rotations happen
  if (strcmpi(interp, "Fourier"))
    c = class (imgPre);
    imgPre = im2double (imgPre);
    if (isgray(imgPre))
      imgPost = imrotate_Fourier(imgPre, thetaDeg, interp, bbox);
    else # rgb image
      for i = 3:-1:1
        imgPost(:,:,i) = imrotate_Fourier(imgPre(:,:,i), thetaDeg, interp, bbox);
      endfor
    endif
    valid = NA;
    
    switch (c)
      case "uint8"
        imgPost = im2uint8 (imgPost);
      case "uint16"
        imgPost = im2uint16 (imgPost);
      case "single"
        imgPost = single (imgPost);
    endswitch
  else
    [imgPost, valid] = imperspectivewarp(imgPre, H, interp, bbox, extrapval);
  endif
endfunction


function fs = imrotate_Fourier (f, theta, method, bbox)

    if (size (f, 3) != 1)
      error("imrotate_Fourier: image argument must be a gray-scale image");
    endif

    # Get original dimensions.
    [ydim_orig, xdim_orig] = size(f);

    # This finds the index coords of the centre of the image (indices are base-1)
    #   eg. if xdim_orig=8, then xcentre_orig=4.5 (half-way between 1 and 8)
    xcentre_orig = (xdim_orig+1) / 2;
    ycentre_orig = (ydim_orig+1) / 2;

    # Pre-process the angle ===========================================================
    # Whichever 90 degree multiple theta is closest to, that multiple of 90 will
    # be implemented by rot90. The remainder will be done by shears.

    # This ensures that 0 <= theta < 360.
    theta = rem( rem(theta,360) + 360, 360 );

    # This is a flag to keep track of 90-degree rotations.
    perp = 0;

    if ( theta>=0 && theta<=45 )
        phi = theta;
    elseif ( theta>45 && theta<=135 )
        phi = theta - 90;
        f = rot90(f,1);
        perp = 1;
    elseif ( theta>135 && theta<=225 )
        phi = theta - 180;
        f = rot90(f,2);
    elseif ( theta>225 && theta<=315 )
        phi = theta - 270;
        f = rot90(f,3);
        perp = 1;
    else
        phi = theta;
    endif

    if ( phi == 0 )
        fs = f;
        if ( strcmp(bbox,"loose") == 1 )
            return;
        else
            xmax = xcentre_orig;
            ymax = ycentre_orig;
            if ( perp == 1 )
                xmax = max([xmax ycentre_orig]);
                ymax = max([ymax xcentre_orig]);
                [ydim xdim] = size(fs);
                xpad = ceil( xmax - (xdim+1)/2 );
                ypad = ceil( ymax - (ydim+1)/2 );
                fs = impad(fs, [xpad,xpad], [ypad,ypad], "zeros");
            endif
            xcentre_new = (size(fs,2)+1) / 2;
            ycentre_new = (size(fs,1)+1) / 2;
        endif
    else

        # At this point, we can assume -45<theta<45 (degrees)
        phi = phi * pi / 180;
        theta = theta * pi / 180;
        R = [ cos(theta) -sin(theta) ; sin(theta) cos(theta) ];

        # Find max of each dimension... this will be expanded for "loose" and "crop"
        xmax = xcentre_orig;
        ymax = ycentre_orig;

        # If we don't want wrapping, we have to zeropad.
        # Cropping will be done later, if necessary.
        if ( strcmp(bbox, "wrap") == 0 )
            corners = ( [ xdim_orig xdim_orig -xdim_orig -xdim_orig ; ydim_orig -ydim_orig ydim_orig -ydim_orig ] + 1 )/ 2;
            rot_corners = R * corners;
            xmax = max([xmax rot_corners(1,:)]);
            ymax = max([ymax rot_corners(2,:)]);

            # If we are doing a 90-degree rotation first, we need to make sure our
            # image is large enough to hold the rot90 image as well.
            if ( perp == 1 )
                xmax = max([xmax ycentre_orig]);
                ymax = max([ymax xcentre_orig]);
            endif

            [ydim xdim] = size(f);
            xpad = ceil( xmax - xdim/2 );
            ypad = ceil( ymax - ydim/2 );
            %f = impad(f, [xpad,xpad], [ypad,ypad], "zeros");
            xcentre_new = (size(f,2)+1) / 2;
            ycentre_new = (size(f,1)+1) / 2;
        endif

        S1 = S2 = eye (2);
        S1(1,2) = -tan(phi/2);
        S2(2,1) = sin(phi);

        f1 = imshear(f, 'x', S1(1,2), 'loose');
        f2 = imshear(f1, 'y', S2(2,1), 'loose');
        fs = real( imshear(f2, 'x', S1(1,2), 'loose') );
        %fs = f2;
        xcentre_new = (size(fs,2)+1) / 2;
        ycentre_new = (size(fs,1)+1) / 2;
    endif

    if ( strcmp(bbox, "crop") == 1 )

        # Crop to original dimensions
        x1 = ceil (xcentre_new - xdim_orig/2);
        y1 = ceil (ycentre_new - ydim_orig/2);
        fs = fs (y1:(y1+ydim_orig-1), x1:(x1+xdim_orig-1));

    elseif ( strcmp(bbox, "loose") == 1 )

        # Find tight bounds on size of rotated image
        # These should all be positive, or 0.
        xmax_loose = ceil( xcentre_new + max(rot_corners(1,:)) );
        xmin_loose = floor( xcentre_new - max(rot_corners(1,:)) );
        ymax_loose = ceil( ycentre_new + max(rot_corners(2,:)) );
        ymin_loose = floor( ycentre_new - max(rot_corners(2,:)) );

        fs = fs( (ymin_loose+1):(ymax_loose-1) , (xmin_loose+1):(xmax_loose-1) );

    endif

    ## Prevent overshooting
    if (strcmp(class(f), "double"))
      fs(fs>1) = 1;
      fs(fs<0) = 0;
    endif

endfunction

%!test
%! ## Verify minimal loss across six rotations that add up to 360 +/- 1 deg.:
%! methods = { "nearest", "bilinear", "bicubic", "Fourier" };
%! angles     = [ 59  60  61  ];
%! tolerances = [ 7.4 8.5 8.6     # nearest
%!                3.5 3.1 3.5     # bilinear
%!                2.7 2.0 2.7     # bicubic
%!                2.7 1.6 2.8 ]/8;  # Fourier
%!
%! # This is peaks(50) without the dependency on the plot package
%! x = y = linspace(-3,3,50);
%! [X,Y] = meshgrid(x,y);
%! x = 3*(1-X).^2.*exp(-X.^2 - (Y+1).^2) \
%!      - 10*(X/5 - X.^3 - Y.^5).*exp(-X.^2-Y.^2) \
%!      - 1/3*exp(-(X+1).^2 - Y.^2);
%!
%! x -= min(x(:));            # Fourier does not handle neg. values well
%! x = x./max(x(:));
%! for m = 1:(length(methods))
%!   y = x;
%!   for i = 1:5
%!     y = imrotate(y, 60, methods{m}, "crop", 0);
%!   end
%!   for a = 1:(length(angles))
%!     assert(norm((x - imrotate(y, angles(a), methods{m}, "crop", 0))
%!                 (10:40, 10:40)) < tolerances(m,a));
%!   end
%! end

%!xtest
%! ## Verify exactness of near-90 and 90-degree rotations:
%! X = rand(99);
%! for angle = [90 180 270]
%!   for da = [-0.1 0.1]
%!     Y = imrotate(X,   angle + da , "nearest", :, 0);
%!     Z = imrotate(Y, -(angle + da), "nearest", :, 0);
%!     assert(norm(X - Z) == 0); # exact zero-sum rotation
%!     assert(norm(Y - imrotate(X, angle, "nearest", :, 0)) == 0); # near zero-sum
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
%!     t(end + 1) = sum(imrotate(eye(n), 20, methods{m}, :, 0)(:));
%!   end
%!   assert(t, range, tolerances(m));
%! end
