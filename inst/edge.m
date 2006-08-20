function [imout, thresh] = edge( im, method, thresh, param2 )
# EDGE: find image edges
# [imout, thresh] = edge( im, method, thresh, param2 )
#
# OUTPUT
#  imout  -> output image
#  thresh -> output thresholds
#
# INPUT
#  im     -> input image (greyscale)
#  thresh -> threshold value (value is estimated if not given)
#  
# The following methods are based on high pass filtering the image in
#   two directions, calculating a combined edge weight from and then thresholding
#
# method = 'roberts'
#     filt1= [1 0 ; 0 -1];   filt2= rot90( filt1 )
#     combine= sqrt( filt1^2 + filt2^2 )  
# method = 'sobel'
#     filt1= [1 2 1;0 0 0;-1 -2 -1];      filt2= rot90( filt1 ) 
#     combine= sqrt( filt1^2 + filt2^2 )  
# method = 'prewitt'
#     filt1= [1 1 1;0 0 0;-1 -1 -1];      filt2= rot90( filt1 ) 
#     combine= sqrt( filt1^2 + filt2^2 )  
# method = 'kirsh'
#     filt1= [1 2 1;0 0 0;-1 -2 -1];  filt2 .. filt8 are 45 degree rotations of filt1
#     combine= max( filt1 ... filt8 )
#
# methods based on filtering the image and finding zero crossings
#
# method = 'log' -> Laplacian of Gaussians 
#      param2 is the standard deviation of the filter, default is 2
# method = 'zerocross' -> generic zero-crossing filter
#      param2 is the user supplied filter
# 
# method = 'andy' -> my idea
#      A.Adler's idea (c) 1999. somewhat based on the canny method
#      Step 1: Do a sobel edge detection and to generate an image at
#               a high and low threshold
#      Step 2: Edge extend all edges in the LT image by several pixels,
#               in the vertical, horizontal, and 45degree directions.
#               Combine these into edge extended (EE) image
#      Step 3: Dilate the EE image by 1 step
#      Step 4: Select all EE features that are connected to features in
#               the HT image
#                
#      Parameters:
#        param2(1)==0 or 4 or 8 -> perform x connected dilatation (step 3)
#        param2(2)    dilatation coeficient (threshold) in step 3
#        param2(3)    length of edge extention convolution (step 2)
#        param2(4)    coeficient of extention convolution in step 2
#        defaults = [8 1 3 3]

# Copyright (C) 1999 Andy Adler
# This code has no warrany whatsoever.
# Do what you like with this code as long as you
#     leave this copyright in place.
#
# $Id$

[n,m]= size(im);
xx= 2:m-1;
yy= 2:n-1;

if   strcmp(method,'roberts') || strcmp(method,'sobel') || ...
     strcmp(method,'prewitt') 
     

   if strcmp(method,'roberts') 
      filt= [1 0;0 -1]/4;               tv= 6;
   elseif strcmp(method,'sobel') 
      filt= [1 2 1;0 0 0; -1 -2 -1]/8;  tv= 2;
   elseif strcmp(method,'prewitt') 
      filt= [1 1 1;0 0 0; -1 -1 -1]/6;  tv= 4;
   end

   imo= conv2(im, rot90(filt), 'same').^2 + conv2(im, filt, 'same').^2;
   
# check to see if the user supplied a threshold
# if not, calculate one in the same way as Matlab

   if nargin<3
      thresh= sqrt( tv* mean(mean( imo(yy,xx) ))  );
   end

# The filters are defined for sqrt(imo), but since we calculated imo, compare
#  to thresh ^2

   imout= ( imo >= thresh^2 );   

# Thin the wide edges
   xpeak= imo(yy,xx-1) <= imo(yy,xx) & imo(yy,xx) > imo(yy,xx+1) ;
   ypeak= imo(yy-1,xx) <= imo(yy,xx) & imo(yy,xx) > imo(yy+1,xx) ;
   imout(yy,xx)= imout(yy,xx) & ( xpeak | ypeak );

