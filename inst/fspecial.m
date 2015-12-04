## Copyright (C) 2005 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2015 Carnë Draug <carandraug@octave.org>
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
## @deftypefn {Function File} {} fspecial(@var{type}, @var{arg1}, @var{arg2})
## Create spatial filters for image processing.
##
## @var{type} determines the shape of the filter and can be
## @table @asis
## @item @qcode{"average"}
## Rectangular averaging filter. The optional argument @var{arg1} controls the
## size of the filter. If @var{arg1} is an integer @var{N}, a @var{N} by @var{N}
## filter is created. If it is a two-vector with elements @var{N} and @var{M}, the
## resulting filter will be @var{N} by @var{M}. By default a 3 by 3 filter is
## created.
##
## @item @qcode{"disk"}
## Circular averaging filter. The optional argument @var{arg1} controls the
## radius of the filter. If @var{arg1} is an integer @var{R}, a 2 @var{R} + 1
## filter is created. By default a radius of 5 is used. If the returned matrix
## corresponds to a cartesian grid, each element of the matrix is weighted by
## how much of the corresponding grid square is covered by a disk of radius
## @var{R} and centered at the middle of the element @var{R}+1,@var{R}+1.
##
## @item @qcode{"gaussian"}
## Gaussian filter. The optional argument @var{arg1} controls the size of the
## filter. If @var{arg1} is an integer @var{N}, a @var{N} by @var{N}
## filter is created. If it is a two-vector with elements @var{N} and @var{M}, the
## resulting filter will be @var{N} by @var{M}. By default a 3 by 3 filter is
## created. The optional argument @var{arg2} sets spread of the filter. By default
## a spread of @math{0.5} is used.
##
## @item @qcode{"log"}
## Laplacian of Gaussian. The optional argument @var{arg1} controls the size of the
## filter. If @var{arg1} is an integer @var{N}, a @var{N} by @var{N}
## filter is created. If it is a two-vector with elements @var{N} and @var{M}, the
## resulting filter will be @var{N} by @var{M}. By default a 5 by 5 filter is
## created. The optional argument @var{arg2} sets spread of the filter. By default
## a spread of @math{0.5} is used.
##
## @item @qcode{"laplacian"}
## 3x3 approximation of the laplacian. The filter is approximated as
##
## @example
## (4/(@var{alpha}+1)) * [   @var{alpha}/4   (1-@var{alpha})/4     @var{alpha}/4
##                  (1-@var{alpha})/4   -1          (1-@var{alpha})/4
##                     @var{alpha}/4   (1-@var{alpha})/4     @var{alpha}/4 ];
## @end example
##
## where @var{alpha} is a number between 0 and 1. This number can be controlled
## via the optional input argument @var{arg1}. By default it is @math{0.2}.
##
## @item @qcode{"unsharp"}
## Sharpening filter. The following filter is returned
## @example
## (1/(@var{alpha}+1)) * [-@var{alpha}   @var{alpha}-1 -@var{alpha}
##                   @var{alpha}-1 @var{alpha}+5  @var{alpha}-1
##                  -@var{alpha}   @var{alpha}-1 -@var{alpha}];
## @end example
##
## where @var{alpha} is a number between 0 and 1. This number can be controlled
## via the optional input argument @var{arg1}. By default it is @math{0.2}.
##
## @item @qcode{"motion"}
## Moion blur filter of width 1 pixel. The optional input argument @var{arg1}
## controls the length of the filter, which by default is 9. The argument @var{arg2}
## controls the angle of the filter, which by default is 0 degrees.
##
## @item @qcode{"sobel"}
## Horizontal Sobel edge filter. The following filter is returned
##
## @example
## [ 1  2  1
##   0  0  0
##  -1 -2 -1 ]
## @end example
##
## @item @qcode{"prewitt"}
## Horizontal Prewitt edge filter. The following filter is returned
##
## @example
## [ 1  1  1
##   0  0  0
##  -1 -1 -1 ]
## @end example
##
## @item "kirsch"
## Horizontal Kirsch edge filter. The following filter is returned
##
## @verbatim
## [ 3  3  3
##   3  0  3
##  -5 -5 -5 ]
## @end verbatim
## @end table
##
## @seealso{conv2, convn, filter2, imfilter}
## @end deftypefn

## Remarks by Søren Hauberg (jan. 2nd 2007)
## The motion filter and most of the documentation was taken from Peter Kovesi's
## GPL'ed implementation of fspecial from 
## http://www.csse.uwa.edu.au/~pk/research/matlabfns/OctaveCode/fspecial.m

