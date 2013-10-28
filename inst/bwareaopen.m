## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
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

## -*- texinfo -*-
## @deftypefn  {Function File} {} bwareaopen (@var{bw}, @var{lim})
## @deftypefnx {Function File} {} bwareaopen (@var{bw}, @var{lim}, @var{conn})
## Perform area opening.
##
## Remove objects with less than @var{lim} elements from a binary image
## @var{bw}.
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
## @seealso{bwconncomp, conndef, bwboundaries}
## @end deftypefn

function bw = bwareaopen (bw, lim, conn)

  if (nargin < 2 || nargin > 3)
    print_usage ();
  elseif (! ismatrix (bw) || ! (isnumeric (bw) || islogical (bw)))
    error ("bwareaopen: BW must be an a numeric matrix");
  elseif (! isnumeric (lim) || ! isscalar (lim) || lim < 0 || fix (lim) != lim)
    error ("bwareaopen: LIM must be a non-negative scalar integer")
  endif

  if (nargin < 3)
    ## Defining default connectivity here because it's dependent
    ## on the first argument
    conn = conndef (ndims (bw), "maximal");
  else
    conn = make_conn ("bwareaopen", 3, ndims (bw), conn);
  endif

  ## Output is always of class logical
  bw = logical (bw);

  ## We only have work to do when lim > 1
  if (lim > 1)
    idx_list = bwconncomp (bw, conn).PixelIdxList;
    ind = cell2mat (idx_list (cellfun ("numel", idx_list) < lim)');
    bw(ind) = false;
  endif

endfunction

%!test
%! in = [ 0   0   1   0   0   1   0   1   0   0
%!        0   0   1   0   0   0   0   0   1   1
%!        1   0   0   0   0   1   1   0   0   0
%!        1   0   0   0   1   0   0   0   0   0
%!        1   1   1   1   0   0   0   0   0   1
%!        0   1   0   1   1   0   0   1   0   0
%!        1   0   0   0   1   0   0   0   0   0
%!        0   0   0   1   1   0   0   1   0   0
%!        0   1   0   1   1   0   0   1   1   0
%!        0   1   0   1   1   1   0   0   1   0];
%! assert (bwareaopen (in, 1, 4), logical (in))
%!
%! out = [0   0   0   0   0   0   0   0   0   0
%!        0   0   0   0   0   0   0   0   0   0
%!        1   0   0   0   0   0   0   0   0   0
%!        1   0   0   0   0   0   0   0   0   0
%!        1   1   1   1   0   0   0   0   0   0
%!        0   1   0   1   1   0   0   0   0   0
%!        0   0   0   0   1   0   0   0   0   0
%!        0   0   0   1   1   0   0   0   0   0
%!        0   0   0   1   1   0   0   0   0   0
%!        0   0   0   1   1   1   0   0   0   0];
%! assert (bwareaopen (logical (in), 10, 4), logical (out))
%! assert (bwareaopen (in, 10, 4), logical (out))
%! assert (bwareaopen (in, 10, [0 1 0; 1 1 1; 0 1 0]), logical (out))
%!
%! out = [0   0   0   0   0   0   0   0   0   0
%!        0   0   0   0   0   0   0   0   0   0
%!        1   0   0   0   0   1   1   0   0   0
%!        1   0   0   0   1   0   0   0   0   0
%!        1   1   1   1   0   0   0   0   0   0
%!        0   1   0   1   1   0   0   0   0   0
%!        1   0   0   0   1   0   0   0   0   0
%!        0   0   0   1   1   0   0   0   0   0
%!        0   0   0   1   1   0   0   0   0   0
%!        0   0   0   1   1   1   0   0   0   0];
%! assert (bwareaopen (in, 10, 8), logical (out))
%! assert (bwareaopen (in, 10, ones (3)), logical (out))
%! assert (bwareaopen (in, 10), logical (out))
%!
%! out = [0   0   0   0   0   0   0   0   0   0
%!        0   0   0   0   0   0   0   0   0   0
%!        1   0   0   0   0   0   0   0   0   0
%!        1   0   0   0   0   0   0   0   0   0
%!        1   1   1   1   0   0   0   0   0   0
%!        0   1   0   1   1   0   0   0   0   0
%!        0   0   0   0   1   0   0   0   0   0
%!        0   0   0   1   1   0   0   1   0   0
%!        0   0   0   1   1   0   0   1   1   0
%!        0   0   0   1   1   1   0   0   1   0];
%! assert (bwareaopen (in, 4, [1 1 0; 1 1 1; 0 1 1]), logical (out))

%!error bwareaopen ("not an image", 78, 8)
%!error bwareaopen (rand (10) > 0.5, 10, 100)
%!error bwareaopen (rand (10) > 0.5, 10, "maximal")
%!error bwareaopen (rand (10) > 0.5, 10, [1 1 1; 0 1 1; 0 1 0])
