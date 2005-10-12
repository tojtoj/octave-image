## This program is public domain.

## build image for image r/w tests
x=linspace(-8,8,200);
[xx,yy]=meshgrid(x,x);
r=sqrt(xx.^2+yy.^2) + eps;
map=colormap(hsv);
A=sin(r)./r;
minval = min(A(:));
maxval = max(A(:));
z = round ((A-minval)/(maxval - minval) * (rows(colormap) - 1)) + 1;
Rw=Gw=Bw=z;
Rw(:)=fix(255*map(z,1));
Gw(:)=fix(255*map(z,2));
Bw(:)=fix(255*map(z,3));
Aw=fix(255*(1-r/max(r(:)))); ## Fade to nothing at the corners

if exist("jpgwrite")
  disp(">jpgwrite"); 
  jpgwrite('test.jpg',Rw,Gw,Bw);
  stats=stat("test.jpg");
  assert(stats.size,6423);
  disp(">jpgread");
  im = jpgread('test.jpg');
  Rr = im(:,:,1); Gr = im(:,:,2); Br = im(:,:,3);
  assert([max(double(Rw(:))-double(Rr(:)))<30, \
          max(double(Gw(:))-double(Gr(:)))<30, \
	  max(double(Bw(:))-double(Br(:)))<30]);
  unlink('test.jpg');
else
  disp(">jpgread ... not available");
  disp(">jpgwrite ... not available");
endif

if exist("pngwrite")
  disp(">pngwrite"); 
  pngwrite('test.png',Rw,Gw,Bw,Aw);
  stats=stat("test.png");
  assert(stats.size,24738);
  disp(">pngread");
  im = pngread('test.png');
  Rr = im(:,:,1); Gr = im(:,:,2); Br = im(:,:,3);
  assert([max(double(Rw(:))-double(Rr(:)))<30, \
          max(double(Gw(:))-double(Gr(:)))<30, \
	  max(double(Bw(:))-double(Br(:)))<30]);
  unlink('test.png');
else
  disp(">pngread ... not available");
  disp(">pngwrite ... not available");
endif
