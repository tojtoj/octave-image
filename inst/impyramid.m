## Copyright (C) 2015 Avinoam Kalma <a.kalma@gmail.com>
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation; either version 3 of the
## License, or (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see
## <http:##www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} impyramid (@var{im}, @var{direction})
## Compute gaussian pyramid expansion of reduction.
##
## Create image which is one level up or down in the Gaussian
## pyramid.  @var{direction} must be @qcode{"reduce"} or
## @qcode{"expand"}.
##
## The @qcode{"reduce"} stage is done by low-pass filtering and
## subsampling of 1:2 in each axis.  If the size of the original
## image is [M N], the size of the reduced image is
## @qcode{[ceil((M+1)/2) ceil((N+1)/2)]}.
##
## The @qcode{"expand"} stage is done by upsampling the image
## (2:1 in each axis), and then low-pass filtering.  If the size
## of the original image is [M N], the size of the expanded image
## is @code{[2M-1 2N-1]}.
##
## Note that image processing pyramids are upside down, so
## @qcode{"reduce"} is going one level @emph{down} in the pyramid,
## while @qcode{"expand"} is going one level @emph{up} in the pyramid.
##
## @example
## @group
## impyramid (im, "reduce");   # return reduced image (one level down)
## impyramid (im, "expand");   # return expanded image (one level up)
## @end group
## @end example
##
## The low-pass filter is done according to Burt & Adelson [1]
## @code{W(i,j) = w(i)w(j)} where
## @code{w = [0.25-alpha/2 0.25 alpha 0.25 0.25-alpha/2]} with
## @code{alpha = 0.375}
##
## [1] Burt, P. J., & Adelson, E. H. (1983).  The Laplacian pyramid
## as a compact image code.  IEEE Transactions on Communications,
## vol. COM-31(4), 532-540.
##
## @seealso{imresize, imfilter}
## @end deftypefn

## Author: Avinoam Kalma <a.kalma@gmail.com>

function imp = impyramid (im, direction)

  if (nargin != 2)
    print_usage ();
  elseif (! isnumeric (im))
    error ("impyramid: IM must be numeric.")
  elseif (ndims (im) != 2 && ndims (im) != 3)
    error ("impyramid: IM should have 2 or 3 dimensions.")
  endif

  ## FIXME: impyramid handles only 2&3 dimensions images.
  ## it should handle n dimensional input
  ## see https://savannah.gnu.org/patch/?8612#comment1 item #3.

  direction = tolower (direction);
  ndim = ndims (im);

  ## low pass filter to be used
  alpha = 0.375;
  filt = [0.25-alpha/2 0.25 alpha 0.25 0.25-alpha/2];

  r = rows (im);
  c = columns (im);

  switch (direction)
    case "reduce"
      ##  perform horizontal low pass filtering
      im1 = imfilter (im, filt, "replicate");
      ##  perform vertical low pass filtering
      im2 = imfilter (im1, filt', "replicate");

      ##  subsampling
      if (ndim == 2)
        imp = im2(1:2:r,1:2:c);
      else
        imp = im2(1:2:r,1:2:c,:);
      end

    case "expand"
      if (ndim == 2)
      ## creating image with dimensions that are twice
        im1 = zeros (2*r-1,2*c-1, class(im));
        ## put original image in odd pixels
        im1 (1:2:2*r-1,1:2:2*c-1) = im;
      else
        ## creating image with the correct dimensions
        im1 = zeros (2*r-1,2*c-1, size(im,3), class(im));
        ## put original image in odd pixels
        im1 (1:2:2*r-1,1:2:2*c-1,:) = im;
      endif
      ##  perform horizontal low pass filtering
      im2 = 2*imfilter (im1, filt);
      ##  perform vertical low pass filtering
      imp = 2*imfilter (im2, filt');
    otherwise
      error ("impyramid: direction must be 'reduce' or 'expand'")
  endswitch
endfunction

%!test
%! in = [116  227  153   69  146  194   59  130  139  106
%!         2   47  137  249   90   75   16   24  158   44
%!       155   68   46   84  166  156   69  204   32  152
%!        71  221  137  230  210  153  192  115   30  118
%!       107  143  108   52   51   73  101   21  175   90
%!        54  158  143   77   26  168  113  229  165  225
%!         9   47  133  135  130  207  236   43   19   73];
%!
%! reduced = [114   139   131   103   110
%!             97   122   140   110   100
%!            103   123   112   124   122
%!             47   107   134   153    94];
%!
%! expand = [
%!    88  132  160  154  132  108   94  102  120  138  138  100   66   74   96  112  116  104   78
%!    62   98  128  142  146  154  154  140  126  126  122   86   54   58   82  114  132  112   74
%!    36   54   74  100  130  168  184  156  118  104   92   64   40   44   66  100  122  104   66
%!    66   68   64   76   98  130  154  148  132  122  108   80   60   78  104  106   98   98   86
%!   104  106   88   78   78   96  122  144  154  154  140  112   98  124  144  110   74   92  106
%!   102  130  134  120  108  126  154  174  180  172  156  142  138  146  140   96   60   84  106
%!    88  140  170  158  140  156  180  188  180  164  152  154  156  140  112   82   66   84   96
%!    90  136  164  154  134  132  138  136  130  122  120  130  134  108   82   86  100  104   92
%!    92  126  142  136  116   96   80   74   72   82   94  106  106   88   78  108  138  132  102
%!    80  116  140  138  122   96   68   52   52   80  110  114  112  118  128  148  164  164  140
%!    58   98  132  140  130  110   82   62   62  102  142  144  138  154  168  164  156  170  162
%!    36   68  100  120  130  122  106   92   96  134  174  182  172  156  136  116  104  122  124
%!    16   34   58   86  108  114  110  106  112  138  170  184  172  126   74   48   44   60   68];
%!
%! assert (impyramid (uint8 (in), "reduce"), uint8 (reduced))
%! assert (impyramid (uint8 (in), "expand"), uint8 (expand))
