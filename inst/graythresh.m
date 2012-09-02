## Copyright (C) 2005 Barre-Piquot
## Copyright (C) 2007 Søren Hauberg
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {[@var{level}, @var{sep}] =} graythresh (@var{img})
## @deftypefnx {Function File} {[@var{level}, @var{sep}] =} graythresh (@var{img}, @var{algo})
## Compute global image threshold.
##
## Given an image @var{img} finds the optimal threshold value @var{level} for
## conversion to a binary image with @code{im2bw}. Color images are converted
## to grayscale before @var{level} is computed.
##
## The optional argument @var{method} is the algorithm to be used (default's to
## Otsu). The available algorithms are:
##
## @table @asis
## @item "Otsu" (default)
## Implements Otsu's method as described in @cite{Nobuyuki Otsu (1979). "A
## threshold selection method from gray-level histograms". IEEE Trans. Sys.,
## Man., Cyber. 9 (1): 62-66}. This algorithm chooses the threshold to minimize
## the intraclass variance of the black and white pixels. The second output,
## @var{sep} represents the ``goodness'' (or separability) of the threshold at
## @var{level}.
##
## @item Huang
## Not yet implemented.
##
## @item ImageJ
## Not yet implemented.
##
## @item intermodes
## Not yet implemented.
##
## @item IsoData
## Not yet implemented.
##
## @item Li
## Not yet implemented.
##
## @item MaxEntropy
## Not yet implemented.
##
## @item mean
## Not yet implemented.
##
## @item MinError
## Not yet implemented.
##
## @item minimum
## Not yet implemented.
##
## @item moments
## Not yet implemented.
##
## @item percentile
## Not yet implemented.
##
## @item RenyiEntropy
## Not yet implemented.
##
## @item Shanbhag
## Not yet implemented.
##
## @item triangle
## Not yet implemented.
##
## @item Yen
## Not yet implemented.
## @end table
##
## @seealso{im2bw}
## @end deftypefn

## Notes:
##  * Otsu's method is a function taken from
##    http://www.irit.fr/~Philippe.Joly/Teaching/M2IRR/IRR05/ Søren Hauberg
##    added texinfo documentation, error checking and sanitised the code.

function [level, goodness] = graythresh (img, algo = "otsu")
    ## Input checking
    if (nargin < 1 || nargin > 2)
      print_usage();
    elseif (!isgray (img) && !isrgb (img))
      error ("graythresh: input must be an image");
    endif

    ## If the image is RGB convert it to grayscale
    if (isrgb(img))
      img = rgb2gray (img);
    endif

    switch tolower (algo)
      case {"otsu"}
        ## Calculation of the normalized histogram
        n = intmax (class (img)) + 1;
        h = hist (img(:), 1:n);
        h = h / (length (img(:)) + 1);

        ## Calculation of the cumulated histogram and the mean values
        w  = cumsum (h);
        mu = zeros (n, 1);
        mu(1) = h(1);
        for i = 2:n
            mu(i) = mu(i-1) + i * h(i);
        endfor

        ## Initialisation of the values used for the threshold calculation
        level = find (h > 0, 1);
        w0  = w(level);
        w1  = 1 - w0;
        mu0 = mu(level) / w0;
        mu1 = (mu(end) - mu(level)) / w1;
        goodness = w0 * w1 * (mu1 - mu0) * (mu1 - mu0);
        
        ## For each step of the histogram, calculation of the threshold
        ## and storing of the maximum
        for i = find (h > 0)
            w0 = w(i);
            w1 = 1 - w0;
            mu0 = mu(i) / w0;
            mu1 = (mu(end) - mu(i)) / w1;
            s = w0 * w1 * (mu1 - mu0) * (mu1 - mu0);
            if (s > max)
                goodness = s;
                level    = i;
            endif
        endfor
        
        ## Normalisation of the threshold
        level /= n;
      otherwise
        error ("graythresh: unknown method '%s'", algo);
    endswitch
endfunction
