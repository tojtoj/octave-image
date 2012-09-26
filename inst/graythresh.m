## Copyright (C) 2004 Antti Niemistö <antti.niemisto@tut.fi>
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
## @deftypefnx {Function File} {[@var{level}] =} graythresh (@var{img}, "percentile", @var{fraction})
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
## @item Otsu (default)
## Implements Otsu's method as described in @cite{Nobuyuki Otsu (1979). "A
## threshold selection method from gray-level histograms", IEEE Trans. Sys.,
## Man., Cyber. 9 (1): 62-66}. This algorithm chooses the threshold to minimize
## the intraclass variance of the black and white pixels. The second output,
## @var{sep} represents the ``goodness'' (or separability) of the threshold at
## @var{level}.
##
## @item concavity
## Find a global threshold for a grayscale image by choosing the threshold to
## be in the shoulder of the histogram @cite{A. Rosenfeld, and P. De La Torre
## (1983). "Histogram concavity analysis as an aid in threshold selection", IEEE
## Transactions on Systems, Man, and Cybernetics, 13: 231-235}.
##
## @item Huang
## Not yet implemented.
##
## @item ImageJ
## A variation of the intermeans algorithm, this is the default for ImageJ.
## Not yet implemented.
##
## @item intermodes
## This assumes a bimodal histogram and chooses the threshold to be the mean of
## the two peaks of the bimodal histogram @cite{J. M. S. Prewitt, and M. L.
## Mendelsohn (1966). "The analysis of cell images", Annals of the New York
## Academy of Sciences, 128: 1035-1053}.
##
## Images with histograms having extremely unequal peaks or a broad and ﬂat
## valley are unsuitable for this method.
##
## @item intermeans
## Iterative procedure based on the iterative intermeans algorithm of @cite{T.
## Ridler, and S. Calvard (1978). "Picture thresholding using an iterative
## selection method", IEEE Transactions on Systems, Man, and Cybernetics, 8: 630-632}
## and @cite{H. J. Trussell (1979). "Comments on 'Picture thresholding using an
## iterative selection method'", IEEE Transactions on Systems, Man, and Cybernetics,
## 9: 311}.
##
## Note that several implementations of this method exist. See the source code
## for details.
##
## @item Li
## Not yet implemented.
##
## @item MaxEntropy
## Implements Kapur-Sahoo-Wong (Maximum Entropy) thresholding method based on the
## entropy of the image histogram @cite{J. N. Kapur, P. K. Sahoo, and A. C. K. Wong
## (1985). "A new method for gray-level picture thresholding using the entropy
## of the histogram", Graphical Models and Image Processing, 29(3): 273-285}.
##
## @item MaxLikelihood
## Find a global threshold for a grayscale image using the maximum likelihood
## via expectation maximization method @cite{A. P. Dempster, N. M. Laird, and D. B.
## Rubin (1977). "Maximum likelihood from incomplete data via the EM algorithm",
## Journal of the Royal Statistical Society, Series B, 39:1-38}.
##
## @item mean
## The mean intensity value. It is mostly used by other methods as a first guess
## threshold.
##
## @item MinError
## An iterative implementation of Kittler and Illingworth's Minimum Error
## thresholding @cite{J. Kittler, and J. Illingworth (1986). "Minimum error
## thresholding", Pattern recognition, 19: 41-47}.
##
## This implementation seems to converge more often than the original.
## Nevertheless, sometimes the algorithm does not converge to a solution. In
## that case a warning is displayed and defaults to the initial estimate of the
## mean method.
##
## @item minimum
## This assumes a bimodal histogram and chooses the threshold to be in the
## valley of the bimodal histogram.  This method is also known as the mode
## method @cite{J. M. S. Prewitt, and M. L. Mendelsohn (1966). "The analysis of
## cell images", Annals of the New York Academy of Sciences, 128: 1035-1053}.
##
## Images with histograms having extremely unequal peaks or a broad and ﬂat
## valley are unsuitable for this method.
##
## @item moments
## Find a global threshold for a grayscale image using moment preserving
## thresholding method @cite{W. Tsai (1985). "Moment-preserving thresholding:
## a new approach", Computer Vision, Graphics, and Image Processing, 29: 377-393}
##
## @item percentile
## Assumes a specific @var{fraction} of pixels to be background.  If no value is
## given, assumes a value of 0.5 (equal distribution of background and foreground)
## @cite{W Doyle (1962). "Operation useful for similarity-invariant pattern
## recognition", Journal of the Association for Computing Machinery 9: 259-267}
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
##  * The following methods were adapted from http://www.cs.tut.fi/~ant/histthresh/
##      intermodes    percentile      minimum
##      MaxEntropy    MaxLikelihood   intermeans
##      moments       minerror        concavity


