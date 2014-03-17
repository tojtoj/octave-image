## Copyright (C) 2014 Benjamin Eltzner <b.eltzner@gmx.de>
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
## @deftypefn {Function File} {} normxcorr2 (@var{a}, @var{b})
## Compute the 2D cross-correlation coefficient of matrices @var{a} and @var{b}.
##
##
## @seealso{xcorr2, conv2, corr2, xcorr}
## @end deftypefn

function c = normxcorr2 (a, b)
  if (nargin != 2)
    print_usage;
  endif
  if (ndims (a) != 2 || ndims (b) != 2)
    error ("normxcorr2: input matrices must have only 2 dimensions");
  endif

  ## compute cross correlation coefficient
  [ma,na] = size(a);
  [mb,nb] = size(b);
  if (ma > mb || na > nb)
    warning ("Template is larger than image.\nArguments may be accidentally interchanged.");
  endif

  a = double (a);
  b = double (b);
  a = a .- mean2(a);
  b = b .- mean2(b);
  c = conv2 (b, conj (a (ma:-1:1, na:-1:1)));
  b = conv2 (b.^2, ones (size (a))) .- conv2 (b, ones (size (a))).^2 ./ (ma*na);
  a = sumsq (a(:));
  c(:,:) = c(:,:) ./ sqrt (b(:,:) * a);
  c(isnan(c)) = 0;
endfunction

%!test # basic usage
%!shared a, b, c, row_shift, col_shift, a_dev1, b_dev1, a_dev2, b_dev2
%! row_shift = 18;
%! col_shift = 20;
%! a = randi (255, 30, 30);
%! b = a(row_shift-10:row_shift, col_shift-7:col_shift);
%! c = normxcorr2 (b, a);
%!assert (nthargout ([1 2], @find, c == max (c(:))), {row_shift, col_shift}); # should return exact coordinates
%! m = rand (size (b)) > 0.5;
%! b(m) = b(m) * 0.95;
%! b(!m) = b(!m) * 1.05;
%! c = normxcorr2 (b, a);
%!assert (nthargout ([1 2], @find, c == max (c(:))), {row_shift, col_shift}); # even with some small noise, should return exact coordinates
%!test # coeff of autocorrelation must be same as negative of correlation by additive inverse
%! a = 10 * randn (100, 100);
%! auto = normxcorr2 (a, a);
%! add_in = normxcorr2 (a, -a);
%! assert (auto, -add_in);
%!test # normalized correlation should be independent of scaling and shifting up to rounding errors
%! a = 10 * randn (50, 50);
%! b = 10 * randn (100, 100);
%! scale = 0;
%! while (scale == 0)
%! scale = 100 * rand();
%! endwhile
%! assert (max (max (normxcorr2 (scale*a,b) .- normxcorr2 (a,b))) < 1e-10);
%! assert (max (max (normxcorr2 (a,scale*b) .- normxcorr2 (a,b))) < 1e-10);
%! a_shift1 = a .+ scale * ones (size (a));
%! b_shift1 = b .+ scale * ones (size (b));
%! a_shift2 = a .- scale * ones (size (a));
%! b_shift2 = b .- scale * ones (size (b));
%! assert (max (max (normxcorr2 (a_shift1,b) .- normxcorr2 (a,b))) < 1e-10);
%! assert (max (max (normxcorr2 (a,b_shift1) .- normxcorr2 (a,b))) < 1e-10);
%! assert (max (max (normxcorr2 (a_shift2,b) .- normxcorr2 (a,b))) < 1e-10);
%! assert (max (max (normxcorr2 (a,b_shift2) .- normxcorr2 (a,b))) < 1e-10);
