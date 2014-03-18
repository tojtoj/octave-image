## Copyright (C) 2014 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn  {Function File} {} imcast (@var{img}, @var{type})
## @deftypefnx {Function File} {} imcast (@var{img}, @var{type}, "indexed")
## Convert image to specific data type @var{type}.
##
## This is the same as calling one of the following
##
## @itemize @bullet
## @item im2double
## @item im2int16
## @item im2single
## @item im2uint8
## @item im2uint16
## @end itemize
##
## @seealso{im2uint8, im2double, im2int16, im2single, im2uint16}
## @end deftypefn

function img = imcast (img, itype, varargin)

  if (nargin < 2 || nargin > 3)
    print_usage ();
  elseif (nargin == 3 && ! strcmpi (varargin{1}, "indexed"))
    error ("imcast: third argument must be the string \"indexed\"");
  endif

  ## We could confirm that the image really is an indexed image in
  ## case the user says so, but the functions im2xxx already do it.

  switch itype
    case "double",  img = im2double (img, varargin{:});
    case "uint8",   img = im2uint8  (img, varargin{:});
    case "uint16",  img = im2uint16 (img, varargin{:});
    case "single",  img = im2single (img, varargin{:});
    case "int16",   img = im2int16  (img, varargin{:});
    otherwise
      error ("imcast: unsupported TYPE \"%s\"", itype);
  endswitch

endfunction

%!test
%! im = randi ([0 255], 40, "uint8");
%! assert (imcast (im, "uint8"), im2uint8 (im))
%! assert (imcast (im, "uint16"), im2uint16 (im))
%! assert (imcast (im, "single"), im2single (im))
%! assert (imcast (im, "uint8", "indexed"), im2uint8 (im, "indexed"))
%! assert (imcast (im, "uint16", "indexed"), im2uint16 (im, "indexed"))
%! assert (imcast (im, "single", "indexed"), im2single (im, "indexed"))

%!test
%! im = randi ([1 256], 40, "double");
%! assert (imcast (im, "uint8"), im2uint8 (im))
%! assert (imcast (im, "uint8", "indexed"), im2uint8 (im, "indexed"))
%! assert (imcast (im, "single", "indexed"), im2single (im, "indexed"))

%!test
%! im = randi ([0 65535], 40, "uint16");
%! assert (imcast (im, "uint8"), im2uint8 (im))
%! assert (imcast (im, "single"), im2single (im))
%! assert (imcast (im, "uint8", "indexed"), im2uint8 (im, "indexed"))
%! assert (imcast (im, "single", "indexed"), im2single (im, "indexed"))

%!test
%! im = randi ([1 255], 40, "double");
%! assert (imcast (im, "uint8", "indexed"), im2uint8 (im, "indexed"))
%! assert (imcast (im, "single", "indexed"), im2single (im, "indexed"))

%!test
%! im = rand (40);
%! assert (imcast (im, "uint8"), im2uint8 (im))

%!error <unsupported TYPE> imcast (randi (255, 40, "uint8"), "uint32")
%!error <unsupported TYPE> imcast (randi (255, 40, "uint8"), "not a class")