function f = fspecial (type, arg1, arg2)

  if (nargin < 1)
    print_usage ();
  endif

  switch lower (type)
    case "average"
      ## Get filtersize
      if (nargin > 1 && isreal (arg1) && length (arg1 (:)) <= 2)
        fsize = arg1 (:);
      else
        fsize = 3;
      endif
      ## Create the filter
      f = ones (fsize);
      ## Normalize the filter to integral 1
      f = f / sum (f (:));

    case "disk"
      ## Get the radius
      if (nargin > 1 && isreal (arg1) && isscalar (arg1))
        r = arg1;
      else
        r = 5;
      endif
      ## Create the filter
      if (r == 0)
        f = 1;
      else
        ax = r + 1; # index of the "x-axis" and "y-axis"
        corner = floor (r / sqrt (2)+0.5)-0.5; # corner corresponding to 45 degrees
        rsq = r*r;
        ## First set values for points completely covered by the disk
        [X, Y] = meshgrid (-r:r, -r:r);
        rhi = (abs (X) +0.5).^2 + (abs (Y)+0.5).^2;
        f = (rhi <= rsq) / 1.0;
        xx = linspace (0.5, r - 0.5, r);
        ii = sqrt (rsq - xx.^2); # intersection points for sqrt (r^2 - x^2)
        ## Set the values at the axis caps
        tmp = sqrt (rsq -0.25);
        rint = (0.5*tmp + rsq * atan (0.5/tmp))/2; # value of integral on the right
        cap = 2*rint - r+0.5; # at the caps, lint = rint
        f(ax  ,ax+r) = cap;
        f(ax  ,ax-r) = cap;
        f(ax+r,ax  ) = cap;
        f(ax-r,ax  ) = cap;
        if (r == 1)
          y = ii(1);
          lint = rint;
          tmp = sqrt (rsq - y^2);
          rint = (y*tmp + rsq * atan (y/tmp))/2;
          val  = rint - lint - 0.5 * (y-0.5);
          f(ax-r,ax-r) = val;
          f(ax+r,ax-r) = val;
          f(ax-r,ax+r) = val;
          f(ax+r,ax+r) = val;
        else
          ## Set the values elsewhere on the rim
          idx = 1; # index in the vector ii
          x   = 0.5; # bottom left corner of the current square
          y   = r-0.5;
          rx  = 0.5; # x on the right of the integrable region
          ybreak = false; # did we change our y last time
          do
            i = x +0.5;
            j = y +0.5;
            lint = rint;
            lx = rx;
            if (ybreak)
              ybreak = false;
              val = lx-x;
              idx++;
              x++;
              rx = x;
              val -= y*(x-lx);
            elseif (ii(idx+1) < y)
              ybreak = true;
              y--;
              rx  = ii(y+1.5);
              val = (y+1) * (x-rx);
            else
              val = -y;
              idx++;
              x++;
              rx = x;
              if (floor (ii(idx)-0.5) == y)
                y++;
              endif
            endif
            tmp  = sqrt (rsq - rx*rx);
            rint = (rx*tmp + rsq * atan (rx/tmp))/2;
            val += rint - lint;
            f(ax+i, ax+j) = val;
            f(ax+i, ax-j) = val;
            f(ax-i, ax+j) = val;
            f(ax-i, ax-j) = val;
            f(ax+j, ax+i) = val;
            f(ax+j, ax-i) = val;
            f(ax-j, ax+i) = val;
            f(ax-j, ax-i) = val;
          until (y < corner || x > corner)
        endif
        # Normalize
        f /= pi * rsq;
      endif

    case "gaussian"
      ## fspecial ("gaussian", lengths = [3 3], sigma = 0.5)

      if (nargin < 2)
        lengths = [3 3];
      else
        validateattributes (arg1, {"numeric"}, {">", 0, "integer"},
                            "fspecial (\"gaussian\")", "HSIZE");
        nd = numel (arg1);
        if (nd == 1)
          lengths = [arg1 arg1];
          nd = 2;
        elseif (nd == 2)
          ## TODO add support for more dimensions
          lengths = arg1(:).';
        else
          error ("fspecial (\"gaussian\"): HSIZE must be a 1 or 2 elements vector");
        endif
      endif

      if (nargin < 3)
        sigma = 0.5;
      else
        ## TODO add support for different sigmas for each dimension
        validateattributes (arg2, {"numeric"}, {">", 0, "scalar"},
                            "fspecial (\"gaussian\")", "SIGMA");
        sigma = arg2;
      endif

      h1 = lengths(1) -1;
      h2 = lengths(2) -1;
      [x, y] = meshgrid (0:h2, 0:h1);
      x = x - (h2/2);
      y = y - (h1/2);
      gauss = exp (- (x.^2 + y.^2) / (2 * (sigma.^2)));
      f = gauss / sum (gauss(:));

    case "laplacian"
      ## Get alpha
      if (nargin > 1 && isscalar (arg1))
        alpha = arg1;
        if (alpha < 0 || alpha > 1)
          error ("fspecial: second argument must be between 0 and 1");
        endif
      else
        alpha = 0.2;
      endif
      ## Compute filter
      f = (4/(alpha+1))*[alpha/4,     (1-alpha)/4, alpha/4; ...
                         (1-alpha)/4, -1,          (1-alpha)/4;  ...
                         alpha/4,     (1-alpha)/4, alpha/4];
    case "log"
      ## Get hsize
      if (nargin > 1 && isreal (arg1))
        if (length (arg1 (:)) == 1)
          hsize = [arg1, arg1];
        elseif (length (arg1 (:)) == 2)
          hsize = arg1;
        else
          error ("fspecial: second argument must be a scalar or a vector of two scalars");
        endif
      else
        hsize = [5, 5];
      endif
      ## Get sigma
      if (nargin > 2 && isreal (arg2) && length (arg2 (:)) == 1)
        sigma = arg2;
      else
        sigma = 0.5;
      endif
      ## Compute the filter
      h1 = hsize (1)-1; h2 = hsize (2)-1; 
      [x, y] = meshgrid(0:h2, 0:h1);
      x = x-h2/2; y = y = y-h1/2;
      gauss = exp( -( x.^2 + y.^2 ) / (2*sigma^2) );
      f = ( (x.^2 + y.^2 - 2*sigma^2).*gauss )/( 2*pi*sigma^6*sum(gauss(:)) );

    case "motion"
      ## Taken (with some changes) from Peter Kovesis implementation 
      ## (http://www.csse.uwa.edu.au/~pk/research/matlabfns/OctaveCode/fspecial.m)
      ## FIXME: The implementation is not quite matlab compatible.
      if (nargin > 1 && isreal (arg1))
        len = arg1;
      else
        len = 9;
      endif
      if (mod (len, 2) == 1)
        sze = [len, len];
      else
        sze = [len+1, len+1];
      end
      if (nargin > 2 && isreal (arg2))
        angle = arg2;
      else
        angle = 0;
      endif
      
      ## First generate a horizontal line across the middle
      f = zeros (sze);
      f (floor (len/2)+1, 1:len) = 1;

      # Then rotate to specified angle
      f = imrotate (f, angle, "bilinear", "loose");
      f = f / sum (f (:));

    case "prewitt"
      ## The filter
      f = [1, 1, 1; 0, 0, 0; -1, -1, -1];
      
    case "sobel"
      ## The filter
      f = [1, 2, 1; 0, 0, 0; -1, -2, -1];
      
    case "kirsch"
      ## The filter
      f = [3, 3, 3; 3, 0, 3; -5, -5, -5];
    
    case "unsharp"
      ## Get alpha
      if (nargin > 1 && isscalar (arg1))
        alpha = arg1;
        if (alpha < 0 || alpha > 1)
          error ("fspecial: second argument must be between 0 and 1");
        endif
      else
        alpha = 0.2;
      endif
      ## Compute filter
      f = (1/(alpha+1))*[-alpha,   alpha-1, -alpha; ...
                          alpha-1, alpha+5,  alpha-1; ...
                         -alpha,   alpha-1, -alpha];

    otherwise
      error ("fspecial: filter type '%s' is not supported", type);
  endswitch
