/*
 *  readpng.c
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
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */


/*

Loads PNG files to octave using libpng;

       PNG  (Portable  Network  Graphics) is an extensible file format for the
       lossless, portable, well-compressed storage of raster images. PNG  pro-
       vides  a patent-free replacement for GIF and can also replace many com-
       mon uses of TIFF. Indexed-color, grayscale, and  truecolor  images  are
       supported,  plus  an optional alpha channel. Sample depths range from 1
       to 16 bits.

*/

#include <png.h>
#include <octave/oct.h>

typedef struct
{
  int width;
  int height;
  int bit_depth;
  int color_type;
  unsigned char **row_pointers;
} canvas;

canvas *load_canvas(char *filename);
void save_canvas(canvas *can,char *filename);
canvas *new_canvas(int x, int y, int stride=0);
void delete_canvas(canvas *can);


DEFUN_DLD (pngread, args, nargout ,"\
pngread reads a png file from disk.\n\
    [R,G,B,A] = pngread('filename') reads the specified file\n\
    and returns the Red, Green, Blue and Alpha intensity matrices.\n")
{
  octave_value_list retval;
  int nargin  = args.length();
  
  //
  // We bail out if the input parameters are bad
  //
  if (nargin != 1 || !args(0).is_string() || nargout < 3) {
    print_usage ("pngread");
    return retval;
  }
  
  //
  // Load png file
  //
  canvas *pic=load_canvas((char *)args(0).string_value().c_str());
  
  // octave_stdout << "Canvas [" << pic->width << "x" << pic->height << "]\n";
 
  if (nargout >= 3) {
    Matrix red   ( pic->height , pic->width );
    Matrix green ( pic->height , pic->width );
    Matrix blue  ( pic->height , pic->width );
    Matrix alpha ( pic->height , pic->width );
    
    for (unsigned long j=0; j<pic->height; j++) 
      for (unsigned long i=0; i<pic->width; i++) 
	{
	  red(j,i) = pic->row_pointers[j][i*4+0];
	  green(j,i) = pic->row_pointers[j][i*4+1]           ;
	  blue(j,i) = pic->row_pointers[j][i*4+2];
	  alpha(j,i) = pic->row_pointers[j][i*4+3];
	}
    retval(3)= alpha;
    retval(2)= blue;
    retval(1)= green;
    retval(0)= red;    
  }

  return retval;
}


DEFUN_DLD (pngwrite, args, ,"\
pngwrite writes a png file to the disk.\n\
    pngwrite('filename',R,G,B,A) writes the specified file\n\
    using the Red, Green, Blue and Alpha matrices.\n\
    \n\
    Data must be [0 255] or the high bytes will be lost.")
{
   octave_value_list retval;
   int nargin  = args.length();
   
   //
   // We bail out if the input parameters are bad
   //
   if (nargin < 4 || !args(0).is_string() ) {
     print_usage ("pngwrite");
     return retval;
   }

   Matrix red  = args(1).matrix_value();
   Matrix green= args(2).matrix_value();
   Matrix blue = args(3).matrix_value();
   Matrix alpha= args(4).matrix_value();
   
   long image_width  = args(1).columns();
   long image_height = args(1).rows();
   
   if ( args(2).columns() != image_width  ||
	args(3).columns() != image_width  ||
	args(4).columns() != image_width  ||
	args(2).rows()    != image_height ||
	args(3).rows()    != image_height ||
	args(4).rows()    != image_height )  
     {
       error("pngwrite R,G,B,A matrix sizes aren't the same");
       return retval;
     }
   
   canvas *pic=new_canvas(image_width,image_height);
   if (pic == NULL) 
     {
       error("pngwrite out of memory");
       return retval;
     }

   // octave_stdout << "Canvas [" << pic->width << "x" << pic->height << "]\n";

   for(int i=0; i<pic->width; i++) 
     for(int j=0; j<pic->height; j++) 
       {
	 pic->row_pointers[j][i*4+0]=(unsigned char)(red(j,i));
	 pic->row_pointers[j][i*4+1]=(unsigned char)(green(j,i));
	 pic->row_pointers[j][i*4+2]=(unsigned char)(blue(j,i));
	 pic->row_pointers[j][i*4+3]=(unsigned char)(alpha(j,i));
       }
   
   save_canvas(pic,(char *)args(0).string_value().c_str());
   delete_canvas(pic);

   return retval;
}

