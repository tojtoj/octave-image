## bmpwrite(X,map,file)
##   Write the bitmap X into file (8-bit uncompressed format).
##   The values in X are indices into the given RGB colour map.

## This code is in the public domain.
## Author: Paul Kienzle <pkienzle@users.sf.net>
## Based information from Jörn Daub's web page:
## http://www.daubnet.com/formats/BMP.html

function bmpwrite(x,map,file)
    header = 14+40+4*rows(map);
    filesize = header+prod(size(x));
    arch = "ieee-le";
    file = fopen(file, "wb");
    fwrite(file,toascii("BM"),"uchar",0,arch); # file tag
    fwrite(file,filesize,"long",0,arch);    # length of file
    fwrite(file,0,"long",0,arch);           # reserved
    fwrite(file,header,"long",0,arch);      # offset of raster data in file

    fwrite(file,40,"long",0,arch);          # header size
    fwrite(file,columns(x),"long",0,arch);  # image width
    fwrite(file,rows(x),"long",0,arch);     # image height
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
    fwrite(file,postpad(flipud(x)',ceil(columns(x)/4)*4),"uchar",0,arch);
    fclose(file);
endfunction

