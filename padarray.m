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
## @deftypefn {Function File} {@var{B} = } padarray (@var{A},@var{padsize})
## @deftypefnx {Function File} {@var{B} = } padarray (@var{A},@var{padsize},@var{padval})
## @deftypefnx {Function File} {@var{B} = } padarray (@var{A},@var{padsize},@var{padval},@var{direction})
## Pads an array in a configurable way.
##
## B = padarray(A,padsize) pads an array @var{A} with zeros, where
## @var{padsize} defines the amount of padding to add in each dimension
## (it must be a vector of positive integers). 
##
## Each component of @var{padsize} defines the number of elements of
## padding that will be added in the corresponding dimension. For
## instance, [4,5] adds 4 elements of padding in first dimension (vertical)
## and 5 in second dimension (horizontal).
##
## B = padarray(A,padsize,padval) pads @var{A} using the value specified
## by @var{padval}. @var{padval} can be a scalar or a string. Possible
## values are:
## @table @code
## @item 0
## Pads with 0 as described above. This is the default behaviour.
## @item scalar
## Pads using @var{padval} as a padding value.
## @item 'circular'
## Pads with a circular repetition of elements in @var{A} (similar to
## tiling @var{A}).
## @item 'replicate'
## Pads 'replicating' values of @var{A} which are at the border of the
## array.
## @item 'symmetric'
## Pads with a mirror reflection of @var{A}.
## @end table
##
## B = padarray(A,padsize,padval,direction) pads @var{A} defining the
## direction of the pad. Possible values are:
## @table @code
## @item 'both'
## For each dimension it pads before the first element the number
## of elements defined by @var{padsize} and the same number again after
## the last element. This is the default value.
## @item 'pre'
## For each dimension it pads before the first element the number of
## elements defined by @var{padsize}.
## @item 'post'
## For each dimension it pads after the last element the number of
## elements defined by @var{padsize}.
## @end table
## @end deftypefn

## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function B = padarray(A, padsize, padval, direction)
  # Check parameters
  if (nargin<2 || nargin>4)
    usage ("B = padarray(A, padsize [, padval] [, direction])");
  endif
  if (nargin<3)
    padval=0;
  endif
  if (nargin<4)
    direction='both';
  endif

  if (!isvector(padsize) || any(padsize<0))
    error("padarray: padsize must be a vector of positive integers.");
  endif

  # Check direction
  pre=false;
  post=false;
  switch(direction)
    case('pre')
      pre=true;
    case('post')
      post=true;
    case('both')
      post=true;
      pre=true;
    otherwise
      error ("padarray: direction possible values are: 'pre', 'post' and 'both'");
  endswitch
  
  
  B=A;
  dim=1;
  for s=padsize
    if (s>0)
      # padding in this dimension was requested
      ds=size(B);
      ds=[ds, ones(1,dim-length(ds))]; # data size
      ps=ds;
      ps(dim)=s;		       # padding size

      if (isstr(padval))
	# Init a "index all" cell array. All cases need it.
	idx=cell();
	for i=1:length(ds)
	  idx{i}=1:ds(i);
	endfor

	switch(padval)
	  case('circular')
	    complete=0;
	    D=B;
	    if (ps(dim)>ds(dim))
	      complete=floor(ps(dim)/ds(dim));
	      ps(dim)=rem(ps(dim),ds(dim));
	    endif
	    if (pre)
	      for i=1:complete
		B=cat(dim,D,B);
	      endfor
	      idxt=idx;
	      idxt{dim}=ds(dim)-ps(dim)+1:ds(dim);
	      B=cat(dim,D(idxt{:}),B);
	    endif
	    if (post)
	      for i=1:complete
		B=cat(dim,B,D);
	      endfor
	      idxt=idx;
	      idxt{dim}=1:ps(dim);
	      B=cat(dim,B,D(idxt{:}));
	    endif
	    # end circular case

	  case('replicate')
	    if (pre)
	      idxt=idx;
	      idxt{dim}=1;
	      pad=B(idxt{:});
	      # can we do this without the loop?	
	      for i=1:s
		B=cat(dim,pad,B);
	      endfor
	    endif
	    if (post)
	      idxt=idx;
	      idxt{dim}=size(B,dim);
	      pad=B(idxt{:});
	      for i=1:s
		B=cat(dim,B,pad);
	      endfor
	    endif
	    # end replicate case
	
	  case('symmetric')
	    if (ps(dim)>ds(dim))
	      error("padarray: padding is longer than data using symmetric padding");
	    endif
	    if (pre)
	      idxt=idx;
	      idxt{dim}=ps(dim):-1:1;
	      B=cat(dim,B(idxt{:}),B);
	    endif
	    if (post)
	      idxt=idx;
	      sbd=size(B,dim);
	      idxt{dim}=sbd:-1:sbd-ps(dim)+1;
	      B=cat(dim,B,B(idxt{:}));
	    endif
	    # end symmetric case

	  otherwise
	    error("padarray: invalid string in padval parameter.");

	endswitch
	# end cases where padval is a string

      elseif (isscalar(padval))
	# Handle fixed value padding
	if (padval==0)
	  pad=zeros(ps);
	else
	  pad=padval*ones(ps);
	endif
	if(pre&&post)
	  # check if this is not quicker than just 2 calls (one for each)
	  B=cat(dim,pad,B,pad);
	elseif(pre)
	  B=cat(dim,pad,B);
	elseif(post)
	  B=cat(dim,B,pad);
	endif
      else
	error ("padarray: padval can only be a scalar or a string.");
      endif
    endif
    dim+=1;
  endfor
