/* ---------------------------------------------------------------------

    bwimage.cc - octave module to label componenets of a binary image

    copyright 2002 Jeffrey E. Boyd

    - uses 4, 6, or 8 connectedness
    - See BKP Horn, Robot Vision, MIT Press, 1986, p 66 - 71 

    labeling scheme

        +-+-+-+
        |D|C|E|
        +-+-+-+
        |B|A| |
        +-+-+-+
        | | | |
        +-+-+-+
                
    A is the center pixel of a neighborhood.  In the 3 versions of
    connectedness:
    
    4:  A connects to B and C
    6:  A connects to B, C, and D
    8:  A connects to B, C, D, and E
    
    
--------------------------------------------------------------------- */



#include <oct.h>

#define     NO_OBJECT       0
#define     MIN(x, y)       (((x) < (y)) ? (x) : (y))



static int find( int *, int );

static bool any_bad_argument( const octave_value_list& );



DEFUN_DLD( bwlabel, args, ,
"\n\
[l,num] = bwlabel( bw, n ) - label foreground components of boolean image\n\
\n\
    bw  -   boolean image array\n\
    n   -   neighborhood connectedness (4, 6,or 8)\n\
\n\
    l   -   label image array\n\
    num -   number of components labeled\n\
\n\
    The algorithm is derived from  BKP Horn, Robot Vision, MIT Press,\n\
    1986, p 65 - 89 \n" )
{
    if ( any_bad_argument(args) )
        return octave_value_list();
    
    // input arguments
    Matrix BW = args(0).matrix_value();     // the input binary image
    int n;
    if ( args.length() < 2 ) n = 6;         // n-hood connectivity
    else n = args(1).int_value(); 
    int nr = args(0).rows();
    int nc = args(0).columns();
    
    // results
    Matrix L( nr, nc );     // the label image
    int nobj;                               // number of objects found in image
    
    // other variables
    int lset[nr * nc];   // label table/tree
    int ntable;                             // number of elements in the component table/tree
    
    ntable = 0;
    lset[0] = 0;
    
    for( int r = 0; r < nr; r++ ) {
        for( int c = 0; c < nc; c++ ) {            
            if ( BW.elem(r,c) ) {               // if A is an object
                // get the neighboring pixels B, C, D, and E
                int B, C, D, E;
                if ( c == 0 ) B = 0; else B = find( lset, (int)L.elem(r,c-1) );
                if ( r == 0 ) C = 0; else C = find( lset, (int)L.elem(r-1,c) );
                if ( r == 0 || c == 0 ) D = 0; else D = find( lset, (int)L.elem(r-1,c-1) );
                if ( r == 0 || c == nc - 1 ) E = 0;
                    else E = find( lset, (int)L.elem(r-1,c+1) );
                    
                if ( n == 4 ) {
                    // apply 4 connectedness
                    if ( B && C ) {        // B and C are labeled
                        if ( B == C )
                            L.elem(r,c) = B;
                        else {
                            lset[C] = B;
                            L.elem(r,c) = B;
                        }
                    } else if ( B )             // B is object but C is not
                        L.elem(r,c) = B;
                    else if ( C )               // C is object but B is not
                        L.elem(r,c) = C;
                    else {                      // B, C, D not object - new object
                        //   label and put into table
                        ntable++;
                        L.elem(r,c) = lset[ ntable ] = ntable;
                    }
                } else if ( n == 6 ) {
                    // apply 6 connected ness
                    if ( D )                    // D object, copy label and move on
                        L.elem(r,c) = D;
                    else if ( B && C ) {        // B and C are labeled
                        if ( B == C )
                            L.elem(r,c) = B;
                        else {
                            int tlabel = MIN(B,C);
                            lset[B] = tlabel;
                            lset[C] = tlabel;
                            L.elem(r,c) = tlabel;
                        }
                    } else if ( B )             // B is object but C is not
                        L.elem(r,c) = B;
                    else if ( C )               // C is object but B is not
                        L.elem(r,c) = C;
                    else {                      // B, C, D not object - new object
                        //   label and put into table
                        ntable++;
                        L.elem(r,c) = lset[ ntable ] = ntable;
                    }
                } else if ( n == 8 ) {
                    // apply 8 connectedness
                    if ( B || C || D || E ) {
                        int tlabel = B;
                        if ( B ) tlabel = B;
                        else if ( C ) tlabel = C;
                        else if ( D ) tlabel = D;
                        else if ( E ) tlabel = E;
                        L.elem(r,c) = tlabel;
                        if ( B && B != tlabel ) lset[B] = tlabel;
                        if ( C && C != tlabel ) lset[C] = tlabel;
                        if ( D && D != tlabel ) lset[D] = tlabel;
                        if ( E && E != tlabel ) lset[E] = tlabel;
                    } else {
                        //   label and put into table
                        ntable++;
                        L.elem(r,c) = lset[ ntable ] = ntable;
                    }
                }
            } else {
                L.elem(r,c) = NO_OBJECT;      // A is not an object so leave it
            }
        }
    }
    
    // consolidate component table
    for( int i = 0; i <= ntable; i++ )
        lset[i] = find( lset, i );

    // run image through the look-up table
    for( int r = 0; r < nr; r++ )
        for( int c = 0; c < nc; c++ )
            L.elem(r,c) = lset[ (int)L.elem(r,c) ];
    
    // count up the objects in the image
    for( int i = 0; i <= ntable; i++ )
        lset[i] = 0;

    for( int r = 0; r < nr; r++ )
        for( int c = 0; c < nc; c++ )
            lset[ (int)L.elem(r,c) ]++;

    // number the objects from 1 through n objects
    nobj = 0;
    lset[0] = 0;
    for( int i = 1; i <= ntable; i++ )
        if ( lset[i] > 0 )
            lset[i] = ++nobj;

    // run through the look-up table again
    for( int r = 0; r < nr; r++ )
        for( int c = 0; c < nc; c++ )
            L.elem(r,c) = lset[ (int)L.elem(r,c) ];

    octave_value_list rval;
    rval(0) = L;
    rval(1) = (double)nobj;
    return rval;
}


static bool any_bad_argument( const octave_value_list& args )
{
    if ( args.length() < 1 || args.length() > 2 ) {
        error( "bwlabel: number of arguments - expecting bwlabel(bw) or bwlabel(bw,n)" );
        return true;
    }
    
    if ( !args(0).is_matrix_type() ) {
        error( "bwlabel: matrix expected for first argument" );
        return true;
    }
    
    if ( args.length() == 2 ) {
        if ( !args(1).is_real_scalar() ) {
            error( "bwlabel: expecting real scalar for second argument" );
            return true;
        }
        int n = args(1).int_value();
        if ( n != 4 && n != 6 && n != 8 ) {
            error( "bwlabel: in bwlabel(BW,n) n must be in {4,6,8}" );
            return true;
        }
    }
    
    return false;
    
}


static int find( int set[], int x )
{
    int r = x;
    while ( set[r] != r )
        r = set[r];
    return r;
}

