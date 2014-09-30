## Copyright (C) 2013 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## Private function to create a connectivity array
##
## Use the following Texinfo on the documentation of functions
## that make use of it (adjust the default)
##
## Element connectivity @var{conn}, to define the size of objects, can be
## specified with a numeric scalar (number of elements in the neighborhood):
##
## @table @samp
## @item 4 or 8
## for 2 dimensional matrices;
## @item 6, 18 or 26
## for 3 dimensional matrices;
## @end table
##
## or with a binary matrix representing a connectivity array.  Defaults to
## @code{conndef (ndims (@var{bw}), "maximal")} which is equivalent to
## @var{conn} of 8 and 26 for 2 and 3 dimensional matrices respectively.

function [conn, N] = make_conn (func, arg_pos, n_dims, conn)

  persistent conn_4  = logical ([0 1 0; 1 1 1; 0 1 0]);
  persistent conn_8  = true (3);
  persistent conn_6  = get_conn_6 ();
  persistent conn_18 = get_conn_18 ();
  persistent conn_26 = true (3, 3, 3);

  iptcheckconn (conn, func, "CONN", arg_pos);
  if (isscalar (conn))
    N = conn;
    if (n_dims == 2)
      if     (conn == 4), conn = conn_4;
      elseif (conn == 8), conn = conn_8;
      else
        error ("%s: CONN must have a value of 4 or 8 for 2 dimensional matrices",
               func);
      endif

    elseif (n_dims == 3)
      if     (conn == 6),  conn = conn_6;
      elseif (conn == 18), conn = conn_18;
      elseif (conn == 26), conn = conn_26;
      else
        error (["%s: CONN must have a value of 6, 18, or 26 for 3 " ...
                "dimensional matrices"], func);
      endif
    else
      error (["%s: CONN must be defined as a binary matrix for matrices " ...
              "with more than 3 dimensions"], func);
    endif
  elseif (nargout > 1)
    if     (isequal (conn, conn_4)),  N = 4;
    elseif (isequal (conn, conn_8)),  N = 8;
    elseif (isequal (conn, conn_6)),  N = 6;
    elseif (isequal (conn, conn_18)), N = 18;
    elseif (isequal (conn, conn_26)), N = 26;
    else,                             N = conn;
    endif
  endif
endfunction

function conn = get_conn_6 ()
  conn = false (3, 3, 3);
  conn(:,2,2) = true;
  conn(2,:,2) = true;
  conn(2,2,:) = true;
endfunction

function conn = get_conn_18 ()
  conn = false (3, 3, 3);
  conn(2,:,:) = true;
  conn(:,2,:) = true;
  conn(:,:,2) = true;
endfunction