function [level, good] = graythresh (img, algo = "otsu", varargin)
  ## Input checking
  if (nargin < 1 || nargin > 3)
    print_usage();
  elseif (!isgray (img) && !isrgb (img))
    error ("graythresh: input must be an image");
  endif

  ## If the image is RGB convert it to grayscale
  if (isrgb (img))
    img = rgb2gray (img);
  endif

  switch tolower (algo)
    case {"concavity"},     [level]       = concavity (img);
    case {"intermeans"},    [level]       = intermeans (img);
    case {"intermodes"},    [level]       = intermodes (img);
    case {"maxlikelihood"}, [level]       = maxlikelihood (img);
    case {"maxentropy"},    [level]       = maxentropy (img);
    case {"mean"},          [level]       = mean (img(:));
    case {"minimum"},       [level]       = minimum (img);
    case {"minerror"},      [level]       = minerror_iter (img);
    case {"moments"},       [level]       = moments (img);
    case {"otsu"},          [level, good] = otsu (img);
    case {"percentile"},    [level]       = percentile (img, varargin{1});
    otherwise, error ("graythresh: unknown method '%s'", algo);
  endswitch
endfunction

function [level, good] = otsu (img)
  ## Calculation of the normalized histogram
  n = double (intmax (class (img))) + 1;
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
  good = w0 * w1 * (mu1 - mu0) * (mu1 - mu0);
  
  ## For each step of the histogram, calculation of the threshold
  ## and storing of the maximum
  for i = find (h > 0)
    w0 = w(i);
    w1 = 1 - w0;
    mu0 = mu(i) / w0;
    mu1 = (mu(end) - mu(i)) / w1;
    s = w0 * w1 * (mu1 - mu0) * (mu1 - mu0);
    if (s > good)
      good  = s;
      level = i;
    endif
  endfor

  ## Normalisation of the threshold
  level /= n;
endfunction

#{
  ##The following is another implementation of Otsu's method from the HistThresh
  ##toolbox
  if nargin == 1
    n = 255;
  end

  % This algorithm is implemented in the Image Processing Toolbox.
  %I = uint8(I);
  %T = n*graythresh(I);

  % The implementation below uses the notations from the paper, but is
  % significantly slower.

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  warning off MATLAB:divideByZero
  for j = 0:n
    mu = partial_sumB(y,j)/partial_sumA(y,j);
    nu = (partial_sumB(y,n)-partial_sumB(y,j))/(partial_sumA(y,n)-partial_sumA(y,j));
    vec(j+1) = partial_sumA(y,j)*(partial_sumA(y,n)-partial_sumA(y,j))*(mu-nu)^2;
  end
  warning on MATLAB:divideByZero

  [maximum,ind] = max(vec);
  T = ind-1;
#}

function level = moments (I, n)

  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist (I(:), 0:n);

  % The threshold is chosen such that partial_sumA(y,t)/partial_sumA(y,n) is closest to x0.
  Avec = zeros (1, n+1);

  for t = 0:n
    Avec(t+1) = partial_sumA (y, t) / partial_sumA (y, n);
  end

  % The following finds x0.
  x2 = (partial_sumB(y,n)*partial_sumC(y,n) - partial_sumA(y,n)*partial_sumD(y,n)) / (partial_sumA(y,n)*partial_sumC(y,n) - partial_sumB(y,n)^2);
  x1 = (partial_sumB(y,n)*partial_sumD(y,n) - partial_sumC(y,n)^2) / (partial_sumA (y,n)*partial_sumC(y,n) - partial_sumB(y,n)^2);
  x0 = .5 - (partial_sumB(y,n)/partial_sumA(y,n) + x2/2) / sqrt (x2^2 - 4*x1);

  % And finally the threshold.
  [minimum, ind] = min (abs (Avec-x0));
  level = ind-1;

  ## Normalisation of the threshold
  level /= n;
endfunction

