## Copyright (C) 2017 Avinoam Kalma <a.kalma@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
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
## @deftypefn {Function File} {} imsharpen (@var{im}, @var{options})
## Using Unsharp Masking to sharpen images:
##
## OUT_image = im + k*(im - smooth(im))
##
## @var{im} is a gray level image or color image.
## @var{smooth(im)} is the image after a gaussian smoothing.
## For color images, the image is transformed to Lab colorspace,
## L channel is sharpen to L', and L'ab is transformed back to RGB.
##
## Parameters:
## @itemize @bullet
## @item @var{"radius"} - sigma of Gaussian Filter for the smoothing stage.
## positive number (default = 1)
## @item  @var{"Amount"} - magnitude of the overshoot k. Non-negative number (default = 0.8)
## @item @var{"Threshold"} - minimum brightness change that will be sharpened.
## Threshold value should be in the range [0:1] (default = 0)
## @end itemize
##
## Examples:
## @example
## @group
## out = imsharpen (im);              # Using imsharpen with default values
## out = imsharpen (im, "Radius", 1.5);
## out = imsharpen (im, "Amount", 1.2);
## out = imsharpen (im, "Threshold", 0.5);
## out = imsharpen (im, "Radius", 1.5, "Amount", 1.2, "Threshold", 0.5);
## @end group
## @end example
##
## See "Unsharp masking" in Wikipedia: https://en.wikipedia.org/wiki/Unsharp_masking
##
## @seealso{imfilter, fspecial}
## @end deftypefn

function [OUT] = imsharpen (im, varargin)

  if (nargin == 0)
    print_usage ();
  elseif (! isnumeric (im) && ! isbool (im))
    error ("imsharpen: IM must be numeric or logical")
  endif

  imsharpen_param = check_imsharpen_args (varargin);

  imsharpen_size = ceil(max(4*imsharpen_param.Radius+1,3));
  if (mod(imsharpen_size,2) == 0)
    imsharpen_size += 1;
  endif

  if (size(im,3) == 1)
     OUT = USMGray(im, imsharpen_size, imsharpen_param.Radius, ...
                      imsharpen_param.Amount, imsharpen_param.Threshold);
  else
     OUT = USMColor(im, imsharpen_size, imsharpen_param.Radius, ...
                       imsharpen_param.Amount, imsharpen_param.Threshold);
  end
  OUT = imcast (OUT, class(im));
  return
endfunction

function [OUT] = USMGray(I, hsize, sigma, amount, thresh)

  ## UnSharp Masking of gray images

  f = fspecial('gaussian', hsize, sigma);
  ID = im2double(I);
  filtered = imfilter (ID, f, 'replicate');
  g = ID - filtered;
  if (thresh > 0)
     absg = abs(g);
     thr = thresh*max(absg(:));
     bw = im2bw (absg, thr);
     g = g.*bw;
  end
  OUT = ID + amount*g;

return
endfunction

function [OUT] = USMColor(I, hsize, sigma, amount, thresh)

  ## UnSharp Masking of color images
  ## Transform image to CIELab color space, perform UnSharp Masking on L channel,
  ## and transform back to RGB.

  ## Convert input RGB image to CIELab color space.
  Lab = rgb2lab (I);
  U = USMGray(Lab(:,:,1), hsize, sigma, amount, thresh);
  Lab(:,:,1) = U;
  ## Convert filtered image back to RGB color space.
  OUT = lab2rgb (Lab);

return
endfunction

function [param_out] = check_imsharpen_args(optional_param)

  param_out.Radius = 1;
  param_out.Amount = 0.8;
  param_out.Threshold = 0;

  p = inputParser;

  ## Parameter values

  p.addParamValue ('Radius', param_out.Radius, @isnumeric);
  p.addParamValue ('Amount', param_out.Amount, @isnumeric);
  p.addParamValue ('Threshold', param_out.Threshold, @isnumeric);

  ## parsing
  p.parse (optional_param{:});

  if (p.Results.Radius <= 0)
    error ('imsharpen: Radius should be positive');
  end

  if (p.Results.Amount < 0)
    error ('imsharpen: Amount should be non-negative');
  end

  if (p.Results.Threshold < 0 || p.Results.Threshold > 1)
    error ('imsharpen: Threshold should be in the range [0:1]');
  end

  ## param_out

  param_out.Radius    = p.Results.Radius;
  param_out.Amount    = p.Results.Amount;
  param_out.Threshold = p.Results.Threshold;

