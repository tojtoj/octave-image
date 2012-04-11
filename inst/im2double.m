## Copyright (C) 2007 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} @var{im2} = im2double(@var{im1})
## @deftypefnx {Function File} @var{im2} = im2double(@var{im1}, "indexed")
## Convert input image @var{im1} to double precision.
##
## The following images type are supported: double, single, uint8, uint16, int16,
## binary (logical), indexed. If @var{im1} is an indexed images, the second
## argument must be a string with the value `indexed'.
##
## Processing will depend on the class of the input image @var{im1}:
## @itemize @bullet
## @item uint8, uint16, int16 - output will be rescaled for the interval [0 1]
## with the limits of the class;
## @item double - output will be the same as input;
## @item single - output will have the same values as input but the class will
## double;
## @item indexed, logical - converted to double class.
## @end itemize
##
## @seealso{im2bw, im2uint16, im2uint8}
## @end deftypefn

function im2 = im2double (im1, ind = false)
  ## Input checking
  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (nargin == 2 && (!ischar (ind) || !strcmpi (ind, "indexed")))
    error ("second argument must be a string with the word `indexed'");
  endif

  if (ind && !isind (im1))
    error ("input should have been an indexed image but it is not");
  endif

  ## Take action depending on the class of the data
  in_class = class (im1);
  switch in_class
    case "double"
      im2 = im1;
    case {"logical", "single"}
      im2 = double (im1);
    case {"uint8", "uint16"}
      if (ind)
        im2 = double (im1) + 1;
      elseif (isind (im1))
        im2 = double (im1) / double (intmax (in_class));
      endif
    case "int16"
      im2 = (double (im1) + double (intmax (in_class)) + 1) / double (intmax ("uint16"));
    otherwise
      error ("unsupported image class");
  endswitch
endfunction
