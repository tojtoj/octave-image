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
## @deftypefn {Function File} {[@var{vals}] = } qtgetblk (@var{I},@var{S},@var{dim})
## @deftypefnx {Function File} {[@var{vals},@var{idx}] = } qtgetblk (@var{I},@var{S},@var{dim})
## @deftypefnx {Function File} {[@var{vals},@var{r},@var{c}] = } qtgetblk (@var{I},@var{S},@var{dim})
## Obtain block values from a quadtree decomposition.
##
## [vals]=qtgetblk(I,S,dim) returns a dim-by-dim-by-k array in
## @var{vals} which contains the dim-by-dim blocks in the quadtree
## decomposition (@var{S}, which is returned by qtdecomp) of @var{I}. If
## there are no blocks, an empty matrix is returned.
##
## [vals,idx]=qtgetblk(I,S,dim) returns @var{vals} as described above.
## In addition, it returns @var{idx}, a vector which contains the linear
## indices of the upper left corner of each block returned (the same
## result as find(full(S)==dim)).
##
## [vals,r,c]=qtgetblk(I,S,dim) returns @var{vals} as described, and two
## vectors, @var{r} and @var{c}, which contain the row and column
## coordinates of the blocks returned.
##
## @seealso{qtdecomp, qtsetblk}
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function [varargout] = qtgetblk(I, S, dim)
  if (nargin!=3)
    usage("[vals,r,c]=qtgetblk(I,S,dim), [vals,idx]=qtgetblk(I,S,dim)");
  endif
  if (nargout>3)
    usage("[vals,r,c]=qtgetblk(I,S,dim), [vals,idx]=qtgetblk(I,S,dim)");
  endif

  ## get blocks
  [i,j,v]=spfind(S);

  ## filter the ones which match dim
  idx=find(v==dim);
  
  if(length(idx)==0)
    for i=1:nargout
      varargout{i}=[];
    endfor
  else
    r=i(idx);
    c=j(idx);
    
    ## copy to a dim-by-dim-by-k array
    vals=zeros(dim,dim,length(idx));
    for i=1:length(idx)
      vals(:,:,i)=I(r(i):r(i)+dim-1,c(i):c(i)+dim-1);
    endfor
    
    varargout{1}=vals;
  
    if(nargout==3)
      varargout{2}=r;
      varargout{3}=c;
    elseif(nargout==2)
      varargout{2}=(c-1)*rows(I)+r;
    endif
  endif
endfunction


%!demo
%! [vals,r,c]=qtgetblk(eye(4),qtdecomp(eye(4)),2)
%! % Returns 2 blocks, at [1,3] and [3,1] (2*2 zeros blocks)

%!shared A,S
%! A=[ 1, 4, 2, 5,54,55,61,62;
%!     3, 6, 3, 1,58,53,67,65;
%!     3, 6, 3, 1,58,53,67,65;
%!     3, 6, 3, 1,58,53,67,65;
%!    23,42,42,42,99,99,99,99;    
%!    27,42,42,42,99,99,99,99;    
%!    23,22,26,25,99,99,99,99;    
%!    22,22,24,22,99,99,99,99];
%! S=qtdecomp(A,10);

%!test
%! [va]=qtgetblk(A,S,8);
%! [vb,r,c]=qtgetblk(A,S,8);
%! [vc,i]=qtgetblk(A,S,8);
%! assert(va, vb);
%! assert(va, vc);
%! assert(i,[]);
%! assert(r,[]);
%! assert(c,[]);
%! R=[];
%! assert(va,R);


%!test
%! [va]=qtgetblk(A,S,4);
%! [vb,r,c]=qtgetblk(A,S,4);
%! [vc,i]=qtgetblk(A,S,4);
%! assert(va, vb);
%! assert(va, vc);
%! assert(i, find(full(S)==4));
%! assert(r,[1;5]);
%! assert(c,[1;5]);
%! R=zeros(4,4,2);
%! R(:,:,1)=A(1:4,1:4);
%! R(:,:,2)=A(5:8,5:8);
%! assert(va,R);

%!test
%! [va]=qtgetblk(A,S,2);
%! [vb,r,c]=qtgetblk(A,S,2);
%! [vc,i]=qtgetblk(A,S,2);
%! assert(va, vb);
%! assert(va, vc);
%! assert(i, find(full(S)==2));
%! assert(r,[7;5;7;1;3;1;3]);
%! assert(c,[1;3;3;5;5;7;7]);
%! R=zeros(2,2,7);
%! R(:,:,1)=A(7:8,1:2);
%! R(:,:,2)=A(5:6,3:4);
%! R(:,:,3)=A(7:8,3:4);
%! R(:,:,4)=A(1:2,5:6);
%! R(:,:,5)=A(3:4,5:6);
%! R(:,:,6)=A(1:2,7:8);
%! R(:,:,7)=A(3:4,7:8);
%! assert(va,R);

%
% $Log$
% Revision 1.4  2007/03/23 16:14:37  adb014
% Update the FSF address
%
% Revision 1.3  2007/01/04 23:50:47  hauberg
% Put seealso before end deftypefn
%
% Revision 1.2  2007/01/04 23:41:47  hauberg
% Minor changes in help text
%
% Revision 1.1  2006/08/20 12:59:35  hauberg
% Changed the structure to match the package system
%
% Revision 1.3  2006/01/02 20:53:42  pkienzle
% Reduce number of shared variables in tests
%
% Revision 1.2  2004/08/11 19:52:41  jmones
% qtsetblk added
%
%
