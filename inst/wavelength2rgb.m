## Copyright (C) 2011 William Krekeler <WKrekeler@cleanearthtech.com>
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

function RGB = wavelength2rgb( WAVELENGTH, varargin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function RGB = wavelength2rgb( WAVELENGTH, <INTENSITY_MAX>, <GAMMA> )
%
%  Author:     William Krekeler
%  Date  :     20111031
%  Synopsis:   convert wavelength in nm into an RGB value set
%
%  Returns:    RGB value set on scale of 1:INTENSITY_MAX
%
%  Variables: 
%           all variables encoded as <VAR> are optional, 
%
%               WAVELENGTH  = wavelength of input light value in nm
%                             value can not be a vector
%
%               INTENSITY_MAX =  ( default = 255 ) max of integer scale to output values in
%
%               GAMMA       = ( default = 0.8 ); value should be 0-1. Controls luminance   
%
%  Example Calls:
%
%     X = 350:0.5:800;
%     Y = exp(log(X.^3));   % arbitrary
%     figure, plot( X, Y )
%     stepSize = .5*max(diff( X ) );
%     for n = 1:numel(Y)
%        RGB = wavelength2rgb( X(n), 1 );
%          if ( sum( RGB ) > 0 )   % ie don't fill black
%             hold on, area( (X(n)-stepSize):(stepSize/1):(X(n)+stepSize), ...
%                repmat( Y(n), 1, numel((X(n)-stepSize):(stepSize/1):(X(n)+stepSize)) ), ...
%                'EdgeColor', RGB, 'FaceColor', RGB ); hold off
%          end
%     end
% 
%  Version Update: 20111031 (created)
%
%  See also:
%             put in src
%
%  Source:
%     http://stackoverflow.com/questions/2374959/algorithm-to-convert-any-positive-integer-to-an-rgb-value
%     http://www.midnightkite.com/color.html per Dan Bruton
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- handle inputs
optargin = size( varargin, 2 );

% set Intensity Max
if ( optargin > 0 )
   INTENSITY_MAX = cell2mat(varargin(1));
else
   INTENSITY_MAX = 255;
end

% set the GAMMA value
if ( optargin > 1 )
   GAMMA = cell2mat(varargin(2));
else
   GAMMA = 0.80;
end

if ( GAMMA > 1 || GAMMA < 0 )
   GAMMA = 0.80;
end

RGB = zeros(3, numel(WAVELENGTH) );  % initialize RGB, each RGB set stored by column

% set the factor
if ( WAVELENGTH >= 380 && WAVELENGTH < 420 )
   factor = 0.3 + 0.7*(WAVELENGTH - 380) / (420 - 380);
elseif ( WAVELENGTH >= 420 && WAVELENGTH < 701 )
   factor = 1;
elseif ( WAVELENGTH >= 420 && WAVELENGTH < 701 )
   factor = 0.3 + 0.7*(780 - WAVELENGTH) / (780 - 700);
else
   factor = 0;
end

% initialize RGB
if ( WAVELENGTH >=380 && WAVELENGTH < 440 )
   RGB(1) = -(WAVELENGTH - 440) / (440 - 380);
   RGB(2) = 0.0;
   RGB(3) = 1.0;
elseif ( WAVELENGTH >= 440 && WAVELENGTH < 490 )
   RGB(1) = 0.0;
   RGB(2) = (WAVELENGTH - 440) / (490 - 440);
   RGB(3) = 1.0;
elseif ( WAVELENGTH >= 490 && WAVELENGTH < 510 )
   RGB(1) = 0.0;
   RGB(2) = 1.0;
   RGB(3) = -(WAVELENGTH - 510) / (510 - 490);
elseif ( WAVELENGTH >= 510 && WAVELENGTH < 580 )
   RGB(1) = (WAVELENGTH - 510) / (580 - 510);
   RGB(2) = 1.0;
   RGB(3) = 0.0;
elseif ( WAVELENGTH >= 580 && WAVELENGTH < 645 )
   RGB(1) = 1.0;
   RGB(2) = -(WAVELENGTH - 645) / (645 - 580);
   RGB(3) = 0.0;
elseif ( WAVELENGTH >= 645 && WAVELENGTH < 781 )
   RGB(1) = 1.0;
   RGB(2) = 0.0;
   RGB(3) = 0.0;
else
   RGB(1) = 0.0;
   RGB(2) = 0.0;
   RGB(3) = 0.0;
end

% correct RGB
RGB = INTENSITY_MAX .* (RGB .* factor) .^GAMMA .* ( RGB > 0 );

return;

