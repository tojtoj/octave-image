## Copyright (C) 2010 Soren Hauberg
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

function [B, L, num_labels] = bwboundaries (bw, N = 4, options = "holes")
  ## Check input
  if (nargin < 1)
    error ("bwboundaries: not enough input arguments");
  endif
  if (!ismatrix (bw) || ndims (bw) != 2)
    error ("bwboundaries: first input argument must be a NxM matrix");
  endif
  if (!isscalar (N) || !any (N == [4])) #, 8]))
    error ("bwboundaries: second input argument must be 4");
  endif
  if (!ischar (options) || !any (strcmpi (options, {"holes", "noholes"})))
    error ("bwboundaries: third input must be either \"holes\" or \"noholes\"");
  endif
  
  
  ## Warn if the user request more output arguments than our implementation supports
  if (nargout > 3)
%    warning ("%s %s %s", ...
%             "bwboundaries: adjacency matrix output is currently not supported." ...
%             "Please contact the Octave-Forge community if you want to contribute" ...
%s             "an implementation of this");
  endif
  
  ## Make sure 'bw' is logical
  bw = logical (bw);
  
  ## Found connected components in 'bw', and treat each of them seperatly
  [L, num_labels] = bwlabel (bw, N);
  B = cell (num_labels, 1);
  for n = 1:num_labels
    segment = (L == n);
    [R, C] = find (segment);
    if (numel (R) > 1)
      ## XXX: support 8-neighbors
      #B {n} = __imboundary__ (segment, N, R (1), C (1));
      B {n} = __imboundary__ (segment, 4, R (1), C (1));
    else
      B {n} = [R, C];
    endif
  endfor
  
  ## If requested, compute internal boundaries as well
  if (strcmpi (options, "holes"))
    filled = bwfill (bw, "holes", N);
    holes = (filled & !bw);
    [internal, in_label, lin] = bwboundaries (holes, N, "noholes");
    B (end+1:end+lin, 1) = internal;
    
    in_label (in_label != 0) += num_labels;
    L += in_label;
  endif
endfunction
