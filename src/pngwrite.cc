/*
 *  pngwrite.cc
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

Write PNG files to disk from octave

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

void save_canvas(canvas *can, char *filename);

DEFUN_DLD (pngwrite, args, ,"\
-*- texinfo -*-\n\
@deftypefn {Function File} pngwrite(@var{filename}, @var{R}, @var{G}, @var{B}, @var{A})\n\
Writes a png file to the disk using the Red, Green, Blue and Alpha matrices.\n\
\n\
Data must be [0 255] or the high bytes will be lost.\n\
@seealso{imwrite}\n\
@end deftypefn\n\
") {
   octave_value_list retval;
   int nargin  = args.length();
   
   //
   // We bail out if the input parameters are bad
   //
   if (nargin < 5 || !args(0).is_string() ) {
     print_usage ();
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
   
   canvas *pic=new_canvas(image_width, image_height, image_width*4);
   if (!pic) {
       error("pngwrite out of memory");
       return retval;
   }

   for(int i=0; i < pic->width; i++) {
       for(int j=0; j < pic->height; j++) {
	   pic->row_pointers[j][i*4+0]=(unsigned char)(red(j,i));
	   pic->row_pointers[j][i*4+1]=(unsigned char)(green(j,i));
	   pic->row_pointers[j][i*4+2]=(unsigned char)(blue(j,i));
	   pic->row_pointers[j][i*4+3]=(unsigned char)(alpha(j,i));
       }
   }
   

   save_canvas(pic,(char *)args(0).string_value().c_str());
   delete_canvas(pic);

   return retval;
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

  png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png_ptr) {
      fclose(fp);
      error("pngwrite: cannot create write structure");
      return;
  }

  info_ptr = png_create_info_struct(png_ptr);
  if (!info_ptr) {
      fclose(fp);
      error("pngwrite: cannot not create image structure");
      png_destroy_write_struct(&png_ptr, png_infopp_NULL);
      return;
  }

  if (setjmp(png_jmpbuf(png_ptr))) {
      fclose(fp);
      png_destroy_write_struct(&png_ptr, &info_ptr);
      error("pngread: libpng exited abnormally");
      return;
  }

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
%!   pngwrite('test.png',Rw,Gw,Bw,Aw);
%!   stats=stat("test.png");
%!   assert(stats.size,24738);
%!   im = pngread('test.png');
%!   Rr = im(:,:,1); Gr = im(:,:,2); Br = im(:,:,3);
%!   assert(all(double(Rr(:))==Rw(:)));
%!   assert(all(double(Gr(:))==Gw(:)));
%!   assert(all(double(Br(:))==Bw(:)));
%!   [im,Ar] = pngread('test.png');
%!   Rr = im(:,:,1); Gr = im(:,:,2); Br = im(:,:,3);
%!   assert(all(double(Rr(:))==Rw(:)));
%!   assert(all(double(Gr(:))==Gw(:)));
%!   assert(all(double(Br(:))==Bw(:)));
%!   assert(all(double(Ar(:))==Aw(:)));
%!   unlink('test.png');
%! endif

*/
