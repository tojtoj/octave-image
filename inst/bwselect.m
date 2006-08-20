function [imout, idx] = bwselect( im, cols, rows, connect )
# BWSELECT: select connected regions in a binary image
# [imout, idx] = bwselect( im, cols, rows, connect )
#
#   im          -> binary input image
#   [cols,rows] -> vectors of starting points (x,y)
#   connect     -> connectedness 4 or 8. default is 8
#   imout       -> the image of all objects in image im that overlap
#                  pixels in (cols,rows)
#   idx         -> index of pixels in imout

# Copyright (C) 1999 Andy Adler
# This code has no warrany whatsoever.
# Do what you like with this code as long as you
#     leave this copyright in place.
#
# $Id$

if nargin<4
   connect= 8;
end

[jnk,idx]= bwfill( ~im, cols,rows, connect );

imout= zeros( size(jnk) );
imout( idx ) = 1;

# 
# $Log$
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

