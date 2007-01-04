 // This is a hack into octave
 //   based on jpgwrite.c by jpgread by Drea Thomas, The Mathworks, and the
 //        examples in the IJG distribution.
 //
 // (C) 1998 Andy Adler. This code is in the public domain
 //  USE THIS CODE AT YOUR OWN RISK 
 //
 // $Id$                                     
 //                                                       

#include <octave/oct.h>
#include <iostream>

#ifdef __cplusplus
extern "C" {
#endif

#include "jpeglib.h"

#ifdef __cplusplus
} //extern "C"
#endif

#define GRAYIMAGES

/*
 * Simple jpeg writing MEX-file. 
 *
 * Synopsis:
 *   jpgwrite(filename,r,g,b,quality)
 *
 * Compilation:
 * First, try
 *   mkoctfile jpgwrite.cc -ljpeg
 *
 * If this doesn't work, then do
 *
 * Calls the jpeg library which is part of 
 * "The Independent JPEG Group's JPEG software" collection.
 *
 * The jpeg library came from,
 *
 * ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6.tar.gz
 */

DEFUN_DLD (jpgwrite, args, , "\
-*- texinfo -*-\n\
@deftypefn {Function File} jpgwrite(@var{filename}, @var{R}, @var{G}, @var{B}, @var{quality})\n\
@deftypefnx{Function File} jpgwrite(@var{filename}, @var{I}, @var{quality})\n\
Write a JPEG file to disc.\n\
\n\
If three matrices @var{R}, @var{G}, and @var{B} are given the function will write\n\
a color image to the disc, where @var{R} is the red channel, @var{G} the green channel,\n\
and @var{B} the blue channel of the image.\n\
\n\
If only one matrix @var{I} is given the function writes a gray-scale image to the disc.\n\
\n\
In all cases the data matrices should have integer values between 0 and 255.\n\
\n\
If specified, @var{quality} should be in the range 1-100 and will default to\n\
75 if not specified. 100 is best quality, and 1 is best compression.\n\
@seealso{jpgread, imwrite}\n\
@end deftypefn\n\
") {
   octave_value_list retval;
   int nargin  = args.length();

   FILE * outfile;

   JSAMPARRAY buffer;
   struct jpeg_compress_struct cinfo;
   struct jpeg_error_mgr jerr;
   int quality=75; //default value

//
// We bail out if the input parameters are bad
//
   if (nargin < 2 || !args(0).is_string() ) {
      print_usage ();
      return retval;
   }


//
// Open jpg file
//
   std::string filename = args(0).string_value();
   if ((outfile = fopen(filename.c_str(), "wb")) == NULL) {
      error("Couldn't open file");
      return retval;
   }

//
// Set Jpeg parameters
//
   if (nargin == 3) {
      quality= (int) args(2).double_value();
   } else if (nargin == 5) {
      quality= (int) args(4).double_value();
   }
  
//
// Initialize the jpeg library
// Read the jpg header to get info about size and color depth 
//
   cinfo.err = jpeg_std_error(&jerr);
   jpeg_create_compress(&cinfo);
   jpeg_stdio_dest(&cinfo, outfile);


//
// set parameters for compression
//
      
   if ( nargin <= 3 ) {
//
// we're here because only one matrix of grey scale values was provided
//
      Matrix avg= args(1).matrix_value();
      long image_width  = args(1).columns();
      long image_height = args(1).rows();


      cinfo.image_width = image_width; 	/* image width and height, in pixels */
      cinfo.image_height = image_height;
#ifdef GRAYIMAGES
      cinfo.input_components = 1;
      cinfo.input_components = JCS_GRAYSCALE;
#else
      cinfo.input_components = 3;
      cinfo.in_color_space = JCS_RGB;
#endif
      jpeg_set_defaults(&cinfo);
      jpeg_set_quality(&cinfo, quality, TRUE /* limit to baseline-JPEG values */);
//
//  start compressor
//
      jpeg_start_compress(&cinfo, TRUE);

//
// Allocate buffer for one scan line
//
      long row_stride = image_width * cinfo.input_components ;
      buffer = (*cinfo.mem->alloc_sarray)
      		((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
//
// Now, loop thru each of the scanlines. For each, copy the image
// data from the buffer, data must be [0 255]
//
      for( long j=0; cinfo.next_scanline < cinfo.image_height; j++) {
         for(unsigned long i=0; i<cinfo.image_width; i++) {
#ifdef GRAYIMAGES
            buffer[0][i] = (unsigned char) avg(j,i);
#else
            buffer[0][i*3+0] = (unsigned char) avg(j,i);
            buffer[0][i*3+1] = (unsigned char) avg(j,i);
            buffer[0][i*3+2] = (unsigned char) avg(j,i);
#endif
         }
         jpeg_write_scanlines(&cinfo, buffer,1);
      }

   } // if nargin <= 3
   else {
//
// we're here because red green and blue matrices were provided
//  we assume that they're the same size
//
      Matrix red  = args(1).matrix_value();
      Matrix green= args(2).matrix_value();
      Matrix blue = args(3).matrix_value();
      long image_width  = args(1).columns();
      long image_height = args(1).rows();

      if ( args(2).columns() != image_width  ||
           args(3).columns() != image_width  ||
           args(2).rows()    != image_height ||
           args(3).rows()    != image_height ) {
         error("R,G,B matrix sizes aren't the same");
         return retval;
      }

      cinfo.image_width = image_width; 	/* image width and height, in pixels */
      cinfo.image_height = image_height;
      cinfo.input_components = 3;		/* # of color components per pixel */
      cinfo.in_color_space = JCS_RGB; 	/* colorspace of input image */
      jpeg_set_defaults(&cinfo);
      jpeg_set_quality(&cinfo, quality, TRUE );
//
//  start compressor
//
      jpeg_start_compress(&cinfo, TRUE);

//
// Allocate buffer for one scan line
//
      long row_stride = image_width * 3;	/* JSAMPLEs per row in image_buffer */
      buffer = (*cinfo.mem->alloc_sarray)
      		((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
//
// Now, loop thru each of the scanlines. For each, copy the image
// data from the buffer, data must be [0 255]
//
      for( long j=0; cinfo.next_scanline < cinfo.image_height; j++) {
         for(unsigned long i=0; i<cinfo.image_width; i++) {
            buffer[0][i*3+0] = (unsigned char) red(j,i);
            buffer[0][i*3+1] = (unsigned char) green(j,i);
            buffer[0][i*3+2] = (unsigned char) blue(j,i);
         }
         jpeg_write_scanlines(&cinfo, buffer,1);
      }

   } // else nargin > 3

//
// Clean up
//

   jpeg_finish_compress(&cinfo);
   fclose(outfile);
   jpeg_destroy_compress(&cinfo);


   return retval;

}

/*

%!test
%! if exist("jpgwrite","file")
%!   ## build test image for r/w tests
%!   x=linspace(-8,8,200);
%!   [xx,yy]=meshgrid(x,x);
%!   r=sqrt(xx.^2+yy.^2) + eps;
%!   map=colormap(hsv);
%!   A=sin(r)./r;
%!   minval = min(A(:));
%!   maxval = max(A(:));
%!   z = round ((A-minval)/(maxval - minval) * (rows(colormap) - 1)) + 1;
%!   Rw=Gw=Bw=z;
%!   Rw(:)=fix(255*map(z,1));
%!   Gw(:)=fix(255*map(z,2));
%!   Bw(:)=fix(255*map(z,3));
%!   Aw=fix(255*(1-r/max(r(:)))); ## Fade to nothing at the corners
%!   jpgwrite('test.jpg',Rw,Gw,Bw);
%!   stats=stat("test.jpg");
%!   assert(stats.size,6423);
%!   im = jpgread('test.jpg');
%!   Rr = im(:,:,1); Gr = im(:,:,2); Br = im(:,:,3);
%!   assert(all(Rw(:)-double(Rr(:))<35));
%!   assert(all(Gw(:)-double(Gr(:))<35));
%!   assert(all(Bw(:)-double(Br(:))<35));
%!   unlink('test.jpg');
%! endif

*/
