## Copyright (C) 2008 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn  {Function File} {} ordfiltn (@var{A}, @var{nth}, @var{domain})
## @deftypefnx {Function File} {} ordfiltn (@var{A}, @var{nth}, @var{domain}, @var{S})
## @deftypefnx {Function File} {} ordfiltn (@dots{}, @var{padding})
## N dimensional ordered filtering.
##
## Ordered filter replaces an element of @var{A} with the @var{nth} element 
## element of the sorted set of neighbours defined by the logical 
## (boolean) matrix @var{domain}.
## Neighbour elements are selected to the sort if the corresponding 
## element in the @var{domain} matrix is true.
## 
## The optional variable @var{S} is a matrix of size(@var{domain}). 
## Values of @var{S} corresponding to nonzero values of domain are 
## added to values obtained from @var{A} when doing the sorting.
##
## Optional variable @var{padding} determines how the matrix @var{A} 
## is padded from the edges. See @code{padarray} for details.
## 
## @seealso{medfilt2, padarray, ordfilt2}
## @end deftypefn

## This function is based on 'ordfilt2' by Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## which is released under GPLv2 or later.

function retval = ordfiltn (A, nth, domain, varargin)

  ## Check input
  if (nargin < 3)
    print_usage ();
  elseif (! ismatrix (A))
    error ("ordfiltn: first input must be an array");
  elseif (! isscalar (nth) || nth <= 0 || fix (nth) != nth)
    error ("ordfiltn: second input argument must be a positive integer");
  elseif (! ismatrix (domain) && ! isscalar (domain))
    error ("ordfiltn: third input argument must be an array or a scalar");
  elseif (isscalar (domain) && (domain <= 0 || fix (domain) != domain))
    error ("ordfiltn: third input argument must be a positive integer, when it is a scalar");
  endif

  if (isscalar (domain))
    domain = true (repmat (domain, 1, ndims (A)));
  endif
  
  if (ndims (A) != ndims (domain))
    error("ordfiltn: first and second argument must have same dimensionality");
  elseif (any (size (A) < size (domain)))
    error ("ordfiltn: domain array cannot be larger than the data array");
  endif

  ## Parse varargin
  S = zeros(size(domain));
  padding = 0;
  for i=1:length(varargin)
    a = varargin{:};
    if (ischar(a) || isscalar(a))
      padding = a;
    elseif (ismatrix(a) && size_equal(a, domain))
      S = a;
    endif
  endfor

  A = pad_for_spatial_filter (A, domain, padding);

  ## Perform the filtering
  retval = __spatial_filtering__ (A, logical (domain), "ordered", S, nth);

endfunction