endfunction

##
## Tests for disk shape
##

## Test that the disk filter's error does not grow unreasonably large
%!test
%! for i = 1:9
%!   n = 2^i;
%!   assert (sum (fspecial ("disk", n)(:)), 1, eps*n*n);
%! endfor

## Test that all squares completely under the disk or completely out of it are
## being assigned the correct values.
%!test
%! for r = [3 5 9 17]
%!   f = fspecial ("disk", r);
%!   [X, Y] = meshgrid (-r:r, -r:r);
%!   rhi = (abs (X) + 0.5).^2 + (abs (Y) + 0.5).^2;
%!   rlo = (abs (X) - 0.5).^2 + (abs (Y) - 0.5).^2;
%!   fhi = (rhi <= (r^2));
%!   flo = (rlo >= (r^2));
%!   for i = 1:(2*r+1)
%!     for j = 1:(2*r+1)
%!       if (fhi(i,j))
%!         assert (f(i,j), 1/(pi*r^2), eps);
%!       endif
%!       if (flo(i,j))
%!         assert (f(i,j), 0);
%!       endif
%!     endfor
%!   endfor
%! endfor

##
## Tests for gaussian shape
##

%!error <HSIZE must be greater than 0>
%!  fspecial ("gaussian", 0)
%!error <HSIZE must be integer>
%!  fspecial ("gaussian", 3.9)

