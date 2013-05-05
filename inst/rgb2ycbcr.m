## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
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
## @deftypefn  {Function File} {@var{YCbCrmap} =} rgb2ycbcr (@var{cmap})
## @deftypefnx {Function File} {@var{YCbCr} =} rgb2ycbcr (@var{RGB})
## @deftypefnx {Function File} {@dots{} =} rgb2ycbcr (@dots{}, [@var{Kb} @var{Kr}])
## @deftypefnx {Function File} {@dots{} =} rgb2ycbcr (@dots{}, @var{standard})
## Convert RGB values to YCbCr.
##
## The convertion changes the image @var{RGB} or colormap @var{cmap}, from
## the RGB color model to YCbCr (luminance, chrominance blue, and chrominance
## red).  @var{RGB} must be of class double, single, uint8, or uint16.
##
## The formula used for the conversion is dependent on two constants, @var{Kb}
## and @var{Kr} which can be specified individually, or according to existing
## standards:
##
## @table @asis
## @item "601" (default)
## According to the ITU-R BT.601 (formerly CCIR 601) standard.  Its values
## of @var{Kb} and @var{Kr} are 0.114 and 0.299 respectively.
## @item "709" (default)
## According to the ITU-R BT.709 standard.  Its values of @var{Kb} and
## @var{Kr} are 0.0722 and 0.2116 respectively.
## @end table
##
## @seealso{hsv2rgb, ntsc2rgb, rgb2hsv, rgb2ntsc}
## @end deftypefn

function ycbcr = rgb2ycbcr (rgb, standard = "601")

  img = false; # was input an image?

  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  if (iscolormap (rgb))
    ## do nothing, it's a colormap
  elseif (isrgb (rgb))
    img = true;
    ## if we have it in 2D, we can use matrix multiplcation
    nRows = rows (rgb);
    nCols = columns (rgb);
    rgb   = reshape (rgb, [nRows*nCols 3]);
  else
    error ("rgb2ycbcr: input must be a colormap (Nx3) or RGB image (NxMx3)");
  endif

  ## TODO would be interesting to accept arbitrary values of Kb and Kr
  if (! ischar (standard))
    error ("rgb2ycbcr; STANDARD must be a string `601' or `709'");
  elseif (strcmpi (standard, "601"))
    ## these are the values for ITU-R BT.601
    Kb = 0.114;
    Kr = 0.299;
  elseif (strcmpi (standard, "709"))
    ## these are the values for ITU-R BT.709
    Kb = 0.0722;
    Kr = 0.2126;
  else
    error ("rgb2ycbcr: unknown standard `%s'", standard);
  endif

  ## the color matrix for the conversion. Derived from:
  ##    Y  = Kr*R + (1-Kr-Kb)*G + kb*B
  ##    Cb = (1/2) * ((B-Y)/(1-Kb))
  ##    Cr = (1/2) * ((R-Y)/(1-Kr))
  ## It expects RGB values in the range [0 1], and returns Y in the
  ## range [0 1], and Cb and Cr in the range [-0.5 0.5]
  cmat = [  Kr            (1-Kr-Kb)            Kb
          -(Kr/(2-2*Kb)) -(1-Kr-Kb)/(2-2*Kb)   0.5
            0.5          -(1-Kr-Kb)/(2-2*Kr) -(Kb/(2-2*Kr)) ];

  cls   = class (rgb);
  rgb   = im2double (rgb);
  ycbcr = (cmat * rgb')'; # transpose in the end to get back colormap shape
  ## rescale Cb and Cr to range [0 1]
  ycbcr(:, [2 3]) += 0.5;
  ## footroom and headroom will take from the range 16/255 each for Cb and Cr,
  ## and 16/255 and 20/255 for Y. So we have to compress the values of the
  ## space, and then shift forward
  ycbcr(:,1) = (ycbcr(:,1) * 219/255) + 16/255;
  ycbcr(:,[2 3]) = (ycbcr(:,[2 3]) * 223/255) + 16/255;

  switch (cls)
    case {"single", "double"}
      ## do nothing. All is good
    case "uint8"
      ycbcr = im2uint8 (ycbcr);
    case "uint16"
      ycbcr = im2uint16 (ycbcr);
    otherwise
      error ("rgb2ycbcr: unsupported image class %s", cls);
  endswitch

  if (img)
    ## put the image back together
    ycbcr = reshape (ycbcr, [nRows nCols 3]);
  endif
endfunction

%!test
%! in(:,:,1) = magic (5);
%! in(:,:,2) = magic (5);
%! in(:,:,3) = magic (5);
%! out(:,:,1) = [31  37  17  23  29
%!               36  20  22  28  30
%!               19  21  27  33  35
%!               25  26  32  34  19
%!               25  31  37  18  24];
%! out(:,:,2) = 128;
%! out(:,:,3) = 128;
%! assert (rgb2ycbcr (uint8 (in)), uint8 (out));

%!test
%! out(1:10, 1)  = linspace (16/255, 235/255, 10);
%! out(:, [2 3]) = 0.5;
%! assert (rgb2ycbcr (gray (10)), out, 0.00001);

%!assert (rgb2ycbcr ([1 1 1]), [0.92157 0.5 0.5], 0.0001);
