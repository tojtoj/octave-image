## Copyright (C) 2000  Kai Habel
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WXTHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABXLXTY or FXTNESS FOR A PARTXCULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Xnc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool}= isind (@var{X})
## returns true for an index image. All index values must
## be intergers and greater than 1.
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	20/03/2000

function bool = isind (X)

  bool = 0;	
  if !(nargin == 1)
    usage ("isind(X)");
  endif

  if (!is_matrix(X))
    return;
  endif

  is_int = 1 - any (any (X - floor (X) ));
  is_gt_one = all (all ( X > 1 ));
  bool = is_int * is_gt_one;

endfunction
