 //
 // This is a hack into octave 
 //   based on jpgread.c by jpgread by Drea Thomas, The Mathworks and the
 //        examples in the IJG distribution. 
 //
 // (C) 1998 Andy Adler. This code is in the public domain
 // USE THIS CODE AT YOUR OWN RISK 
 //
 // $Id$                                     
 //

/* Modified: Stefan van der Walt <stefan@sun.ac.za>
 * Date: 27 January 2004
 * - Manual error handler to prevent segfaults in Octave.
 * - Use uint8NDArray for output.
 */

/*
 * Compilation:
 * First, try
 *   mkoctfile jpgread.cc -ljpeg
 *
 * If this doesn't work, install the jpeg library which is part of
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from
 *
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 *
 * Extract and build the library:
 * tar xvfz jpegsrc.v6.tar.gz
 * cd jpeg-6b
 * ./configure
 * make
 * make test
 *
 * Compile this file using:
 * mkoctfile jpgread.cc -I<jpeg-6b include dir> -L<jpeg-6b lib dir> -ljpeg
 */

#include <octave/oct.h>
#include <iostream>
#include <csetjmp>

#ifdef __cplusplus
extern "C" {
#endif

#include "jpeglib.h"

#ifdef __cplusplus
} //extern "C"
#endif

struct oct_error_mgr {
    struct jpeg_error_mgr pub;    /* "public" fields */
    jmp_buf setjmp_buffer;        /* for return to caller */
};

typedef struct oct_error_mgr * oct_error_ptr;

METHODDEF(void)
oct_error_exit (j_common_ptr cinfo)
{
    /* cinfo->err really points to an oct_error_mgr struct, so coerce pointer */
    oct_error_ptr octerr = (oct_error_ptr) cinfo->err;
    
    /* Format error message and send to interpreter */
    char errmsg[JMSG_LENGTH_MAX];
    (octerr->pub.format_message)(cinfo, errmsg);
    error("jpgread: %s", errmsg);
    
    /* Return control to the setjmp point */
    longjmp(octerr->setjmp_buffer, 1);
}

DEFUN_DLD (jpgread, args, nargout ,
"usage: I = jpgread('filename')\n\
\n\
  Read a JPEG file from disk.\n\
\n\
  For a grey-level image, the output is an MxN matrix. For a\n\
  colour image, three such matrices are returned (MxNx3),\n\
  representing the red, green and blue components. The output\n\
  is of class 'uint8'.\n\
\n\
  See also: imread, im2double, im2gray, im2rgb.")
{ 
    octave_value_list retval;
    int nargin  = args.length();
    
    FILE * infile;
    
    JSAMPARRAY buffer;
    long row_stride;
    struct jpeg_decompress_struct cinfo;
    struct oct_error_mgr jerr;

    //
    // We bail out if the input parameters are bad
    //
    if ((nargin != 1) || !args(0).is_string() || (nargout != 1)) {
	print_usage ();
	return retval;
    }    
    
    //
    // Open jpg file
    //
    std::string filename = args(0).string_value();
    if ((infile = fopen(filename.c_str(), "rb")) == NULL) {
	error("jpgread: couldn't open file %s", filename.c_str());
	return retval;
    }
    
    //
    // Initialize the jpeg library
    //
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = oct_error_exit;
    if (setjmp(jerr.setjmp_buffer)) {
	/* If we get here, the JPEG code has signaled an error.
	 * We need to clean up the JPEG object, close the input file, and return.
	 */
	jpeg_destroy_decompress(&cinfo);
	fclose(infile);
	return retval;
    }
    
    jpeg_create_decompress(&cinfo);
    
    //
    // Read the jpg header to get info about size and color depth
    //
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, TRUE);
    jpeg_start_decompress(&cinfo);
    
    //
    // Allocate buffer for one scan line
    //
    row_stride = cinfo.output_width * cinfo.output_components;
    buffer = (*cinfo.mem->alloc_sarray)
	((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
    
    //
    // Create an NDArray for the output.  Loop through each of the
    // scanlines and copy the image data from the buffer.
    //
    
    dim_vector dim = dim_vector();
    dim.resize(3);
    dim(0) = cinfo.output_height;
    dim(1) = cinfo.output_width;
    dim(2) = cinfo.output_components;
    uint8NDArray out = uint8NDArray(dim, 0);
    
    Array<int> coord = Array<int> (3);
    for (unsigned long j=0; cinfo.output_scanline < cinfo.output_height; j++) {
	jpeg_read_scanlines(&cinfo, buffer, 1);
	
	coord(0) = j;
	for (unsigned long i=0; i<cinfo.output_width; i++) {
	    coord(1) = i;
	    for (unsigned int c = 0; c < cinfo.output_components; c++) {
		coord(2) = c;
		out(coord) = buffer[0][i*cinfo.output_components+c];
	    }
	}
    }
    retval.append(out.squeeze());
    
    //
    // Clean up
    //
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);
    
    return retval;
}