endfunction

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! B = ...
%! [0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000,
%!  0.00000  -0.00238  -0.01064  -0.01755  -0.01064  -0.00238   0.00000,
%!  0.00000  -0.01064  -0.04771  -0.07866  -0.04771  -0.01064   0.00000,
%!  0.00000  -0.01755  -0.07866   1.67032  -0.07866  -0.01755   0.00000,
%!  0.00000  -0.01064  -0.04771  -0.07866  -0.04771  -0.01064   0.00000,
%!  0.00000  -0.00238  -0.01064  -0.01755  -0.01064  -0.00238   0.00000,
%!  0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000];
%! assert (imsharpen(A), B, 5e-6);

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! B = ...
%! [-0.0035147  -0.0065663  -0.0095539  -0.0108259  -0.0095539  -0.0065663  -0.0035147,
%!  -0.0065663  -0.0122674  -0.0178490  -0.0202255  -0.0178490  -0.0122674  -0.0065663,
%!  -0.0095539  -0.0178490  -0.0259701  -0.0294280  -0.0259701  -0.0178490  -0.0095539,
%!  -0.0108259  -0.0202255  -0.0294280   1.7666538  -0.0294280  -0.0202255  -0.0108259,
%!  -0.0095539  -0.0178490  -0.0259701  -0.0294280  -0.0259701  -0.0178490  -0.0095539,
%!  -0.0065663  -0.0122674  -0.0178490  -0.0202255  -0.0178490  -0.0122674  -0.0065663,
%!  -0.0035147  -0.0065663  -0.0095539  -0.0108259  -0.0095539  -0.0065663  -0.0035147];
%! assert (imsharpen(A, 'radius', 2), B, 5e-8);

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! assert (imsharpen(A, 'radius', 0.01), A, 0);

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! B = A;
%! B(3:5,3:5) = -0.000000000011110;
%! B(3:5,4)   = -0.000002981278097;
%! B(4,3:5)   = -0.000002981278097;
%! B(4,4)     =  1.000011925156828;
%! assert (imsharpen(A, 'radius', 0.2), B, 5e-16);

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! B = ...
%!  [0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000,
%!   0.00000  -0.00297  -0.01331  -0.02194  -0.01331  -0.00297   0.00000,
%!   0.00000  -0.01331  -0.05963  -0.09832  -0.05963  -0.01331   0.00000,
%!   0.00000  -0.02194  -0.09832   1.83790  -0.09832  -0.02194   0.00000,
%!   0.00000  -0.01331  -0.05963  -0.09832  -0.05963  -0.01331   0.00000,
%!   0.00000  -0.00297  -0.01331  -0.02194  -0.01331  -0.00297   0.00000,
%!   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000   0.00000];
%! assert (imsharpen(A, 'amount', 1), B, 5e-6);

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! B = zeros(7,7);
%! B(4,4) =  1.670317742690299;
%! B(4,3) = -0.078656265079077;
%! B(3,4) = -0.078656265079077;
%! B(4,5) = -0.078656265079077;
%! B(5,4) = -0.078656265079077;
%! assert (imsharpen(A, 'Threshold', 0.117341762), B, 5e-16)

%!test
%! A = zeros(7,7);
%! A(4,4) = 1;
%! B = zeros(7,7);
%! B(4,4) = 1.670317742690299;
%! assert (imsharpen(A, 'Threshold', 0.117341763), B, 5e-16)

## uint8 test
%!test
%! A=zeros(7,7,'uint8');
%! A(3:5,3:5)=150;
%! B=zeros(7,7,'uint8');
%! B(3:5,3:5)=211;
%! B(4,3:5)=195;
%! B(3:5,4)=195;
%! B(4,4)=175;
%! assert (imsharpen(A), B, 0);

## uint8 test
%!test
%! A=zeros(7,7,'uint8');
%! A(3:5,3:5)=100;
%! B=zeros(7,7,'uint8');
%! B(3:5,3:5)=173;
%! assert (imsharpen(A, 'radius', 4), B, 0);

## color image test #1
%!test
%! A = zeros(7,7,3,'uint8');
%! A(4,4,:) = 255;
%! assert (imsharpen(A), A, 0);

## Matlab result is different by 1 grayscale
%!test
%! A = zeros(7,7,3,'uint8');
%! A(4,4,1) = 255;
%! B = A;
%! B(4,4,2) = 146;   # Octave result is 145;
%! B(4,4,3) = 100;   # Octave result is 99;
%! assert (imsharpen(A), B, 1);

## Matlab result is different by 1 grayscale
%!test
%! A = zeros(7,7,3,'uint8');
%! A(3:5,3:5,1) = 100;
%! A(3:5,3:5,2) = 150;
%! B = A;
%! B(3:5,3:5,1) = 164;
%! B(3:5,4,1)   = 146;     # Octave result is 147
%! B(4,3:5,1)   = 146;     # Octave result is 145
%! B(4,4,1)     = 125;     # Octave result is 126
%! B(3:5,3:5,2) = 213;
%! B(3:5,4,2)   = 195;     # Octave result is 196
%! B(4,3:5,2)   = 195;     # Octave result is 196
%! B(4,4,2)     = 175;
%! B(3:5,3:5,3) = 79;
%! B(3:5,4,3)   = 62;
%! B(4,3:5,3)   = 62;
%! B(4,4,3)     = 40;      # Octave result is 39
%! assert (imsharpen(A), B, 1);

## Test input validation
%!error imsharpen ()
%!error imsharpen (ones(3,3), 'Radius')
%!error imsharpen (ones(3,3), 'Radius', 0)
%!error imsharpen (ones(3,3), 'Amount', -1)
%!error imsharpen (ones(3,3), 'Threshold', 1.5)
%!error imsharpen (ones(3,3), 'Threshold', -1)
%!error imsharpen (ones(3,3), 'foo')
%!error imsharpen ('foo')
