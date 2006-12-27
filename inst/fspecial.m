## Copyright (C) 2005 S�ren Hauberg
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function [ f ] = fspecial (type, arg1, arg2)
  if (!ischar(type))
    error("fspecial: first argument must be a string");
  endif
  
  switch lower(type)
    case "average"
      ## Get filtersize
      if (nargin > 1 && isreal(arg1) && length(arg1(:)) <= 2)
        fsize = arg1(:);
      else
        fsize = 3;
      endif
      ## Create the filter
      f = ones(fsize);
      ## Normalize the filter to integral 1
      f = f/sum(f(:));

    case "disk"
      ## Get the radius
      if (nargin > 1 && isreal(arg1) && length(arg1(:)) == 1)
        radius = arg1;
      else
        radius = 5;
      endif
      ## Create the filter
      [x,y] = meshgrid(-c2:c2, -r2:r2);
      r = sqrt(x.^2 + y.^2);
      f = (r <= radius);
      ## Normalize the filter to integral 1
      f = f/sum(f(:));

    case "gaussian"
      ## Get hsize
      if (nargin > 1 && isreal(arg1))
        if (length(arg1(:)) == 1)
          hsize = [arg1, arg1];
        elseif (length(arg1(:)) == 2)
          hsize = arg1;
        else
          error("fspecial: second argument must be a scalar or a vector of two scalars");
        endif
      else
        hsize = [3, 3];
      endif
      ## Get sigma
      if (nargin > 2 && isreal(arg2) && length(arg2(:)) == 1)
        sigma = arg2;
      else
        sigma = 0.5;
      endif
      h1 = hsize(1)-1; h2 = hsize(2)-1; 
      [x, y] = meshgrid(0:h2, 0:h1);
      x = x-h2/2; y = y-h1/2;
      gauss = exp( -( x.^2 + y.^2 ) / (2*sigma^2) );
      f = gauss/sum(gauss(:));

    case "laplacian"
      ## Get alpha
      if (nargin > 1 && isscalar(arg1))
        alpha = arg1;
        if (alpha<0 | alpha>1)
          error("fspecial: second argument must be between 0 and 1");
        endif
      else
        alpha = 0.2;
      endif
      ## Compute filter
      f = (4/(alpha+1))*[alpha/4, (1-alpha)/4, alpha/4; ...
                         (1-alpha)/4, -1, (1-alpha)/4;  ...
                         alpha/4, (1-alpha)/4, alpha/4];
    case "log"
      ## Get hsize
      if (nargin > 1 && isreal(arg1))
        if (length(arg1(:)) == 1)
          hsize = [arg1, arg1];
        elseif (length(arg1(:)) == 2)
          hsize = arg1;
        else
          error("fspecial: second argument must be a scalar or a vector of two scalars");
        endif
      else
        hsize = [5, 5];
      endif
      ## Get sigma
      if (nargin > 2 && isreal(arg2) && length(arg2(:)) == 1)
        sigma = arg2;
      else
        sigma = 0.5;
      endif
      ## Compute the filter
      h1 = hsize(1)-1; h2 = hsize(2)-1; 
      [x y] = meshgrid(0:h2, 0:h1);
      x = x-h2/2; y = y = y-h1/2;
      gauss = exp( -( x.^2 + y.^2 ) / (2*sigma^2) );
      f = ( (x.^2 + y.^2 - 2*sigma^2).*gauss )/( 2*pi*sigma^6*sum(gauss(:)) );

    case "motion"
      ## Taken (with some changes) from Peter Kovesis implementation 
      ## (http://www.csse.uwa.edu.au/~pk/research/matlabfns/OctaveCode/fspecial.m)
      ## FIXME: The implementation is not quite matlab compatible.
      if (nargin > 1 && isreal(arg1))
        len = arg1;
      else
        len = 9;
      endif
      if (mod(len,2) == 1)
        sze = [len, len];
      else
        sze = [len+1, len+1];
      end
      if (nargin > 2 && isreal(arg2))
        angle = arg2;
      else
        angle = 0;
      endif
	    
      ## First generate a horizontal line across the middle
      f = zeros(sze);
      f(floor(len/2)+1,1:len) = 1;   

      # Then rotate to specified angle
      f = imrotate(f, angle, 'bilinear', 'loose');
      f = f/sum(f(:));

    case "prewitt"
      ## The filter
      f = [1 1 1; 0 0 0; -1 -1 -1];
      
    case "sobel"
      ## The filter
      f = [1 2 1; 0 0 0; -1 -2 -1];
      
    case "kirsch"
      ## The filter
      f = [3 3 3; 3 0 3; -5 -5 -5];
    
    case "unsharp"
      ## Get alpha
      if (nargin > 1 && isscalar(arg1))
        alpha = arg1;
        if (alpha<0 | alpha>1)
          error("fspecial: second argument must be between 0 and 1");
        endif
      else
        alpha = 0.2;
      endif
      ## Compute filter
      f = (1/(alpha+1))*[-alpha,  alpha-1, -alpha; ...
                         alpha-1, alpha+5, alpha-1; ...
                         -alpha,  alpha-1, -alpha];

    otherwise
      error("fspecial: filter type '%s' is not supported", type);
  endswitch
endfunction
