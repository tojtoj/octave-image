## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##

## -*- texinfo -*-
## @deftypefn {Function File} {@var{hw} =} imginfo (@var{filename})
## @deftypefnx{Function File} {[@var{h}, @var{w}] =} imginfo (@var{filename})
## Get image size from file @var{filename}.
##
## The output is the size of the image
## @table @code
## @item @var{h}
## Height of image, in pixels.
## @item @var{w}
## Width  of image, in pixels.
## @item @var{hw} = [@var{h}, @var{w}]
## Height and width of image.
## @end table
##
## NOTE : imginfo relies on the 'convert' program.
## @end deftypefn

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: Setembro 2002

function [h,w] = imginfo (fn)

[status, res] = system(sprintf("convert -verbose '%s' /dev/null",fn),1);

if status,
  error (["imginfo : 'convert' exited with status %i ",\
	  "and produced\n%s\n"],\
	 status, res);
end

res = res(index(res," ")+1:length(res));

i = index (res,"x");
if ! i, error ("imginfo : Can't interpret string (i)\n%s\n", res); end

j = index (res(i-1:-1:1)," ");
if j<2, error ("imginfo : Can't interpret string (j)\n%s\n", res); end
w = str2num (res(i-j:i-1));

k = index (res(i+1:length(res))," ");
if k<2, error ("imginfo : Can't interpret string (k)\n%s\n", res); end
h = str2num (res(i+1:i+k));

if nargout<2, h = [h,w]; end
