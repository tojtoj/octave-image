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
## @deftypefn {Function File} {[@var{gradX}, @var{gradY}] =} imgradientxy (@var{image}, @var{method})
## Compute the x and y gradients of an image using various methods.  The first input @var{image} is the gray
## scale image to compute the edges on.  The second input @var{method} controls the method used to calculate 
## the gradients.  The first output @var{gradX} returns the gradient in the x direction.  The second output
## @var{gradY} returns the gradient in the y direction.  
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

function [gradX gradY] = imgradientxy (image, method)
  ## Get the image
  if (nargin == 0)
    error("gradientxy: not enough input arguments");
  endif
  if ( ndims(image) > 2 )
    error("gradientxy: first input must be a gray-scale image");
  endif

  ## Get the method
  if (nargin == 1)
    method = "Sobel";
  endif
  if (!ischar(method))
    error("gradientxy: second argument must be a string");
  endif
  method = lower(method);
 
  switch(method)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Sobel, Prewitt
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'sobel','prewitt'}
      ker = fspecial(method); # horizontal
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Central Difference
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case {'centraldifference'}
      ker = [0.5; 0; -0.5];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Intermediate Difference
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case {'intermediatedifference'}
      ker = [1; -1];
 
    otherwise
      error('Unrecognized method');
  end
  
  gradX = conv2(image, ker', 'same');
  gradY = conv2(image, ker, 'same');

endfunction

%% run tests
%!A = [0 1 0; 1 1 1; 0 1 0]; 
%![gxSobel, gySobel] = imgradientxy(A);
%![gxSobel2, gySobel2] = imgradientxy(A,'Sobel');
%![gxPrewitt,gyPrewitt] = imgradientxy(A,'Prewitt');
%![gxCd,gyCd] = imgradientxy(A,'CentralDifference');
%![gxId,gyId] = imgradientxy(A,'IntermediateDifference');
%%
%!assert(gxSobel,gxSobel2);
%!assert(gySobel,gySobel2);
%%
%% Test Sobel
%!assert(gxSobel,[3 0 -3; 4 0 -4; 3 0 -3]);
%!assert(gySobel,[3 4  3; 0 0 0; -3 -4 -3]);
%%
%% Test Prewitt
%!assert(gxPrewitt,[2 0 -2; 3 0 -3; 2 0 -2]);
%!assert(gyPrewitt,[2 3 2; 0 0 0; -2 -3 -2]);
%%
%% Test Central Difference
%!assert(gxCd,[0.5 0 -0.5; 0.5 0 -0.5; 0.5 0  -0.5]);
%!assert(gyCd,[0.5 0.5 0.5; 0 0 0; -0.5 -0.5 -0.5]);
%% 
%!assert(gxId,[1 -1 0; 0 0 -1; 1 -1 0]);
%!assert(gyId,[1 0 1; -1 0 -1; 0 -1 0]);
