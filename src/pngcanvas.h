/*
 *  readpng.h
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
 * Modified: Stefan van der Walt <stefan@sun.ac.za>
 * Date: 28 January 2005
 * - Fix bugs, restructure
 */

typedef struct
{
  int width;
  int height;
  int bit_depth;
  int color_type;
  unsigned char **row_pointers;
} canvas;

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

