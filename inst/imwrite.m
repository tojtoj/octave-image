## Copyright (C) 2002 Andy Adler
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version. USE THIS SOFTWARE AT YOUR OWN RISK.

## -*- texinfo -*-
## @deftypefn {Function File} imwrite(@var{fname}, @var{img})
## Write image from octave to various file formats
##
## Note: this requires the ImageMagick "convert" utility.
## get this from www.imagemagick.org if required
## additional documentation of options is available from the
## convert man page.
##
## @deftypefnx{Function File} imwrite(@var{fname}, @var{img})
## @var{img} is a greyscale (0-255) of image in fname.
## @deftypefnx{Function File} imwrite(@var{fname}, @var{img}, @var{map})
## @var{map} is a matrix of [r,g,b], 0-1 triplesm and
## @var{img} is a matrix on indeces into map.
## @deftypefnx{Function File} imwrite(@var{fname}, @var{r}, @var{g}, @var{b});
## @var{r}, @var{g}, @var{b} are red, green, blue (0-255) compondents.
##
## Formats for image fname
## @enumerate
## @item
## Simple guess from extention, i.e. "fig.jpg", "blah.gif".
## @item
## Specify explicitly, i.e. "jpg:fig.jpg", "gif:blah.gif".
## @item
## Specify subimage for multi-image format: "tiff:file.tif[3]".
## @item
## Raw images (row major format) specify geometry: "raw:img[256x180]".
## @end enumerate
##
## @deftypefnx{Function File} imwrite(@var{fname}, @var{img}, @var{options})
## @deftypefnx{Function File} imwrite(@var{fname}, @var{img}, @var{map}, @var{options})
## @deftypefnx{Function File} imwrite(@var{fname}, @var{r}, @var{g}, @var{b}, @var{options});
## It is possible to give extra options to imwrite, for example:
## @example
## options= ["-rotate 25";
##           "-crop 200x200+150+150";
##           "-sample 200%" ];
## @end example
## will rotate, crop, and then expand the image.
## note that the order of operations is important
##
## The following options are supported
## @table @code
## @item -antialias
## remove pixel-aliasing
## @item  -background color
## background color
## @item  -blur geometry
## blur the image
## @item  -border geometry
## surround image with a border of color
## @item  -bordercolor color
## border color
## @item  -box color
## color for annotation bounding box
## @item  -charcoal radius
## simulate a charcoal drawing
## @item  -colorize value
## colorize the image with the fill color
## @item  -colors value
## preferred number of colors in the image
## @item  -colorspace type
## alternate image colorspace
## @item  -comment string
## annotate image with comment
## @item  -compress type
## type of image compression
## @item  -contrast
## enhance or reduce the image contrast
## @item  -crop geometry
## preferred size and location of the cropped image
## @item  -density geometry
## vertical and horizontal density of the image
## @item  -depth value
## depth of the image
## @item  -despeckle
## reduce the speckles within an image
## @item  -dispose method
## GIF disposal method
## @item  -dither
## apply Floyd/Steinberg error diffusion to image
## @item  -draw string
## annotate the image with a graphic primitive
## @item  -edge radius
## apply a filter to detect edges in the image
## @item  -emboss radius
## emboss an image
## @item  -enhance
## apply a digital filter to enhance a noisy image
## @item  -equalize
## perform histogram equalization to an image
## @item  -fill color
## color to use when filling a graphic primitive
## @item  -filter type
## use this filter when resizing an image
## @item  -flip
## flip image in the vertical direction
## @item  -flop
## flop image in the horizontal direction
## @item  -font name
## font for rendering text
## @item  -frame geometry
## surround image with an ornamental border
## @item  -fuzz distance
## colors within this distance are considered equal
## @item  -gamma value
## level of gamma correction
## @item  -geometry geometry
## perferred size or location of the image
## @item  -gaussian geometry
## gaussian blur an image
## @item  -gravity type
## vertical and horizontal text placement
## @item  -implode amount
## implode image pixels about the center
## @item  -intent type
## Absolute, Perceptual, Relative, or Saturation
## @item  -interlace type
## None, Line, Plane, or Partition
## @item  -label name
## assign a label to an image
## @item  -level value
## adjust the level of image contrast
## @item  -list type
## Color, Delegate, Format, Magic, Module, or Type
## @item  -map filename
## transform image colors to match this set of colors
## @item  -matte
## store matte channel if the image has one
## @item  -median radius
## apply a median filter to the image
## @item  -modulate value
## vary the brightness, saturation, and hue
## @item  -monochrome
## transform image to black and white
## @item  -morph value
## morph an image sequence
## @item  -negate
## replace every pixel with its complementary color 
## @item  -noise radius
## add or reduce noise in an image
## @item  -normalize
## transform image to span the full range of colors
## @item  -opaque color
## change this color to the fill color
## @item  -page geometry
## size and location of an image canvas
## @item  -paint radius
## simulate an oil painting
## @item  -profile filename
## add ICM or IPTC information profile to image
## @item  -quality value
## JPEG/MIFF/PNG compression level
## @item  -raise value
## lighten/darken image edges to create a 3-D effect
## @item  -region geometry
## apply options to a portion of the image
## @item  -roll geometry
## roll an image vertically or horizontally
## @item  -rotate degrees
## apply Paeth rotation to the image
## @item  -sample geometry
## scale image with pixel sampling
## @item  -scale geometry
## resize image
## @item  -segment values
## segment an image
## @item  -seed value
## pseudo-random number generator seed value
## @item  -shade degrees
## shade the image using a distant light source
## @item  -sharpen geometry
## sharpen the image
## @item  -shave geometry
## shave pixels from the image edges
## @item  -shear geometry
## slide one edge of the image along the X or Y axis
## @item  -size geometry
## width and height of image
## @item  -solarize threshold
## negate all pixels above the threshold level
## @item  -spread amount
## displace image pixels by a random amount
## @item  -stroke color
## color to use when stoking a graphic primitive
## @item  -strokewidth value
## width of stroke
## @item  -swirl degrees
## swirl image pixels about the center
## @item  -texture filename
## name of texture to tile onto the image background
## @item  -threshold value
## threshold the image
## @item  -tile filename
## tile image when filling a graphic primitive
## @item  -transparent color
## make this color transparent within the image
## @item  -treedepth value
## depth of the color tree
## @item  -type type
## image type
## @item  -units type
## PixelsPerInch, PixelsPerCentimeter, or Undefined
## @item  -unsharp geometry
## sharpen the image
## @end table
## @end deftypefn

