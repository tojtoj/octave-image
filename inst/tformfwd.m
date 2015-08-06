## Copyright (C) 2012 Pantxo Diribarne
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{UV}] =} tformfwd (@var{T}, @var{XY})
## @deftypefnx {Function File} {[@var{U}, @var{V}] =} tformfwd (@var{T}, @var{X}, @var{Y})
## 
## Given two dimensional coordinates from one space, returns two 
## dimensional coordinates in the other space, as defined in 
## the transform structure @var{T}. Input and output coordinates 
## may be given either as a n-by-2 arrays, or as two n-by-1 vectors.
## @seealso{maketform, cp2tform, tforminv}
## @end deftypefn

## Author: Pantxo Diribarne <pantxo@dibona>

function varargout = tformfwd (T, varargin)

  if (nargin > 3 || nargin < 2)
    print_usage ();
  elseif (! istform (T))
    error ("tformfwd: expect a transform structure as first argument")
  elseif (nargin == 2)
    XX = varargin{1};
    if (columns (XX) != 2)
      error ("tformfwd: expect n-by-2 array as second argument")
    endif
  else
    if (!isvector (varargin{1}) || !isvector (varargin{2}))
      error ("tformfwd: expect vectors as coordinates")
    elseif (!all (size (varargin{1}) == size (varargin{2})))
      error ("tformfwd: expect two vectors the same size")
    elseif (columns (varargin{1}) != 1)
      error ("tformfwd: expect column vectors")
    endif
    XX = [varargin{1} varargin{2}];
  endif
  UU = T.forward_fcn(XX, T);
  if (nargin == 3)
    varargout{1} = UU(:,1);
    varargout{2} = UU(:,2);
  else
    varargout{1} = UU;
  endif
endfunction