elseif strcmp(method,'kirsch')   

   filt1= [1 2 1;0 0 0;-1 -2 -1];   fim1= conv2(im,filt1,'same');
   filt2= [2 1 0;1 0 -1;0 -1 -2];   fim2= conv2(im,filt2,'same');
   filt3= [1 0 -1;2 0 -2;1 0 -1];   fim3= conv2(im,filt3,'same');
   filt4= [0 1 2;-1 0 1;-2 -1 0];   fim4= conv2(im,filt4,'same');

   imo= reshape(max([abs(fim1(:)) abs(fim2(:)) abs(fim3(:)) abs(fim4(:))]'),n,m);

   if nargin<3
      thresh=  2* mean(mean( imo(yy,xx) )) ;
   end

   imout=  imo >= thresh ;   

# Thin the wide edges
   xpeak= imo(yy,xx-1) <= imo(yy,xx) & imo(yy,xx) > imo(yy,xx+1) ;
   ypeak= imo(yy-1,xx) <= imo(yy,xx) & imo(yy,xx) > imo(yy+1,xx) ;
   imout(yy,xx)= imout(yy,xx) & ( xpeak | ypeak );

elseif  strcmp(method,'log') || strcmp(method,'zerocross') 

   if strcmp(method,'log') 
      if nargin >= 4;    sd= param2;
      else               sd= 2;
      end

      sz= ceil(sd*3);
      [x,y]= meshgrid( -sz:sz, -sz:sz );
      filt = exp( -( x.^2 + y.^2 )/2/sd^2 ) .* ...
                   ( x.^2 + y.^2 - 2*sd^2 ) / 2 / pi / sd^6 ;
   else
      filt = param2;
   end
   filt = filt - mean(filt(:));

   imo= conv2(im, filt, 'same');

   if nargin<3 || isempty( thresh )
      thresh=  0.75* mean(mean( abs(imo(yy,xx)) )) ;
   end

   zcross= imo > 0;
   yd_zc=  diff( zcross );
   xd_zc=  diff( zcross' )';
   yd_io=  abs(diff( imo ) ) > thresh;
   xd_io=  abs(diff( imo')') > thresh;

# doing it this way puts the transition at the <=0 point
   xl= zeros(1,m);  yl= zeros(n,1);
   imout= [    ( yd_zc ==  1 ) & yd_io ; xl] | ...
          [xl; ( yd_zc == -1 ) & yd_io     ] | ...
          [    ( xd_zc ==  1 ) & xd_io , yl] | ... 
          [yl, ( xd_zc == -1 ) & xd_io     ];

elseif  strcmp(method,'canny')  
    error("method canny not implemented");

elseif  strcmp(method,'andy')  

   filt= [1 2 1;0 0 0; -1 -2 -1]/8;  tv= 2;
   imo= conv2(im, rot90(filt), 'same').^2 + conv2(im, filt, 'same').^2;
   if nargin<3 || thresh==[];
      thresh= sqrt( tv* mean(mean( imo(yy,xx) ))  );
   end
#     sum( imo(:)>thresh ) / prod(size(imo))
   dilate= [1 1 1;1 1 1;1 1 1]; tt= 1; sz=3; dt=3;
   if nargin>=4
      # 0 or 4 or 8 connected dilation
      if length(param2) > 0
         if      param2(1)==4 ; dilate= [0 1 0;1 1 1;0 1 0];
         elseif  param2(1)==0 ; dilate= 1;
         end
      end
      # dilation threshold
      if length(param2) > 2; tt= param2(2); end
      # edge extention length
      if length(param2) > 2; sz= param2(3); end
      # edge extention threshold
      if length(param2) > 3; dt= param2(4); end
      
   end
   fobliq= [0 0 0 0 1;0 0 0 .5 .5;0 0 0 1 0;0 0 .5 .5 0;0 0 1 0 0; 
                      0 .5 .5 0 0;0 1 0 0 0;.5 .5 0 0 0;1 0 0 0 0];
   fobliq= fobliq( 5-sz:5+sz, 3-ceil(sz/2):3+ceil(sz/2) );

   xpeak= imo(yy,xx-1) <= imo(yy,xx) & imo(yy,xx) > imo(yy,xx+1) ;
   ypeak= imo(yy-1,xx) <= imo(yy,xx) & imo(yy,xx) > imo(yy+1,xx) ;

   imht= ( imo >= thresh^2 * 2); # high threshold image   
   imht(yy,xx)= imht(yy,xx) & ( xpeak | ypeak );
   imht([1,n],:)=0; imht(:,[1,m])=0;

%  imlt= ( imo >= thresh^2 / 2); # low threshold image   
   imlt= ( imo >= thresh^2 / 1); # low threshold image   
   imlt(yy,xx)= imlt(yy,xx) & ( xpeak | ypeak );
   imlt([1,n],:)=0; imlt(:,[1,m])=0;

# now we edge extend the low thresh image in 4 directions

   imee= ( conv2( imlt, ones(2*sz+1,1)    , 'same') > tt ) | ...
         ( conv2( imlt, ones(1,2*sz+1)    , 'same') > tt ) | ...
         ( conv2( imlt, eye(2*sz+1)       , 'same') > tt ) | ...
         ( conv2( imlt, rot90(eye(2*sz+1)), 'same') > tt ) | ...
         ( conv2( imlt, fobliq            , 'same') > tt ) | ...
         ( conv2( imlt, fobliq'           , 'same') > tt ) | ...
         ( conv2( imlt, rot90(fobliq)     , 'same') > tt ) | ...
         ( conv2( imlt, flipud(fobliq)    , 'same') > tt );
#  imee(yy,xx)= conv2(imee(yy,xx),ones(3),'same') & ( xpeak | ypeak );
   imee= conv2(imee,dilate,'same') > dt; #

%  ff= find( imht==1 );
%  imout = bwselect( imee, rem(ff-1, n)+1, ceil(ff/n), 8);  
   imout = imee;


else

   error (['Method ' method ' is not recognized']);

end




# 
# $Log$
# Revision 1.1  2006/08/20 12:59:32  hauberg
# Changed the structure to match the package system
#
# Revision 1.1  2002/03/17 02:38:52  aadler
# fill and edge detection operators
#
# Revision 1.4  2000/11/20 17:13:07  aadler
# works?
#
# Revision 1.3  1999/06/09 17:29:36  aadler
# implemented 'andy' mode edge detection
#
# Revision 1.2  1999/06/08 14:26:50  aadler
# zero-cross and LoG filters work
#
# Revision 1.1  1999/06/07 21:01:38  aadler
# Initial revision
#
#

#  
