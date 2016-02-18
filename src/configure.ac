AC_PREREQ([2.67])
AC_INIT([Octave-Forge image package], [2.5.0+])

AC_PROG_SED

AC_PROG_CXX
AC_LANG(C++)

XTRA_CXXFLAGS="-Wall"


AC_PATH_PROG([MKOCTFILE], [mkoctfile])
if test -z "$MKOCTFILE"; then
  AC_MSG_ERROR([*** 'mkoctfile' not found.])
fi

AC_PATH_PROG([OCTAVE], [octave])
if test -z "$OCTAVE"; then
  AC_MSG_ERROR([*** 'octave' not found.])
fi


image_save_CXX="$CXX"
OCTAVE_IMAGE_PROG_CXX_CXX11(
  [],
  [AC_MSG_ERROR([*** A compiler with support for C++11 is required])])

CXX11_SWITCH=$(echo "$CXX" | $SED "s,^$image_save_CXX ,,")
MKOCTFILE="$MKOCTFILE $CXX11_SWITCH"


## Test for gcc bug #65843 https://gcc.gnu.org/bugzilla/show_bug.cgi?id=65843
## which shows up as Octave bug #45096 https://savannah.gnu.org/bugs/?45096
AC_CACHE_CHECK([whether templated lambda functions accept '&const int'],
  [_cv_template_lambda_accepts_ref_const_inst],
  [AC_COMPILE_IFELSE(
    [AC_LANG_PROGRAM([[
      template<class T>
      void test (T b)
      {
        const int a = b;
        [&] () { return a, a; }();
      }
      ]], [[ test (1); ]])],
    [_cv_template_lambda_accepts_ref_const_inst=yes],
    [_cv_template_lambda_accepts_ref_const_inst=no])
])
if test $_cv_template_lambda_accepts_ref_const_inst = no; then
  AC_MSG_WARN([
    Your C++ compiler (are you using GCC 5.0 or 5.1?) has a bug that
    prevents it from building the Octave Forge image package.  But you
    can fix it very easily.  See https://savannah.gnu.org/bugs/?45096
    for details on working around it.
  ])
fi

## Starting with Octave 4.2 (and some 4.1.X versions), the function
## im2double has been moved to Octave core.
HAS_IM2DOUBLE=`$OCTAVE -qf --eval "printf ('%i', exist ('im2double'))"`
if test "$HAS_IM2DOUBLE" == 0; then
  AC_CONFIG_FILES([im2double.m])
fi

AC_SUBST([XTRA_CXXFLAGS])

AC_CONFIG_FILES([Makefile])

AC_OUTPUT
