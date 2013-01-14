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
## @deftypefn  {Function File} {} normxcorr2 (@var{template}, @var{img})
## @deftypefnx {Function File} {} normxcorr2 (@var{template}, @var{img})
## Compute the normalized 2D cross-correlation.
##
## Returns the normalized cross correlation matrix of @var{template} and
## @var{img} so that a value of 1 corresponds to the positions of @var{img} that
## match @var{template} perfectly.
##
## @emph{Note}: this function exists only for @sc{matlab} compatibility and is
## just a wrapper to the @code{coeff} option of @code{xcorr2} with the arguments
## inverted.  See the @code{xcorr2} documentation for more details. Same results
## can be obtained with @code{xcorr2 (img, template, "coeff")}
##
## @seealso{conv2, corr2, xcorr2}
## @end deftypefn

function cc = normxcorr2 (temp, img)
  if (nargin != 2)
    print_usage ();
  elseif (rows (temp) > rows (img) || columns (temp) > columns (img))
    error ("normxcorr2: template must be same size or smaller than image");
  endif
  cc = xcorr2 (img, temp, "coeff");
endfunction
