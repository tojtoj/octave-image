## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} im2col (@var{A}, @var{block_size})
## @deftypefnx {Function File} {} im2col (@var{A}, v, @var{block_type})
## @deftypefnx {Function File} {} im2col (@var{A}, "indexed", @dots{})
## Rearrange image blocks into columns.
##
## @code{B=im2col(A, block_size, blocktype)} rearranges blocks in @var{A}
## into columns in a way that's determined by @var{block_type}, which
## can take the following values:
##
## @table @code
## @item distinct
## Rearranges each distinct @var{m}-by-@var{n} block in image @var{A}
## into a column of @var{B}. Blocks are scanned from left to right and
## the up to bottom in @var{A}, and columns are added to @var{B} from
## left to right. If @var{A}'s size is not multiple @var{m}-by-@var{n}
## it is padded.
## @item sliding
## Rearranges any @var{m}-by-@var{n} sliding block of @var{A} in a
## column of @var{B}, without any padding, so only sliding blocks which
## can be built using a full @var{m}-by-@var{n} neighbourhood are taken.
## In consequence, @var{B} has @var{m}*@var{n} rows and
## (@var{mm}-@var{m}+1)*(@var{nn}-@var{n}+1) columns (where @var{mm} and
## @var{nn} are the size of @var{A}).
##
## This case is thought to be used applying operations on columns of
## @var{B} (for instance using sum(:)), so that result is a
## 1-by-(@var{mm}-@var{m}+1)*(@var{nn}-@var{n}+1) vector, that is what
## the complementary function @code{col2im} expects.
## @end table
##
## @code{B=im2col(A, block_size)} takes @code{distinct} as a default value for
## @var{block_type}. 
##
## @code{B=im2col(A,'indexed', @dots{})} will treat @var{A} as an indexed
## image, so it will pad using 1 if @var{A} is double. All other cases
## (incluing indexed matrices with uint8 and uint16 types and
## non-indexed images) will use 0 as padding value.
##
## Any padding needed in 'distinct' processing will be added at right
## and bottom edges of the image.
##
## @seealso{col2im}
## @end deftypefn

