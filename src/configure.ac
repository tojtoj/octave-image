AC_PREREQ([2.67])
AC_INIT([Octave-Forge image package], [2.4.1])

AC_PROG_CXX
AC_LANG(C++)

AX_CXX_COMPILE_STDCXX_11()

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
  AC_MSG_ERROR([
    Your C++ compiler (are you using GCC 5.0 or 5.1?) has a bug that
    prevents it from building the Octave Forge image package.  But you
    can fix it very easily.  See https://savannah.gnu.org/bugs/?45096
    for details on working around it.
  ])
fi

AC_CONFIG_FILES([Makefile])

AC_OUTPUT