endfunction

%!demo
%! padarray([1,2,3;4,5,6],[2,1])
%! % pads [1,2,3;4,5,6] with a whole border of 2 rows and 1 columns of 0

%!demo
%! padarray([1,2,3;4,5,6],[2,1],5)
%! % pads [1,2,3;4,5,6] with a whole border of 2 rows and 1 columns of 5

%!demo
%! padarray([1,2,3;4,5,6],[2,1],0,'pre')
%! % pads [1,2,3;4,5,6] with a left and top border of 2 rows and 1 columns of 0

%!demo
%! padarray([1,2,3;4,5,6],[2,1],'circular')
%! % pads [1,2,3;4,5,6] with a whole 'circular' border of 2 rows and 1 columns
%! % border 'repeats' data as if we tiled blocks of data

%!demo
%! padarray([1,2,3;4,5,6],[2,1],'replicate')
%! % pads [1,2,3;4,5,6] with a whole border of 2 rows and 1 columns which
%! % 'replicates' edge data

%!demo
%! padarray([1,2,3;4,5,6],[2,1],'symmetric')
%! % pads [1,2,3;4,5,6] with a whole border of 2 rows and 1 columns which
%! % is symmetric to the data on the edge 

% Test default padval and direction
%!assert(padarray([1;2],[1]), [0;1;2;0]);
%!assert(padarray([3,4],[0,2]), [0,0,3,4,0,0]);
%!assert(padarray([1,2,3;4,5,6],[1,2]), \
%!      [zeros(1,7);0,0,1,2,3,0,0;0,0,4,5,6,0,0;zeros(1,7)]);

% This segfaults because of cat (uncomment when
% cat(3,eye(2),eye(2)) works)
%! %assert(padarray([1,2,3;4,5,6],[3,2,1]), cat(3, 			\
%! %	zeros(7,7),							\
%! %	[zeros(3,7); [zeros(2,2), [1,2,3;4,5,6], zeros(2,2)]; zeros(3,7)], \
%! %	zeros(7,7))); 

% Test if default param are ok
%!assert(padarray([1,2],[4,5])==padarray([1,2],[4,5],0));
%!assert(padarray([1,2],[4,5])==padarray([1,2],[4,5],0,'both'));

% Test literal padval
%!assert(padarray([1;2],[1],i), [i;1;2;i]);

% Test directions (horizontal)
%!assert(padarray([1;2],[1],i,'pre'), [i;1;2]);
%!assert(padarray([1;2],[1],i,'post'), [1;2;i]);
%!assert(padarray([1;2],[1],i,'both'), [i;1;2;i]);

% Test directions (vertical)
%!assert(padarray([1,2],[0,1],i,'pre'), [i,1,2]);
%!assert(padarray([1,2],[0,1],i,'post'), [1,2,i]);
%!assert(padarray([1,2],[0,1],i,'both'), [i,1,2,i]);

% Test circular padding
%!test
%! A=[1,2,3;4,5,6];
%! B=repmat(A,7,9);
%! assert(padarray(A,[1,2],'circular','pre'), B(2:4,2:6));
%! assert(padarray(A,[1,2],'circular','post'), B(3:5,4:8));
%! assert(padarray(A,[1,2],'circular','both'), B(2:5,2:8));
%! % This tests when padding is bigger than data
%! assert(padarray(A,[5,10],'circular','both'), B(2:13,3:25));

% Test replicate padding
%!test
%! A=[1,2;3,4];
%! B=kron(A,ones(10,5));
%! assert(padarray(A,[9,4],'replicate','pre'), B(1:11,1:6));
%! assert(padarray(A,[9,4],'replicate','post'), B(10:20,5:10));
%! assert(padarray(A,[9,4],'replicate','both'), B);

% Test symmetric padding
%!test
%! A=[1:3;4:6];
%! HA=[3:-1:1;6:-1:4];
%! VA=[4:6;1:3];
%! VHA=[6:-1:4;3:-1:1];
%! B=[VHA,VA,VHA; HA,A,HA; VHA,VA,VHA];
%! assert(padarray(A,[1,2],'symmetric','pre'), B(2:4,2:6));
%! assert(padarray(A,[1,2],'symmetric','post'), B(3:5,4:8));
%! assert(padarray(A,[1,2],'symmetric','both'), B(2:5,2:8));

%
% $Log$
% Revision 1.1  2004/08/08 21:20:25  jmones
% uintlut and padarray functions added
%
%
