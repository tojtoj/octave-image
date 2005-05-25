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

## [h,w] = imginfo (filename) - Get image size from file
##  hw   = imginfo (filename)
## 
## filename : string : Name of image file
##
## h        : 1      : Height of image, in pixels
## w        : 1      : Width  of image, in pixels
##    or
## hw=[h,w] : 2      : Height and width of image 
##
## NOTE : imginfo relies on the 'convert' program.

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: Setembro 2002

function [h,w] = imginfo (fn)

[res,status] = system(sprintf("convert -verbose '%s' /dev/null",fn),1);

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
