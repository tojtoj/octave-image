## Copyright (C) 2008 Soren Hauberg
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

## -*- texinfo -*-
## @deftypefn {Function File} cordflt2(@var{A}, @var{nth}, @var{domain}, @var{S})
## Implementation of two-dimensional ordered filtering. This function has been
## deprecated and should NOT be used. Instead use @code{ordfilt2}.
## @seealso{ordfilt2}
## @end deftypefn

function varargout = cordflt2(varargin)
  warning(["cordflt2: this function is deprecated and will be removed in upcoming "
           "releases. Use 'ordfilt2' instead."]);
  [varargout{1:nargout}] = __cordfltn__(varargin{:});
endfunction
