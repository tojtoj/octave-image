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
## @deftypefn  {Function File} {@var{T} =} maketform (@var{ttype}, @var{tmat})
## @deftypefnx {Function File} {@var{T} =} maketform ("custom", @var{ndims_in}, @var{ndims_out}, @var{forward_fcn}, @var{inverse_fcn}, @var{tdata})
## Returns a transform structure containing fields @var{ndims_in},
## @var{ndims_out}, @var{forward_fcn}, @var{inverse_fcn} and @var{tdata}. The content
## of each field depends on the requested transform type @var{ttype}:
## @table @asis
## @item "projective"
## A ndims_in = N -> ndims_out = N projective transformation structure
## is returned.
## The second input argument @var{tmat} must be a (N+1)-by-(N+1)
## transformation matrix. The
## (N+1)th column must contain projection coefficients. As an example a two
## dimentionnal transform from [x y] coordinates to [u v] coordinates
## is represented by a transformation matrix defined so that:
## @example
## [xx yy zz] = [u v 1] * [a d g;
##                         b e h;
##                         c f i]
## [x y] =  [xx./zz yy./zz];
## @end example
## @item "affine"
## Affine is a subset of projective transform (see above). A ndims_in = N ->
## ndims_out = N  affine transformation structure is returned.
## The second input argument @var{tmat} must be a (N+1)-by-(N+1) or
## (N+1)-by-(N) transformation matrix. If present, the (N+1)th column  must
## contain [zeros(N,1); 1] so that projection is suppressed.
## @item "custom"
## For user defined transforms every field of the transform structure
## must be supplied. The prototype of the transform functions,
## @var{forward_fcn} and @var{inverse_fcn}, should be X' =
## transform_fcn (X, T). X and X' are respectively p-by-ndims_in and
## p-by-ndims_out arrays for forward_fcn and reversed for inverse_fcn.
## The argument T is the transformation structure which will contain
## the user supplied transformation matrix @var{tdata}. 
## @end table
## @seealso{tformfwd, tforminv, cp2tform}
## @end deftypefn

## Author: Pantxo Diribarne <pantxo@dibona>
## Created: 2012-09-05

function T = maketform (ttype, varargin)

  if (nargin < 2 || ! any (strcmp (ttype, {"affine", "projective", "custom"})))
    print_usage ();
  endif
  if (numel (varargin) == 1)
    tmat = varargin {1};
    ndin = rows (tmat) - 1;
    ndout = columns (tmat) - 1;
    if (ndin < 2);
      error ("maketform: expect at least 3-by-2 transform matrix")
    elseif ((ndin-ndout) > 1 || (ndout > ndin))
      print_usage ();
    endif

    switch ttype
      case "affine"
        if ((ndin - ndout) == 1)
          tmat = [tmat [zeros(ndin, 1); 1]];
          ndout += 1;
        elseif (!all (tmat(:,end) == [zeros(ndin, 1); 1]))
          error ("maketform: \"affine\" expect [zeros(N,1); 1] as (N+1)th column");
        endif
        forward_fcn = @fwd_affine; 
        inverse_fcn = @inv_affine;
      case "projective"
        if ((ndin - ndout) == 1)
          print_usage ();
        endif
        forward_fcn = @fwd_projective;
        inverse_fcn = @inv_projective;
    endswitch
    T.ndims_in = ndin;
    T.ndims_out = ndout;
    T.forward_fcn = forward_fcn;
    T.inverse_fcn = inverse_fcn;
    T.tdata.T = inv (tmat);
    T.tdata.Tinv = tmat;
  elseif (numel (varargin) == 5 && strcmp (ttype, "custom"))
    if (isscalar (varargin{1}) && isscalar (varargin{2})
        && varargin{1} > 0 && varargin{2} > 0)
      T.ndims_in = varargin{1};
      T.ndims_out = varargin{2};
    else
      error ("maketform: expect positive scalars as ndims.")
    endif
    if (is_function_handle (varargin{3}) || isempty (varargin{3}))
      T.forward_fcn = varargin{3};
    else
      error ("maketform: expect function handle as forward_fcn.")
    endif
    if (is_function_handle (varargin{4}) || isempty (varargin{4}))
      T.inverse_fcn = varargin{4};
    else
      error ("maketform: expect function handle as inverse_fcn.")
    endif
    
    T.tdata = varargin{5};
  else
    print_usage ();
  endif
endfunction

function X = fwd_affine (U, T)
  U = [U, ones(rows(U), 1)];
  X = U * T.tdata.T(:,1:end-1);
endfunction

function U = inv_affine (X, T)
  X = [X, ones(rows(X), 1)];
  U = X * T.tdata.Tinv(:,1:end-1);
endfunction

function X = fwd_projective (U, T)
  U = [U, ones(rows(U), 1)];
  XX = U * T.tdata.T;
  X = [XX(:,1)./XX(:,3) XX(:,2)./XX(:,3)];
endfunction

function U = inv_projective (X, T)
  X = [X, ones(rows(X), 1)];
  UU = X * T.tdata.Tinv;
  U = [UU(:,1)./UU(:,3) UU(:,2)./UU(:,3)];
endfunction