function B = im2col (A, varargin)
  if (nargin < 2 || nargin > 4)
    print_usage ();
  elseif (! ismatrix (A) || ! (isnumeric (A) || islogical (A)))
    error ("im2col: A must be a numeric of logical matrix");
  endif
  p = 1;  # varargin param being processsed

  ## Defaults
  block_type  = "sliding";
  padval      = 0;
  indexed     = false;

  ## Check for 'indexed' presence
  if (ischar (varargin{p}) && strcmpi (varargin{p}, "indexed"))
    indexed = true;
    if (nargin < 3)
      print_usage ();
    endif
    if (isfloat (A))
      ## We pad with value of 1 for indexed images of floating point class,
      ## because lowest index is 1 for them (it's 0 for integer indexed images).
      padval = 1;
    endif
    p++;
  elseif (nargin > 3)
    ## If we didn't have "indexed" but had 4 parameters there's an error
    print_usage ();
  endif

  ## check [m,n]
  block_size = varargin{p};
  if (! isnumeric (block_size) || ! isvector (block_size) ||
      any (block_size(:) < 1))
    error ("im2col: BLOCK_SIZE must be a vector of positive elements.");
  elseif (numel (block_size) > ndims (A))
    error ("im2col: BLOCK_SIZE can't have more elements than the dimensions of A");
  endif
  block_size(end+1:ndims(A)) = 1; # expand singleton dimensions
  block_size = block_size(:).'; # make sure it's a row vector
  p++;

  if (nargin > p)
    ## we have block_type param
    if (! ischar (varargin{p}))
      error("im2col: invalid parameter block_type.");
    endif
    block_type = varargin{p};
  endif

  switch (tolower (block_type))
    case "distinct"
      ## Calculate needed padding
      sp = mod (-size (A), block_size);
      if (any (sp))
        A = padarray (A, sp, padval, "post");
      endif

      ## Create the dimensions arguments for mat2cell (one per dimension
      ## with the length of that dimension repeated the number of blocks
      ## for that dimension)
      n_blocks   = size (A) ./ block_size;
      cell_split = arrayfun (@(x) repmat (block_size(x), [1 n_blocks(x)]),
                             1:numel (block_size), "UniformOutput", false);

      ## This functions may be a good candidate to rewrite in C++, making
      ## use of the code in mat2cell without the need to convert between
      ## cell and matrix and transposing.
      B_cell = mat2cell (A, cell_split{:})';
      B = cell2mat (cellfun (@(x) x(:), B_cell(:), "UniformOutput", false)');

    case "sliding"
      if (any (size (A) < block_size))
        error("im2col: no dimension of A can be greater than BLOCK_SIZE in sliding");
      elseif (ndims (A) > 2)
        ## TODO: implement n-dimensional sliding
        error ("im2col: only 2 dimensional are supported for sliding");
      endif
      m = block_size(1);
      n = block_size(2);
      ## TODO: check if matlab uses top-down and left-right order
      B = [];
      for j = 1:1:size(A,2)-n+1 ## left to right
        for i=1:1:size(A,1)-m+1 ## up to bottom
          ## TODO: check if we can horzcat([],uint8([10;11])) in a
          ## future Octave version > 2.1.58
          if(isempty(B))
            B=A(i:i+m-1,j:j+n-1)(:);
          else
            B=horzcat(B, A(i:i+m-1,j:j+n-1)(:));
          endif
        endfor
      endfor

    otherwise
      error ("im2col: invalid BLOCK_TYPE `%s'.", block_type);
  endswitch

endfunction

%!demo
%! A=[1:10;11:20;21:30;31:40]
%! B=im2col(A,[2,5],'distinct')
%! C=col2im(B,[2,5],[4,10],'distinct')
%! # Divide A using distinct blocks and reverse operation

%!shared B, A, Bs, As, Ap, Bp0, Bp1
%! v=[1:10]';
%! r=reshape(v,2,5);
%! B=[v, v+10, v+20, v+30, v+40, v+50];
%! A=[r, r+10; r+20, r+30; r+40, r+50];
%! As=[1,2,3,4,5;6,7,8,9,10;11,12,13,14,15];
%! b1=As(1:2,1:4)(:);
%! b2=As(2:3,1:4)(:);
%! b3=As(1:2,2:5)(:);
%! b4=As(2:3,2:5)(:);
%! Bs=[b1,b2,b3,b4];
%! Ap=A(:,1:9);
%! Bp1=Bp0=B;
%! Bp0([9:10],[2,4,6])=0;
%! Bp1([9:10],[2,4,6])=1;

%!# bad block_type
%!error(im2col(A,[2,5],'wrong_block_type'));

%!# distinct
%!assert(im2col(A,[2,5],'distinct'), B);

%!# padding
%!assert(im2col(Ap,[2,5],'distinct'), Bp0);
%!assert(im2col(Ap,'indexed',[2,5],'distinct'), Bp1);

%!# now sliding
%!assert(im2col(As,[2,4]), Bs);
%!assert(im2col(As,[2,4],'sliding'), Bs);
%!assert(im2col(As,[3,5],'sliding'), As(:));

%!# disctint uint8 & uint16
%!assert(im2col(uint8(A),[2,5],'distinct'), uint8(B));
%!assert(im2col(uint16(A),[2,5],'distinct'), uint16(B));

%!# padding uint8 & uint16 (to 0 even in indexed case)
%!assert(im2col(uint8(Ap),[2,5],'distinct'), uint8(Bp0));
%!assert(im2col(uint8(Ap),'indexed',[2,5],'distinct'), uint8(Bp0));
%!assert(im2col(uint16(Ap),[2,5],'distinct'), uint16(Bp0));
%!assert(im2col(uint16(Ap),'indexed',[2,5],'distinct'), uint16(Bp0));

%!# now sliding uint8 & uint16
%!assert(im2col(uint8(As),[2,4],'sliding'), uint8(Bs));
%!assert(im2col(uint16(As),[2,4],'sliding'), uint16(Bs));
