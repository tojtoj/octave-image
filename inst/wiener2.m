## Copyright (C) 2017 Hartmut Gimpel <hg_code@gmx.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {@var{J} =} @ wiener2 (@var{I})
## @deftypefnx {Function File} {@var{J} =} @ wiener2 (@var{I}, [@var{m}, @var{n}])
## @deftypefnx {Function File} {@var{J} =} @ wiener2 (@var{I}, @var{noise})
## @deftypefnx {Function File} {@var{J} =} @ wiener2 (@var{I}, [@var{m}, @var{n}], @var{noise})
## @deftypefnx {Function File} {[@var{J}, @var{noise}] =} @
##    wiener2 (@var{I}, [@var{m}, @var{n}])
## Apply an adaptive noise reduction filter on a 2D grayscale image.
##
## The wiener2 function locally applies a linear averaging filter to the input
## image @var{I}. The averaging operation will be performed using the
## given [@var{m}, @var{n}] neighborhood of each pixel.
## The strength of the averaging depends on the local variance in this
## neighborhood and on the given variance of the @var{noise} (of mean zero).
## As a result, pixels in a region with higher contrast will be smoothed less,
## and pixels in a region with lower contrast will be smoothed more.
##
## This operation is useful to remove noise from the image, while blurring edges
## much less compared to a global linear averaging filter.
##
## The @var{m}-by-@var{n} neighborhood defaults to 3-by-3 if not given.
## The @var{noise} variance will be estimated by the mean variance
## in the neighborhoods, if not given.
##
## @seealso{imfilter, medfilt2}
## @end deftypefn

## The algorithm is taken from the book
## "Two-Dimensional Signal and Image Processing"
## by Jae S. Lim, Prentice Hall Ptr, 1st edition 1989.
## Equations (9.26), (9.27) and (9.29) on page 538 - 539.

function [mean_im, noise] = wiener2 (im, varargin)

  ## Default parameters:
  noise = [];
  nhood = [3 3];

  if (nargin < 1 || nargin > 3)
    print_usage ();

  elseif (nargin == 1)
    ## wiener2 (I), do nothing.

  elseif (nargin == 2)
    if (numel (varargin{1}) == 1)
      ## wiener2 (I, noise)
      noise = varargin{1};
    elseif (numel (varargin{1}) == 2)
      ## wiener2 (I, [m, n])
      nhood = varargin{1};
    else
      print_usage ();
    endif

  elseif (nargin == 3)
    ## wiener2 (I, [m, n], noise)
    nhood = varargin{1};
    noise = varargin{2};
  endif

  if (! isimage (im) || islogical (im) || ndims (im) != 2)
    error ("wiener2: I must be a 2D image");
  elseif (! isreal (noise) || (numel (noise) != 0 && numel (noise) != 1))
    error ("wiener2: NOISE must be a real number");
  elseif (! isreal (nhood) || numel (nhood) != 2)
    error ("wiener2: NHOOD must be a 1x2 vector of the form [N, M]");
  endif

  ## transform input image to class double (leave class single alone):
  class_before = class (im);
  if (! isfloat (im))
    im = im2double (im);
  endif

  ## do the Wiener filtering:
  ## This is the algorithm from the book cited above:
  ## im_out = mean_im + variance_orig / (variance_orig + variance_noise) * (im - mean_im)
  ## with
  ## variance_orig = variance_im - variance_noise if variance_im > variance_noise
  ## variance_orig = 0 otherwise
  ## and
  ## mean_im = "mean value of pixel neighborhood" in im
  ## variance_im = "variance of pixel neighbohood" in im
  ## variance_noise = "variance of noise" to be removed (mean_noise assumed to be zero)
  box_filter = ones (nhood) ./ prod (nhood);
  mean_im = imfilter (im, box_filter);

  variance_im = imfilter (im.^ 2, box_filter) - mean_im.^ 2;

  if (isempty (noise))
    noise = mean (variance_im(:));
  endif

  variance_im = max (0, variance_im - noise); # = variance_orig
  mean_im +=  variance_im ./ (variance_im + noise) .* (im - mean_im); # = im_out

  ## restore original class of input image:
  mean_im = imcast (mean_im, class_before);

endfunction

