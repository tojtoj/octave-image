#IMREAD: read images into octave from various file formats
#
# Note: this requires the ImageMagick "convert" utility
#       get this from www.imagemagick.org if required
#       additional documentation of options is available from the
#       convert man page
#
# BASIC USAGE:
# img    = imread( fname )
#                 - img is a greyscale (0-255) of image in fname
# [im,map]=imread( fname )
#                 - map is a matrix of [r,g,b], 0-1 triples
#                 - img is a matrix on indeces into map
# [r,g,b]= imread( fname )
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
# img    = imread( fname , options)
# [r,g,b]= imread( fname , options)
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
#  -blur geometry       blur the image
#  -border geometry     surround image with a border of color
#  -bordercolor color   border color
#  -colors value        maximum number of colors in the image
#  -colorspace type     alternate image colorspace
#  -contrast            enhance or reduce the image contrast
#  -crop geometry       preferred size and location of the cropped image
#  -despeckle           reduce the speckles within an image
#  -dither              apply Floyd/Steinberg error diffusion to image
#  -draw string         annotate the image with a graphic primitive
#  -edge radius         apply a filter to detect edges in the image
#  -emboss radius       emboss an image
#  -enhance             apply a digital filter to enhance a noisy image
#  -equalize            perform histogram equalization to an image
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
#  -level value         adjust the level of image contrast
#  -map filename        transform image colors to match this set of colors
#  -median radius       apply a median filter to the image
#  -modulate value      vary the brightness, saturation, and hue
#  -monochrome          transform image to black and white
#  -mosaic              create an mosaic from an image sequence
#  -negate              replace every pixel with its complementary color
#  -noise radius        add or reduce noise in an image
#  -normalize           transform image to span the full range of colors
#  -paint radius        simulate an oil painting
#  -raise value         lighten/darken image edges to create a 3-D effect
#  -region geometry     apply options to a portion of the image
#  -roll geometry       roll an image vertically or horizontally
#  -rotate degrees      apply Paeth rotation to the image
#  -sample geometry     scale image with pixel sampling
#  -scale geometry      resize image
#  -scene value         image scene number
#  -segment values      segment an image
#  -seed value          pseudo-random number generator seed value
#  -shade degrees       shade the image using a distant light source
#  -sharpen geometry    sharpen the image
#  -shave geometry      shave pixels from the image edges
#  -shear geometry      slide one edge of the image along the X or Y axis
#  -size geometry       width and height of image
#  -solarize threshold  negate all pixels above the threshold level
#  -spread amount       displace image pixels by a random amount
#  -swirl degrees       swirl image pixels about the center
#  -texture filename    name of texture to tile onto the image background
#  -threshold value     threshold the image
#  -transparent color   make this color transparent within the image
#  -treedepth value     depth of the color tree
#  -type type           image type
#  -unsharp geometry    sharpen the image
#  -wave geometry       alter an image along a sine wave

# Author: Andy Adler

function [out1,out2,out3]= imread(filename, options );

save_empty_list_elements_ok= empty_list_elements_ok;
unwind_protect
empty_list_elements_ok= 1;

if (nargin == 0)
  usage (["img    =  imread (filename,options)\n", ...
          "[r,g,b]=  imread (filename,options)\n", ...
          "[img,map]=imread (filename,options)" ]);
elseif (! isstr (filename))
  error ("imread: expecting filename as a string");
endif

if any(filename==':') || any(filename=='[')
   # we've using special imagemagick characters, so we don't
   # do any octave path processing
   fname= filename;
else
   fname= file_in_path(IMAGEPATH,filename);
   if isempty(fname)
      error(['imread: file ' filename ' not found']);
   end
end

# Put together the options string
# TODO: add some error checking here
if nargin==1
   option_str="";
else
   option_str="";
   if     ( is_list( options ) )
      for i= 1:length(options)
         option_str=[option_str," ", nth(options,i) ];
      end
   elseif ( isstr( options ) )
      for i= 1:size(options,1)
         option_str=[option_str," ", options(i,:) ];
      end
   else
     error ("imread: expecting options as a string");
   end
end
#
# decode the nargout to output what the user wants
#
if     nargout==3;
    wantgreyscale= 0;
    wantmap= 0;
    outputtype="ppm";
elseif nargout==2;
    wantgreyscale= 0; wantmap= 1;
    outputtype="ppm";
else
    wantgreyscale= 1; wantmap= 0;
    outputtype="pgm";
end

#  pname= sprintf("convert %s '%s' %s:- 2>/dev/null",
#  pname= sprintf("convert %s '%s' %s:- ",
#                 option_str, fname, outputtype);
#  fid= popen(pname ,'r');
#  disp(pname); disp(fid);

   tnam= tmpnam();
   cmd= sprintf("convert %s '%s' %s:%s 2>/dev/null ",
                  option_str, fname, outputtype, tnam);
   system(cmd);
   fid= fopen(tnam,"rb");
