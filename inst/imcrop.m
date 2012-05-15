## Copyright (C) 2012 Pablo Rossi <prossi@ing.unrc.edu.ar>
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
## @deftypefn {Function File} @var{col} = imcrop (@var{Img})
## Crop image.
##
## Displays the image @var{Img} in a figure window and creates a
## cropping tool associated with that image. Pick: first the top left
## corner, second bottom right. The cropped image returned, @var{col}.
## @end deftypefn

## Author:  Pablo Rossi <prossi@ing.unrc.edu.ar>
## Date:    13 March 2012

function col = imcrop (Img)

  imshow(Img);
  [a,b]=size(Img);
  [hl,rd]=ginput;

  if hl(1)<=1; hl(1)=1; endif

  if rd(1)<=1; rd(1)=1; endif

  if hl(2)>=b; hl(2)=b; endif

  if rd(2)>=a; rd(2)=a; endif

  while hl(1) > hl(2) || rd(1) > rd(2)

    display ("Pick: first the top left corner, second bottom right","Error Procedure");

    [hl,rd]=ginput;

    if hl(1)<=1; hl(1)=1; endif

    if rd(1)<=1; rd(1)=1; endif

    if hl(2)>=b; hl(2)=b; endif

    if rd(2)>=a; rd(2)=a; endif

  endwhile

  hl=floor(hl);
  rd=floor(rd);
  col=[];
  col=Img(rd(1):rd(2),hl(1):hl(2));

endfunction
