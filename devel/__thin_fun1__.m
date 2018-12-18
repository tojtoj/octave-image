## Copyright (C) 2018 Avinoam Kalma <a.kalma@gmail.com>
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
## @deftypefn {Function File} {@var{r} = } __thin_fun1__ (@var{X})
## Calculates the results of the first iteration for
## bwmorph (BW, "thin", 1) calculation
##
## @var{X} contains a 3-by-3 matrix to be evaluated.
##
## @var{r} =  __thin_fun1__ (@var{X}) evaluates a 3-by-3 BW matrix
## neighbourhood according to rules in Lam et al. paper,
## as first stage for thin morphological operation to create a
## LUT using makelut.
##
## Returns 0 if the central pixel is deleted after the first
## iteration for "thin" operators and 1 otherwise.
##
## This function is needed by bwmorph, although it just contains the
## result matrix as a literal inside the code.
##
## This function probably never be needed by itself, but it's useful to
## know how bwmorph was coded.
##
## References:
## Louisa Lam, Seong-Whan Lee, and Ching Y. Suen,
## "Thinning methodologies - a comprehensive survey,"
## in IEEE Transactions on Pattern Analysis and Machine Intelligence,
## vol. 14, no. 9, pp. 869-885, Sept. 1992.
## @url{https://pdfs.semanticscholar.org/0404/ba243ecbb8efc6bcb07a754b6f8770856131.pdf}
## The algorithm used here appears on the bottom of first column of page 879,
## through top of second column.
## @end deftypefn
## @seealso{bwmorph}

function ret = __thin_fun1__ (A)

  ## stage 1 in thin algorithm
  x1 = A(2,3);
  x2 = A(1,3);
  x3 = A(1,2);
  x4 = A(1,1);
  x5 = A(2,1);
  x6 = A(3,1);
  x7 = A(3,2);
  x8 = A(3,3);
  p = A(2,2);

  ## condition 1
  b1 = (!x1) & (x2 | x3);
  b2 = (!x3) & (x4 | x5);
  b3 = (!x5) & (x6 | x7);
  b4 = (!x7) & (x8 | x1);
  xh = b1 + b2 + b3 + b4;

  ## condition 2
  n1 = (x1 | x2) + (x3 | x4) + (x5 | x6) + (x7 | x8);
  n2 = (x2 | x3) + (x4 | x5) + (x6 | x7) + (x8 | x1);
  m = min (n1, n2);

  ## condition 3
  G3 = (x2 | x3 | (!x8)) & x1;
  G3 = !G3;

  ## point p is deleted iff all conditions are true
  ret = p & (!((xh == 1) & (m == 2 | m == 3) & G3));

endfunction
