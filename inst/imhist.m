## Copyright (C) 1999,2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2000 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {} imhist (@var{I})
## @deftypefnx {Function File} {} imhist (@var{I}, @var{n})
## @deftypefnx {Function File} {} imhist (@var{X}, @var{cmap})
## @deftypefnx {Function File} {[@var{counts}, @var{x}] =} imhist (@dots{})
## Shows the histogram of an image @var{I}.
##
## The second argument can either be @var{n}, a scalar that specifies the number
## of bins; or @var{cmap}, a colormap in which case @var{X} is expected to be
## an indexed image. If not specified, @var{n} defauls to 2 for binary images,
## and 256 for grayscale images.
##
## If output is requested, @var{counts} is the number of counts for each bin and
## @var{x} is a range for the bins so that @code{stem (@var{x}, @var{counts})} will
## show the histogram.
## @seealso{hist, histc, histeq}
## @end deftypefn

function [nn, bins] = imhist (I, b)

  if (nargin < 1 || nargin > 2)
    print_usage();

  elseif (nargin == 1)
    if (islogical(I))
      bins = 0:1;
    else
      bins = 0:255;
    endif

  elseif (nargin == 2)
    ## A matrix with 3 columns is a colormap so...
    if (ismatrix (b) && columns (b) == 3)
      using_colormap = true;
      ## if using a colormap, image must be an indexed image
      if (!isind(I))
        error ("second argument is a colormap but image is not indexed");
      endif
      max_idx = max (I(:));
      bins    = 0:rows(b)-1;
      if (max_idx > bins(end))
        warning ("largest index exceeds length of colormap");
      endif
    elseif (isnumeric (b) && isscalar (b) && fix(b) == b)
      bins = 0:b-1;
    else
      error ("second argument should either be a positive integer scalar or a colormap");
    endif
  endif

  ## matlab returns bins as one column and not one row so we transpose the range
  bins = bins';

  ## XXX at the moment, this function is not working at all, at least for
  ## grayscale images. I'm assuming that the code will at least be working for
  ## indexed images and colormaps so I'm leaving the original code for those
  ## cases and use only the "new" code when "using_colormap" is false
  ## Carnë Draug 10/11/2011
  if (nargout == 0)
    if (exist ("using_colormap", "var") && using_colormap)
      hist (I(:), bins);
    else
      [nn] = histc (I(:), bins);
      stem (bins, nn);
    endif
  else
    if (exist ("using_colormap", "var") && using_colormap)
      [nn,bins] = hist (I(:), bins);
    else
      [nn] = histc (I(:), bins);
    endif

    vr_val_cnt = 1;
    varargout{vr_val_cnt++} = nn;
    varargout{vr_val_cnt++} = bins;
  endif
endfunction