function T = maxentropy(I,n)
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  warning off
  % The threshold is chosen such that the following expression is minimized.
  for j = 0:n
    vec(j+1) = negativeE(y,j)/partial_sumA(y,j) - log10(partial_sumA(y,j)) + ...
        (negativeE(y,n)-negativeE(y,j))/(partial_sumA(y,n)-partial_sumA(y,j)) - log10(partial_sumA(y,n)-partial_sumA(y,j));
  end
  warning on

  [minimum,ind] = min(vec);
  T = ind-1;
endfunction

function [T] = intermodes (I,n)
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  % Smooth the histogram by iterative three point mean filtering.
  iter = 0;
  while ~bimodtest(y)
    h = ones(1,3)/3;
    y = conv2(y,h,'same');
    iter = iter+1;
    % If the histogram turns out not to be bimodal, set T to zero.
    if iter > 10000;
      T = 0;
      return
    end
  end

  % The threshold is the mean of the two peaks of the histogram.
  ind = 0;
  for k = 2:n
    if y(k-1) < y(k) && y(k+1) < y(k)
      ind = ind+1;
      TT(ind) = k-1;
    end
  end
  T = floor(mean(TT));
endfunction

function [T] = percentile (I, p, n)
  if nargin == 1
    p = 0.5;
    n = 255;
  elseif nargin == 2
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  % The threshold is chosen such that 50% of pixels lie in each category.
  Avec = zeros(1,n+1);
  for t = 0:n
    Avec(t+1) = partial_sumA(y,t)/partial_sumA(y,n);
  end

  [minimum,ind] = min(abs(Avec-p));
  T = ind-1;
endfunction


function T = minimum(I,n);
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  % Smooth the histogram by iterative three point mean filtering.
  iter = 0;
  while ~bimodtest(y)
    h = ones(1,3)/3;
    y = conv2(y,h,'same');
    iter = iter+1;
    % If the histogram turns out not to be bimodal, set T to zero.
    if iter > 10000;
      T = 0;
      return
    end
  end

  % The threshold is the minimum between the two peaks.
  for k = 2:n
    if y(k-1) > y(k) && y(k+1) > y(k)
      T = k-1;
    end
  end
endfunction

function [T] = minerror_iter (I,n)
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  % The initial estimate for the threshold is found with the MEAN algorithm.
  T = floor (mean (I, img(:)));
  Tprev = NaN;

  while T ~= Tprev
    
    % Calculate some statistics.
    mu = partial_sumB(y,T)/partial_sumA(y,T);
    nu = (partial_sumB(y,n)-partial_sumB(y,T))/(partial_sumA(y,n)-partial_sumA(y,T));
    p = partial_sumA(y,T)/partial_sumA(y,n);
    q = (partial_sumA(y,n)-partial_sumA(y,T)) / partial_sumA(y,n);
    sigma2 = partial_sumC(y,T)/partial_sumA(y,T)-mu^2;
    tau2 = (partial_sumC(y,n)-partial_sumC(y,T)) / (partial_sumA(y,n)-partial_sumA(y,T)) - nu^2;

    % The terms of the quadratic equation to be solved.
    w0 = 1/sigma2-1/tau2;
    w1 = mu/sigma2-nu/tau2;
    w2 = mu^2/sigma2 - nu^2/tau2 + log10((sigma2*q^2)/(tau2*p^2));
    
    % If the next threshold would be imaginary, return with the current one.
    sqterm = w1^2-w0*w2;
    if sqterm < 0
      warning('MINERROR:NaN','Warning: th_minerror_iter did not converge.')
      return
    end

    % The updated threshold is the integer part of the solution of the
    % quadratic equation.
    Tprev = T;
    T = floor((w1+sqrt(sqterm))/w0);

    % If the threshold turns out to be NaN, return with the previous threshold.
    if isnan(T)
      warning('MINERROR:NaN','Warning: th_minerror_iter did not converge.')
      T = Tprev;
    end
    
  end
