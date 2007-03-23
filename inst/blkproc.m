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
## @deftypefn {Function File} {@var{B} = } blkproc (@var{A}, [@var{m},@var{n}], @var{fun})
## @deftypefnx {Function File} {@var{B} = } blkproc (@var{A}, [@var{m},@var{n}], @var{fun}, ...)
## @deftypefnx {Function File} {@var{B} = } blkproc (@var{A}, [@var{m},@var{n}], [@var{mborder},@var{nborder}], @var{fun}, @var{...})
## @deftypefnx {Function File} {@var{B} = } blkproc (@var{A}, 'indexed', ...)
## Processes image in blocks using user-supplied function.
##
## @code{B=blkproc(A,[m,n],fun)} divides image @var{A} in
## @var{m}-by-@var{n} blocks, and passes them to user-supplied function
## @var{fun}, which result is concatenated to build returning matrix
## @var{B}. If padding is needed to build @var{m}-by-@var{n}, it is added
## at the bottom and right borders of the image.  0 is used as a padding
## value.
##
## @code{B=blkproc(A,[m,n],fun,...)} behaves as described above but
## passes extra parameters to function @var{fun}.
##
## @code{B=blkproc(A,[m,n],[mborder,nborder],fun,...)} behaves as
## described but uses blocks which overlap with neighbour blocks.
## Overlapping dimensions are @var{mborder} vertically and @var{nborder}
## horizontally. This doesn't change the number of blocks in an image
## (which depends only on size(@var{A}) and [@var{m},@var{n}]). Adding a
## border requires extra padding on all edges of the image. 0 is used as
## a padding value.
##
## @code{B=blkproc(A,'indexed',...)} assumes that @var{A} is an indexed
## image, so it pads the image using proper value: 0 for uint8 and
## uint16 images and 1 for double images. Keep in mind that if 'indexed'
## is not specified padding is always done using 0.
##
## @seealso{colfilt,inline,bestblk}
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function B = blkproc(A, varargin)
  if(nargin<3)
    error("blkproc: invalid number of parameters.");
  endif
  
  ## check 'indexed' presence
  indexed=false;
  p=1;
  if(ischar(varargin{1}) && strcmp(varargin{1}, "indexed"))
    indexed=true;
    p+=1;
    if(isa(A,"uint8") || isa(A,"uint16"))
	padval=0;
    else
      padval=1; 
    endif
  else
    padval=0;
  endif

  ## check [m,n]
  if(!isvector(varargin{p}))
    error("blkproc: expected [m,n] but param is not a vector.");
  endif
  if(length(varargin{p})!=2)
    error("blkproc: expected [m,n] but param has wrong length.");
  endif
  sblk=varargin{p}(:);
  p+=1;

  ## check [mborder,nborder]
  if(nargin<p)
    error("blkproc: required parameters haven't been supplied.");
  endif

  if(isvector(varargin{p}) && isnumeric(varargin{p})) 
    if(length(varargin{p})!=2)
      error("blkproc: expected [mborder,nborder] but param has wrong length.");
    endif
    sborder=varargin{p}(:);
    p+=1;
  else
    sborder=[0;0];
  endif

  ## check fun
  ## TODO: add proper checks for this one
  if(nargin<p)
    error("blkproc: required parameters haven't been supplied.");
  endif

  fun=varargin{p};
  if(!isa(fun,"function_handle") &&
     !isa(fun,"inline function") &&
     !ischar(fun))
    error("blkproc: invalid fun parameter.");
  endif
  
  ## remaining params are params to fun
  ## extra params are p+1:nargin-1

  ## First of all we calc needed padding which will be applied on bottom
  ## and right borders
  ## The "-" makes the function output needed elements to fill another
  ## block directly
  sp=mod(-size(A)',sblk);

  if(any(sp))
    A=padarray(A,sp,padval,'post');
  endif

  ## we store A size without border padding to iterate later
  soa=size(A);
  
  ## If we have borders then we need more padding
  if(any(sborder))
    A=padarray(A,sborder,padval);
  endif

  ## calculate end of block
  eblk=sblk+sborder*2-1;

  ## now we can process by blocks
  ## we try to preserve fun return type by concatenating everything
  for i=1:sblk(1):soa(1)
    ## This assures r has the same class as returned by fun
    r=feval(fun,A(i:i+eblk(1),1:1+eblk(2)),varargin{p+1:nargin-1});
    for j=1+sblk(2):sblk(2):soa(2)
      r=horzcat(r,feval(fun,A(i:i+eblk(1),j:j+eblk(2)),varargin{p+1:nargin-1}));
    endfor
    if(i==1) ## this assures B has the same class as A
      B=r;
    else
      B=vertcat(B,r);
    endif
  endfor
endfunction

%!demo
%! blkproc(eye(6),[2,2],inline("any(x(:))","x"))
%! # Returns a 3-by-3 diagonal


%!assert(blkproc(eye(6),[2,2],"sum"),blkproc(eye(6),[2,2],@sum));
%!assert(blkproc(eye(6),[2,2],"sum"),blkproc(eye(6),[2,2],inline("sum(x)","x")));
%!assert(blkproc(eye(6),[1,2],@sum),kron(eye(3),[1;1]));
%!assert(blkproc(eye(6),[2,2],inline("any(x(:))","x")),eye(3)!=0);
%!assert(blkproc(eye(6),[1,2],[1,1],inline("sum(x(:))","x")),[2,1,0;3,2,0;2,3,1;1,3,2;0,2,3;0,1,2]);
%!assert(blkproc(eye(6),'indexed',[1,2],[1,1],inline("sum(x(:))","x")),[8,5,6;6,2,3;5,3,4;4,3,5;3,2,6;6,5,8]);
%!assert(blkproc(eye(6),[2,3],[4,3],inline("sum(x(:))","x")),ones(3,2)*6);

% Some int* and uint* tests
%!assert(blkproc(eye(6),[2,2],inline("int8(sum(x(:)))","x")),eye(3,"int8")*2);

% Padding is 0 even for indexed
%!assert(blkproc(uint8(eye(6)),[1,2],[1,1],inline("sum(x(:))","x")),[2,1,0;3,2,0;2,3,1;1,3,2;0,2,3;0,1,2]);
%!assert(blkproc(uint8(eye(6)),'indexed',[1,2],[1,1],inline("sum(x(:))","x")),[2,1,0;3,2,0;2,3,1;1,3,2;0,2,3;0,1,2]);
%!assert(blkproc(uint16(eye(6)),[1,2],[1,1],inline("sum(x(:))","x")),[2,1,0;3,2,0;2,3,1;1,3,2;0,2,3;0,1,2]);
%!assert(blkproc(uint16(eye(6)),'indexed',[1,2],[1,1],inline("sum(x(:))","x")),[2,1,0;3,2,0;2,3,1;1,3,2;0,2,3;0,1,2]);


%
% $Log$
% Revision 1.5  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.4  2007/01/04 23:44:22  hauberg
% Minor changes in help text
%
% Revision 1.3  2007/01/04 23:37:54  hauberg
% Minor changes in help text
%
% Revision 1.2  2006/10/08 21:41:04  adb014
% check isnumeric for vector and 'function_handle' not 'function handle' in isa test
%
% Revision 1.1  2006/08/20 12:59:31  hauberg
% Changed the structure to match the package system
%
% Revision 1.5  2005/09/08 02:00:17  pkienzle
% [for Bill Denney] isstr -> ischar
%
% Revision 1.4  2004/11/15 16:04:20  pkienzle
% Fix tests for functions which return boolean matrices
%
% Revision 1.3  2004/09/03 17:49:37  jmones
% Improved uint8 and uint16 padding expections
%
% Revision 1.2  2004/09/03 13:40:13  jmones
% Check result has same class as function result, and improved fun param checking
%
% Revision 1.1  2004/08/15 19:27:46  jmones
% blkproc: block process an image using user-supplied function
%
%
