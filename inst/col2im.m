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
## @deftypefn {Function File} {@var{A} = } col2im (@var{B}, [@var{m},@var{n}], [@var{mm},@var{nn}], @var{block_type})
## @deftypefnx {Function File} {@var{A} = } col2im (@var{B}, [@var{m},@var{n}], [@var{mm},@var{nn}])
## Rearranges matrix columns into blocks.
##
## @code{A=col2im(B,[m,n],[mm,nn],block_type)} rearranges columns of
## matrix @var{B} intro blocks in a way controlled by @var{block_type}
## param, which can take the following values:
##
## @table @code
## @item distinct
## It uses @var{m}-by-@var{n} distinct blocks (which are not
## overlapped), and are rearranged to form a @var{mm}-by-@var{nn} matrix
## @var{A}. @var{B}'s height must be @var{m}*@var{n} and @code{col2im}
## rearranges each column to a @var{m}-by-@var{n} block and uses them to
## fill the whole matrix in left-to-right and then up-to-down order.
## @item sliding
## Is uses @var{m}-by-@var{n} sliding blocks. It rearranges row vector
## @var{B} to a (@var{mm}-@var{m}+1)-by-(@var{nn}-@var{n}+1) matrix
## @var{A}. @var{B} must be a
## 1-by-(@var{mm}-@var{m}+1)*(@var{nn}-@var{n}+1).
## @end table
##
## @code{A=col2im(B,[m,n],[mm,nn])} takes @code{distinct} as a default
## value for @var{block_type}.
##
## @seealso{im2col}
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function A = col2im(B, sblock, sb, block_type)
  if(nargin<3 || nargin>4)
    usage("A=col2im(B, [m,n], [mm,nn] [, block_type])");
  endif
  
  if(nargin!=4)
    block_type='sliding';
  endif

  ## common checks
  if(!ismatrix(B))
    error("col2im: B should be a matrix (or vector).");
  endif
  if(!isvector(sblock) || length(sblock)!=2)
    error("col2im: expected [m,n] as second parameter.");
  endif
  if(!isvector(sb) || length(sb)!=2)
    error("col2im: expected [mm,nn] as third parameter.");
  endif

  m=sblock(1);
  n=sblock(2);
  mm=sb(1);
  nn=sb(2);

  switch(block_type)
    case('distinct')
      if(rows(B)!=m*n)
	error("col2im: B height must be m*n for 'distinct' block_type.");
      endif
      if(rem(mm,m)!=0)
	error("col2im: mm should be multiple of m");
      endif
      if(rem(nn,n)!=0)
	error("col2im: nn should be multiple of n");
      endif
      mt=mm/m;
      nt=nn/n;
      if(columns(B)<mt*nt)
	error("col2im: B's width is too small (should be mm*nn/(m*m)).");
      endif
      c=1;
      for i=1:mt
	## TODO: check if we can horzcat([],uint8([10;11])) in a
	## future Octave version > 2.1.58 in order to deuglify this!
	r=reshape(B(:,c),m,n);
	c+=1;
	for j=2:nt
	  r=horzcat(r, reshape(B(:,c),m,n));
	  c+=1;
	endfor
	if(i==1) ## this workarrounds a bug in ver<=2.1.57 cat implementation
	  A=r;
	else
	  A=vertcat(A,r);
	endif
      endfor
	
    case('sliding')
      if(!all(size(B)==[1,(mm-m+1)*(nn-n+1)]))
	error("col2im: wrong B size. Should be 1-by-(mm-m+1)*(nn-n+1).");
      endif
      A=reshape(B, mm-m+1, nn-n+1);
      
    otherwise
      error("col2im: invalid block_type.");
  endswitch

endfunction

%!demo
%! A=[1:10;11:20;21:30;31:40]
%! B=im2col(A,[2,5],'distinct')
%! C=col2im(B,[2,5],[4,10],'distinct')
%! # Divide A using distinct blocks and reverse operation


%!shared B, Ad
%! v=[1:10]';
%! r=reshape(v,2,5);
%! B=[v, v+10, v+20, v+30, v+40, v+50];
%! Ad=[r, r+10; r+20, r+30; r+40, r+50];

%!# bad m
%!error(col2im(B,[3,5],[6,10],'distinct'));

%!# bad n
%!error(col2im(B,[2,3],[6,10],'distinct'));

%!# bad mm
%!error(col2im(B,[2,5],[7,10],'distinct'));

%!# bad nn
%!error(col2im(B,[2,5],[6,11],'distinct'));

%!# bad block_type
%!error(col2im(B,[2,5],[6,10],'wrong_block_type'));

%!# this should be ok
%!assert(col2im(B,[2,5],[6,10],'distinct'), Ad);

%!# now sliding
%!assert(col2im(ones(1,(10-2+1)*(7-3+1)),[2,3],[10,7]), ones((10-2+1),(7-3+1)));
%!assert(col2im(ones(1,(10-2+1)*(7-3+1)),[2,3],[10,7],'sliding'), ones((10-2+1),(7-3+1)));


%!# disctint on uint8
%!assert(col2im(uint8(B),[2,5],[6,10],'distinct'), uint8(Ad));

%!# now sliding on uint8
%!assert(col2im(ones(1,(10-2+1)*(7-3+1),"uint8"),[2,3],[10,7]), ones((10-2+1),(7-3+1),"uint8"));


%
% $Log$
% Revision 1.4  2007/03/23 16:14:36  adb014
% Update the FSF address
%
% Revision 1.3  2007/01/04 23:46:17  hauberg
% Minor changes in help text
%
% Revision 1.2  2007/01/04 23:37:54  hauberg
% Minor changes in help text
%
% Revision 1.1  2006/08/20 12:59:32  hauberg
% Changed the structure to match the package system
%
% Revision 1.2  2004/09/03 17:57:42  jmones
% Added support for int* and uint* types
%
% Revision 1.1  2004/08/18 14:39:07  jmones
% im2col and col2im added
%
%
