## Copyright (C) 2005 Barre-Piquot
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
## @deftypefn {Function File} {@var{level}=} graythresh (@var{I})
## Compute global image threshold using Otsu's method.
##
## The output @var{level} is a global threshold (level) that can be used to convert
## an intensity image to a binary image with @code{im2bw}.
## @var{level} is a normalized intensity value that lies in the range [0, 1]. 
## 
## The function uses Otsu's method, which chooses the threshold to
## minimize the intraclass variance of the black and white pixels. 
## 
## Color images are converted grayscale before @var{level} is computed.
## @seealso{im2bw}
## @end deftypefn

## Note:
## This function is taken from
## http://www.irit.fr/~Philippe.Joly/Teaching/M2IRR/IRR05/
## I added texinfo documentation, error checking and sanitised the code.
##    -- Søren Hauberg

function level = graythresh (I)
    ## Input checking
    if (nargin != 1)
      print_usage();
    endif
    if (!isgray(I) && !isrgb(I))
      error("graythresh: input must be an image");
    endif
    
    ## If the image is RGB convert it to grayscale
    if (isrgb(I))
      I = rgb2gray(I);
    endif

    ## Calculation of the normalized histogram
    n = 256;
    h = hist(I(:), 1:n);        
    h = h/(length(I(:))+1);
    
    ## Calculation of the cumulated histogram and the mean values
    w = cumsum(h);
    mu = zeros(n, 1); mu(1) = h(1);
    for i=2:n
        mu(i) = mu(i-1) + i*h(i);
    end    
         
    ## Initialisation of the values used for the threshold calculation
    level = find (h > 0, 1);
    w0 = w(level);
    w1 = 1-w0;
    mu0 = mu(level)/w0;
    mu1 = (mu(end)-mu(level))/w1;
    max = w0*w1*(mu1-mu0)*(mu1-mu0);
    
    ## For each step of the histogram, calculation of the threshold and storing of the maximum
    for i = find (h > 0)
        w0 = w(i);
        w1 = 1-w0;
        mu0 = mu(i)/w0;
        mu1 = (mu(end)-mu(i))/w1;
        s = w0*w1*(mu1-mu0)*(mu1-mu0);
        if (s > max)
            max = s;
            level = i;
        endif
    endfor
    
    ## Normalisation of the threshold        
    level /= n;
endfunction
