## -*- texinfo -*-
## @deftypefn {Function File} bmpwrite (@var{X}, @var{map}, @var{file})
## Write the bitmap @var{X} into @var{file} (8-bit indexed uncompressed).
## The values in @var{X} are indices into the given RGB colour @var{map}.
## @deftypefnx{Function File} bmpwrite (@var{X}, @var{file})
## Write the bitmap @var{X} into @var{file} (24-bit truecolor uncompressed).
## @var{X} is an m x n x 3 array of R,G,B integer values in the range 0 to 255.
## @end deftypefn

## This code is in the public domain.
## Author: Paul Kienzle <pkienzle@users.sf.net>


function bmpwrite(x,colormap_or_file,file)
  if nargin==2
     bmpwrite_truecolor(x,colormap_or_file);
  else
     bmpwrite_indexed(x,colormap_or_file,file);
  endif
endfunction

function bmpwrite_truecolor(x,file)
    h = rows(x); w = columns(x);
    padw = ceil(3*w/4)*4-3*w;
    header = 14+40;
    filesize = header+h*(3*w+padw);
    arch = "ieee-le";
    file = fopen(file, "wb");
    fwrite(file,toascii("BM"),"uchar",0,arch); # file tag
    fwrite(file,filesize,"long",0,arch);    # length of file
    fwrite(file,0,"long",0,arch);           # reserved
    fwrite(file,header,"long",0,arch);      # offset of raster data in file

    fwrite(file,40,"long",0,arch);          # header size
    fwrite(file,w,"long",0,arch);           # image width
    fwrite(file,h,"long",0,arch);           # image height
    fwrite(file,1,"short",0,arch);          # number of planes
    fwrite(file,24,"short",0,arch);         # pixels per plane
    fwrite(file,0,"long",0,arch);           # compression (none)
    fwrite(file,0,"long",0,arch);           # compressed size of image
    resolution = 72/2.54*100;               # 72 dpi / 2.54 cm/in * 100 cm/m
    fwrite(file,resolution,"long",0,arch);  # horizontal resolution
    fwrite(file,resolution,"long",0,arch);  # vertical resolution
    fwrite(file,0,"long",0,arch);           # number of colours used
    fwrite(file,0,"long",0,arch);           # number of "important" colors

    ## raster image, lines written bottom to top.
    R = x(end:-1:1,:,1)';
    G = x(end:-1:1,:,2)';
    B = x(end:-1:1,:,3)';
    RGB=[B(:),G(:),R(:)]';  # Now [[B;G;R],[B;G;R],...,[B;G;R]]
    RGB=reshape(RGB,3*w,h); # Now [[B;G;R;...;B;G;R],...,[B;G;R;...;B;G;R]]
    fwrite(file,[RGB;zeros(padw,h)],"uchar",0,arch);
    fclose(file);
endfunction

function bmpwrite_indexed(x,map,file)

    if rows(map) > 256, 
      error("bmpwrite supports at most 256 color indexed images"); 
    endif
    [h,w] = size(x);
    padw = ceil(w/4)*4-w;
    header = 14+40+4*rows(map);
    filesize = header+(w+padw)*h;
    arch = "ieee-le";
    file = fopen(file, "wb");
    fwrite(file,toascii("BM"),"uchar",0,arch); # file tag
    fwrite(file,filesize,"long",0,arch);    # length of file
    fwrite(file,0,"long",0,arch);           # reserved
    fwrite(file,header,"long",0,arch);      # offset of raster data in file

    fwrite(file,40,"long",0,arch);          # header size
    fwrite(file,w,"long",0,arch);           # image width
    fwrite(file,h,"long",0,arch);           # image height
    fwrite(file,1,"short",0,arch);          # number of planes
    fwrite(file,8,"short",0,arch);          # pixels per plane
    fwrite(file,0,"long",0,arch);           # compression (none)
    fwrite(file,0,"long",0,arch);           # compressed size of image
    resolution = 72/2.54*100;               # 72 dpi / 2.54 cm/in * 100 cm/m
    fwrite(file,resolution,"long",0,arch);  # horizontal resolution
    fwrite(file,resolution,"long",0,arch);  # vertical resolution
    fwrite(file,rows(map),"long",0,arch);   # number of colours used
    fwrite(file,0,"long",0,arch);           # number of "important" colors

    ## colormap BGR0BGR0BGR0BGR0...
    map=[round(map*255), zeros(rows(map),1)];
    map=map(:,[3,2,1,4]);
    fwrite(file,map',"uchar",0,arch);

    ## raster image, each line on a 32-bit boundary, padded with zeros
    ## lines written bottom to top.
    fwrite(file,[flipud(x-1)';zeros(padw,h)],"uchar",0,arch);
    fclose(file);
endfunction
