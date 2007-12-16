## Copyright (C) 2007  Soren Hauberg
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3, or (at your option)
## any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details. 
## 
## You should have received a copy of the GNU General Public License
## along with this file.  If not, write to the Free Software Foundation,
## 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} @var{J} = imsmooth(@var{I}, @var{name}, @var{options})
## Smooth the given image using several different algorithms.
##
## The first input argument @var{I} is the image to be smoothed. If it is an RGB
## image, each color plane is treated separately.
## The variable @var{name} must be a string that determines which algorithm will
## be used in the smoothing. It can be any of the following strings
##
## @table @asis
## @item  "Gaussian"
## Isotropic Gaussian smoothing. This is the default.
## @item  "Average"
## Smoothing using a rectangular averaging linear filter.
## @item  "Disk"
## Smoothing using a circular averaging linear filter.
## @item  "Perona & Malik"
## @itemx "Perona and Malik"
## @itemx "P&M"
## Smoothing using anisotropic diffusion as described by Perona and Malik.
## @end table
##
## In all algorithms the computation is done in double precision floating point
## numbers, but the result has the same type as the input. Also, the size of the
## smoothed image is the same as the input image.
##
## @strong{Isotropic Gaussian smoothing}
##
## The image is convolved with a Gaussian filter with spread @var{sigma}.
## By default @var{sigma} is @math{0.5}, but this can be changed. If the third
## input argument is a scalar it is used as the filter spread.
##
## The image is extrapolated symmetrically before the convolution operation.
##
## @strong{Rectangular averaging linear filter}
##
## The image is convolved with @var{N} by @var{M} rectangular averaging filter.
## By default a 3 by 3 filter is used, but this can e changed. If the third
## input argument is a scalar @var{N} a @var{N} by @var{N} filter is used. If the third
## input argument is a two-vector @code{[@var{N}, @var{M}]} a @var{N} by @var{M}
## filter is used.
##
## The image is extrapolated symmetrically before the convolution operation.
##
## @strong{Circular averaging linear filter}
##
## The image is convolved with circular averaging filter. By default the filter
## has a radius of 5, but this can e changed. If the third input argument is a
## scalar @var{r} the radius will be @var{r}.
##
## The image is extrapolated symmetrically before the convolution operation.
##
## @strong{Perona and Malik}
##
## The image is smoothed using anisotropic diffusion as described by Perona and
## Malik. The algorithm iteratively updates the image using
##
## @example
## I += lambda * (g(dN).*dN + g(dS).*dS + g(dE).*dE + g(dW).*dW)
## @end example
##
## @noindent
## where @code{dN} is the spatial derivative of the image in the North direction,
## and so forth. The function @var{g} determines the behaviour of the diffusion.
## If @math{g(x) = 1} this is standard isotropic diffusion.
##
## The above update equation is repeated @var{iter} times, which by default is 10
## times. If the third input argument is a positive scalar, that number of updates
## will be performed.
##
## The update parameter @var{lambda} affects how much smoothing happens in each
## iteration. The algorithm can only be proved stable is @var{lambda} is between
## 0 and 0.25, and by default it is 0.25. If the fourth input argument is given
## this parameter can be changed.
##
## The function @var{g} in the update equation determines the type of the result.
## By default @code{@var{g}(@var{d}) = exp(-(@var{d}./@var{K}).^2)} where @var{K} = 25.
## This choice gives privileges to high-contrast edges over low-contrast ones.
## An alternative is to set @code{@var{g}(@var{d}) = 1./(1 + (@var{d}./@var{K}).^2)},
## which gives privileges to wide regions over smaller ones. The choice of @var{g}
## can be controlled through the fifth input argument. If it is the string
## @code{"method1"}, the first mentioned function is used, and if it is @var{"method2"}
## the second one is used. The argument can also be a function handle, in which case
## the given function is used. It should be noted that for stability reasons,
## @var{g} should return values between 0 and 1.
##
## The following example shows how to set
## @code{@var{g}(@var{d}) = exp(-(@var{d}./@var{K}).^2)} where @var{K} = 50.
## The update will be repeated 25 times, with @var{lambda} = 0.25.
##
## @example
## @var{g} = @@(@var{d}) exp(-(@var{d}./50).^2);
## @var{J} = imsmooth(@var{I}, "p&m", 25, 0.25, @var{g});
## @end example
##
## @seealso{imfilter, fspecial}
## @end deftypefn

## TODO: Implement Joachim Weickert's anisotropic diffusion (it's soo cool)

