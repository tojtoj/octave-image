## Copyright (C) 2002 Andy Adler
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version. USE THIS SOFTWARE AT YOUR OWN RISK.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{I} =} imread(@var{filename})
## Read images from various file formats.
##
## The size and numeric class of the output depends on the
## format of the image.  A colour image is returned as an
## MxNx3 matrix.  Grey-level and black-and-white images are
## of size MxN.
## The colour depth of the image determines the numeric
## class of the output: 'uint8' or 'uint16' for grey
## and colour, and 'logical' for black and white.
##
## Note: For image formats other than jpeg and png, the
## ImageMagick "convert" and "identify" utilities
## are needed. ImageMagick can be found at www.imagemagick.org
## @end deftypefn

## Author: Andy Adler
##
## Modified: Stefan van der Walt <stefan@sun.ac.za>
## Date: 24 January 2005
##
## Modified: Thomas Weber <thomas.weber.mail@gmail.com>
## Date: 20 December 2006
## Change parsing of imagemagick's output to get the 'color' depth for grayscale
## images
##
## Modified Kristian Rumberg <kristianrumberg@gmail.com>
## Date 2 April 2008
## Imread now works with BMP's created with "convert inputimage out.bmp"
## (tested with stable release Octave 3.0 in GNU/Linux and Windows XP),
## modified the calling parameters to identify and convert

function varargout = imread(filename, varargin)
    if (nargin != 1)
      usage("I = imread(filename)")
    endif

    if !ischar (filename)
      error("imread: filename must be a string")
    endif

    filename = tilde_expand(filename);
    fn = file_in_path(IMAGE_PATH, filename);
    if isempty(fn)
      error("imread: cannot find %s", filename);
    endif


    [ig, ig, ext] = fileparts(fn);
    ext = upper(ext);    
    
    ## divert jpegs and pngs to "jpgread" and "pngread"
    if ( file_in_loadpath("jpgread.oct") &&
      (strcmp(ext, ".JPG") || strcmp(ext, ".JPEG")) )
      varargout{1} = jpgread(fn);
      break
    endif
    if ( file_in_loadpath("pngread.oct") && (strcmp(ext, ".PNG")) )
      varargout{1} = pngread(fn);
      break
    endif
    
    ## alternately, use imagemagick
    if ( file_in_loadpath("__magick_read__.oct") )
      [varargout{1:nargout}] = __magick_read__(fn, varargin{:});
      break
    endif
    
    [sys, ident] = system(sprintf('identify -verbose \"%s\" | grep -e "bit" -e Type', fn));
    if (sys != 0)
      error("imread: error running ImageMagick's 'identify' on %s", fn);
    endif
    depth = re_grab("([[:digit:]]{1,2})-bit", ident);
    imtype = re_grab("Type: ([[:alpha:]]*)", ident);

    depth = str2num(depth);
    if isempty(depth) || (pow2(nextpow2(depth)) != depth)
      error("imread: invalid image depth %s", depth);
    endif

    if !( strcmp(imtype, "Bilevel")   || strcmp(imtype, "Grayscale") ||
          strcmp(imtype, "TrueColor") || strcmp(imtype, "TrueColorMatte") ||
          strcmp(imtype, "Palette") )
      error("imread: unknown image type '%s'", imtype);
    endif

    switch (imtype)
    case {"Bilevel"}
      fmt = "pgm";
    case {"Grayscale"}
      fmt = "pgm";
    case {"TrueColor", "TrueColorMatte", "Palette"}
      fmt = "ppm";
    endswitch
    
    ## Why are pipes so slow?
    ##    cmd = sprintf("convert -flatten -strip %s %s:-", fn, fmt);
    
    tmpf = [tmpnam(), ".", fmt];
    ##cmd = sprintf("convert -flatten -strip +compress '%s' '%s' 2>/dev/null",
    ##		  fn, tmpf);
    cmd = sprintf("convert -strip \"%s\" \"%s\"", fn, tmpf);

    sys = system(cmd);    
    if (sys != 0)
      error("imread: error running ImageMagick's 'convert'");
      unlink(tmpf);
    endif

    try
      fid = fopen(tmpf, "rb");
    catch
      unlink(tmpf);
      error("imread: could not open temporary file %s", tmpf)
    end_try_catch

    fgetl(fid); # P5 or P6 (pgm or ppm)
    [width, height] = sscanf(fgetl(fid), "%d %d", "C");
    fgetl(fid); # ignore max components

    if (depth == 16)
	## PGM format has MSB first, i.e. big endian
	[data, count] = fread(fid, "uint16", 0, "ieee-be");
    else
      [data, count] = fread(fid, "uint8");
    endif
    
    fclose(fid);
    unlink(tmpf);

    if (any(strcmp(imtype, {"TrueColor", "TrueColorMatte", "Palette"})))
      channels = 3;
    else
      channels = 1;
    endif
    if (count != width*height*channels)
      error("imread: image data chunk has invalid size %i != %i*%i*%i == %i",
	    count, width, height, channels, width*height*channels);
    endif

    varargout = {};
    switch (imtype)
 	case {"Bilevel"}
      varargout{1} = logical(reshape(data, width, height)');
 	case {"Grayscale"}
      varargout{1} = uint8(reshape(data, width, height)');
 	case {"TrueColor", "TrueColorMatte", "Palette"}
      varargout{1} = cat(3, reshape(data(1:3:end), width, height)',
                            reshape(data(2:3:end), width, height)',
                            reshape(data(3:3:end), width, height)');
      eval(sprintf("varargout{1} = uint%d(varargout{1});", depth));
    endswitch
endfunction

function value = re_grab(re, str)
  T = regexp(str,re,'tokens');
  if (isempty(T))
    value = "";
  else
    value = T{1}{1};
  endif
endfunction
