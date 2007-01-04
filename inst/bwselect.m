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

# Copyright (C) 1999 Andy Adler
# This code has no warrany whatsoever.
# Do what you like with this code as long as you
#     leave this copyright in place.
#
# $Id$
function [imout, idx] = bwselect( im, cols, rows, connect )

if nargin<4
   connect= 8;
end

[jnk,idx]= bwfill( ~im, cols,rows, connect );

imout= zeros( size(jnk) );
imout( idx ) = 1;

# 
# $Log$
# Revision 1.3  2007/01/04 23:41:47  hauberg
# Minor changes in help text
#
# Revision 1.2  2007/01/02 21:58:38  hauberg
# Documentation is now in Texinfo (looks better on the website)
#
# Revision 1.1  2006/08/20 12:59:32  hauberg
# Changed the structure to match the package system
#
# Revision 1.1  2002/03/17 02:38:52  aadler
# fill and edge detection operators
#
# Revision 1.1  1999/06/08 17:06:01  aadler
# Initial revision
#
#