%!shared im0, im0_out, im0_n
%! im0 = ones(5,5);
%! im0_out = ones(5,5);
%! im0_out(1:4:5, 1:4:5) = 0.67111;
%! im0_out(1:4:5, 2:4) = 0.78074;
%! im0_out(2:4, 1:4:5) = 0.78074;
%! im0_n = 0.1462;

## test input syntax:
%!error wiener2 ()
%!assert (wiener2 (im0))
%!assert (wiener2 (im0, [2, 3]))
%!assert (wiener2 (im0, 0.5))
%!assert (wiener2 (im0, [2, 3], 0.5))
%!error wiener2 (im0, [2, 3], 0.5, 2)

## test dimensions and classes:
%!test
%! [im_out, noise_out] = wiener2 (im0);
%! assert (size (im_out), size (im0))
%! assert (class (noise_out), "double")
%! assert (numel (noise_out), 1)

%!assert (wiener2 (im0), im0_out, 1e-5)
%!assert (wiener2 (single (im0)), single (im0_out), 1e-5)
%!assert (class (wiener2 (single (im0))), "single")
%!assert (wiener2 (im2uint8 (im0)), im2uint8 (im0_out))
%!assert (class (wiener2 (im2uint8 (im0))), "uint8")
%!assert (wiener2 (im2uint16 (im0)), im2uint16 (im0_out), 1)
%!assert (class (wiener2 (im2uint16 (im0))), "uint16")
%!assert (wiener2 (im2int16 (im0)), im2int16 (im0_out), 1)
%!assert (class (wiener2 (im2int16 (im0))), "int16")
%!error wiener2 (true (5))

## test calculation results:
%!test
%! im_out = wiener2 (im0);
%! assert (im_out, im0_out, 1e-4)
%! [out, n] = wiener2 (im0);
%! assert (out, im0_out, 1e-4)
%! assert (n, im0_n, 1e-4)

%!test
%! im1 = zeros (5, 5);
%! im1(2:4, 2:4) = 1;
%! im1_out = [
%!    0.1111    0.2222    0.2726    0.2222    0.1111;
%!    0.2222    0.5911    0.7274    0.5911    0.2222;
%!    0.2726    0.7274    1.0000    0.7274    0.2726;
%!    0.2222    0.5911    0.7274    0.5911    0.2222;
%!    0.1111    0.2222    0.2726    0.2222    0.1111];
%! im1_n = 0.1817;
%! im1_out_55 = [
%!    0.1600    0.2400    0.2400    0.2400    0.1600;
%!    0.2400    0.4667    0.4667    0.4667    0.2400;
%!    0.2400    0.4667    0.4667    0.4667    0.2400;
%!    0.2400    0.4667    0.4667    0.4667    0.2400;
%!    0.1600    0.2400    0.2400    0.2400    0.1600];
%! im1_n_55 = 0.1920;
%! im1_out_05 = [
%!    0.1111    0.2222    0.3333    0.2222    0.1111;
%!    0.2222    0.4444    0.6667    0.4444    0.2222;
%!    0.3333    0.6667    1.0000    0.6667    0.3333;
%!    0.2222    0.4444    0.6667    0.4444    0.2222;
%!    0.1111    0.2222    0.3333    0.2222    0.1111];
%! im1_out_55_05 = [
%!    0.1600    0.2400    0.2400    0.2400    0.1600;
%!    0.2400    0.3600    0.3600    0.3600    0.2400;
%!    0.2400    0.3600    0.3600    0.3600    0.2400;
%!    0.2400    0.3600    0.3600    0.3600    0.2400;
%!    0.1600    0.2400    0.2400    0.2400    0.1600];
%! im1_out_35 = [
%!    0.1333    0.2000    0.2000    0.2000    0.1333;
%!    0.2642    0.5156    0.5156    0.5156    0.2642;
%!    0.3230    0.6770    0.6770    0.6770    0.3230;
%!    0.2642    0.5156    0.5156    0.5156    0.2642;
%!    0.1333    0.2000    0.2000    0.2000    0.1333];
%! im1_out_51 = [
%!         0    0.2400    0.2400    0.2400         0
%!         0    0.7600    0.7600    0.7600         0
%!         0    0.7600    0.7600    0.7600         0
%!         0    0.7600    0.7600    0.7600         0
%!         0    0.2400    0.2400    0.2400         0];
%! assert (wiener2 (im1), im1_out, 1e-4)
%! [out, n] = wiener2 (im1);
%! assert (out, im1_out, 1e-4)
%! assert (n, im1_n, 1e-4)
%! assert (wiener2 (im1, [5, 5]), im1_out_55, 1e-4)
%! [out, n] = wiener2 (im1, [5, 5]);
%! assert (out, im1_out_55, 1e-4)
%! assert (n, im1_n_55, 1e-4)
%! assert (wiener2 (im1, 0.5), im1_out_05, 1e-4)
%! assert (wiener2 (im1, [5, 5], 0.5), im1_out_55_05, 1e-4)
%! assert (wiener2 (im1, [3, 5]), im1_out_35, 1e-4)
%! assert (wiener2 (im1, [5, 1]), im1_out_51, 1e-4)

