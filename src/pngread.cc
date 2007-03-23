/*
 *  pngread.cc
 *
 *  Copyright (C) 2003 Nadav Rotem <nadav256@hotmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

/*

Load PNG files to octave using libpng;

       PNG  (Portable  Network  Graphics) is an extensible file format for the
       lossless, portable, well-compressed storage of raster images. PNG  pro-
       vides  a patent-free replacement for GIF and can also replace many com-
       mon uses of TIFF. Indexed-color, grayscale, and  truecolor  images  are
       supported,  plus  an optional alpha channel. Sample depths range from 1
       to 16 bits.

*/

/*
 * Modified: Stefan van der Walt <stefan@sun.ac.za>
 * Date: 28 January 2005
 * - Fix bugs, restructure
 */

#include "png.h"
#include "pngcanvas.h"
#include <octave/oct.h>

canvas *load_canvas(char *filename);

DEFUN_DLD (pngread, args, nargout ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{I}, @var{alpha}] =} pngread(@var{filename})\n\
\n\
Read a PNG file from disk.\n\
\n\
The image is returned as a matrix of dimension MxN (for grey-level images)\n\
or MxNx3 (for colour images).  The numeric type of @var{I} and @var{alpha}\n\
is @code{uint8} for grey-level and RGB images, or @code{logical} for\n\
black-and-white images.\n\
\n\
@end deftypefn\n\
@seealso{imread}")
{
  octave_value_list retval;
  int nargin  = args.length();
  
  //
  // We bail out if the input parameters are bad
  //
  if (nargin != 1 || !args(0).is_string()) {
    print_usage ();
    return retval;
  }
  
  //
  // Load png file
  //
  canvas *pic=load_canvas((char *)args(0).string_value().c_str());
  if (!pic) return retval;

  dim_vector dim = dim_vector();
  dim.resize(3);
  dim(0) = pic->height;
  dim(1) = pic->width;
  dim(2) = 3;

  if ( (pic->color_type == PNG_COLOR_TYPE_GRAY) ||
       (pic->color_type == PNG_COLOR_TYPE_GRAY_ALPHA) ||
       ((pic->color_type == PNG_COLOR_TYPE_PALETTE) && (pic->bit_depth == 1)) )
      dim(2) = 1;

  if (pic->bit_depth > 1 && pic->bit_depth < 8)
      pic->bit_depth = 8;

  NDArray out(dim);
  
  dim.resize(2);
  NDArray alpha(dim);
   
  Array<int> coord = Array<int> (3);
  
  for (unsigned long j=0; j < pic->height; j++) {
      coord(0) = j;
      for (unsigned long i=0; i < pic->width; i++) {
	  coord(1) = i;

	  for (int c = 0; c < out.dims()(2); c++) {
	      coord(2) = c;
	      out(coord) = pic->row_pointers[j][i*4+c];
	  }
	  alpha(j,i) = pic->row_pointers[j][i*4+3];
      }
  }
  out = out.squeeze();

  switch (pic->bit_depth) {
  case 1: 
     retval.append((boolNDArray)out);
     retval.append((boolNDArray)alpha);
     break;
  case 8:
     retval.append((uint8NDArray)out);
     retval.append((uint8NDArray)alpha);
     break;
  case 16:
     retval.append((uint16NDArray)out);
     retval.append((uint16NDArray)alpha);
     break;
  default:
     retval.append(out);
     retval.append(alpha);
  }

  delete_canvas(pic);
  return retval;
}

canvas *load_canvas(char *filename)
{
  png_structp png_ptr;
  png_infop info_ptr;
  
  FILE *infile = fopen(filename,"rb");
  if (!infile) {
    error("pngread could not open file %s", filename); 
    return NULL;
  }
  
  unsigned char sig[8];
  fread(sig,1,8,infile);
  if (!png_check_sig(sig,8)) {
    error("pngread invalid signature in %s", filename); 
    fclose(infile);
    return NULL;
  }
  
  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING,NULL,NULL,NULL);
  if (!png_ptr) {
    error("pngread out of memory"); 
    fclose(infile);
    return NULL;
  }
  
  info_ptr = png_create_info_struct(png_ptr);
  if(!info_ptr) { 
    error("pngread can't generate info");  
    png_destroy_read_struct(&png_ptr,NULL,NULL); 
    fclose(infile);
    return NULL;
  }

  /* Set error handling */
  if (setjmp(png_jmpbuf(png_ptr))) {
      error("pngread: libpng exited abnormally");
      png_destroy_read_struct(&png_ptr, &info_ptr, png_infopp_NULL);
      fclose(infile);
      return NULL;
  }

  png_init_io(png_ptr, infile);
  png_set_sig_bytes(png_ptr, 8);
  png_read_info(png_ptr, info_ptr);
  
  png_uint_32 width,height;
  int color_type, bit_depth;
  png_get_IHDR(png_ptr,info_ptr,&width,&height,
	       &bit_depth,&color_type,NULL,NULL,NULL);
  
  /* Transform grayscale images with depths < 8-bit to 8-bit, change
   * paletted images to RGB, and add a full alpha channel if there is
   * transparency information in a tRNS chunk.
   */
  if (color_type == PNG_COLOR_TYPE_PALETTE) {
      png_set_palette_to_rgb(png_ptr);
  }
  if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8) {
      png_set_gray_1_2_4_to_8(png_ptr);
  }
  if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS)) { //add alpha
      png_set_tRNS_to_alpha(png_ptr);
  }
  
  // Always transform image to RGB
  if (color_type == PNG_COLOR_TYPE_GRAY 
      || color_type == PNG_COLOR_TYPE_GRAY_ALPHA) 
      png_set_gray_to_rgb(png_ptr);
   
  // If no alpha layer is present, create one
  if (color_type == PNG_COLOR_TYPE_GRAY
      || color_type == PNG_COLOR_TYPE_RGB)
     png_set_add_alpha(png_ptr, 0xff, PNG_FILLER_AFTER);

  if (bit_depth < 8) {
      png_set_packing(png_ptr);
  }
  
  // For now, use 8-bit only
  if (bit_depth == 16) {
      png_set_strip_16(png_ptr);
  }
   
  png_read_update_info(png_ptr,info_ptr);

  // Read the data from the file
  int stride = png_get_rowbytes(png_ptr, info_ptr);
  canvas *can = new_canvas(width, height, stride);
  
  if (can) {
    png_read_image(png_ptr, can->row_pointers);
  } else {
    error("pngread out of memory");
  }

  png_read_end(png_ptr,NULL);
  png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp)NULL);

  fclose(infile);

  // Set color type and depth. Used to determine octave output arguments.
  can->color_type = color_type;  
  can->bit_depth = bit_depth;
  return can;
}