#
# can we open the pipe?
# if not 1) The file format is wrong and the conver program has bailed out
#        2) The apropriate converter program hasn't been installed
#
   if fid<0;
      unlink(tnam);
      error(['could not read file: ' tnam]);
   end

# get file type
   line= fgetl( fid );
   if     strcmp(line, 'P1');   bpp=1; spp=1; bindata=0;
   elseif strcmp(line, 'P4');   bpp=1; spp=1; bindata=1;
   elseif strcmp(line, 'P2');   bpp=8; spp=1; bindata=0;
   elseif strcmp(line, 'P5');   bpp=8; spp=1; bindata=1;
   elseif strcmp(line, 'P3');   bpp=8; spp=3; bindata=0;
   elseif strcmp(line, 'P6');   bpp=8; spp=3; bindata=1;
   else
#     pclose(fid);
      fclose(fid); unlink(tnam);
      error(['Image format error for ',fname,':line=', setstr(line)]);
   end

# ignore comments
   line= fgetl( fid );
   while length(line)==0 || line(1)=='#'
      line= fgetl( fid );
   end

# get width, height
   [wid, hig]= sscanf( line, '%d %d', 'C' );

# get max component value
   if bpp==8
      max_component= sscanf( fgetl(fid), '%d' );
   end

   if bindata
      data= fread(fid);
      numdata= size(data,1);

      if bpp==1
         data= rem( floor( (data*ones(1,8)) ./ ...
                 (ones(length(data),1)*[128 64 32 16 8 4 2 1]) ), 2)';
      end
   else
      numdata= wid*hig*spp;
      data= zeros( numdata,1 );
      dptr= 1;

         line= fgetl( fid );
      while !feof( fid)
         rdata= sscanf( line ,' %d');
         nptr= dptr + size(rdata,1);
         data( dptr:nptr-1 ) = rdata;
         dptr= nptr;
         line= fgetl( fid );
      end # feof
   end #if bindata

#  pclose(fid);
   fclose(fid); unlink(tnam);

   if spp==1
      greyimg= reshape( data(:), wid, hig )';
   elseif spp==3
      redimg= reshape( data(1:spp:numdata), wid, hig )';
      grnimg= reshape( data(2:spp:numdata), wid, hig )';
      bluimg= reshape( data(3:spp:numdata), wid, hig )';
   else
      error(sprintf("imread: don't know how to handle pnm with spp=%d",spp));
   end


#   This section outputs the image in the desired output format
# if the user requested the colour map, the we regenerate it from
# the image.
#
#   Of course, 1) This may result in huge colourmaps
#              2) The colourmap will not be in the same order as
#                   in the original file

if wantgreyscale

   if exist('greyimg')
      out1= greyimg;
   elseif exist('idximg')
      greymap= mean(map')';
      out1= reshape( greymap( idximg ) , size(idximg,1), size(idximg,2) );
   else
      out1= ( redimg+grnimg+bluimg ) / 3 ;
   end

elseif wantmap

   if exist('idximg')
      out1= idximg;
      out2= map;
   elseif exist('greyimg')
      [simg, sidx] = sort( greyimg(:) );
      [jnkval, sidx] = sort( sidx );

      dimg= [1; diff(simg)>0 ];
      cimg= cumsum( dimg );
      out1= reshape( cimg( sidx ) , hig, wid);
      out2= ( simg(find( dimg ))*[1,1,1] - 1)/256;
   else
#
# attempt to generate a colourmap for r,g,b images, assume range is 0<v<1000
# for each value ( This will also be inaccurate for noninteger v )
# however, we shouldn't be getting any of that from the pnm converters
#
      c_range= 1000;
      [simg, sidx] = sort( round(redimg(:)) + ...
                  c_range *round(grnimg(:)) + ...
                c_range^2 *round(bluimg(:)) );
      [jnkval, sidx] = sort( sidx );

      dimg= [1; diff(simg)>0 ];
      cimg= cumsum( dimg );
      out1= reshape( cimg( sidx ) , hig, wid );
      tmpv= simg(find( dimg )) - (1 + c_range + c_range^2);
      out2= [ rem(tmpv,c_range), ...
              rem(floor(tmpv/c_range), c_range), ...
              floor(tmpv/c_range^2) ]/256;
   end


else

   if exist('greyimg')
      out1= greyimg;
      out2= greyimg;
      out3= greyimg;
   else
      out1= redimg;
      out2= grnimg;
      out3= bluimg;
   end

end

unwind_protect_cleanup
empty_list_elements_ok= save_empty_list_elements_ok;
end_unwind_protect

#
# $Log$
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
