AC_PREREQ([2.67])
AC_INIT([Octave-Forge image package], [2.1.0+])

AH_BOTTOM([#include "undef_unordered_map.h"])
AC_CONFIG_HEADERS([config.h])

CXXFLAGS="-std=c++0x"
CPPFLAGS="-std=c++0x"

AC_PROG_CXX
AC_LANG(C++)

AC_CHECK_PROG([HAVE_MKOCTFILE], [mkoctfile], [yes], [no])
if [test $HAVE_MKOCTFILE = "no"]; then
  AC_MSG_ERROR([mkoctfile required to install $PACKAGE_NAME])
fi

dnl
dnl Check for unordered map headers and whether tr1 namespace is
dnl required. This is copied from m4/acinclude.m4 from core Octave
dnl
AC_DEFUN([OCTAVE_UNORDERED_MAP_HEADERS], [
  AC_CHECK_HEADERS([unordered_map], [],
    [AC_CHECK_HEADERS([tr1/unordered_map])])
  AC_CACHE_CHECK([whether unordered_map requires tr1 namespace], 
    [octave_cv_header_require_tr1_namespace],
    [AC_LANG_PUSH(C++)
    octave_cv_header_require_tr1_namespace=no
    if test $ac_cv_header_unordered_map = yes; then
      ## Have <unordered_map>, but still have to check whether
      ## tr1 namespace is required (like MSVC, for instance).
      AC_COMPILE_IFELSE(
        [AC_LANG_PROGRAM([[
          #include <unordered_map>
          ]], [[
          std::unordered_map<int,int> m;
        ]])],
        octave_cv_header_require_tr1_namespace=no, 
        octave_cv_header_require_tr1_namespace=yes)
    elif test $ac_cv_header_tr1_unordered_map = yes; then
      octave_cv_header_require_tr1_namespace=yes
    fi
    AC_LANG_POP(C++)
  ])
  if test $octave_cv_header_require_tr1_namespace = yes; then
    AC_DEFINE(USE_UNORDERED_MAP_WITH_TR1, 1, 
      [Define to 1 if unordered_map requires the use of tr1 namespace.])
  fi
])

OCTAVE_UNORDERED_MAP_HEADERS

AC_OUTPUT