%!test
%! im2 = zeros (5, 5);
%! im2(2:4, 2:4) = 70;
%! im2(3, 3) = 90;
%! im2 = uint8 (im2);
%! im2_out = uint8 ([
%!    8   16   20   16    8 ;
%!   16   46   54   46   16;
%!   20   54   72   54   20;
%!   16   46   54   46   16;
%!    8   16   20   16    8 ]);
%! im2_n = 0.0146;
%! im2_out_55 = uint8 ([
%!   12   18   18   18   12;
%!   18   32   32   32   18;
%!   18   32   35   32   18;
%!   18   32   32   32   18;
%!   12   18   18   18   12]);
%! im2_n_55 = 0.0160;
%! im2_out_03 = uint8 ([
%!    8   16   23   16    8 ;
%!   16   33   49   33   16;
%!   23   49   72   49   23;
%!   16   33   49   33   16;
%!    8   16   23   16    8 ]);
%! im2_n_03 = 0.3000;
%! [out, n] = wiener2 (im2);
%! assert (out, im2_out)
%! assert (n, im2_n, 1e-4)
%! [out, n] = wiener2 (im2, [5, 5]);
%! assert (out, im2_out_55)
%! assert (n, im2_n_55, 1e-4)
%! [out, n] = wiener2 (im2, 0.3);
%! assert (out, im2_out_03)
%! assert (n, im2_n_03, 1e-4)

%!test
%! im3 = zeros (5, 5);
%! im3(2:4, 2:4) = 70;
%! im3(3, 3) = 20;
%! im3 = uint8 (im3);
%! im3_out = uint8 ([
%!    8   16   19   16    8 ;
%!   16   32   47   32   16;
%!   19   47   64   47   19;
%!   16   32   47   32   16;
%!    8   16   19   16    8 ]);
%! im3_n = 0.0134;
%! [out, n] = wiener2 (im3);
%! assert (out, im3_out)
%! assert (n, im3_n, 1e-4)

%!test
%! im4 = 50 .* ones (5, 5);
%! im4(:, 1) = 200;
%! im4(:, 2) = 100;
%! im4 = uint8 (im4);
%! im4_out = uint8 ([
%!  148   90   44   33   22;
%!  161  111   67   50   33;
%!  161  111   67   50   33;
%!  161  111   67   50   33;
%!  148   90   44   33   22]);
%! im4_n = 0.0398;
%! [out, n] = wiener2 (im4);
%! assert (out, im4_out)
%! assert (n, im4_n, 1e-4)

%!test
%! im5 = zeros (100, 100);
%! im5(30, 30) = 1;
%! im5_out_center = [
%!    0    0         0         0         0    0    0;
%!    0    0         0         0         0    0    0;
%!    0    0    0.0001    0.0001    0.0001    0    0;
%!    0    0    0.0001    0.9992    0.0001    0    0;
%!    0    0    0.0001    0.0001    0.0001    0    0;
%!    0    0         0         0         0    0    0;
%!    0    0         0         0         0    0    0];
%! im5_n = 8.8889e-5;
%! [out, n] = wiener2 (im5);
%! out_center = out(27:33, 27:33);
%! assert (out_center, im5_out_center, 1e-4)
%! assert (n, im5_n, 1e-4)

%!demo
%! I = phantom ();
%! J = imnoise (I, "gaussian", 0, 0.02);
%! figure, imshow (J);
%! title ("Image with added Gaussian noise");
%! K = wiener2 (J, [5 5]);
%! figure, imshow (K);
%! title ("Image with noise reduced by wiener2 filtering");