function J = imsmooth(I, name = "gaussian", varargin)
  ## Check inputs
  if (nargin == 0)
    print_usage();
  endif
  if (!ismatrix(I))
    error("imsmooth: first input argument must be an image");
  endif
  [imrows, imcols, imchannels, tmp] = size(I);
  if ((imchannels != 1 && imchannels != 3) || tmp != 1)
    error("imsmooth: first input argument must be an image");
  endif
  if (!ischar(name))
    error("imsmooth: second input must be a string");
  endif
  len = length(varargin);
  
  ## Save information for later
  C = class(I);
  I = double(I);
  
  ## Take action depending on 'name'
  switch (lower(name))
    ##############################
    ###   Gaussian smoothing   ###
    ##############################
    case "gaussian"
      ## Check input
      s = 0.5;
      if (len > 0)
        if (isscalar(varargin{1}) && varargin{1} > 0)
          s = varargin{1};
        else
          error("imsmooth: third input argument must be a positive scalar when performing Gaussian smoothing");
        endif
      endif
      ## Compute filter
      h = ceil(3*s);
      f = exp( (-(-h:h).^2)./(2*s^2) ); f /= sum(f);
      ## Pad image
      I = impad(I, h, h, "symmetric");
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = conv2(f, f, I(:,:,i), "valid");
      endfor

    ############################
    ###   Square averaging   ###
    ############################
    case "average"
      ## Check input
      s = [3, 3];
      if (len > 0)
        if (isscalar(varargin{1}) && varargin{1} > 0)
          s = [varargin{1}, varargin{1}];
        elseif (isvector(varargin{1}) && length(varargin{1}) == 2 && all(varargin{1} > 0))
          s = varargin{1};
        else
          error("imsmooth: third input argument must be a positive scalar or two-vector when performing averaging");
        endif
      endif
      ## Compute filter
      f2 = ones(1,s(1))/s(1);
      f1 = ones(1,s(2))/s(2);
      ## Pad image
      I = impad(I, floor([s(2), s(2)-1]/2), floor([s(1), s(1)-1]/2), "symmetric");
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = conv2(f1, f2, I(:,:,i), "valid");
      endfor
      
    ##############################
    ###   Circular averaging   ###
    ##############################
    case "disk"
      ## Check input
      r = 5;
      if (len > 0)
        if (isscalar(varargin{1}) && varargin{1} > 0)
          r = varargin{1};
        else
          error("imsmooth: third input argument must be a positive scalar when performing averaging");
        endif
      endif
      ## Compute filter
      f = fspecial("disk", r);
      ## Pad image
      I = impad(I, r, r, "symmetric");
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = conv2(I(:,:,i), f, "valid");
      endfor
    
    ############################
    ###   Perona and Malik   ###
    ############################
    case {"perona & malik", "perona and malik", "p&m"}
      ## Check input
      K = 25;
      method1 = @(d) exp(-(d./K).^2);
      method2 = @(d) 1./(1 + (d./K).^2);
      method = method1;
      lambda = 0.25;
      iter = 10;
      if (len > 0 && !isempty(varargin{1}))
        if (isscalar(varargin{1}) && varargin{1} > 0)
          iter = varargin{1};
        else
          error("imsmooth: number of iterations must be a positive scalar");
        endif
      endif
      if (len > 1 && !isempty(varargin{2}))
        if (isscalar(varargin{2}) && varargin{2} > 0)
          lambda = varargin{2};
        else
          error("imsmooth: fourth input argument must be a scalar when using 'Perona & Malik'");
        endif
      endif
      if (len > 2 && !isempty(varargin{3}))
        fail = false;
        if (ischar(varargin{3}))
          if (strcmpi(varargin{3}, "method1"))
            method = method1;
          elseif (strcmpi(varargin{3}, "method2"))
            method = method2;
          else
            fail = true;
          endif
        elseif (strcmp(typeinfo(varargin{3}), "function handle"))
          method = varargin{3};
        else
          fail = true;
        endif
        if (fail)
          error("imsmooth: fifth input argument must be a function handle or the string 'method1' or 'method2' when using 'Perona & Malik'");
        endif
      endif
      ## Perform the filtering
      for i = imchannels:-1:1
        J(:,:,i) = pm(I(:,:,i), iter, lambda, method);
      endfor

    #############################
    ###   Unknown filtering   ###
    #############################
    otherwise
      error("imsmooth: unsupported smoothing type '%s'", name);
  endswitch
  
  ## Cast the result to the same class as the input
  J = cast(J, C);
endfunction

## Perona and Malik for gray-scale images
function J = pm(I, iter, lambda, g)
  ## Initialisation
  [imrows, imcols] = size(I);
  J = I;
  
  for i = 1:iter
    ## Pad image
    padded = impad(J, 1, 1, "replicate");

    ## Spatial derivatives
    dN = padded(1:imrows, 2:imcols+1) - J;
    dS = padded(3:imrows+2, 2:imcols+1) - J;
    dE = padded(2:imrows+1, 3:imcols+2) - J;
    dW = padded(2:imrows+1, 1:imcols) - J;

    gN = g(dN);
    gS = g(dS);
    gE = g(dE);
    gW = g(dW);

    ## Update
    J += lambda*(gN.*dN + gS.*dS + gE.*dE + gW.*dW);
  endfor
endfunction
