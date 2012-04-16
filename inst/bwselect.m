## Copyright (C) 1999 Andy Adler
## This code has no warrany whatsoever.
## Do what you like with this code as long as you leave this copyright in place.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{imout}, @var{idx}] =} bwselect(@var{im}, @var{cols}, @var{rows}, @var{connect})
## Select connected regions in a binary image.
##
## @table @code
## @item @var{im}
## binary input image
## @item [@var{cols}, @var{rows}]
## vectors of starting points (x,y)
## @item @var{connect}
## connectedness 4 or 8. default is 8
## @item @var{imout}
## the image of all objects in image im that overlap
## pixels in (cols,rows)
## @item @var{idx}
## index of pixels in imout
## @end table
## @end deftypefn

function [imout, idx] = bwselect( im, cols, rows, connect )

if nargin<4
   connect= 8;
end

[jnk,idx]= bwfill( ~im, cols,rows, connect );

imout= zeros( size(jnk) );
imout( idx ) = 1;
