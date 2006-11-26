## Copyright (C) 2002 Andy Adler
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version. USE THIS SOFTWARE AT YOUR OWN RISK.

#IMWRITE: write image from octave to various file formats
#
# Note: this requires the ImageMagick "convert" utility.
#       get this from www.imagemagick.org if required
#       additional documentation of options is available from the
#       convert man page
#
# BASIC USAGE:
# imwrite( fname, img )
#                 - img is a greyscale (0-255) of image in fname
# imwrite( fname, img, map )
#                 - map is a matrix of [r,g,b], 0-1 triples
#                 - img is a matrix on indeces into map
# imwrite( fname, r,g,b );
#                 - r,g,b are red,green,blue (0-255) compondents
#
# Formats for image fname
#   1. simple guess from extention ie "fig.jpg", "blah.gif"
#   2. specify explicitly             "jpg:fig.jpg", "gif:blah.gif"
#   3. specify subimage for multi-image format "tiff:file.tif[3]"
#   4. raw images (row major format) specify geometry
#                                      "raw:img[256x180]"
#
# IMREAD OPTIONS:
# imread will support most of the options for convert.1
#
# imwrite( fname, img, options )
# imwrite( fname, img, map, options )
# imwrite( fname, r,g,b, options );
#
# where options is a string matrix (or list) of options
#
# example:   options= ["-rotate 25";
#                      "-crop 200x200+150+150";
#                      "-sample 200%" ];
#   will rotate, crop, and then expand the image.
#   note that the order of operations is important
#
# The following options are supported
#  -antialias           remove pixel-aliasing
#  -background color    background color
#  -blur geometry       blur the image
#  -border geometry     surround image with a border of color
#  -bordercolor color   border color
#  -box color           color for annotation bounding box
#  -charcoal radius     simulate a charcoal drawing
#  -colorize value      colorize the image with the fill color
#  -colors value        preferred number of colors in the image
#  -colorspace type     alternate image colorspace
#  -comment string      annotate image with comment
#  -compress type       type of image compression
#  -contrast            enhance or reduce the image contrast
#  -crop geometry       preferred size and location of the cropped image
#  -density geometry    vertical and horizontal density of the image
#  -depth value         depth of the image
#  -despeckle           reduce the speckles within an image
#  -dispose method      GIF disposal method
#  -dither              apply Floyd/Steinberg error diffusion to image
#  -draw string         annotate the image with a graphic primitive
#  -edge radius         apply a filter to detect edges in the image
#  -emboss radius       emboss an image
#  -enhance             apply a digital filter to enhance a noisy image
#  -equalize            perform histogram equalization to an image
#  -fill color          color to use when filling a graphic primitive
#  -filter type         use this filter when resizing an image
#  -flip                flip image in the vertical direction
#  -flop                flop image in the horizontal direction
#  -font name           font for rendering text
#  -frame geometry      surround image with an ornamental border
#  -fuzz distance       colors within this distance are considered equal
#  -gamma value         level of gamma correction
#  -geometry geometry   perferred size or location of the image
#  -gaussian geometry   gaussian blur an image
#  -gravity type        vertical and horizontal text placement
#  -implode amount      implode image pixels about the center
#  -intent type         Absolute, Perceptual, Relative, or Saturation
#  -interlace type      None, Line, Plane, or Partition
#  -label name          assign a label to an image
#  -level value         adjust the level of image contrast
#  -list type           Color, Delegate, Format, Magic, Module, or Type
#  -map filename        transform image colors to match this set of colors
#  -matte               store matte channel if the image has one
#  -median radius       apply a median filter to the image
#  -modulate value      vary the brightness, saturation, and hue
#  -monochrome          transform image to black and white
#  -morph value         morph an image sequence
#  -negate              replace every pixel with its complementary color 
#  -noise radius        add or reduce noise in an image
#  -normalize           transform image to span the full range of colors
#  -opaque color        change this color to the fill color
#  -page geometry       size and location of an image canvas
#  -paint radius        simulate an oil painting
#  -profile filename    add ICM or IPTC information profile to image
#  -quality value       JPEG/MIFF/PNG compression level
#  -raise value         lighten/darken image edges to create a 3-D effect
#  -region geometry     apply options to a portion of the image
#  -roll geometry       roll an image vertically or horizontally
#  -rotate degrees      apply Paeth rotation to the image
#  -sample geometry     scale image with pixel sampling
#  -scale geometry      resize image
#  -segment values      segment an image
#  -seed value          pseudo-random number generator seed value
#  -shade degrees       shade the image using a distant light source
#  -sharpen geometry    sharpen the image
#  -shave geometry      shave pixels from the image edges
#  -shear geometry      slide one edge of the image along the X or Y axis
#  -size geometry       width and height of image
#  -solarize threshold  negate all pixels above the threshold level
#  -spread amount       displace image pixels by a random amount
#  -stroke color        color to use when stoking a graphic primitive
#  -strokewidth value   width of stroke
#  -swirl degrees       swirl image pixels about the center
#  -texture filename    name of texture to tile onto the image background
#  -threshold value     threshold the image
#  -tile filename       tile image when filling a graphic primitive
#  -transparent color   make this color transparent within the image
#  -treedepth value     depth of the color tree
#  -type type           image type
#  -units type          PixelsPerInch, PixelsPerCentimeter, or Undefined
#  -unsharp geometry    sharpen the image

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