function imwrite(fname, p2, p3 ,p4 ,p5 );

try save_empty_list_elements_ok= empty_list_elements_ok;
catch save_empty_list_elements_ok= 0;
end
try save_warn_empty_list_elements= warn_empty_list_elements;
catch save_warn_empty_list_elements= 0;
end
unwind_protect
empty_list_elements_ok= 1;
warn_empty_list_elements= 0;

# some older versions of octave didn't seem handle piped output correctly
usepipe=1;

# Support matlabs input order
if (nargin >= 2 && ismatrix(fname) && ischar(p2))
  tmp = p2;
  p2 = fname;
  fname = tmp;
endif

if  ( nargin <= 1 )     || ...
    ( ! ischar (fname))  || ...
    ( nargin == 2 && ischar(p2) )
    usage([ ...
    "imwrite( fname, img )\n", ...
    "imwrite( fname, img, map )\n", ...
    "imwrite( fname, r,g,b );\n", ...
    "imwrite( fname, img, options )\n", ...
    "imwrite( fname, img, map, options )\n", ...
    "imwrite( fname, r,g,b, options );\n"]);
endif

fname = tilde_expand(fname);

# Put together the options string
# TODO: add some error checking to options
option_str="";
n_mat= nargin-1;

options= eval(sprintf("p%d",nargin));
# process options strings if given
if    ischar(options)
   n_mat--;
   for i= 1:size(options,1)
      option_str=[option_str," ", options(i,:) ];
   end
