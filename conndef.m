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
## @deftypefn {Function File} {@var{conn} = } conndef (@var{num_dims}, @var{type})
## Creates a connectivity array
##
## @code{conn=conndef(num_dims,type)} creates a connectivity array
## (@var{CONN}) of @var{num_dims} dimensions and which type is defined
## by @var{type} as follows:
## @table @code
## @item minimal
## Neighbours touch the central element on a (@var{num_dims}-1)-dimensional
## surface.
## @item maximal
## Neighbours touch the central element in any way. Equivalent to
## @code{ones(repmat(3,1,@var{num_dims}))}.
## @end table
##
## @end deftypefn



## Author:  Josep Mones i Teixidor <jmones@puntbarra.com>

function conn = conndef(num_dims,conntype)
  if(nargin!=2)
    usage("conn=conndef(num_dims, type)");
  endif
  if(num_dims<=0)
    error("conndef: num_dims must be > 0");
  endif
    
  if(strcmp(conntype,"minimal"))
    if(num_dims==1)
      conn=[1;1;1];
    elseif(num_dims==2)
      conn=[0,1,0;1,1,1;0,1,0];
    else
      conn=zeros(repmat(3,1,num_dims));
      idx={};
      idx{1}=1:3;
      for i=2:num_dims
	idx{i}=2;
      endfor
      conn(idx{:})=1;
      for i=2:num_dims
	idx{i-1}=2;
	idx{i}=1:3;
	conn(idx{:})=1;
      endfor
    endif
    
  elseif(strcmp(conntype,"maximal"))
    if(num_dims==1)
      conn=[1;1;1];
    else
      conn=ones(repmat(3,1,num_dims));
    endif
  else
    error("conndef: invalid type parameter.");
  endif
  
endfunction

%!demo
%! conndef(2,'minimal')
%! % Create a 2-D minimal connectivity array

%!assert(conndef(1,'minimal'), [1;1;1]);

%!assert(conndef(2,'minimal'), [0,1,0;1,1,1;0,1,0]);

%!test
%! C=zeros(3,3);
%! C(2,2,1)=1;
%! C(2,2,3)=1;
%! C(:,:,2)=[0,1,0;1,1,1;0,1,0];
%! assert(conndef(3,'minimal'), C);

%!assert(conndef(1,'maximal'), ones(3,1));
%!assert(conndef(2,'maximal'), ones(3,3));
%!assert(conndef(3,'maximal'), ones(3,3,3));
%!assert(conndef(4,'maximal'), ones(3,3,3,3));



%
% $Log$
% Revision 1.1  2004/08/15 19:38:44  jmones
% conndef added: Creates a connectivity array
%
%