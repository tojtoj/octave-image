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
## @deftypefn {Function File} @var{J}= imadjust (@var{I},[low high],[bottom top],gamma)
## the values in the range [low high] of the image I (intensity) are transformed 
## in range [bottom top] of the resulting intensity image (J).
## A gamma value is applied.
## If gamma is ommitted then a linear mapping (gamma=1) is assumed.
## 
## @end deftypefn

## o    |
## u  ot+           ****
## t    |        *
## p    |     *
## u  ob+****
## t    |
##      -+--+-------+--+-
##       0  il      ih 1
##         input range
##
## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	17/03/2000

function ret = imadjust (I, in, out, gamma)

  if (nargin < 3 || nargin > 4)
    usage ("imadjust(...) number of arguments must be 3 or 4");
  endif

  if (nargin == 3)
    gamma = 1;
  else 
    if !(is_scalar (gamma))
      error ("imadjust(...,gamma) gamma must be a scalar");
    else
      if !(gamma >= 0 && gamma < Inf)
        error ("gamma range [0,Inf)");
      endif
    endif
  endif

  if !(is_matrix (I))
    error ("imadjust(I,...) I must be a image matrix or colormap");
  endif

  if !((is_vector (in) || isempty (in)) && (is_vector (out) || isempty (out)) )
    usage ("imadjust(I,[low high],[bottom top],gamma)");
  else
    if (length (in) == 0)
      il = 0;
      ih = 1;
    elseif (length (in) == 2)
      il = min (in);
      ih = max (in);
    else
      usage ("imadjust(I,[low high],[bottom top],gamma)");
    endif

    if (length (out) == 0)
      ob = 0;
      ot = 1;
    elseif (length (out) == 2)
      ob = out (1);
      ot = out (2);

      if (ob >= ot)
        ob = out (1);
        ot = out (2);
        warning ("bottom greater top");
      endif
    else
      usage ("imadjust(I,[low high],[bottom top],gamma)");
    endif
  endif

  ret = (I < il) .* ob;
  ret = ret + (I >= il & I < ih) .* (ob + (ot - ob) .* ((I - il) / (ih - il)) .^ gamma);
  ret = ret + (I >= ih) .* ot;

  if (in(1) > in(2))
    # hmm don't know if this is correct for gamma!=1
    ret = il + (ih - ret);
  endif

endfunction
