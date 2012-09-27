## Copyright (C) 2011 William Krekeler <WKrekeler@cleanearthtech.com>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn{Function File} {@var{rgb} =} wavelength2rgb (@var{wavelength})
## @deftypefnx{Function File} {@var{rgb} =} wavelength2rgb (@var{wavelength}, @var{intensity_max})
## @deftypefnx{Function File} {@var{rgb} =} wavelength2rgb (@var{wavelength}, @var{intensity_max}, @var{gamma})
## Convert wavelength in nm into an RGB value set.
##
## Output:
## @itemize @bullet
## @item @var{rgb}: value set on scale of 1:@var{intensity_max}
## @end itemize
##
## Input:
## Output:
## @itemize @bullet
## @item @var{wavelength}: wavelength of input light value in nm. Must be a positive
## numeric scalar.
## @item @var{intensity_max}: max of integer scale to output values. Defaults to 255.
## @item @var{gamma}: Controls luminance. Must be a value between 0 and 1. Defaults to 0.8.
## @end itemize
##
## @example
## X = 350:0.5:800;
## Y = exp (log (X.^3));   # arbitrary
## figure, plot(X, Y)
## stepSize = 0.5 * max (diff (X));
## for n = 1:numel(Y)
##   RGB = wavelength2rgb (X(n), 1);
##   if (sum (RGB) > 0 )   # ie don't fill black
##     hold on, area( (X(n)-stepSize):(stepSize/1):(X(n)+stepSize), ...
##                   repmat( Y(n), 1, numel((X(n)-stepSize):(stepSize/1):(X(n)+stepSize)) ), ...
##                   'EdgeColor', RGB, 'FaceColor', RGB ); hold off
##   endif
## endfor
## @end example
##
## Reference:
## @itemize @bullet
## @item @uref{http://stackoverflow.com/questions/2374959/algorithm-to-convert-any-positive-integer-to-an-rgb-value}
## @item @uref{http://www.midnightkite.com/color.html} per Dan Bruton
## @end itemize
## @end deftypefn

function rgb = wavelength2rgb (wavelength, intensity_max = 255, gamma = 0.8)

  if (nargin < 1 || nargin > 3)
    print_usage;
  elseif (!isnumeric (wavelength) || !isscalar (wavelength) || wavelength <= 0)
    error ("wavelength must a positive numeric scalar");
  elseif (!isnumeric (intensity_max) || !isscalar (intensity_max) || intensity_max <= 0)
    error ("intensity_max must a positive numeric scalar");
  elseif (!isnumeric (gamma) || !isscalar (gamma) || gamma > 1 || gamma < 0)
    error ("gamma must a numeric scalar between 1 and 0");
  endif

  rgb = zeros (3, numel (wavelength));  # initialize rgb, each rgb set stored by column

  ## set the factor
  if ( wavelength >= 380 && wavelength < 420 )
     factor = 0.3 + 0.7*(wavelength - 380) / (420 - 380);
  elseif ( wavelength >= 420 && wavelength < 701 )
     factor = 1;
  elseif ( wavelength >= 420 && wavelength < 701 )
     factor = 0.3 + 0.7*(780 - wavelength) / (780 - 700);
  else
     factor = 0;
  endif

  ## initialize rgb
  if ( wavelength >= 380 && wavelength < 440 )
     rgb(1) = -(wavelength - 440) / (440 - 380);
     rgb(2) = 0.0;
     rgb(3) = 1.0;
  elseif ( wavelength >= 440 && wavelength < 490 )
     rgb(1) = 0.0;
     rgb(2) = (wavelength - 440) / (490 - 440);
     rgb(3) = 1.0;
  elseif ( wavelength >= 490 && wavelength < 510 )
     rgb(1) = 0.0;
     rgb(2) = 1.0;
     rgb(3) = -(wavelength - 510) / (510 - 490);
  elseif ( wavelength >= 510 && wavelength < 580 )
     rgb(1) = (wavelength - 510) / (580 - 510);
     rgb(2) = 1.0;
     rgb(3) = 0.0;
  elseif ( wavelength >= 580 && wavelength < 645 )
     rgb(1) = 1.0;
     rgb(2) = -(wavelength - 645) / (645 - 580);
     rgb(3) = 0.0;
  elseif ( wavelength >= 645 && wavelength < 781 )
     rgb(1) = 1.0;
     rgb(2) = 0.0;
     rgb(3) = 0.0;
  else
     rgb(1) = 0.0;
     rgb(2) = 0.0;
     rgb(3) = 0.0;
  endif

  ## correct rgb
  rgb = intensity_max .* (rgb .* factor) .^gamma .* ( rgb > 0 );

endfunction
