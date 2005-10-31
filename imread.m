## Copyright (C) 2002 Andy Adler
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version. USE THIS SOFTWARE AT YOUR OWN RISK.

## usage: I = imread(fname)
##
## Read images from various file formats.
##
##   The size and numeric class of the output depends on the
##   format of the image.  A colour image is returned as an
##   MxNx3 matrix.  Grey-level and black-and-white images are
##   of size MxN.
##     The colour depth of the image determines the numeric
##   class of the output: 'uint8' or 'uint16' for grey
##   and colour, and 'logical' for black and white.
##
##   Note: For image formats other than jpeg and png, the
##         ImageMagick "convert" and "identify" utilities
##         are needed. ImageMagick can be found at
##
##         www.imagemagick.org
##

## Author: Andy Adler
##
## Modified: Stefan van der Walt <stefan@sun.ac.za>
## Date: 24 January 2005

function varargout = imread(filename, varargin)
    if (nargin != 1)
	usage("I = imread(filename)")
    endif

    if !isstr(filename)
	error("imread: filename must be a string")
    endif

    fn = file_in_path(IMAGEPATH, filename);
    if isempty(fn)
	error("imread: cannot find %s", filename);
    endif


    [ig, ig, ext] = fileparts(fn);
    ext = upper(ext);
    if ( file_in_loadpath("__magick_read__.oct") )
        varargout{:} = __magick_read__(fn, varargin{:});
        break
    endif
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

    [ident, sys] = system(sprintf('identify -verbose %s | grep -e "Red: " -e Type',
				  fn));
    if (sys != 0)
	error("imread: error running ImageMagick's 'identify' on %s", fn)
    endif
    depth = re_grab("Red: ([[:digit:]]{1,2})", ident);
    imtype = re_grab("Type: ([[:alpha:]]*)", ident);

    depth = str2num(depth);
    if isempty(depth) || (pow2(nextpow2(depth)) != depth)
	error("imread: invalid image depth %s", depth)
    endif

    if !(strcmp(imtype, "Bilevel") || strcmp(imtype, "Grayscale") ||
	 strcmp(imtype, "TrueColor"))
	error("imread: unknown image type '%s'", imtype);
    endif

    switch (imtype)
	case("Bilevel")
	    fmt = "pgm";
	case("Grayscale")
	    fmt = "pgm";
	case("TrueColor")
	    fmt = "ppm";
    endswitch
    
    ## Why are pipes so slow?
    ##    cmd = sprintf("convert -flatten -strip %s %s:-", fn, fmt);
    
    tmpf = [tmpnam(), ".", fmt];
    cmd = sprintf("convert -flatten -strip +compress '%s' '%s' 2>/dev/null",
		  fn, tmpf);

    [ignored, sys] = system(cmd);    
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

    if (imtype == "TrueColor")
	channels = 3;
    else
	channels = 1;
    endif
    if (count != width*height*channels)
	error("imread: image data chunk has invalid size")
    endif

    varargout = {};
    switch (imtype)
 	case ("Bilevel")
 	    varargout{1} = logical(reshape(data, width, height)');
 	case ("Grayscale") 
 	    varargout{1} = uint8(reshape(data, width, height)');
 	case ("TrueColor")
 	    varargout{1} = cat(3, reshape(data(1:3:end), width, height)',
 			       reshape(data(2:3:end), width, height)',
 			       reshape(data(3:3:end), width, height)');
 	    eval(sprintf("varargout{1} = uint%d(varargout{1});", depth));
		
    endswitch
endfunction

function value = re_grab(re, str)
    idx = regexp(re, str);
    if !isempty(idx)
	idx = idx(2,:);
	value = substr(str, idx(1), diff(idx)+1);	
    else
	value = "";
    endif    
endfunction
