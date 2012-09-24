 /* $Id$ */
#include <octave/oct.h>
 /****************************************************************************
  * (C)opyright Christian Kotz 2006
  * This code has no warranty whatsover. Do what you like with this code 
  *  as long as you leave this copyright in place.
  ****************************************************************************
  * author: Christian Kotz 
  * date:     $Date$
  * version: $Revision$
  *
  * (email: christian dot kotz at gmx dot net)
  *
  * History: 
  * $Log$
  * Revision 1.2  2007/01/04 21:58:50  hauberg
  * Texinfo-fication of the help texts
  *
  * Revision 1.1  2006/12/08 06:43:30  cocus
  * fast c implementation to replace m file deriche.m
  *
  */
/*  
              "-*- texinfo -*-\n\
 @deftypefn{Loadable Function} {@var{b}} = deriche(@var{a}, @var{n}, @var{m})\n\
 \n\
 @cindex deriche edge detector\n\
 \n\
 Return edge detector image of @var{a} image according to an algorithm by Rachid Deriche. \n\
 Matrix @var{a} is a real matrix, and @var{n} a non-negative real kernel scaling parameter (default 1.0).\
 Specify @var{m} of 0 for a gradient magnitude result (default), @var{m} of 1 for a vector\
 gradient result.\n @var{n} and @var{m} are optional arguments.\
 Processing time is independent on var{n}. see Klette, Zameroni: Handbuch der\
 Operatoren fuer die Bildverarbeitung, vieweg 2. ed. 1995 pp. 224--229. for\
 details.\n\
 Original paper: Deriche, R.: Fast algorithms for low-level vision: IEEE Trans PAMI-12 (1990) pp 78--87\n\
"
*/
 
 static void dericheAbs(const double  *p, double *q, int w, int h, int linLen, double alpha);
 static void dericheVec(const double  *p, double *q, int w, int h, int linLen, double alpha);
 
 DEFUN_DLD(deriche, args, ,
            "-*- texinfo -*-\n\
@deftypefn{Loadable Function} {@var{b}} = deriche(@var{a}, @var{n}, @var{m})\n\
 \n\
 @cindex deriche edge detector\n\
 Return edge detector image of @var{a} image according to an algorithm by Rachid Deriche. \n\
 Matrix @var{a} is a real matrix, and @var{n} a non-negative real kernel scaling parameter (default 1.0).\
 Specify @var{m} = 0 for a gradient magnitude result (default), @var{m} = 1 for a vector\
 gradient result.\n @var{n} and @var{m} are optional arguments.\
 \n\n\
 Processing time is independent on @var{n}.\n\
 see for details: Klette, Zameroni: Handbuch der Operatoren fuer die Bildverarbeitung, vieweg 2. ed. 1995 pp. 224--229.\n\
 Original paper: Deriche, R.: Fast algorithms for low-level vision: IEEE Trans PAMI-12 (1990) pp 78--87.\
 \n\n\
 Example:\
  @example\n\
  a = double(imread('myimg.png'));\n\
  b = deriche(a, 1.0, 1);\n\
  imshow(b(:,:,1));\n\
  imshow(b(:,:,2));\n\
  @end example\n\
 @end deftypefn\
 ")

 {  
     enum Method { absgrad, vecgrad, polargrad };
     const int nargin = args.length();
     
     if (nargin < 1 || nargin > 2){
        error("call to deriche needs 1 or 2 arguments supplied.");
        return octave_value_list ();
     }       
     
     const double alpha = (nargin <  2) ? 1.0: args(1).double_value();  
     Method method = absgrad;
     if (args.length() >  2){
        int m = (int)(args(2).double_value());
        switch(m){
        case 0: break;
        case 1: method = vecgrad; break;
        case 2: method = polargrad;
          error("not yet implemented. Use builtin 'card2pol' after method 2 (cartesian vector grad).");
          return octave_value_list ();
        default:
          error("unknown method parameter.");
          return octave_value_list ();
        }
     }
  
     Matrix p(args(0).matrix_value());
     const int h = p.rows();
     const int w = p.columns();
     switch (method){
     case absgrad:{
        Matrix b(h, w);
        dericheAbs(p.fortran_vec(), b.fortran_vec(), h, w, h, alpha);
        return octave_value(b);     
     }
     case vecgrad:{
        NDArray b(dim_vector(h,w,2));
        dericheVec(p.fortran_vec(), b.fortran_vec(), h, w, h, alpha);
        return octave_value(b);
     }
     default:
      error("method not yet implemented.");
        return octave_value_list();
     }     
 }
 
 // q has to be dense gapless, for w and liLen may differ
 static void dericheAbs(const double  *p, double *q, int w, int h, int linLen, double alpha){
  double a(1.0-exp(-alpha));
  a = - (a*a);
  double b1(-2.0 * exp(-alpha));
  double b2(exp(-2.0*alpha));
  double a0(-a/(1.0-a*b1-b2));
  double a1(a0*(alpha-1)*exp(-alpha));
  double a2(a1-a0*b1);
  double a3(-a0*b2);
  double *tmp = 0;
  //const int sz = h*w; // unused 
  try {
    tmp = new double[2*h*w + 2*w];
    if (!tmp) {
        error("alloc error");
        return;
    }
    memset(tmp, 0, 2*h*w+2*linLen * sizeof(double));
    double* B1 = tmp;
    double* B2 = B1 + h *w;
    double* Z3 = B2 + h * w;
    double* Z2 = Z3 + w;
  
    const double  *ze; // int8
    //double  *za; // int8 // unused
    double *Ba1;
    double *Ba2;

  // Berechnung von H
  int y;
  for(y=2; y < h; y++){  // (i)
    ze = p + linLen*y;
    Ba1 = B1 + w*y;  
    for(int x=0;x < w; x++)
      Ba1[x] = ze[x] - b1* *(Ba1 + x - w) - b2 * *(Ba1 + x -w -w);   
  };
 
  for(y = h-3 ; y >= 0 ; y--){       // (ii)
     ze = p + (y+1) * linLen;
     Ba1 = B1 + w*y;
     Ba2 = B2 + w*y;
    int x;
    for(x=0; x < w; x++){
      Ba2[x] = ze[x] - b1 * Ba2[x+w] - b2 * Ba2[x+w+w];
      Ba1[x] = a * (Ba1[x] - Ba2[x]);
    };
  };
  
  for(y=0;y<h;y++){ // (iii, iv)
     Ba1 = B1 + w*y; // Ba1 ist Z1 im Buch
     int x;
     for(x=2;x<w;x++)
       Z2[x] = a0 * Ba1[x] + a1 * *(Ba1 + x - 1) - b1 * *(Z2 + x -1) - b2 * *(Z2 + x-2);
     for(x = w-3; x >= 0 ; x--)
       Z3[x] = a2 * Ba1[x+1] + a3 * Ba1[x+2] - b1 * Z3[x+1] - b2 * Z3[x+2];
     for(x=0;x<w;x++){
         q[y*w+x] = Z2[x] + Z3[x];
     };
   }
  
    // Berechnung von V
    memset (Z2, 0, w*sizeof(double));
    memset (Z3, 0, w*sizeof(double));
  
  for(y=0; y < h; y++){  // (v, vi)
      ze = p + linLen*y;
      Ba1 = B1 + w*y;
      int x;
      for(x=2;x < w; x++)
        Z2[x] = *(ze+x-1) - b1 * *(Z2+x-1) - b2 * *(Z2+x-2);
      for(x=w-3; x >=0 ; x--)
        Z3[x] = ze[x+1] - b1 * Z3[x+1] - b2 * Z3[x+2];
      for(x=0; x < w; x++)
        Ba1[x] = a * (Z2[x] - Z3[x]);
    };
    for(y = 2 ; y < h ; y++){       // (vii)
       Ba2 = B2 + w*y;
       Ba1 = B1 + w*y;
       int x;
       for(x=0; x < w; x++)
          Ba2[x] = (a0 + a1) * Ba1[x] - b1 * *(Ba2+x-w) - b2 * *(Ba2+x-w-w);
    };
    for(y = h - 3 ; y >= 0 ; y--){  // (viii)
       Ba1 = B1 + y * w;
       Ba2 = B2 + y * w;
       memcpy(Z2, Ba2, w * sizeof(double)); // save contents of row in Z2
       int x;
       for(x= 0; x < w; x++){
          Ba2[x] = a2 * Ba1[x+w] + a3 * Ba1[x+w+w]
            - b1 * Ba2[x+w] - b2 * Ba2[x+w+w];
       };
       for(x= 0; x < w; x++){//  memset (B1, 0, h*w*sizeof(double));
          double z1 = Ba2[x] + Z2[x];
          double z2 = q[y*w+x];
          q[y*w+x] = sqrt(z1 * z1 + z2 * z2);
       };
    }  
  }catch(...){
    delete [] tmp;
    throw;
  }
  delete[] tmp;  
  }

  // q has to be dense gapless, for w and liLen may differ
  static void dericheVec(const double  *p, double *q, int w, int h, int linLen, double alpha){
  double a(1.0-exp(-alpha));
  a = - (a*a);
  double b1(-2.0 * exp(-alpha));
  double b2(exp(-2.0*alpha));
  double a0(-a/(1.0-a*b1-b2));
  double a1(a0*(alpha-1)*exp(-alpha));
  double a2(a1-a0*b1);
  double a3(-a0*b2);
  double *tmp = 0;
  double *r=q+h*w;
  //const int sz = h*w;  // unused
  try {
    tmp = new double[2*h*w + 2*w];
    if (!tmp) {
        error("alloc error");
        return;
    }
    memset(tmp, 0, 2*h*w+2*linLen * sizeof(double));
    double* B1 = tmp;
    double* B2 = B1 + h *w;
    double* Z3 = B2 + h * w;
    double* Z2 = Z3 + w;
  
    const double  *ze; // int8
    //double  *za; // int8 // unused
    double *Ba1;
    double *Ba2;

  // Berechnung von H
  int y;
  for(y=2; y < h; y++){  // (i)
    ze = p + linLen*y;
    Ba1 = B1 + w*y;  
    for(int x=0;x < w; x++)
      Ba1[x] = ze[x] - b1* *(Ba1 + x - w) - b2 * *(Ba1 + x -w -w);
  };
 
  for(y = h-3 ; y >= 0 ; y--){       // (ii)
     ze = p + (y+1) * linLen;
     Ba1 = B1 + w*y;
     Ba2 = B2 + w*y;
    int x;
    for(x=0; x < w; x++){
      Ba2[x] = ze[x] - b1 * Ba2[x+w] - b2 * Ba2[x+w+w];
      Ba1[x] = a * (Ba1[x] - Ba2[x]);
    };
  };
  
  for(y=0;y<h;y++){ // (iii, iv)
     Ba1 = B1 + w*y; // Ba1 ist Z1 im Buch
     int x;
     for(x=2;x<w;x++)
       Z2[x] = a0 * Ba1[x] + a1 * *(Ba1 + x - 1) - b1 * *(Z2 + x -1) - b2 * *(Z2 + x-2);
     for(x = w-3; x >= 0 ; x--)
       Z3[x] = a2 * Ba1[x+1] + a3 * Ba1[x+2] - b1 * Z3[x+1] - b2 * Z3[x+2];
     for(x=0;x<w;x++){
       q[y*w+x] =  Z2[x] + Z3[x];
     };
   }
  
    // Berechnung von V
    memset (Z2, 0, w*sizeof(double));
    memset (Z3, 0, w*sizeof(double));
  
  for(y=0; y < h; y++){  // (v, vi)
      ze = p + linLen*y;
      Ba1 = B1 + w*y;
      int x;
      for(x=2;x < w; x++)
        Z2[x] = *(ze+x-1) - b1 * *(Z2+x-1) - b2 * *(Z2+x-2);
      for(x=w-3; x >=0 ; x--)
        Z3[x] = ze[x+1] - b1 * Z3[x+1] - b2 * Z3[x+2];
      for(x=0; x < w; x++)
        Ba1[x] = a * (Z2[x] - Z3[x]);
    };
    for(y = 2 ; y < h ; y++){       // (vii)
       Ba2 = B2 + w*y;
       Ba1 = B1 + w*y;
       int x;
       for(x=0; x < w; x++)
          Ba2[x] = (a0 + a1) * Ba1[x] - b1 * *(Ba2+x-w) - b2 * *(Ba2+x-w-w);
    };
    for(y = h - 3 ; y >= 0 ; y--){  // (viii)
       Ba1 = B1 + y * w;
       Ba2 = B2 + y * w;
       memcpy(Z2, Ba2, w * sizeof(double)); // save contents of row in Z2
       int x;
       for(x= 0; x < w; x++){
          Ba2[x] = a2 * Ba1[x+w] + a3 * Ba1[x+w+w]
            - b1 * Ba2[x+w] - b2 * Ba2[x+w+w];
       };
       for(x= 0; x < w; x++){//  memset (B1, 0, h*w*sizeof(double));
          r[y*w+x]  = Ba2[x] + Z2[x];
       };
    }  
  }catch(...){
    delete [] tmp;
    throw;
  }
  delete[] tmp;
  }
