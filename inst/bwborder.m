## Copyright (C) 2000 Etienne Grossmann <etienne@egdn.net>
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
## @deftypefn {Function File} {@var{b} = } bwborder (@var{im})
## Finds the borders of foreground objects in a binary image.
##
## @code{bwborder} has been deprecated in favor of
## @code{bwmorph (@var{im},"remove")}.  This function will be removed from
## future versions of the `image' package.
##
## @var{b} is the borders in the 0-1 matrix @var{im}. 4-neighborhood is considered.
## 
## A pixel is on the border if it is set in @var{im}, and it has at least one
## neighbor that is not set.
## @end deftypefn

function b = bwborder(im)

  ## Deprecate bwborder because bwmorph does the same job, works for any
  ## number of dimensions, performs faster, and exist in Matlab.
  persistent warned = false;
  if (! warned)
    warned = true;
    warning ("Octave:deprecated-function",
             ["`bwborder' has been deprecated in favor of " ...
              "`bwmorph (IM,\"remove\")'.  This function will be removed " ...
              "from future versions of the `image' package"]);
  endif

[R,C]=size(im);

b = im & ...
    !([im(2:R,:) ;  zeros(1,C) ] & ...
      [zeros(1,C); im(1:R-1,:) ] & ...
      [im(:,2:C) ,  zeros(R,1) ] & ...
      [zeros(R,1),  im(:,1:C-1)] ) ;

endfunction