//////////////Libcanvas///////////
canvas *new_canvas(int width, int height, int stride)
{
  // Default stride if none given
  if (stride==0) stride=width*4;

  // Clean allocation of canvas structure
  canvas *can=new(canvas);
  unsigned char *image_data = new unsigned char[stride*height];
  unsigned char **row_pointers = new unsigned char *[height];
  if (can == NULL || image_data == NULL || row_pointers == NULL) 
    {
      if (can == NULL) delete can;
      if (image_data == NULL) delete[] image_data;
      if (row_pointers == NULL) delete[] row_pointers;
      return NULL;
    }

  // Fill in canvas structure
  can->width=width;
  can->height=height;
  can->bit_depth=8;
  can->color_type=PNG_COLOR_TYPE_RGB_ALPHA;
  can->row_pointers = row_pointers;
  for (int i=0; i < height; i++) row_pointers[i] = image_data + i*stride;

  return can;
}



void delete_canvas(canvas *can)
{
  
  if (can!=NULL)
    {
      delete[] can->row_pointers[0]; 
      delete[] can->row_pointers;
      delete can;
    }
  return;
}

canvas *load_canvas(char *filename)
{
  FILE *infile;
  png_structp png_ptr;
  png_infop info_ptr;
  
  infile = fopen(filename,"r");
  if (NULL==infile) {
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
  
  png_ptr=png_create_read_struct(PNG_LIBPNG_VER_STRING,NULL,NULL,NULL);
  if (!png_ptr) {
    error("pngread out of mem"); 
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
  
  // XXX FIXME XXX do we need to check for failure in any of these steps?
  png_init_io(png_ptr,infile);
  png_set_sig_bytes(png_ptr,8);
  png_read_info(png_ptr,info_ptr);
  
  png_uint_32 width,height;
  int color_type,bit_depth;
  png_get_IHDR(png_ptr,info_ptr,&width,&height,
	       &color_type,&bit_depth,NULL,NULL,NULL);
  
  // Set to RGB - ALPHA - 8bit
  if (color_type == PNG_COLOR_TYPE_PALETTE)
    png_set_palette_to_rgb(png_ptr);
  
  if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
    png_set_gray_1_2_4_to_8(png_ptr);
  
  if (png_get_valid(png_ptr, info_ptr,PNG_INFO_tRNS)) //add alpha
    png_set_tRNS_to_alpha(png_ptr);
  
  if (bit_depth == 16)
    png_set_strip_16(png_ptr);
  
  if (color_type == PNG_COLOR_TYPE_GRAY 
      || color_type == PNG_COLOR_TYPE_GRAY_ALPHA) 
    png_set_gray_to_rgb(png_ptr);
  
  if (color_type ==2)
    png_set_filler(png_ptr,0xff, PNG_FILLER_AFTER);
  
  png_read_update_info(png_ptr,info_ptr);

  // Read the data from the file
  int stride=png_get_rowbytes(png_ptr,info_ptr);
  canvas *can = new_canvas(width,height,stride);
  if (can != NULL) {
    png_read_image(png_ptr,can->row_pointers);
  } else {
    error("pngread out of mem");
  }

  png_read_end(png_ptr,NULL);
  png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp)NULL);

  fclose(infile);
  
  return can;
}

void save_canvas(canvas *can,char *filename)
{
  FILE            *fp;
  png_structp     png_ptr;
  png_infop       info_ptr;
  
  fp = fopen(filename, "wb");
  if (fp == NULL) {
    error("pngwrite could not open %s", filename);
    return;
  }

  // XXX FIXME XXX do we need to check for failure in any of these steps?
  png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  info_ptr = png_create_info_struct(png_ptr);             
  png_init_io(png_ptr, fp);
  png_set_compression_level(png_ptr, 3);
  
  png_set_IHDR(png_ptr, info_ptr, can->width, can->height,         
	       can->bit_depth, can->color_type, PNG_INTERLACE_NONE,
	       PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
  
  
  png_set_gAMA(png_ptr, info_ptr, 0.7);
  
  time_t          gmt;
  png_time        mod_time;
  png_text        text_ptr[2];
  time(&gmt);
  png_convert_from_time_t(&mod_time, gmt);
  png_set_tIME(png_ptr, info_ptr, &mod_time);
  text_ptr[0].key = "Created by";
  text_ptr[0].text = "Octave";
  text_ptr[0].compression = PNG_TEXT_COMPRESSION_NONE;
  
  png_set_text(png_ptr, info_ptr, text_ptr, 1);
  
  png_write_info(png_ptr, info_ptr);
  png_write_image(png_ptr, can->row_pointers);
  png_write_end(png_ptr, info_ptr);                      
  png_destroy_write_struct(&png_ptr, &info_ptr);          
  fclose(fp); 
}
