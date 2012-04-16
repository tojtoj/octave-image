## Copyright (C) 2000 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2004 Stefan van der Walt <stefan@sun.ac.za>
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
## @deftypefn {Function File} {@var{B} =} imnoise (@var{A}, @var{type})
## Adds noise to image in @var{A}.
##
## @table @code
## @item imnoise (A, 'gaussian' [, mean [, var]])
## additive gaussian noise: @var{B} = @var{A} + noise
## defaults to mean=0, var=0.01
## @item  imnoise (A, 'salt & pepper' [, density])
## lost pixels: A = 0 or 1 for density*100% of the pixels
## defaults to density=0.05, or 5%
## @item imnoise (A, 'speckle' [, var])
## multiplicative gaussian noise: @var{B} = @var{A} + @var{A}*noise
## defaults to var=0.04
## @end table
## @end deftypefn

function A = imnoise (A, stype, a, b)

  if (nargin < 2 || nargin > 4 || !ismatrix(A) || !ischar(stype))
    print_usage;
  endif
  
  valid = (min(A(:)) >= 0 && max(A(:)) <= 1);

  stype = tolower(stype);
  if (strcmp(stype, 'gaussian'))
    if (nargin < 3), a = 0.0; endif
    if (nargin < 4), b = 0.01; endif
    A = A + (a + randn(size(A)) * sqrt(b));
    ## Variance of Gaussian data with mean 0 is E[X^2]
  elseif (strcmp(stype, 'salt & pepper'))
    if (nargin < 3), a = 0.05; endif
    noise = rand(size(A));
    A(noise <= a/2) = 0;
    A(noise >= 1-a/2) = 1;
  elseif (strcmp(stype, 'speckle'))
    if (nargin < 3), a = 0.04; endif
    A = A .* (1 + randn(size(A))*sqrt(a));
  else
    error("imnoise: use type 'gaussian', 'salt & pepper', or 'speckle'");
  endif
  
  if valid
    A(A>1) = 1;
    A(A<0) = 0;
  else
    warning("Image should be in [0,1]");
  endif

endfunction

%!assert(var(imnoise(ones(10)/2,'gaussian')(:)),0.01,0.005) # probabilistic
%!assert(length(find(imnoise(ones(10)/2,'salt & pepper')~=0.5)),5,10) # probabilistic
%!assert(var(imnoise(ones(10)/2,'speckle')(:)),0.01,0.005) # probabilistic
