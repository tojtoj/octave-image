## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
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
## @deftypefn {Function File} {} conndef (@var{num_dims}, @var{type})
## Create connectivity array.
##
## Creates a binary matrix of @var{num_dims} dimensions for morphological
## operations, where elements with a value of 1 are considered connected
## to the center element (a connectivity array).
##
## There are two possible @var{type}s of connectivity array, defined with
## the strings:
## @table @asis
## @item @qcode{"minimal"}
## Neighbours touch the central element on a (@var{num_dims}-1)-dimensional
## surface.
##
## @item @qcode{"maximal"}
## Neighbours touch the central element in any way. Equivalent to
## @code{ones (repmat (3, 1, @var{num_dims}))}.
##
## @end table
##
## @seealso{iptcheckconn, strel}
## @end deftypefn

function conn = conndef (num_dims, conntype)

  if (nargin != 2)
    print_usage ();
  elseif (! isnumeric (num_dims) || ! isscalar (num_dims) || num_dims <= 0 ||
          fix (num_dims) != num_dims)
    error ("conndef: NUM_DIMS must be a positive integer");
  elseif (! ischar (conntype))
    error ("conndef: CONNTYPE must be a string with type of connectivity")
  endif

  if (strcmpi (conntype, "minimal"))
    if (num_dims == 1)
      ## This case does not exist in Matlab
      conn = [1; 1; 1];
    elseif (num_dims == 2)
      ## The general case with the for loop below would also work for
      ## 2D but it's such a simple case we have it like this, no need
      ## to make it hard to read.
      conn = [0 1 0
              1 1 1
              0 1 0];
    else
      conn   = zeros (repmat (3, 1, num_dims));
      template_idx = repmat ({2}, [num_dims 1]);
      for dim = 1:num_dims
        idx = template_idx;
        idx(dim) = ":";
        conn(idx{:}) = 1;
      endfor
    endif

  elseif (strcmpi (conntype, "maximal"))
    if (num_dims == 1)
      ## This case does not exist in Matlab
      conn = [1; 1; 1];
    else
      conn = ones (repmat (3, 1, num_dims));
    endif

  else
    error ("conndef: invalid type of connectivity '%s'.", conntype);
  endif

endfunction

%!demo
%! ## Create a 2-D minimal connectivity array
%! conndef (2, "minimal")

%!assert (conndef (1, "minimal"), [1; 1; 1]);
%!assert (conndef (2, "minimal"), [0 1 0; 1 1 1; 0 1 0]);

%!test
%! C = zeros (3, 3, 3);
%! C(:,2,2) = 1;
%! C(2,:,2) = 1;
%! C(2,2,:) = 1;
%! assert (conndef (3, "minimal"), C);

%!test
%! C = zeros (3, 3, 3, 3);
%! C(:,:,2,1) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! C(:,:,1,2) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! C(:,:,2,2) = [0   1   0
%!               1   1   1
%!               0   1   0];
%! C(:,:,3,2) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! C(:,:,2,3) = [0   0   0
%!               0   1   0
%!               0   0   0];
%! assert (conndef (4, "minimal"), C);

%!assert (conndef (1, "maximal"), ones (3, 1));
%!assert (conndef (2, "maximal"), ones (3, 3));
%!assert (conndef (3, "maximal"), ones (3, 3, 3));
%!assert (conndef (4, "maximal"), ones (3, 3, 3, 3));

%!error conndef (-2, "minimal")
%!error conndef (char (2), "minimal")
%!error <type of connectivity> conndef (3, "invalid")
%!error conndef ("minimal", 3)

