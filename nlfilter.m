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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{B} = } nlfilter (@var{A}, [@var{m},@var{n}], @var{fun})
## @deftypefnx {Function File} {@var{B} = } nlfilter (@var{A}, [@var{m},@var{n}], @var{fun}, ...)
## @deftypefnx {Function File} {@var{B} = } nlfilter (@var{A},'indexed', ...)
## Processes image in siliding blocks using user-supplied function
##
## @code{B=nlfilter(A,[m,n],fun)} passes sliding @var{m}-by-@var{n}
## blocks to user-supplied function @var{fun}. A block is build for
## every pixel in @var{A}, such as it is centered within the block.
## @var{fun} must return a scalar, and it is used to create matrix
## @var{B}. @var{nlfilter} pads the @var{m}-by-@var{n} block at the
## edges if necessary.
## 
## Center of block is taken at ceil([@var{m},@var{n}]/2).
##
## @code{B=nlfilter(A,[m,n],fun,...)} behaves as described above but
## passes extra parameters to function @var{fun}.
##
## @code{B=nlfilter(A,'indexed',...)} assumes that @var{A} is an indexed
## image, so it pads the image using proper value: 0 for uint8 and
## uint16 images and 1 for double images. Keep in mind that if 'indexed'
## is not specified padding is always done using 0.
##
## @end deftypefn
## @seealso{colfilt,blkproc,inline}

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function B = nlfilter(A, varargin)
  if(nargin<3)
    error("nlfilter: invalid number of parameters.");
  endif
  
  ## check 'indexed' presence
  indexed=false;
  p=1;
  if(isstr(varargin{1}) && strcmp(varargin{1}, "indexed"))
    indexed=true;
    p+=1;
    if(strcmp(typeinfo(A), 'uint8 matrix'))
      padval=0; ## padval=uint8(0); in future...
    elseif(strcmp(typeinfo(A), 'uint16 matrix'))
      padval=0; ## padval=uint16(0); in future...
    else
      padval=1; ## array of double
    endif
  else
    padval=0;
  endif

  ## check [m,n]
  if(!isvector(varargin{p}))
    error("nlfilter: expected [m,n] but param is not a vector.");
  endif
  if(length(varargin{p})!=2)
    error("nlfilter: expected [m,n] but param has wrong length.");
  endif
  sblk=varargin{p}(:);
  p+=1;

  ## check fun
  ## TODO: add proper checks for this one
  if(nargin<p)
    error("nlfilter: required parameters haven't been supplied.");
  endif
  fun=varargin{p};
  
  ## remaining params are params to fun
  ## extra params are p+1:nargin-1

  ## We take an easy approach... feel free to optimize it (coding this
  ## in C++ would be a great idea).
  
  ## Calculate center of block
  c=ceil(sblk/2);
  
  ## Pre-padding
  prepad=c-ones(2,1);
  
  ## Post-padding
  postpad=sblk-c;
  
  ## Create room in output matrix
  B=zeros(size(A));

  ## Pad data
  if(all(prepad==postpad))
    if(any(prepad>0))
      A=padarray(A,prepad,padval,'both');
    endif
  else
    if(any(prepad>0))
      A=padarray(A,prepad,padval,'pre');
    endif
    if(any(postpad>0))
      A=padarray(A,postpad,padval,'post');
    endif
  endif

  ## calc end offsets
  me=postpad(1)+prepad(1);
  ne=postpad(2)+prepad(2);
	
  ## Fill it!
  for i=1:rows(B)
    for j=1:columns(B)
      B(i,j)=feval(fun,A(i:i+me,j:j+ne),varargin{p+1:nargin-1});
    endfor
  endfor
endfunction

%!demo
%! nlfilter(eye(10),[3,3],inline("any(x(:)>0)","x"))
%! # creates a "wide" diagonal	

%!assert(nlfilter(eye(4),[2,3],inline("sum(x(:))","x")),[2,2,1,0;1,2,2,1;0,1,2,2;0,0,1,1]);
%!assert(nlfilter(eye(4),'indexed',[2,3],inline("sum(x(:))","x")),[4,2,1,2;3,2,2,3;2,1,2,4;4,3,4,5]);
%!assert(nlfilter(eye(4),'indexed',[2,3],inline("sum(x(:))==y","x","y"),2),[0,1,0,1;0,1,1,0;1,0,1,0;0,0,0,0]);



%
% $Log$
% Revision 1.1  2004/08/15 19:42:14  jmones
% nlfilter: Processes image in siliding blocks using user-supplied function
%
%