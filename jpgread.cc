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

#include <octave/oct.h>
#include <iostream.h>

/*
 * Simple jpeg reading MEX-file. 
 *
 * Compilation:
 * First, try
 *   mkoctfile jpgread.cc -ljpeg
 *
 * If this doesn't work, then do
 *
 * Calls the jpeg library which is part of 
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from,
 *
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 * tar xvfz jpegsrc.v6.tar.gz
 * cd jpeg-6b
 * ./configure
 * make
 * make test
 * mkoctfile jpgread.cc -I<jpeg-6b include> -L<jpeg-6b lib> -ljpeg
 */

#ifdef __cplusplus
extern "C" {
#endif

#include "jpeglib.h"

#ifdef __cplusplus
} //extern "C"
#endif

DEFUN_DLD (jpgread, args, nargout ,
"JPGREAD Read a JPEG file from disk. \n\
       [R,G,B] = jpgread('filename') reads the specified file \n\
       and returns the Red, Green, and Blue intensity matrices.\n\
\n\
       [X] = jpgread('filename') reads the specified file \n\
       and returns the average intensity matrix.")
{ 
   octave_value_list retval;
   int nargin  = args.length();

   FILE * infile;

   JSAMPARRAY buffer;
   long row_stride;
   struct jpeg_decompress_struct cinfo;
   struct jpeg_error_mgr jerr;

//
// We bail out if the input parameters are bad
//
   if (nargin != 1 || !args(0).is_string() ) {
      print_usage ("jpgread");
      return retval;
   }

   if (nargout != 1 && nargout != 3 ) {
      print_usage ("jpgread");
      return retval;
   }

//
// Open jpg file
//
   string filename = args(0).string_value();
   if ((infile = fopen(filename.c_str(), "rb")) == NULL) {
      error("Couldn't open file");
      return retval;
   }

//
// Initialize the jpeg library
//
   cinfo.err = jpeg_std_error(&jerr);
   jpeg_create_decompress(&cinfo);

//
// Read the jpg header to get info about size and color depth
//
   jpeg_stdio_src(&cinfo, infile);
   jpeg_read_header(&cinfo, TRUE);
   jpeg_start_decompress(&cinfo);
   /*
   if (cinfo.output_components == 1) { // Grayscale 
      jpeg_destroy_decompress(&cinfo);
      error("Grayscale jpegs not supported");
   }
   */
  
//
// Allocate buffer for one scan line
//

   row_stride = cinfo.output_width * cinfo.output_components;
   buffer = (*cinfo.mem->alloc_sarray)
                 ((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);

//
// Create 3 matrices, One each for the Red, Green, and Blue component of the image.
// or create 1 matrix for the avg intensity
//
// Now, loop through each of the scanlines. For each, copy the image
// data from the buffer, convert to double.
//

   if (nargout == 3) {
      Matrix red   ( cinfo.output_height , cinfo.output_width );
      Matrix green ( cinfo.output_height , cinfo.output_width );
      Matrix blue  ( cinfo.output_height , cinfo.output_width );

      for (unsigned long j=0; cinfo.output_scanline < cinfo.output_height; j++) {
         jpeg_read_scanlines(&cinfo, buffer,1);
   
         if (cinfo.output_components == 1) { // Grayscale 
            for (unsigned long i=0; i<cinfo.output_width; i++) {
               red(j,i)   =
               green(j,i) =
               blue(j,i)  = (double) buffer[0][i*3+2];
            } // for i
	 } else { // not Grayscale
            for (unsigned long i=0; i<cinfo.output_width; i++) {
               red(j,i)   = (double) buffer[0][i*3+0];
               green(j,i) = (double) buffer[0][i*3+1];
               blue(j,i)  = (double) buffer[0][i*3+2];
            } // for i
	 } // not grayscale
      } //for j

      retval(0)= red;
      retval(1)= green;
      retval(2)= blue;

   } // if nargout==3
   else {
      Matrix avg   ( cinfo.output_height , cinfo.output_width );

      for (unsigned long j=0; cinfo.output_scanline < cinfo.output_height; j++) {
         jpeg_read_scanlines(&cinfo, buffer,1);
   
         if (cinfo.output_components == 1) { // Grayscale 
            for (unsigned long i=0; i<cinfo.output_width; i++) {
               avg(j,i)   = (double) buffer[0][i];
            } // for i
	 } else { // not Grayscale
            for (unsigned long i=0; i<cinfo.output_width; i++) {
               avg(j,i)   = ((double) buffer[0][i*3+0] +
                                         buffer[0][i*3+1] +
                                         buffer[0][i*3+2] ) / 3;
            } // for i
	} // not Grayscale
      } //for j

      retval(0)= avg;
   } // if nargout

//
// Clean up
//
   jpeg_finish_decompress(&cinfo);
   jpeg_destroy_decompress(&cinfo);
   fclose(infile);
   
   return retval;
};
