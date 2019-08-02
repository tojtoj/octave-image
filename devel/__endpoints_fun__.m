## Copyright (C) 2019 Avinoam Kalma <a.kalma@gmail.com>
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
## @deftypefn {Function File} {@var{r} = } __endpoints_fun__ (@var{X})
## Calculates the results of the first iteration for
## bwmorph (BW, "endpoints", 1) calculation
##
## @var{X} contains a 3-by-3 matrix to be evaluated.
##
## @var{r} =  __endpoints_fun__ (@var{X}) evaluates a 3-by-3 BW matrix
## neighbourhood. The function returns 0 if the central pixel is deleted
## after the first iteration for "endpoints" operators and 1 otherwise.
##
## If the  middle pixel is 1, and its neighbourhood contaians
## only 0-7 consecutive pixels, the pixel remains.
##
## This function is needed by bwmorph, although it just contains the
## result matrix as a literal inside the code.
##
## This function probably never be needed by itself, but it's useful to
## know how bwmorph was coded.
##
## @end deftypefn
## @seealso{bwmorph}

function ret = __endpoints_fun__ (A)

  ret = 0;
  if (A(2,2) == 0)      # middle pixel is zero
    return;
  end

  nb = nnz(A)-1;        # number of neighbours
  if (nb == 8)
    return;
  end

  ret = 1;
  if (nb == 0 || nb == 1 || nb == 7)
    ##  only one neighbour, or 7 neighbours
    return;
  end

  ## building chain code
  ##   +---+---+---+
  ##   | 3 | 2 | 1 |
  ##   +---+---+---+
  ##   | 4 |-1 | 0 |
  ##   +---+---+---+
  ##   | 5 | 6 | 7 |
  ##   +---+---+---+

  if (nb >= 5)
    A = !A;
    nb = 8-nb;
  end

  CC = zeros(4,1);
  cnt = 0;
  if (A(2,3) == 1)
    cnt = 1;
  end
  if (A(1,3) == 1);
    cnt = cnt+1;
    CC(cnt) = 1;
  end
  if (A(1,2) == 1);
    cnt = cnt+1;
    CC(cnt) = 2;
  end
  if (A(1,1) == 1);
    cnt = cnt+1;
    CC(cnt) = 3;
  end
  if (A(2,1) == 1);
    cnt = cnt+1;
    CC(cnt) = 4;
  end
  if (A(3,1) == 1);
    cnt = cnt+1;
    CC(cnt) = 5;
  end
  if (A(3,2) == 1);
    cnt = cnt+1;
    CC(cnt) = 6;
  end
  if (A(3,3) == 1);
    cnt = cnt+1;
    CC(cnt) = 7;
  end

  DD = diff(CC);

  if (nb == 2)
    ret = (DD(1) == 1 || DD(1) == 7);
    return;
  end

  if (nb == 3)
    ret = ((DD(1) == 1 && DD(2) == 1) || ...
    (DD(1) == 1 && DD(2) == 6) || ...
    (DD(1) == 6 && DD(2) == 1));
    return;
  end

  if (nb == 4)
    ret = ((DD(1) == 1 && DD(2) == 1 && DD(3) == 1) || ...
    (DD(1) == 1 && DD(2) == 1 && DD(3) == 5) || ...
    (DD(1) == 1 && DD(2) == 5 && DD(3) == 1) || ...
    (DD(1) == 5 && DD(2) == 1  && DD(3) == 1));
    return;
  end

endfunction