endfunction
#{
  ## this was not an implementatino of the original minerror algorithm but seems
  ## to converg more often than the original. The original is (also from the
  ## HistThresh toolbox
  function T = th_minerror(I,n)
    if nargin == 1
      n = 255;
    end

    I = double(I);

    % Calculate the histogram.
    y = hist(I(:),0:n);

    warning off
    % The threshold is chosen such that the following expression is minimized.
    for j = 0:n
      mu = partial_sumB(y,j)/partial_sumA(y,j);
      nu = (partial_sumB(y,n)-partial_sumB(y,j))/(partial_sumA(y,n)-partial_sumA(y,j));
      p = partial_sumA(y,j)/partial_sumA(y,n);
      q = (partial_sumA(y,n)-partial_sumA(y,j)) / partial_sumA(y,n);
      sigma2 = partial_sumC(y,j)/partial_sumA(y,j)-mu^2;
      tau2 = (partial_sumC(y,n)-partial_sumC(y,j)) / (partial_sumA(y,n)-partial_sumA(y,j)) - nu^2;
      vec(j+1) = p*log10(sqrt(sigma2)/p) + q*log10(sqrt(tau2)/q);
    end
    warning on

    vec(vec==-inf) = NaN;
    [minimum,ind] = min(vec);
    T = ind-1;
  endfunction
#}

function T = maxlikelihood (I,n)
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  % The initial estimate for the threshold is found with the MINIMUM
  % algorithm.
  T = th_minimum(I,n);

  % Calculate initial values for the statistics.
  mu = partial_sumB(y,T)/partial_sumA(y,T);
  nu = (partial_sumB(y,n)-partial_sumB(y,T))/(partial_sumA(y,n)-partial_sumA(y,T));
  p = partial_sumA(y,T)/partial_sumA(y,n);
  q = (partial_sumA(y,n)-partial_sumA(y,T)) / partial_sumA(y,n);
  sigma2 = partial_sumC(y,T)/partial_sumA(y,T)-mu^2;
  tau2 = (partial_sumC(y,n)-partial_sumC(y,T)) / (partial_sumA(y,n)-partial_sumA(y,T)) - nu^2;

  mu_prev = NaN;
  nu_prev = NaN;
  p_prev = NaN;
  q_prev = NaN;
  sigma2_prev = NaN;
  tau2_prev = NaN;

  while abs(mu-mu_prev) > eps || abs(nu-nu_prev) > eps || ...
        abs(p-p_prev) > eps || abs(q-q_prev) > eps || ...
        abs(sigma2-sigma2_prev) > eps || abs(tau2-tau2_prev) > eps
    for i = 0:n
      phi(i+1) = p/q * exp(-((i-mu)^2) / (2*sigma2)) / ...
          (p/sqrt(sigma2) * exp(-((i-mu)^2) / (2*sigma2)) + ... 
           (q/sqrt(tau2)) * exp(-((i-nu)^2) / (2*tau2)));
    end
    ind = 0:n;
    gamma = 1-phi;
    F = phi*y';
    G = gamma*y';
    p_prev = p;
    q_prev = q;
    mu_prev = mu;
    nu_prev = nu;
    sigma2_prev = nu;
    tau2_prev = nu;
    p = F/partial_sumA(y,n);
    q = G/partial_sumA(y,n);
    mu = ind.*phi*y'/F;
    nu = ind.*gamma*y'/G;
    sigma2 = ind.^2.*phi*y'/F - mu^2;
    tau2 = ind.^2.*gamma*y'/G - nu^2;
  end

  % The terms of the quadratic equation to be solved.
  w0 = 1/sigma2-1/tau2;
  w1 = mu/sigma2-nu/tau2;
  w2 = mu^2/sigma2 - nu^2/tau2 + log10((sigma2*q^2)/(tau2*p^2));
    
  % If the threshold would be imaginary, return with threshold set to zero.
  sqterm = w1^2-w0*w2;
  if sqterm < 0;
    T = 0;
    return
  end

  % The threshold is the integer part of the solution of the quadratic
  % equation.
  T = floor((w1+sqrt(sqterm))/w0);
endfunction

function T = intermeans (I,n)
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram.
  y = hist(I(:),0:n);

  % The initial estimate for the threshold is found with the MEAN algorithm.
  T = floor (mean (I, img(:)));
  Tprev = NaN;

  % The threshold is found iteratively. In each iteration, the means of the
  % pixels below (mu) the threshold and above (nu) it are found. The
  % updated threshold is the mean of mu and nu.
  while T ~= Tprev
    mu = partial_sumB(y,T)/partial_sumA(y,T);
    nu = (partial_sumB(y,n)-partial_sumB(y,T))/(partial_sumA(y,n)-partial_sumA(y,T));
    Tprev = T;
    T = floor((mu+nu)/2);
  end
endfunction

