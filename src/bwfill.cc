/*
 * BWFILL: fill a bw image starting at points
 * imo= block(im, xregs, yregs);
 *
 * Copyright (C) 1999 Andy Adler
 * This code has no warrany whatsoever.
 * Do what you like with this code as long as you
 *     leave this copyright in place.
 *
 * $Id$
 */

#include <octave/oct.h>

#ifndef OCTAVE_LOCAL_BUFFER
#include <vector>
#define OCTAVE_LOCAL_BUFFER(T, buf, size) \
  std::vector<T> buf ## _vector (size); \
  T *buf = &(buf ## _vector[0])
#endif

#define   ptUP     (-1)
#define   ptDN     (+1)
#define   ptRT     (+ioM)
#define   ptLF     (-ioM)

/*
 * check if the point needs to be filled, if so
 * fill it and change the appropriate variables
 */
void checkpoint( int pt,
      unsigned char* imo,
               int * ptstack,
               int * npoints ) {
// printf("filling %d np=%d fill=%d\n",pt,*npoints, *(imo+pt)==0 );
   if( *(imo+pt) != 0 ) return;

   *(imo+pt) = 2;
   *(ptstack + (*npoints))= pt;
   (*npoints)++;
}

DEFUN_DLD (bwfill, args, ,
  "[...] = bwfill (...)\n\
   [BW2,IDX] = BWFILL(BW1,Y,X,N) performs a flood-fill on BW1\n\
\n\
       (X(k), Y(k)) are rows and columns of seed points\n\
\n\
   [BW2,IDX] = BWFILL(BW1,'holes',N) fills interior holes in BW1\n\
\n\
       N = 4 or 8(default) for neighborhood connectedness\n\
\n\
       IDX is the indices of the filled pixels")
{
   octave_value_list retval;
   octave_value tmp;
   ColumnVector xseed, yseed ;
   int nargin = args.length ();

   if (nargin < 2 ) {
      print_usage ();
      return retval;
   }

   Matrix       im=    args(0).matrix_value();
   int          imM=   im.rows();
   int          imN=   im.columns();

   int          nb=    8;
   int          npoints= 0;
   bool         fillmode= false;
   if (args(1).is_string() && args(1).string_value() == "holes" ) {
      fillmode= true;

      npoints= 2*( imM + imN - 4 ); // don't start fill from corners

      xseed= ColumnVector( npoints );
      yseed= ColumnVector( npoints );
      int idx= 0;
      for (int j=2; j<= imN-1; j++) {
         xseed( idx )= j;   yseed( idx++)= 1;   
         xseed( idx )= j;   yseed( idx++)= imM;   
      }

      for (int i=2; i<= imM-1; i++) {
         yseed( idx )= i;   xseed( idx++)= 1;   
         yseed( idx )= i;   xseed( idx++)= imN;   
      }

      if (nargin >= 4 ) 
         nb= (int) args(2).double_value();
   } // holes mode? 
   else {
      {
         ColumnVector tmp( args(2).vector_value() );
         xseed= tmp;
      }
      {
         ColumnVector tmp( args(1).vector_value() );
         yseed= tmp;
      }
      npoints= xseed.length();
      if (nargin >= 4 ) 
         nb= (int) args(3).double_value();
   } // holes mode? 

/*
 * put a one pixel thick boundary around the image
 *  so that we can be more efficient in the main loop
 */
   int           ioM=   imM+2;
   OCTAVE_LOCAL_BUFFER(unsigned char, imo, (imM+2) * (imN+2));

   for (int i=0; i<imM; i++) 
      for (int j=0; j<imN; j++)
         imo[(i+1) + ioM*(j+1)]= ( im(i,j) > 0 ) ;

   for (int i=0; i<ioM; i++) 
      imo[i]= imo[i + ioM*(imN+1)] = 3;

   for (int j=1; j<imN+1; j++)
      imo[ioM*j]= imo[imM+1 + ioM*j] = 3;

// This is obviously big enough for the point stack, but I'm
// sure it can be smaller. 
   OCTAVE_LOCAL_BUFFER(int, ptstack, ioM*imN );

   int seedidx= npoints; 
   npoints= 0;
   while ( (--seedidx) >= 0 ) {
// no need to add 1 to convert indexing style because we're adding a boundary
      int pt= (int) xseed( seedidx )*ioM + (int) yseed( seedidx ); 
      checkpoint( pt , imo, ptstack, &npoints );
   }

   while ( npoints > 0 ) {
      npoints--;
      int pt= ptstack[ npoints ];
      
      checkpoint( pt + ptLF, imo, ptstack, &npoints );
      checkpoint( pt + ptRT, imo, ptstack, &npoints );
      checkpoint( pt + ptUP, imo, ptstack, &npoints );
      checkpoint( pt + ptDN, imo, ptstack, &npoints );
      
      if (nb==8) {
         checkpoint( pt + ptLF + ptUP, imo, ptstack, &npoints );
         checkpoint( pt + ptRT + ptUP, imo, ptstack, &npoints );
         checkpoint( pt + ptLF + ptDN, imo, ptstack, &npoints );
         checkpoint( pt + ptRT + ptDN, imo, ptstack, &npoints );
      }
   } // while ( npoints

   Matrix       imout( imM, imN );
   ColumnVector idxout (imM*imN );
   int idx=0;

   int notvalidpt= 0;
   int idxpoint=   2;
   if ( fillmode ) {
      notvalidpt= 2;
      idxpoint=   0;
   }

   for (int i=0; i<imM; i++) 
      for (int j=0; j<imN; j++) {
         imout(i,j) =    (double) ( imo[(i+1) + ioM*(j+1)] != notvalidpt );
         if ( imo[(i+1) + ioM*(j+1)] == idxpoint )
            idxout(idx++) = (double) (i + j*imM + 1);
      }

   /*
   Matrix imout( imM+2, imN+2 );
   for (int i=0; i<imM+2; i++) 
      for (int j=0; j<imN+2; j++)
         imout(i,j) = (double) imo[i + ioM*j];
    */

   retval(0)= imout;
// we need to do this to be able to return a proper empty vector
   if (idx > 0) 
      retval(1)= idxout.extract(0, idx-1);
   else
      retval(1)= ColumnVector ( 0 );
   return retval;
}


/*
 * $Log$
 * Revision 1.1  2006/08/20 12:59:36  hauberg
 * Changed the structure to match the package system
 *
 * Revision 1.7  2006/05/19 06:58:50  jwe
 * *** empty log message ***
 *
 * Revision 1.5  2003/05/15 21:25:40  pkienzle
 * OCTAVE_LOCAL_BUFFER now requires #include <memory>
 *
 * Revision 1.4  2003/03/05 15:31:52  pkienzle
 * Backport to octave-2.1.36
 *
 * Revision 1.3  2003/02/20 23:03:57  pkienzle
 * Use of "T x[n]" where n is not constant is a g++ extension so replace it with
 * OCTAVE_LOCAL_BUFFER(T,x,n), and other things to keep the picky MipsPRO CC
 * compiler happy.
 *
 * Revision 1.2  2002/11/02 10:39:36  pkienzle
 * gcc 3.2 wants \n\ for multi-line strings.
 *
 * Revision 1.1  2002/03/17 02:38:51  aadler
 * fill and edge detection operators
 *
 * Revision 1.9  2000/06/16 20:22:47  aadler
 * mods for 2.1/2.0 compat
 *
 * Revision 1.8  2000/06/13 17:27:24  aadler
 * mods for 2.1.30
 *
 * Revision 1.7  1999/06/10 19:42:12  aadler
 * minor verbose fix
 *
 * Revision 1.6  1999/06/08 16:30:30  aadler
 * bug fix. reversed r,c input arguments
 *
 * Revision 1.5  1999/06/08 15:41:02  aadler
 * now fills in holes
 *
 * Revision 1.4  1999/06/08 15:21:02  aadler
 * fixed bug that so specified points are only used if they can fill
 *
 * Revision 1.3  1999/06/08 15:05:08  aadler
 * now returns 1 and gives index output
 *
 * Revision 1.2  1999/06/04 21:58:57  aadler
 * fixed 8 vs 4 neighborhood
 *
 * Revision 1.1  1999/06/04 21:43:20  aadler
 * Initial revision
 *
 *
 */
