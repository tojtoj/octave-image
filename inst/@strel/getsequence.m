## Copyright (C) 2012 Roberto Metere <roberto@metere.it>
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
## @deftypefn {Function File} {@var{seq} =} getsequence (@var{se})
## Decompose structuring element.
##
## Returns a strel object @var{se} that can be indexed with @code{()} to obtain
## the decomposed structuring elements that can be used to "rebuild" @var{se}.
##
## @seealso{imdilate, imerode, strel}
## @end deftypefn

function se = getsequence (se)

  if (isempty (se.seq))
    switch (se.shape)
      case {"square", "cube", "hypercube", "rectangle", "hyperrectangle"}
        nd = ndims (se.nhood);
        for idx = 1:nd
          vec_size      = ones (1, nd);
          vec_size(idx) = size (se.nhood, idx);
          se.seq{idx}   = strel ("arbitrary", true (vec_size));
        endfor

      otherwise
        se.seq{1,1} = se;
    endswitch
  endif

endfunction