elseif is_list( options )
   n_mat--;
   for i= 1:length(options)
      option_str=[option_str," ", nth(options,i) ];
   end
end

[hig,wid] = size(p2);
if n_mat==1
   data= p2';
   outputtype="pgm";
   pnm_sig="P5";
elseif n_mat==2
   img= p2';
   data= [ reshape(p3(img,1),1, hig*wid);
           reshape(p3(img,2),1, hig*wid);
           reshape(p3(img,3),1, hig*wid) ];
   outputtype="ppm";
   pnm_sig="P6";
elseif n_mat==3
   data= [ reshape(p2',1, hig*wid);
           reshape(p3',1, hig*wid);
           reshape(p4',1, hig*wid) ];
   outputtype="ppm";
   pnm_sig="P6";
else
   error("imwrite: too many data matrices specified");
end

# Scale data depending on data type
switch(class(data))
case "double"
  data *= 255;
case "uint8"
case "uint16"
  data /= 255;
otherwise
  error("imwrite: unsupported data type %s", class(data));
endswitch

if usepipe
   pname= sprintf("convert %s %s:- '%s' 2>/dev/null",
                  option_str, outputtype, fname);
   fid= popen(pname ,'w');

   if fid<0;
      error('could not create image data. Is ImageMagick installed?');
   end
else
   tnam= tmpnam();
   cmd= sprintf("convert %s '%s:%s' '%s' 2>/dev/null",
                 option_str, outputtype, tnam, fname);
   fid= fopen(tnam, "wb");
end   

   fprintf(fid,"%s\n%d %d\n255\n",pnm_sig,wid,hig);
   write_count= fwrite(fid,data(:));
   if write_count != prod(size(data))
      fclose(fid);
      if ~usepipe
         unlink(tnam);
      end
      error(['Problem writing image: ', fname ]);
   end

   fclose(fid);
   if ~usepipe
      retcode = system(cmd);
      if retcode !=0 
         error('could not call imagemagick convert');
      end
      unlink( tnam );
   end

unwind_protect_cleanup
empty_list_elements_ok= save_empty_list_elements_ok;
warn_empty_list_elements= save_warn_empty_list_elements;
end_unwind_protect

#
# $Log$
# Revision 1.3  2007/01/02 21:58:38  hauberg
# Documentation is now in Texinfo (looks better on the website)
#
# Revision 1.2  2006/11/26 10:47:39  hauberg
# Compatibility changes
#
# Revision 1.1  2006/08/20 12:59:34  hauberg
# Changed the structure to match the package system
#
# Revision 1.11  2006/03/22 17:50:47  qspencer
# Change calls to 'system' function to reflect new ordering of output arguments.
#
# Revision 1.10  2005/09/08 02:00:17  pkienzle
# [for Bill Denney] isstr -> ischar
#
# Revision 1.9  2005/07/21 16:03:02  aadler
# Improve error messages and use pipes
#
# Revision 1.8  2005/05/25 03:43:40  pkienzle
# Author/Copyright consistency
#
# Revision 1.7  2005/04/25 01:05:28  aadler
# added GPL copyrights
#
# Revision 1.6  2003/09/12 14:22:42  adb014
# Changes to allow use with latest CVS of octave (do_fortran_indexing, etc)
#
# Revision 1.5  2003/07/25 19:11:41  pkienzle
# Make sure all files names referenced in system calls are wrapped in quotes
# to protect against spaces in the path.
#
# Revision 1.4  2002/11/27 08:40:11  pkienzle
# author/license updates
#
# Revision 1.3  2002/03/19 18:14:13  aadler
# unfortunately using popen seems to create problems, mostly
# on win32, but also on linux, so we need to move to a tmpfile approach
#
# Revision 1.2  2002/03/17 05:26:14  aadler
# now accept filenames with spaces
#
# Revision 1.1  2002/03/11 01:56:47  aadler
# general image read/write functionality using imagemagick utilities
#
#
