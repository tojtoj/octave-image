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

DEFUN_DLD(graycomatrix, args, , "\
\
usage: P = graycomatrix(I, levels, distances, angles)\n\
\n\
  Calculate the gray-level co-occurrence matrix P = f(i,j,d,theta)\n\
  of a gray-level image.\n\
\n\
  P is a 4-dimensional matrix (histogram). The value P(i,j,d,theta)\n\
  is the number of times that gray-level j occurs at a distance 'd' and\n\
  at an angle 'theta' from gray-level j.\n\
\n\
  'I' is the input image which should contain integers in [0, levels-1],\n\
  where 'levels' indicate the number of gray-levels counted (typically\n\
  256 for an 8-bit image).  'distances' and 'angles' are vectors of\n\
  the different distances and angles to use.\n" ) {

    // 4-dimensional histogram
    // P = f(i, j, d, theta) where i and j are gray levels
    // See Pattern Recognition Engineering (Morton Nadler & Eric P. Smith)

    octave_value_list retval;

    if (args.length() != 4) {
	print_usage ();
	// 'I' must be integer values [0, nr_of_levels-1]

	return retval;
    }

    // Input arguments
    Matrix I = args(0).matrix_value();
    int L = args(1).int_value();
    ColumnVector d = ColumnVector(args(2).vector_value());
    ColumnVector th = ColumnVector(args(3).vector_value());

    if (error_state) {
	print_usage ();
	return retval;
    }

    // Create output NDArray, P
    dim_vector dim = dim_vector();
    dim.resize(4);
    dim(0) = L; dim(1) = L; dim(2) = d.length(); dim(3) = th.length();
    NDArray P = NDArray(dim, 0);

    // Run through image
    int d_max = (int)ceil(d.max());
    int cnt = 0;

    for (int r = 0; r < I.rows(); r++) {
	for (int c = 0; c < I.columns(); c++) {
	    int i = (int)I(r,c);

	    for (int d_idx = 0; d_idx < d.length(); d_idx++) {
		int d_val = (int)d(d_idx);
		for (int th_idx = 0; th_idx < th.length(); th_idx++) {
		    
		    double angle = th(th_idx);
		    
		    int row = r + (int)floor(cos(angle) * d_val + 0.5);
		    int col = c - (int)floor(sin(angle) * d_val + 0.5);

		    if ( ( row >= 0 ) && ( row < I.rows() ) &&
			 ( col >= 0 ) && ( col < I.cols() ) ) {

			int j = (int)I(row, col);

			if (i >= 0 && i < L && j >= 0 && j < L) {
			    Array<int> coord = Array<int> (4);
			    coord(0) = i;
			    coord(1) = j;
			    coord(2) = d_idx;
			    coord(3) = th_idx;
			    
			    P(coord)++;			    
			} else {
			    warning("Image contains invalid gray-level! (%d, %d)", i, j);
			} 
		    }

		}
	    }

	}
    }

    return octave_value(P);
    
}

/*

%!shared a
%!test
%!  a = [0 0 0 1 2;
%!       1 1 0 1 1;
%!       2 2 1 0 0;
%!       1 1 0 2 0;
%!       0 0 1 0 1];
%!  squeeze(graycomatrix(a, 3, 1, -pi/4)) == [4 2 0;
%!                                     2 3 2;
%!                                     1 2 0];
%!
%!assert(size(graycomatrix(a, 3, 1:5, [0:3]*-pi/4)), [3, 3, 5, 4])

%!demo
%!
%!  # Pattern Recognition Engineering (Nadler & Smith)
%!  # Digital Image Processing (Gonzales & Woods), p. 668
%!
%!  a = [0 0 0 1 2;
%!       1 1 0 1 1;
%!       2 2 1 0 0;
%!       1 1 0 2 0;
%!       0 0 1 0 1];
%!
%!  graycomatrix(a, 3, 1, [0 1]*-pi/4)
%!


*/