function T = concavity (I,n)
  if nargin == 1
    n = 255;
  end

  I = double(I);

  % Calculate the histogram and its convex hull.
  h = hist(I(:),0:n);
  H = hconvhull(h);

  % Find the local maxima of the difference H-h.
  lmax = flocmax(H-h);

  % Find the histogram balance around each index.
  for k = 0:n
    E(k+1) = hbalance(h,k);
  end

  % The threshold is the local maximum with highest balance.
  E = E.*lmax;
  [dummy ind] = max(E);
  T = ind-1;
endfunction

################################################################################
## Auxiliary functions from HistThresh toolbox http://www.cs.tut.fi/~ant/histthresh/
################################################################################

## partial sums from C. A. Glasbey, "An analysis of histogram-based thresholding
## algorithms," CVGIP: Graphical Models and Image Processing, vol. 55, pp. 532-537, 1993.
function x = partial_sumA (y, j)
  x = sum (y(1:j+1));
endfunction
function x = partial_sumB (y, j)
  ind = 0:j;
  x   = ind*y(1:j+1)';
endfunction
function x = partial_sumC (y, j)
  ind = 0:j;
  x = ind.^2*y(1:j+1)';
endfunction
function x = partial_sumD (y, j)
  ind = 0:j;
  x = ind.^3*y(1:j+1)';
endfunction

## Test if a histogram is bimodal.
function b = bimodtest(y)
  len = length(y);
  b = false;
  modes = 0;

  % Count the number of modes of the histogram in a loop. If the number
  % exceeds 2, return with boolean return value false.
  for k = 2:len-1
    if y(k-1) < y(k) && y(k+1) < y(k)
      modes = modes+1;
      if modes > 2
        return
      end
    end
  end

  % The number of modes could be less than two here
  if modes == 2
    b = true;
  end
endfunction

## Find the local maxima of a vector using a three point neighborhood.
function y = flocmax(x)
%  y    binary vector with maxima of x marked as ones

  len = length(x);
  y = zeros(1,len);

  for k = 2:len-1
    [dummy,ind] = max(x(k-1:k+1));
    if ind == 2
      y(k) = 1;
    end
  end
endfunction

## Calculate the balance measure of the histogram around a histogram index.
function E = hbalance(y,ind)
%  y    histogram
%  ind  index about which balance is calculated
%
% Out:
%  E    balance measure
%
% References: 
%
% A. Rosenfeld and P. De La Torre, "Histogram concavity analysis as an aid
% in threhold selection," IEEE Transactions on Systems, Man, and
% Cybernetics, vol. 13, pp. 231-235, 1983.
%
% P. K. Sahoo, S. Soltani, and A. K. C. Wong, "A survey of thresholding
% techniques," Computer Vision, Graphics, and Image Processing, vol. 41,
% pp. 233-260, 1988.

  n = length(y)-1;
  E = partial_sumA(y,ind)*(partial_sumA(y,n)-partial_sumA(y,ind));
endfunction

## Find the convex hull of a histogram.
function H = hconvhull(h)
  % In:
  %  h    histogram
  %
  % Out:
  %  H    convex hull of histogram
  %
  % References: 
  %
  % A. Rosenfeld and P. De La Torre, "Histogram concavity analysis as an aid
  % in threhold selection," IEEE Transactions on Systems, Man, and
  % Cybernetics, vol. 13, pp. 231-235, 1983.

  len = length(h);
  K(1) = 1;
  k = 1;

  % The vector K gives the locations of the vertices of the convex hull.
  while K(k)~=len

    theta = zeros(1,len-K(k));
    for i = K(k)+1:len
      x = i-K(k);
      y = h(i)-h(K(k));
      theta(i-K(k)) = atan2(y,x);
    end

    maximum = max(theta);
    maxloc = find(theta==maximum);
    k = k+1;
    K(k) = maxloc(end)+K(k-1);
    
  end

  % Form the convex hull.
  H = zeros(1,len);
  for i = 2:length(K)
    H(K(i-1):K(i)) = h(K(i-1))+(h(K(i))-h(K(i-1)))/(K(i)-K(i-1))*(0:K(i)-K(i-1));
  end
endfunction

## Entroy function. Note that the function returns the negative of entropy.
function x = negativeE(y,j)
  ## used by the maxentropy method only
  y = y(1:j+1);
  y = y(y~=0);
  x = sum(y.*log10(y));
endfunction
