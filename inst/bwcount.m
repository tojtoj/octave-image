## (C) 2010 Muthiah Annamalai <muthuspost@gmail.com>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
## 

## Find the blobs in a binary image, return the number,
## position of blobs and area. Connected-ness is taken 
## in the 8-neighborhood of the images.
## 
## Input: 'img' a binary image. Grayscale images with non-zero values
##        taken as logical 1.
## 
## Output: result structure with elements, nblob - gives number of contours,
##         a cell array of position coordinates as 2xN matrix of indices,
##         and a matrix of blobarea. Indices correspond to the enumerated
##         contours in the same order.
## 
## eg: load 'smiley.dat'; r = bwcount(smiley)
## r =
## {
##     nblob =  4
##     blobpos = {4 element cell-array of 2xN matrices}
##     blobarea = [ 28    4    4    4 ]
## }
##
function result = bwcount( origimg )

  result = {}; result.nblob = 0; result.blobpos = {}; result.blobarea = [];

  ## Standard Contour finding algoritm using queues.
  img = origimg; irows = size( img, 1 ); icols = size( img, 2 );
  while ( 1 )
    [rpos,cpos] = find( img > 0 );
    if ( isempty( rpos ) | isempty( cpos ) )
        break;
    end
    rpos = rpos(1); cpos = cpos(1);
    
    ## Queue of positions to visit.
    q = [rpos;cpos]; bpos = [];
    while( ~isempty( q ) )
        ## dequeue the next 'on' pixel and save it as part of our contour.
        rpos = q(1,1); cpos = q(2,1); q = q(:,2:end);
        bpos = [ bpos, [rpos; cpos]];
        
        ## check 8-connected nbhd in a clockwise fashion
        ## and ( turn-off pixel ) queue up all the on-pixels of blob.        
        
        ## same-row
        ## same-row same-col pixel is already counted so turn it off
        img( rpos, cpos ) = 0;
        if ( cpos + 1 <= icols )
              if ( img( rpos , cpos + 1) > 0 )
                 img( rpos, cpos + 1 ) = 0;
                 newpixel = [ rpos ; cpos + 1 ];
                 q = [q, newpixel];
              end                
        end
        if ( cpos - 1 >= 1 )
              if ( img( rpos , cpos - 1) > 0 )
                  img( rpos, cpos - 1 ) = 0;
                  newpixel = [ rpos ; cpos - 1 ];
                  q = [q, newpixel];
              end
        end

        ## next-row
        if( rpos + 1 <= irows )
            if ( img( rpos + 1, cpos ) > 0 )
                img( rpos + 1, cpos ) = 0;
                newpixel = [ rpos + 1; cpos];
                q = [q, newpixel];
            end
            if ( cpos + 1 <= icols )
                if ( img( rpos + 1, cpos + 1) > 0 )
                    img( rpos + 1, cpos + 1 ) = 0;
                    newpixel = [ rpos + 1; cpos + 1 ];
                    q = [q, newpixel];
                end                
            end
            if ( cpos - 1 >= 1 )
                if ( img( rpos + 1, cpos - 1) > 0 )
                    img( rpos + 1, cpos - 1 ) = 0;
                    newpixel = [ rpos + 1; cpos - 1 ];
                    q = [q, newpixel];
                end
            end
        end
        
        ## prev-row
        if( rpos - 1 >= 1 )
            if ( img( rpos - 1, cpos ) > 0 )
                img( rpos - 1, cpos ) = 0;
                newpixel = [ rpos - 1; cpos];
                q = [q, newpixel];
            end
            if ( cpos + 1 <= icols )
                if ( img( rpos - 1, cpos + 1) > 0 )
                    img( rpos - 1, cpos + 1 ) = 0;
                    newpixel = [ rpos - 1; cpos + 1 ];
                    q = [q, newpixel];
                end                
            end
            if ( cpos - 1 >= 1 )
                if ( img( rpos - 1, cpos - 1) > 0 )
                    img( rpos - 1, cpos - 1 ) = 0;
                    newpixel = [ rpos - 1; cpos - 1 ];
                    q = [q, newpixel];
                end
            end
        end                    
    end

    result.nblob = result.nblob + 1;
    result.blobpos{result.nblob} = bpos;
    result.blobarea(result.nblob) = size(bpos,2);
  end

  return
end
