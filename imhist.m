## Copyright (C) 1999,2000  Kai Habel
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} imhist (@var{I},@var{n})
## @deftypefnx {Function File} {} imhist (@var{I})
## @deftypefnx {Function File} {} imhist (@var{X},@var{cmap})
## @deftypefnx {Function File} {[@var{n,x}] = } imhist (...)
## Shows the histogram of an image using hist 
## @end deftypefn
## @seealso{hist}

## Author:	Kai Habel <kai.habel@gmx.de>
## July 2000 : Paul Kienzle code simplification for hist() call.

function [...] = imhist (I, b)

  if (nargin < 1 || nargin > 2)
    usage("imhist(image,n)");
  endif

  b_is_colormap = 0;

  if (nargin == 2)
    if (is_matrix (b))
      b_is_colormap = (columns (b) == 3);
    endif
  endif

  if (b_is_colormap)
    ## assuming I is an indexed image
    ## b is colormap
    max_idx = max (max (I));
    bins = rows (b);
    if (max_idx > bins)
      warning ("largest index exceedes length of colormap");
    endif
  else
    ## assuming I is an intensity image
    ## b is number of bins
    if (nargin == 1)
      bins = 256;
    else
      bins = b;
    endif

    ## scale image to range [0,1]
    I = mat2gray (I);
  endif
  
  if (nargout == 2)
    [nn,xx] = hist (I(:), bins);
    vr_val (nn);
    vr_val (xx);
  else
    hist (I(:), bins);
  endif

endfunction
