## Copyright (C) 2010 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{value}, @var{offset}] = tiff_tag_read (@var{file}, @var{tag}, @var{ifd})
## Reads the values of TIFF file tags.
##
## @var{file} is a TIFF file and @var{tag} is the tag number to read. If
## @var{ifd} is given, only the tag value from that IFD (Image File Directory)
## will be read. By default, reads only the first IFD.
##
## @var{value} is the read value from @var{tag}. @var{offset} will be @code{1}
## if @var{value} is a file offset. 
##
## @seealso{imread, imfinfo, readexif}
## @end deftypefn

## Based on the documentation at
##  * http://en.wikipedia.org/wiki/Tagged_Image_File_Format
##  * http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf
##  * http://ibb.gsf.de/homepage/karsten.rodenacker/IDL/Lsmfile.doc
##  * http://www.awaresystems.be/imaging/tiff/faq.html
##
## and the function tiff_read by F. Nedelec, EMBL (www.cytosim.org)
##  * http://www.cytosim.org/misc/index.html
##
## * On the TIFF image file header:
##     bytes 00-01 --> byte order used within the file: "II" for little endian
##                     and "MM" for big endian byte ordering.
##     bytes 02-03 --> number 42 that identifies the file as TIFF
##     bytes 04-07 --> file offset (in bytes) of the first IFD (Image File Directory)
##
##   Note: offset is always from the start of the file ("bof" in fread) and first
##   byte has an offset of zero.
##
## * On a TIFF's IFD structure:
##     bytes 00-01 --> number of entries (or tags or fields or directories)
##     bytes 02-13 --> the entry (the tag is repeated the number of times
##                     specified at the start of the IFD, but always takes
##                     12 bytes of size)
##     bytes XX-XX --> file offset for next IFD (last 4 bytes of the IFD)
##
##   Note: there must be always one IFD and each IFD must have at least one entry
##
## * On an IFD entry (or TIFF's field) structure:
##     bytes 00-01 --> tag that identifies the entry
##     bytes 02-03 --> entry type
##                      1  --> BYTE (uint8)
##                      2  --> ASCII
##                      3  --> SHORT (uint16)
##                      4  --> LONG (uint32)
##                      5  --> RATIONAL (two LONGS)
##                      6  --> SBYTE (int8)
##                      7  --> UNDEFINED (8 bit)
##                      8  --> SSHORT (int16)
##                      9  --> SLONG (int32)
##                      10 --> FLOAT (single IEEE precision)
##                      11 --> DOUBLE (double IEEE precision)
##     bytes 04-07 --> number of values (count)
##     bytes 08-11 --> file offset to the value or value (only if it fits in 4 bytes)
##
##   Note: file offset of the value may point anywhere in the file, even after the image.

function [value, offset] = tiff_tag_read (file, tag, ifd)

  [FID, msg] = fopen (file, "r", "native");
  if (msg != 0)
    error ("Unable to fopen '%s': %s.", file, msg);
  endif

  # Read byte order
  byte_order = fread(FID, 2, "char=>char");
  if ( strcmp(byte_order', "II") )
    arch = "ieee-le";                             # IEEE little endian format
  elseif ( strcmp(byte_order',"MM") )
    arch = "ieee-be";                             # IEEE big endian format
  else
    error("First 2 bytes of header returned '%s'. TIFF file expects either 'II' or 'MM'.", byte_order');
  endif

  # Read number 42
  nTIFF = fread(FID, 1, "uint16", arch);
  if (nTIFF != 42)
    error("This is not a TIFF file (missing 42 on header at offset 2. Instead got '%g').", tiff_id);
  endif

  # Read offset and move for the first IFD
  offset_IFD = fread(FID, 1, "uint32", arch);
  status = fseek(FID, offset_IFD, "bof");
  if (status != 0)
      error("Error on fseek when moving to first IFD.");
  endif

  # Read number of entries (nTag) and look for the desired tag ID
  nTag = fread(FID, 1, "uint16", arch);
  iTag = 0;                                       # Tag index
  while (1)                                       # Control is made inside the loop
    iTag++;
    cTag = fread(FID, 1, "uint16", arch);         # Tag ID
    if (cTag == tag)                              # Tag ID was found
      value = read_value (FID, arch, tag);        # Read tag value
      break
    elseif (iTag == nTag || cTag > tag)           # All tags have been read (tags are in ascendent order)
      error ("Unable to find tag %g.", tag)
    endif
    status = fseek(FID, 10, "cof");               # Move to the next tag
    if (status != 0)
      error("Error on fseek when moving to tag %g of %g. Last tag read had value of %g", rTag, nTag, tag);
    endif
  endwhile

  fclose (FID);

endfunction

#####
function [value, offset] = read_value (FID, arch, tag)

  tiff_type = fread(FID, 1, "uint16", arch);
  count     = fread(FID, 1, "uint32", arch);

  switch (tiff_type)
    case 1      # BYTE      = 8-bit unsigned integer
      nBytes    = 1;
      precision = "uint8";
    case 2      # ASCII     = 8-bit byte that contains a 7-bit ASCII code; the last byte must be NUL (binary zero)
      nBytes    = 1;
      precision = "uchar";
    case 3      # SHORT     = 16-bit (2-byte) unsigned integer
      nBytes    = 2;
      precision = "uint16";
    case 4      # LONG      = 32-bit (4-byte) unsigned integer
      nBytes    = 4;
      precision = "uint32";
    case 5      # RATIONAL  = Two LONGs: the first represents the numerator of a fraction; the second, the denominator
      nBytes    = 8;
      precision = "uint32";
    case 6      # SBYTE     = An 8-bit signed (twos-complement) integer
      nBytes    = 1;
      precision = "int8";
    case 7      # UNDEFINED = An 8-bit byte that may contain anything, depending on the definition of the field
      nBytes    = 1;
      precision = "uchar";
    case 8      # SSHORT    = A 16-bit (2-byte) signed (twos-complement) integer
      nBytes    = 2;
      precision = "int16";
    case 9      # SLONG     = A 32-bit (4-byte) signed (twos-complement) integer
      nBytes    = 4;
      precision = "int32";
    case 10     # SRATIONAL = Two SLONG’s: the first represents the numerator of a fraction, the second the denominator
      nBytes    = 8;
      precision = "int32";
    case 11     # FLOAT     = Single precision (4-byte) IEEE format
      nBytes    = 4;
      precision = "float32";
    case 12     # DOUBLE    = Double precision (8-byte) IEEE format
      nBytes   = 8;
      precision = "float64";
    otherwise # Warning (from TIFF file specifications): It is possible that other TIFF field types will be added in the future
      error("TIFF type %i not supported", tiff_type)
  endswitch

  if ( (nBytes*count) > 4 )    # If it doesn't fit in 4 bytes, it's an offset
    offset = 1;
    value = fread(FID, 1, "uint32", arch);
    ## The file offset must be an even number
    if ( rem(value,2) != 0 )
      error("Couldn't find correct value offset for tag %g", tag);
    endif
  else
    offset = 0;
    ## read here
    switch precision
      case { 5, 10 }
        value = fread(FID, 2*count, precision, arch);
      otherwise
        value = fread(FID, count, precision, arch);
    endswitch
    if (precision == 2)
        value = char(value');
    endif
  endif

endfunction
