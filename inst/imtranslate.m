## Copyright (C) 2002 Jeff Orchard
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{Y}} = imtranslate (@var{M}, @var{x}, @var{y} [, @var{bbox}])
## Translate a 2D image by (x,y) using Fourier interpolation.
##
## @var{M} is a matrix, and is translated to the right by @var{X} pixels
## and translated up by @var{Y} pixels.
##
## @var{bbox} can be either 'crop' or 'wrap' (default).
##
## @end deftypefn

## Author: Jeff Orchard <jjo@cs.sfu.ca>

function Y = imtranslate(X, a, b, bbox_in)

	bbox = "wrap";
	if ( nargin > 3 )
		bbox = bbox_in;
	endif

	if ( strcmp(bbox, "crop")==1 )

		xpad = [0,0];
		if (a>0)
			xpad = [0,ceil(a)];
		elseif (a<0)
			xpad = [-ceil(a),0];
		endif

		ypad = [0,0];
		if (b>0)
			ypad = [ceil(b),0];
		elseif (b<0)
			ypad = [0,-ceil(b)];
		endif

		X = impad(X, xpad, ypad, 'zeros');
	endif


	[dimy, dimx] = size(X);
	x = ifftshift(fft2(fftshift(X)));
	px = exp(-2*pi*i*a*(0:dimx-1)/dimx);
	py = exp(-2*pi*i*b*(0:dimy-1)/dimy)';
	P = py * px;
	y = x .* P;
	Y = abs( ifftshift(ifft2(fftshift(y))) );
	#Y = ifftshift(ifft2(fftshift(y)));

	if ( strcmp(bbox, "crop")==1 )
		Y = Y(  ypad(1)+1:dimy-ypad(2) , xpad(1)+1:dimx-xpad(2));
	endif
endfunction
