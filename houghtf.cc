/* Copyright (C) 2004 Stefan van der Walt <stefan@sun.ac.za>

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#include <octave/oct.h>

DEFUN_DLD( houghtf, args, , "\
\
usage: [H, R]  = houghtf(I[, angles])\n\
\n\
  Calculate the straight line Hough transform of an image.\n\
\n\
  The image, I, should be a binary image in [0,1].  The angles are given\n\
  in degrees and defaults to -90..90.\n\
\n\
  H is the resulting transform, R the radial distances.\n\
\n\
  See also: Digital Image Processing by Gonzales & Woods (2nd ed., p. 587)\n") {

    octave_value_list retval;
    bool DEF_THETA = false;

    if (args.length() == 1) {
	DEF_THETA = true;
    } else if (args.length() != 2) {
	print_usage("houghtf");
	return retval;
    } 

    Matrix I = args(0).matrix_value();

    ColumnVector thetas = ColumnVector();
    if (!DEF_THETA) {
    	thetas = ColumnVector(args(1).vector_value());
    } else {
        thetas = ColumnVector(Range(-90,90).matrix_value());
    }

    if (error_state) {
	print_usage("houghtf");
	return retval;
    }

    thetas = thetas / 180 * M_PI;

    int r = I.rows();
    int c = I.columns();

    Matrix xMesh = Matrix(r, c);
    Matrix yMesh = Matrix(r, c);
    for (int m = 0; m < r; m++) {
	for (int n = 0; n < c; n++) {
	    xMesh(m, n) = n+1;
	    yMesh(m, n) = m+1;
	}
    }

    Matrix size = Matrix(1, 2);
    size(0) = r; size(1) = c;
    double diag_length = sqrt( size.sumsq()(0) );
    int nr_bins = 2 * (int)ceil(diag_length) - 1;
    RowVector bins = RowVector( Range(1, nr_bins).matrix_value() ) - (int)ceil(nr_bins/2);

    Matrix J = Matrix(bins.length(), 0);

    for (int i = 0; i < thetas.length(); i++) {
	double theta = thetas(i);
	ColumnVector rho_count = ColumnVector(bins.length(), 0);

	double cT = cos(theta); double sT = sin(theta);
	for (int x = 0; x < r; x++) {
	    for (int y = 0; y < c; y++) {
		if ( I(y, x) == 1 ) {
		    int rho = (int)round( cT*x + sT*y );
		    int bin = (int)(rho - bins(0));
		    if ( (bin > 0) && (bin < bins.length()) ) {
			rho_count( bin )++;
		    }
		}
	    }
	}

	J = J.append( rho_count );
    }

    retval.append(J);
    retval.append(bins);
    return retval;

}

/*
%!test
%! I = zeros(100, 100);
%! I(1,1) = 1; I(100,100) = 1; I(1,100) = 1; I(100, 1) = 1; I(50,50) = 1;
%! [J, R] = houghtf(I); J = J / max(J(:));
%! assert(size(J) == [length(R) 181]);
%!

%!demo
%! I = zeros(100, 150);
%! I(30,:) = 1; I(:, 65) = 1; I(35:45, 35:50) = 1;
%! for i = 1:90, I(i,i) = 1;endfor
%! I = imnoise(I, 'salt & pepper');
%! imshow(I);
%! J = houghtf(I); J = J / max(J(:));
%! imshow(J, bone(128), 'truesize');

*/