%!assert (fspecial ("gaussian"), fspecial ("gaussian", 3, 0.5))
%!assert (fspecial ("gaussian"), fspecial ("gaussian", [3 3], 0.5))

%!test
%! c = ([-1:1].^2) .+ ([-1:1]'.^2);
%! gauss = exp (- (c ./ (2 * (0.5 .^ 2))));
%! f = gauss / sum (gauss(:));
%! assert (fspecial ("gaussian"), f)
%!
%! expected = [
%!   0.01134373655849507   0.08381950580221061   0.01134373655849507
%!   0.08381950580221061   0.61934703055717721   0.08381950580221061
%!   0.01134373655849507   0.08381950580221061   0.01134373655849507];
%! assert (f, expected, eps)

## An implementation of the function for 2d, we must also check it
## against some of the values.  Note that hsize is (radius -1) and
## only works for odd lengths.
%!function f = f_gaussian_2d (hsize, sigma)
%!  c = ([(-hsize(1)):(hsize(1))]'.^2) .+ ([(-hsize(2)):(hsize(2))].^2);
%!  gauss = exp (- (c ./ (2 * (sigma .^ 2))));
%!  f = gauss ./ sum (gauss(:));
%!endfunction

%!test
%! f = fspecial ("gaussian");
%! assert (f, f_gaussian_2d ([1 1], .5))
%! expected = [
%!   0.01134373655849507   0.08381950580221061   0.01134373655849507
%!   0.08381950580221061   0.61934703055717721   0.08381950580221061
%!   0.01134373655849507   0.08381950580221061   0.01134373655849507];
%! assert (f, expected, eps)

%!test
%! f = fspecial ("gaussian", 7, 2);
%! assert (f, f_gaussian_2d ([3 3], 2))
%! expected = [
%!    0.00492233115934352
%!    0.00919612528958620
%!    0.01338028334410124
%!    0.01516184737296414
%!    0.01338028334410124
%!    0.00919612528958620
%!    0.00492233115934352
%!    0.00919612528958620
%!    0.01718062389630964
%!    0.02499766026691484
%!    0.02832606006174462
%!    0.02499766026691484
%!    0.01718062389630964
%!    0.00919612528958620
%!    0.01338028334410124
%!    0.02499766026691484
%!    0.03637138107390363
%!    0.04121417419979795
%!    0.03637138107390363
%!    0.02499766026691484
%!    0.01338028334410124
%!    0.01516184737296414
%!    0.02832606006174462
%!    0.04121417419979795
%!    0.04670177773892775];
%! expected = reshape ([expected; expected((end-1):-1:1)], [7 7]);
%! assert (f, expected, eps)

%!test
%! f = fspecial ("gaussian", [7 5], 2);
%! assert (f, f_gaussian_2d ([3 2], 2))
%! expected = [
%!    0.01069713252648568
%!    0.01998487459872362
%!    0.02907782096336423
%!    0.03294948784319031
%!    0.02907782096336423
%!    0.01998487459872362
%!    0.01069713252648568
%!    0.01556423598706978
%!    0.02907782096336423
%!    0.04230797985750011
%!    0.04794122192790870
%!    0.04230797985750011
%!    0.02907782096336423
%!    0.01556423598706978
%!    0.01763658993191515
%!    0.03294948784319031
%!    0.04794122192790870
%!    0.05432452146574315];
%! expected = reshape ([expected; expected((end-1):-1:1)], [7 5]);
%! assert (f, expected, eps)

%!test
%! f = fspecial ("gaussian", [4 2], 2);
%! expected = [0.10945587477855045 0.14054412522144952];
%! expected = expected([1 1; 2 2; 2 2; 1 1]);
%! assert (f, expected, eps)

%!test
%! expected =[0.04792235409415088 0.06153352068439959 0.07901060453704994];
%! expected = expected([1 2 2 1; 2 3 3 2; 2 3 3 2; 1 2 2 1]);
%! assert (fspecial ("gaussian", 4, 2), expected)
