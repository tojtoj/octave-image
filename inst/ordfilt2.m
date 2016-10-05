## Copyright (C) 2000 Teemu Ikonen <tpikonen@pcu.helsinki.fi>
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
## @deftypefn  {Function File} {} ordfilt2 (@var{A}, @var{nth}, @var{domain})
## @deftypefnx {Function File} {} ordfilt2 (@var{A}, @var{nth}, @var{domain}, @var{S})
## @deftypefnx {Function File} {} ordfilt2 (@dots{}, @var{padding})
## Two dimensional ordered filtering.
##
## This function exists only for @sc{matlab} compatibility as is just a wrapper
## to the @code{ordfiltn} which performs the same function on N dimensions.  See
## @code{ordfiltn} help text for usage explanation.
##
## @seealso{medfilt2, padarray, ordfiltn}
## @end deftypefn

function A = ordfilt2 (A, nth, domain, varargin)

  if (nargin < 3)
    print_usage ();
  elseif (ndims (A) > 2 || ndims (domain) > 2 )
    error ("ordfilt2: A and DOMAIN are limited to 2 dimensinos. Use `ordfiltn' for more")
  endif
  A = ordfiltn (A, nth, domain, varargin{:});

endfunction
