## COLFILT Apply filter to matrix blocks
## colfilt(A,[r c],[m n],'sliding',f,...)
##   For each r x c overlapping subblock of A, add a column in matrix C
##   f(C,...) should return a row vector which is then reshaped into a
##   a matrix of size A and returned.  A is processed in chunks of size m x n.
## colfilt(A,[r c],[m n],'distinct',f,...)
##   For each r x c non-overlapping subblock of A, add a column in matrix C
##   f(C,...) should return a matrix of size C each column of which is
##   placed back into the subblock from whence it came.  A is processed
##   in chunks of size m x n.
##
## The present version requires [m n], but for compatibility it should
## be optional.  Use colfilt(A,[r c],size(A),...)
##
## The present version requires that [m n] divide size(A), but for
## compatibility it should work even if [m n] does not divide A. Use
## the following instead:
##    [r c] = size(A);
##    padA = zeros (m*ceil(r/m),n*ceil(c/n));
##    padA(1:r,1:c) = A;
##    B = colfilt(padA,...);
##    B = B(1:r,1:c);
##
## The present version does not handle 'distinct'

## This software is granted to the public domain
## Author: Paul Kienzle <pkienzle@users.sf.net>

function B = colfilt(A,filtsize,blksize,blktype,f,varargin)

   [m,n]=size(A);
   r = filtsize(1);
   c = filtsize(2);
   mblock = blksize(1);
   nblock = blksize(2);

   switch blktype
   case 'sliding'
     # pad with zeros
     padm = (m+r-1);
     padn = (n+c-1);
     padA = zeros(padm, padn);
     padA([1:m]+floor((r-1)/2),[1:n]+floor((c-1)/2)) = A;
     padA = padA(:);

     # throw away old A to save memory.
     B=A; clear A;  

     # build the index vector
     colidx = [0:r-1]'*ones(1,c) + padm*ones(r,1)*[0:c-1];
     offset = [1:mblock]'*ones(1,nblock) + padm*ones(mblock,1)*[0:nblock-1];
     idx = colidx(:)*ones(1,mblock*nblock) + ones(r*c,1)*offset(:)';
     clear colidx offset;

     # process the matrix, one block at a time
     idxA = zeros(r*c,mblock*nblock);
     tmp = zeros(mblock,nblock);
     for i = 0:m/mblock-1
       for j = 0:n/nblock-1
         idxA(:) = padA(idx + (i*mblock + padm*j*nblock));
         tmp(:) = feval(f,idxA,varargin{:});
         B(1+i*mblock:(i+1)*mblock, 1+j*nblock:(j+1)*nblock) = tmp;
       end
     end

   case 'old-sliding'  # processes the whole matrix at a time
     padA = zeros(m+r-1,n+c-1);
     padA([1:m]+floor(r/2),[1:n]+floor(c/2)) = A;
     [padm,padn] = size(padA);
     colidx = [0:r-1]'*ones(1,c) + padm*ones(r,1)*[0:c-1];
     offset = [1:m]'*ones(1,n) + padm*ones(m,1)*[0:n-1];
     idx = colidx(:)*ones(1,m*n) + ones(r*c,1)*offset(:)';
     idxA = zeros(r*c,m*n);
     idxA(:) = padA(:)(idx);
     B = zeros(size(A));
     B(:) = feval(f,idxA,varargin{:});
   case 'old-distinct' # processes the whole matrix at a time
     if (r*floor(m/r) != m || c*floor(n/c) != n)
        error("colfilt expected blocks to exactly fill A");
     endif
     colidx = [0:r-1]'*ones(1,c) + m*ones(r,1)*[0:c-1];
     offset = [1:r:m]'*ones(1,n/c) + m*ones(m/r,1)*[0:c:n-1];
     idx =colidx(:)*ones(1,m*n/r/c) + ones(r*c,1)*offset(:)';
     idxA = zeros(r*c,m*n/r/c);
     idxA(:) = A(:)(idx);
     B = zeros(prod(size(A)),1);
     B(idx) = feval(f,idxA,varargin{:});
     B = reshape(B,size(A));
   endswitch
endfunction

%!test
%! A = reshape(1:36,6,6);
%! assert(colfilt(A,[2,2],[3,3],'sliding','sum'), conv2(A,ones(2),'same'));