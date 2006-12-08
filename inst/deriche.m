# $Id$
function result = deriche(img, alpha, method)
# OUTPUT
# method  0 (default)
#    magnitude of gradient
# method = 1 
#    vector gradient (last index 1 for H, 2 for V)
# 
# INPUT
#  img    -> input image (as matrix of doubles) 
#  alpha  -> filter paramter (scale)
#
# Deriche 2D image gradient using recursive filters. Precessing time is 
# independent of alpha.
# taken from:
# Klette, Zamperoni: Handbuch der Operatoren für die Bildverarbeitung, vieweg 
# 2.Aufl. 1995 pp 224-229
# algorithm: Deriche R.: Fast algorithms for low-level vision: IEEE Trans. 
# PAMI-12 (1990) pp 78-87
#
# Due to the inherent recursive nature of the algorithms the octave 
# implementation is rather slow compared to a C implementation although I have
# vectorized it as far as possible at the expense of memory consuption. As a 
# side effect the evaluation order had to be modified compared to the Klette / 
# Zamperoni approach. (A C Implementation can easily process PAL a video stream in 
# realtime on moderate hardware.)
#
# (C)opyright Christian Kotz 2006
# This code has no warrany whatsoever.
# Do what you like with this code as long as you
# leave this copyright in place.
#
# author:   Christian Kotz
# date:     11/21/2006
# version:  0.1
#
## $Log$
## Revision 1.2  2006/12/08 06:41:30  cocus
## interface changed to match cc implementation. (returns magnitude by default)
##
## Revision 1.1  2006/12/03 10:53:14  cocus
## initial m-file implementetaion.
##
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin < 2
  alpha = 1.0
end

if nargin < 3
  method = 0
end

   a   =  -(1-exp(-alpha))^2;
   b1 =  -2*exp(-alpha);
   b2 = exp(-2*alpha);
   a0 = -alpha / (1 - alpha * b1 - b2);
   a1 = a0 * (alpha-1)*exp(-alpha);
   a2 = a1 - a0 * b1;
   a3 = -a0 * b2;
   

  [n m] = size(img);
  
  g_v1 = zeros(n,m);
  g_v2 = zeros(n,m);
  g_h1 = zeros(n,m);
  g_h2 = zeros(n,m);
  g_hv = zeros(n,m);
  result = zeros(n,m,2);
    
  for k=3:m
    g_v1(:,k) = img(:, k-1) - b1 * g_v1(:,k-1)- b2 * g_v1(:,k-2);
  end;

  for k=m-2:-1:1
    g_v2(:,k) = img(:, k+1) - b1 * g_v2(:,k+1)- b2 * g_v2(:,k+2);
  end;
  
  g_hv = a * (g_v1 - g_v2);

   for k=3:n
     g_h1(k,:) = a0 * g_hv(k,:) + a1 * g_hv(k-1,:) - b1 *  g_h1(k-1,:) - b2 * g_h1(k-2,:);
  end;
  for k=n-2:-1:1
     g_h1(k,:) = a2 * g_hv(k+1,:) + a3 * g_hv(k+2,:) - b1 *  g_h2(k+1,:) - b2 * g_h2(k+2,:);
  end;

result(:,:,1) = g_h1 + g_h2;
  
  for k=3:n
    g_v1(k,:) = img(k-1,:) - b1 * g_v1(k-1,:)- b2 * g_v1(k-2,:);
  end;

  for k=n-2:-1:1
    g_v2(k,:) = img(k+1,:) - b1 * g_v2(k+1,:)- b2 * g_v2(k+2,:);
  end;
  
  g_hv = a * (g_v1 - g_v2);

   for k=3:m
     g_h1(:,k) = a0 * g_hv(:,k) + a1 * g_hv(:,k-1) - b1 *  g_h1(:,k-1) - b2 * g_h1(:,k-2);
  end;
  for k=m-2:-1:1
     g_h1(:,k) = a2 * g_hv(:,k+1) + a3 * g_hv(:,k+2) - b1 *  g_h2(:,k+1) - b2 * g_h2(:,k+2);
  end;

result(:,:,2) = g_h1 + g_h2;

if (method == 0)
  result = sqrt(result(:,:,1).*result(:,:,1)+result(:,:,2).*result(:,:,2));
end


