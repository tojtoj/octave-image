## Copyright (C) 2000  Etienne Grossmann
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

##       [im2,npix,bb] = bwlabel(im,...)
##  
## im  : RxC 0-1 matrix
##
## im2 : RxC int matrix in which the connected regions of im have been
##       numbered. 4-neighborhoods are considered.
##
## npix : 1xQ int number of pixel in each region
##
## bb   : 4xQ int bounding boxes of the regions. Rows are minrow,
##        maxrow, mincol, maxcol.
##
## Since the algorithm is slow, it will report progress if it has to do
## more than 100 loops.
##
## Options :
##
## "verbose"  : Be verbose
## "quiet"    : Don't report anything (overrides "verbose")
## "prudent"  : Check that regions do not touch
## "mins", m  : Minimum size of the regions
## "maxs", m  : Maximum size of the regions
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: January 2000

function [im2,npix,bb] = bwlabel(im,...)

[R,C]=size(im);
tr = 0 ;
				# Loop as little as possible
if R<C, tr = 1; im = im' ; [R,C]=size(im); end

report = C>100 ;

quiet = 0 ;
verbose = 0 ;
prudent = 1 ;
mins = maxs = 0 ;


filename = "bwlabel" ;
opt0 = " verbose quiet " ;
opt1 = " mins maxs " ;
nargin-- ;
read_options ;


if any(im(:)&im(:)!=1),
  printf("bwlabel : im is not binary\n");
  return
end

if quiet, verbose = report = 0 ; end

gsize = 100 ;			# Predicted number of slices

im2 = zeros(R,C);
## keyboard
				# find horizontal up/down going edges
imup =  max(im2, diff([zeros(1,C);im])) ;
imdo = -min(im2, diff([im;zeros(1,C)])) ;

im2 = ones(R,C);
######################################################################
## Find connected regions ############################################

rc = 1 ;			# Counter of region slices 

rnum = ones(1,gsize);		# List of labels of each slice
npix = zeros(1,gsize);		# Sizes of regions (actual size is in
				# region's first slice)
bb = zeros(4,gsize);		# Bounding boxes

if report && !verbose,
  printf("bwlabel : There will be %i loops ... \n%5i ",C,0) ;
end

lrow = zeros(R,1);		# Last treated image column
 
for i=1:C,
  ## i
  t1 = find(imup(:,i)) ;
  t2 = find(imdo(:,i)) ;
  
  nrow = zeros(R,1);		# Next row

  ## if i==42 || i==41,"i==42 || i==41", keyboard; end

  for j = 1:rows(t1(:)) ,	# Loop over slices of i'th column

    rc++ ;			# rc = number of current slice.
    im2(t1(j):t2(j),i) = rc ;
    ## if rc==341, "rc==341",keyboard; end
				# Slices from previous column that touch
				# this slice.
    rr = create_set(lrow(t1(j):t2(j))) ;
    if !isempty(rr) && !rr(1), rr = rr(2:length(rr)) ; end

    if rc>size(rnum,2),		# Get more space (uncertain effect on
				# speed; avoids resizing rnum and npix)
      tmp = 2*(ceil(C*rc/i)-rc+1+rows(t1(:))-j) ;
      sayif(verbose,"bwlabel : (i=%i) Foreseeing %i more regions\n",i,tmp);
      rnum = [ rnum, ones(1,tmp) ] ;
      npix = [ npix,zeros(1,tmp) ] ;
      bb = [ bb,zeros(4,tmp) ] ;
    end

    if isempty(rr),			# New region 
      sayif(verbose,"bwlabel : creating region %i\n",rc);

      r0 = rc ;			# r0 = number of the region

      bb(1,r0) = t1(j) ;
      bb(2,r0) = t2(j) ;
      bb(3:4,r0) = i ;

    else			# Add to already existing region #####

      ## rr
      r0 = rnum(rr(1)) ;

      bb(1,r0) = min(bb(1,r0),t1(j)) ;
      bb(2,r0) = max(bb(2,r0),t2(j)) ;
      bb(4,r0) = i ;

				# Touches region r0
      sayif(verbose,"bwlabel : adding to region %i\n",r0);

				# Touches other regions too
      for k = rr(find(rr!=r0)),	# Loop over other touching regions, that
				# should be merged to the first.
	sayif(verbose,"bwlabel : merging regions %i and %i\n",k,r0);
	rnum(find(rnum==k)) = r0 ;
	npix(r0) = npix(r0) + npix(k) ;
	bb([1,3],r0) = min(bb([1,3],r0)',bb([1,3],k)')' ;
	bb([2,4],r0) = max(bb([2,4],r0)',bb([2,4],k)')' ;
      end
      
    end				# End of add to already existing region
    ## if r0==259 && i==39,"r0==259",keyboard;end
    rnum(rc) = r0 ;

    npix(r0) = npix(r0) + 1+t2(j)-t1(j) ;

    nrow(t1(j):t2(j)) = r0 ;
  end				# End of looping over slices
  lrow = nrow ;
  if report && !verbose,
    printf(".") ;
    if !rem(i,70) && i<C, printf("\n%5i ",i); end
  end
end				# End of looping over columns
## length(regs)
if report && !verbose,
  printf("\n") ;
end
## im2
## [ 1:rc ; rnum(1:rc) ]
keep = ones(1,rc) ; 

if mins, keep = keep & (npix(rnum(1:rc))>=mins) ; end
if maxs, keep = keep & (npix(rnum(1:rc))<=maxs) ; end
keep(1) = 1 ;
keep = find(keep) ;		# Indices of slices to be kept

foo = create_set(rnum(keep)) ;	# Indices of regions to be kept
nr = prod(size(foo)) ;		# Number of regions (including bg)
## lrow = zeros(1,nr) ;
tmp = zeros(1,rc) ;
tmp(foo) = 0:nr-1 ;

bar = zeros(1,rc) ;
bar(keep) = tmp(rnum(keep)) ;

## keyboard

im2 = reshape(bar(im2),R,C) ;

npix = npix(foo(2:nr));
bb = bb(:,foo(2:nr));

if 0,				# Draw bb on the image (will ruin
				# coherence)
  for i=1:nr-1,
    im2([bb(1,i),bb(2,i)] ,bb(3,i):bb(4,i) ) = i ;
    im2( bb(1,i):bb(2,i) ,[bb(3,i),bb(4,i)]) = i ;
  end
end

## keyboard
if prudent,

  sayif(verbose,"bwlabel : Checking coherence\n");

  hcontact = im2 & im2!=[im2(:,2:C),zeros(R,1)] & [im2(:,2:C),zeros(R,1)] ;
  vcontact = im2 & im2!=[im2(2:R,:);zeros(1,C)] & [im2(2:R,:);zeros(1,C)] ;
  ok = 1 ;
  if any(hcontact(:)),
    ok = 0 ;
    printf("bwlabel: Whoa! Found horizontally connected separated regions\n");
  end
  if any(vcontact(:)),
    ok = 0 ;
    printf("bwlabel: Whoa! Found vertically connected separated regions\n");
  end
  if !ok, keyboard ; end
end

## Eventually transpose result
if tr, 
  im2 = im2' ; 
  bb = bb([3,4,1,2],:);
end
