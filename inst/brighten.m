## Copyright (C) 1999,2000  Kai Habel
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{map_out}= brighten (@var{map},@var{beta})
## @deftypefnx {Function File} @var{map_out}= brighten (@var{beta})
## darkens or brightens the given colormap.
## If the @var{map} argument is omitted, the function is applied to the
## current colormap.
## Should the resulting colormap @var{map_out} not be assigned, it will be
## written to the current colormap.
## The argument @var{beta} should be a scalar between -1 and 1,
## where a negative value darkens and a positive value brightens
## the colormap.
##
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	05. March 2000

function [Rmap] = brighten (m, beta)

  if (nargin == 1)
    beta = m;
    m = colormap;

  elseif (nargin == 2)
    if ( (!is_matrix (m)) || (size (m, 2) != 3) )
      error ("brighten(map,beta) map must be a matrix of size nx3.");
    endif

  else
    usage ("brighten(...) number of arguments must be 1 or 2.");
  endif

  if ( (!is_scalar (beta)) || (beta <= -1) || (beta >= 1) )
    error ("brighten(...,beta) beta must be a scalar in the range (-1,1).");
  endif

  if (beta > 0)
    gamma = 1 - beta;
  else
    gamma = 1 / (1 + beta);
  endif

  if (nargout == 0)
    colormap (m .^ gamma);
  else
    Rmap = m .^ gamma;
  endif

endfunction
