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
## @deftypefn {Function File} {@var{SEQ} =} getsequence (@var{SE})
## The sequence of decomposed structuring elements of SE.
##
## @seealso{imdilate, imerode, strel}
## @end deftypefn

function seq = getsequence (se)

  ## We can do this in 2 ways:
  ##   1. calculate this when creating the object and this only returns it
  ##   2. have strel keep the options and calculate the sequence (and store it )
  ##      only if requested (probably this is better)
  if (isempty (se.seq))
    ## this is just a sequence of SEs that can be used instead of a larger one,
    ## so it's still valid to have a single element same as nhood. While we
    ## don't implement this properly...
    se.seq{1} = se;
  endif
  seq = se.seq;

endfunction
