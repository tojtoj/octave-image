## Copyright (C) 2013 Brandon Miles  <brandon.miles7 at gmail.com>
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {[@var{gradMag}, @var{gradDir}] =} imgradient (@var{image}, @var{method})
## @deftypefn {Function File} {[@var{gradMag}, @var{gradDir}] =} imgradient (@var{gx}, @var{gy})
## Compute the gradient magnitude and direction in degrees for an image.  These are computed from the 
## x and y gradients using imgradientxy.  The first input @var{image} is a gray
## scale image to compute the edges on.  The second input @var{method} controls the method used to calculate 
## the gradients. Alternatively the first input @var{gx} can be the x gradient and the second input @var{gy} can be the y gradient.
## The first output @var{gradMag} returns the magnitude of the gradient.  The second output
## @var{gradDir} returns the direction in degrees.  
##
## The @var{method} input argument can be any of the following strings (the default
## value is "Sobel")
##
## @table @asis
## @item "Sobel"
## Calculates the gradient in @var{image} using the Sobel approximation to the
## derivatives.
##
## @item "Prewitt"
## Calculates the gradient in @var{image} using the Prewitt approximation to the
## derivatives. This method works just like "Sobel" except a different approximation of
## the gradient is used.
##
## @item "Central Difference"
## Calculates the gradient in @var{image} using the central difference approximation to the
## derivatives: (x(i-1) - x(i+1))/2.
##
## @item "Intermediate Difference"
## Calculates the gradient in @var{image} using the intermediate difference approximation to
## the derivatives: x(i) - x(i+1).
##
## @end table
##
## @seealso{edge, gradientxy}
## @end deftypefn

function [gradMag, gradDir] = imgradient (var1, var2)

  ## Get the image
  if (nargin == 0)
    error("imgradient: not enough input arguments");
  endif
  if ( ndims(var1) > 2 )
    error("imgradient: first input must be a gray-scale image");
  endif

  ## Get the method
  if (nargin == 1)
    method = "Sobel";
    image = var1;
    [gradX, gradY] = imgradientxy(image, method);
  endif
  
  ## determine whether the two inputs are the same size
  if(nargin == 2)
    ## test for var2 as a string
    if( ischar(var2))
      image  = var1;
      method = var2;
      [gradX, gradY] = imgradientxy(image, method);
      
    ## use gx, gy instead
    else
      if( size(var2) !=  size(var1))
        error("imgradient: expected inputs gx, gy to be the same size")
      endif
      gradX = var1;
      gradY = var2;
    endif
  endif
  
  gradMag = sqrt(gradX.^2 + gradY.^2);
  
  ## use atan2(-gy,gx)*pi/180 
  ## see:  http://stackoverflow.com/questions/18549015/why-imgradient-invert-vertical-when-computing-the-angle
  if (nargout == 2)
    gradDir = atan2d(-gradY,gradX);
  end
  
endfunction

%% run tests
%!A = [0 1 0; 1 1 1; 0 1 0]; 
%![gMag,gDir] = imgradient(A);
%!assert(gMag,[sqrt(18),4,sqrt(18); 4 0 4; sqrt(18),4,sqrt(18)]);
%!assert(gDir,[-45 -90 -135; -0 -0 -180; 45 90 135]);
%%
%% Test combinations
%![gxSobel, gySobel] = imgradientxy(A);
%![gxSobel2, gySobel2] = imgradientxy(A,'Sobel');
%![gxPrewitt,gyPrewitt] = imgradientxy(A,'Prewitt');
%![gxCd,gyCd] = imgradientxy(A,'CentralDifference');
%![gxId,gyId] = imgradientxy(A,'IntermediateDifference');
%%
%!assert(imgradient(A),imgradient(gxSobel,gySobel));
%!assert(imgradient(A,'Sobel'),imgradient(gxSobel2,gySobel2));
%!assert(imgradient(A,'Prewitt'),imgradient(gxPrewitt,gyPrewitt));
%!assert(imgradient(A,'CentralDifference'),imgradient(gxCd,gyCd));
%!assert(imgradient(A,'IntermediateDifference'),imgradient(gxId,gyId));
    