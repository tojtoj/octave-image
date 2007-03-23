## Copyright (C) 2004 Josep Mones i Teixidor
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
## @deftypefn {Function File} {@var{siz} = } bestblk ([@var{m} @var{n}], @var{k})
## @deftypefnx {Function File} {[@var{mb} @var{nb}] = } bestblk ([@var{m} @var{n}], @var{k})
## Calculates the best size of block for block processing.
##
## @code{siz=bestblk([m,n],k)} calculates the optimal block size for block
## processing for a @var{m}-by-@var{n} image. @var{k} is the maximum
## side dimension of the block. Its default value is 100. @var{siz} is a
## row vector which contains row and column dimensions for the block.
##
## @code{[mb,nb]=bestblk([m,n],k)} behaves as described above but
## returns block dimensions to @var{mb} and @var{nb}.
##
## @strong{Algorithm:}
##
## For each dimension (@var{m} and @var{n}), it follows this algorithm:
##
## 1.- If dimension is less or equal than @var{k}, it returns the
## dimension value.
##
## 2.- If not then returns the value between
## @code{round(min(dimension/10,k/2))} which minimizes padding.
##
##
## @seealso{blkproc}
## @end deftypefn


## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function [varargout] = bestblk(ims,k)
  if(nargin<1 || nargin>2)
    usage("siz=bestblk([m,n],k), [mb,nb]=bestblk([m,n],k)");
  endif
  if(nargout>2)
    usage("siz=bestblk([m,n],k), [mb,nb]=bestblk([m,n],k)");
  endif
  if(nargin<2)
    k=100;
  endif
  if(!isvector(ims))
    error("bestblk: first parameter is not a vector.");
  endif
  ims=ims(:);
  if(length(ims)!=2)
    error("bestblk: length of first parameter is not 2.");
  endif

  mb=mi=ims(1);
  p=mi;
  if(mi>k)
    for i=round(min(mi/10,k/2)):k
      pt=rem(mi,i);
      if(pt<p)
	p=pt;
	mb=i;
      endif
    endfor
  endif

  nb=ni=ims(2);
  p=ni;
  if(ni>k)
    for i=round(min(ni/10,k/2)):k
      pt=rem(ni,i);
      if(pt<p)
	p=pt;
	nb=i;
      endif
    endfor
  endif

  if(nargout<=1)
    varargout{1}=[mb;nb];
  else
    varargout{1}=mb;
    varargout{2}=nb;
  endif

endfunction

%!demo
%! siz=bestblk([200;10],50)
%! # Best block is [20,10]

%!assert(bestblk([300;100],150),[30;100]);
%!assert(bestblk([256,128],17),[16;16]);

% $Log$
% Revision 1.3  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.2  2007/01/04 23:44:22  hauberg
% Minor changes in help text
%
% Revision 1.1  2006/08/20 12:59:31  hauberg
% Changed the structure to match the package system
%
% Revision 1.2  2005/07/03 01:10:19  pkienzle
% Try to correct for missing newline at the end of the file
%
% Revision 1.1  2004/08/15 19:01:05  jmones
% bestblk added: Calculates best block size for block processing
