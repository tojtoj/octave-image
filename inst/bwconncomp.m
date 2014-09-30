## Copyright (C) 2010 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
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
## @deftypefn  {Function File} {@var{cc} =} bwconncomp (@var{bw})
## @deftypefnx {Function File} {@var{cc} =} bwconncomp (@var{bw}, @var{conn})
## Find connected objects.
##
## Elements from the matrix @var{bw}, belong to an object if they have a
## non-zero value.  The output @var{cc} is a structure with information about
## each object;
##
## @table @asis
## @item @qcode{"Connectivity"}
## The connectivity used in the boundary tracing. This may be different from
## the input argument, e.g., if @var{conn} is defined as a matrix of 1s and
## size 3x3, the @qcode{"Connectivity"} value will still be 8.
##
## @item @qcode{"ImageSize"}
## The size of the matrix @var{bw}.
##
## @item @qcode{"NumObjects"}
## The number of objects in the image @var{bw}.
##
## @item @qcode{"PixelIdxList"}
## A cell array with linear indices for each element of each object in @var{bw}
## A cell array containing where each element corresponds to an object in @var{BW}.
## Each element is represented as a vector of linear indices of the boundary of
## the given object.
##
## @end table
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
##
## @seealso{bwlabel, bwlabeln, bwboundaries, ind2sub, regionprops}
## @end deftypefn

function CC = bwconncomp (bw, N)

  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif (! ismatrix (bw) || ! (isnumeric (bw) || islogical (bw)))
    error ("bwconncomp: BW must be an a numeric matrix");
  endif
  if (nargin < 2)
    ## Defining default connectivity here because it's dependent
    ## on the first argument
    N = conndef (ndims (bw), "maximal");
  endif
  [conn, N] = make_conn ("bwconncomp", 2, ndims (bw), N);

  [bw, n_obj] = bwlabeln (logical (bw), conn);
  ## We should probably implement this as the first part of bwlabeln
  ## as getting the indices is the first part of its code. Here we are
  ## just reverting the work already done.
  P = arrayfun (@(x) find (bw == x), 1:n_obj, "UniformOutput", false);

  ## Return result
  CC = struct ("Connectivity",  N,
               "ImageSize",     size (bw),
               "NumObjects",    n_obj,
               "PixelIdxList",  {P});
endfunction

%!test
%! a = rand (10) > 0.5;
%! cc = bwconncomp (a, 4);
%! assert (cc.Connectivity, 4)
%! assert (cc.ImageSize, [10 10])
%!
%! b = false (10);
%! for i = 1:numel (cc.PixelIdxList)
%!   b(cc.PixelIdxList{i}) = true;
%! endfor
%! assert (a, b)

%!test
%! a = rand (10, 13) > 0.5;
%! cc = bwconncomp (a, 4);
%! assert (cc.ImageSize, [10 13])
%!
%! b = false (10, 13);
%! for i = 1:numel (cc.PixelIdxList)
%!   b(cc.PixelIdxList{i}) = true;
%! endfor
%! assert (a, b)

%!test
%! a = rand (15) > 0.5;
%! conn_8 = bwconncomp (a, 8);
%! assert (conn_8, bwconncomp (a))
%! assert (conn_8, bwconncomp (a, ones (3)))
%! assert (conn_8.Connectivity, 8)
%! assert (bwconncomp (a, ones (3)).Connectivity, 8)
%! assert (bwconncomp (a, [0 1 0; 1 1 1; 0 1 0]).Connectivity, 4)

## test that PixelIdxList is a row vector
%!test
%! a = rand (40, 40) > 0.2;
%! cc = bwconncomp (a, 4);
%! assert (rows (cc.PixelIdxList), 1)
%! assert (columns (cc.PixelIdxList) > 1)
