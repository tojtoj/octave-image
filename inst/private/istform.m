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
## @deftypefnx {Function File} {[@var{U} @var{V}] =} tformfwd (@var{T}, @var{X},@var{Y})
## 
## Given to dimensionnal coordinates from one space, returns two 
## dimensionnal coordinates in the other space, as defined in 
## the transform structure @var{T}. Input and output coordinates 
## may be gigen either as a n-by-2 arrays, or as two n-by-1 vectors.
## @seealso{maketform, cp2tform, tforminv}
## @end deftypefn

## Author: Pantxo Diribarne <pantxo@dibona>

function out = istform (T)
  out = true;
  if (!isstruct (T))
    out = false;
  else
    required = {"ndims_in";"ndims_out"; ...
                "forward_fcn"; "inverse_fcn"; ...
                "tdata"};
  
    fields = fieldnames (T);
    tst = cellfun (@(x) any (strcmp (fields, x)), required);
    if (! all (tst))
      out = false
    endif
  endif 
endfunction
