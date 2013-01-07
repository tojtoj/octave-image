## Copyright (C) 2012 Roberto Metere <roberto@metere.it>
## Copyright (C) 2012 Carnë Draug <roberto@metere.it>
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
## @deftypefn {Function File} {@var{se2} =} reflect (@var{se})
## Reflect structuring element of strel object.
##
## Returns another strel object with all its elements reflected.  If @var{se} is
## a sequence of strel objects, reflects each one of them.  If @var{se} is a
## non-flat structuring element, its height is reflected accordingly.
##
## Reflection is a rotation of 180 degrees around the center, including for
## N-dimensional matrices.
##
## @seealso{strel, @@strel/getheight, @@strel/getsequence, @@strel/translate}
## @end deftypefn

function se = reflect (se)

  ## FIXME this should be done in a smarter way for non-arbitrary shapes (but
  ##       then we may need to also change some of the options values...)
  if (isempty (se.seq))
    se = rotate_strel (se);
  else
    for idx = 1:numel (se.seq)
      se.seq{idx} = rotate_strel (se.seq{idx});
    endfor
  endif

endfunction

function se = rotate_strel (se)
  nhood  = getnhood (se);
  height = getheight (se);
  rotate = @(x) reshape (x(end:-1:1), size (x));
  se     = strel ("arbitrary", rotate (nhood), rotate (height));
endfunction




