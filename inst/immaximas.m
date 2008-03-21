## Copyright (c) 2003-2005 Peter Kovesi
## School of Computer Science & Software Engineering
## The University of Western Australia
## http://www.csse.uwa.edu.au/
##   
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## The Software is provided "as is", without warranty of any kind.
##
## I've made minor changes compared to the original 'nonmaxsuppts' function developed
## by Peter Kovesi. The original is available at
## http://www.csse.uwa.edu.au/~pk/research/matlabfns/Spatial/nonmaxsuppts.m
##    -- Søren Hauberg, 2008

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{r}, @var{c}] =} immaximas (@var{im}, @var{radius})
## @deftypefnx{Function File} {[@var{r}, @var{c}] =} immaximas (@var{im}, @var{radius}, @var{thresh})
## Finds local spatial maximas of the given image. A local spatial maxima is
## defined as an image point with a value that is larger than all neighbouring
## values in a square region of width 2*@var{radius}+1. By default @var{radius}
## is 1, such that a 3 by 3 neighbourhood is searched. If the @var{thresh} input
## argument is supplied, only local maximas with a value greater than @var{thresh}
## are retained.
## 
## The output vectors @var{r} and @var{c} contain the row-column coordinates
## of the local maximas. The actual values are computed to sub-pixel precision
## by fitting a parabola to the data around the pixel.
## @end deftypefn

function [r, c] = immaximas(im, radius, thresh)
  ## Check input
  if (nargin == 0)
    error("immaximas: not enough input arguments");
  endif
  if (nargin <= 1 || isempty(radius))
    radius = 1;
  endif
  if (nargin <= 2)
    thresh = [];
  endif
  if (!ismatrix(im) || ndims(im) != 2)
    error("immaximas: first input argument must be an M by N matrix");
  endif
  if (!isscalar(radius) && !isempty(radius))
    error("immaximas: second input argument must be a scalar or an empty matrix");
  endif
  if (!isscalar(thresh) && !isempty(thresh))
    error("immaximas: third input argument must be a scalar or an empty matrix");
  endif
  
  ## Find local maximas
  s = size(im);
  sze = 2*radius+1;
  mx = ordfilt2(im, sze^2, ones(sze, "logical"));
  mx2 = ordfilt2(im, sze^2-1, ones(sze, "logical"));

  ## Make mask to exclude points within radius of the image boundary. 
  bordermask = zeros(s, "logical");
  bordermask(radius+1:end-radius, radius+1:end-radius) = 1;
    
  # Find maxima, threshold, and apply bordermask
  immx = (im == mx) & (im != mx) & bordermask;
  if (!isempty(thresh))
    immx &= (im>thresh);
  endif
    
  ## Find local maximas and fit parabolas locally
  [r, c] = find(immx);
  if (!isempty(r))
    ind = sub2ind(s,r,c); # 1D indices of feature points
    w = 1; # Width that we look out on each side of the feature point to fit a local parabola

    ## Indices of points above, below, left and right of feature point
    indrminus1 = max(ind-w,1);
    indrplus1  = min(ind+w,s(1)*s(2));
    indcminus1 = max(ind-w*s(1),1);
    indcplus1  = min(ind+w*s(1),s(1)*s(2));

    ## Solve for quadratic down rows
    cy = im(ind);
    ay = (im(indrminus1) + im(indrplus1))/2 - cy;
    by = ay + cy - im(indrminus1);
    rowshift = -w*by./(2*ay); # Maxima of quadradic

    ## Solve for quadratic across columns
    cx = im(ind);
    ax = (im(indcminus1) + im(indcplus1))/2 - cx;
    bx = ax + cx - im(indcminus1);
    colshift = -w*bx./(2*ax); # Maxima of quadradic

    ## Add subpixel corrections to original row and column coords.
    r += rowshift;
    c += colshift;
  endif
endfunction

