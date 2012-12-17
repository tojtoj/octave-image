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
## @deftypefn {Function File} {} display (@var{SE})
## Display the contents of object SE.
##
## @seealso{strel}
## @end deftypefn

function display (SE)

  % Some elaborations
  P = sum(SE.nhood(:) == 1);
  if (SE.flat)
    flatstr = "Flat";
  else
    flatstr = "Nonflat";
  endif
  if (P != 1)
    plural_p = "s";
  else
    plural_p = "";
  endif

  % Output
  fprintf ("%s = \n", inputname(1));
  fprintf ("  %s strel object with %d neighbor%s\n\n", flatstr, P, plural_p);
  fprintf ("  Neighborhood:\n");
  display (SE.nhood);
  if (!SE.flat)
    fprintf ("  Height:\n");
    display (SE.height);
  endif

endfunction