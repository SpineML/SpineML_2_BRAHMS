dnl Process this file with autoconf to produce a configure script.
AC_PREREQ(2.59)
AC_INIT([spineml-2-brahms], [0.1], [a.cope@sheffield.ac.uk])
AC_CONFIG_SRCDIR(tools/allToAll/brahms/0/component.cpp)
AC_REVISION([$Revision: 1.0.0 $])
AC_PREFIX_DEFAULT(/usr/local)

AM_INIT_AUTOMAKE([1.9 foreign])

AC_CONFIG_HEADER(config.h)

AC_LANG_CPLUSPLUS

dnl Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
dnl We don't ever use static versions of the components so disable static:
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

dnl check for libs
dnl AC_CHECK_LIB([futil], [main])

dnl Checks for header files.
AC_CHECK_HEADERS([sys/types.h pthread.h sys/stat.h sys/socket.h netinet/in.h arpa/inet.h dirent.h pwd.h errno.h string.h stdlib.h unistd.h])

dnl Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST
AC_TYPE_PID_T
#AC_STRUCT_TM

dnl Checks for library functions.
AC_FUNC_FORK
AC_FUNC_MALLOC
AC_HEADER_STDC
AC_FUNC_SELECT_ARGTYPES
AC_FUNC_STAT
AC_CHECK_FUNCS([memset mkdir]) # would be more of these.

dnl Checks for endianness
AC_C_BIGENDIAN

dnl
dnl Checks for word sizes
dnl Note: These #defines (in config.h) could be used in place of the typedefs in 
dnl framework/public/brahms-component.h 
dnl

AC_CHECK_SIZEOF([char])
AC_CHECK_SIZEOF([unsigned char])
if test "$ac_cv_sizeof_char" -eq 1; then
  AC_DEFINE(INT8_TYPE, [char], [Signed 8 bit])
else
  AC_MSG_ERROR([compiler has no 1 byte char])
fi
if test "$ac_cv_sizeof_unsigned_char" -eq 1; then
  AC_DEFINE(UINT8_TYPE, [unsigned char], [Unsigned 8 bit])
else
  AC_MSG_ERROR([compiler has no 1 byte unsigned char])
fi

AC_CHECK_SIZEOF([short])
AC_CHECK_SIZEOF([unsigned short])
if test "$ac_cv_sizeof_short" -eq 2; then
  AC_DEFINE(INT16_TYPE, [short], [Signed 16 bit])
else
  AC_MSG_ERROR([compiler has no 2 byte short])
fi
if test "$ac_cv_sizeof_unsigned_short" -eq 2; then
  AC_DEFINE(UINT16_TYPE, [unsigned short], [Unsigned 16 bit])
else
  AC_MSG_ERROR([compiler has no 2 byte unsigned short])
fi

AC_CHECK_SIZEOF([int])
AC_CHECK_SIZEOF([unsigned int])
AC_CHECK_SIZEOF([long])
AC_CHECK_SIZEOF([unsigned long])
if test "$ac_cv_sizeof_int" -eq 4; then
  AC_DEFINE(INT32_TYPE, [int], [Signed 32 bit])
elif test "$ac_cv_sizeof_long" -eq 4; then
  AC_DEFINE(INT32_TYPE, [long], [Signed 32 bit])
else
  AC_MSG_ERROR([compiler has no 4 byte integer])
fi
if test "$ac_cv_sizeof_unsigned_int" -eq 4; then
  AC_DEFINE(UINT32_TYPE, [unsigned int], [Unsigned 32 bit])
elif test "$ac_cv_sizeof_unsigned_long" -eq 4; then
  AC_DEFINE(UINT32_TYPE, [unsigned long], [Unsigned 32 bit])
else
  AC_MSG_ERROR([compiler has no 4 byte unsigned integer])
fi

if test "$ac_cv_sizeof_long" -eq 8; then
  AC_DEFINE(INT64_TYPE, [long], [Signed 64 bit])
else
  AC_CHECK_SIZEOF([long long])
  if test "$ac_cv_sizeof_long_long" -eq 8; then
    AC_DEFINE(HAVE_LONG_LONG, 1, [Have the long long type])
    AC_DEFINE(INT64_TYPE, [long long], [Signed 64 bit])
  else
    AC_MSG_ERROR([compiler has no 8 byte integer])
  fi
fi
if test "$ac_cv_sizeof_unsigned_long" -eq 8; then
  AC_DEFINE(UINT64_TYPE, [unsigned long], [Unsigned 32 bit])
else
  AC_CHECK_SIZEOF([unsigned long long])
  if test "$ac_cv_sizeof_unsigned_long_long" -eq 8; then
    AC_DEFINE(HAVE_UNSIGNED_LONG_LONG, 1, [Have the unsigned long long type])
    AC_DEFINE(UINT64_TYPE, [unsigned long long], [Unsigned 32 bit])
  else
    AC_MSG_ERROR([compiler has no 8 byte unsigned integer])
  fi
fi

AC_CHECK_SIZEOF([float])

if test "$ac_cv_sizeof_float" -eq 4; then
  AC_DEFINE(FLOAT4_TYPE, [float], [32 bit float])
else
  AC_MSG_ERROR([compiler has no 4 byte float])
fi

AC_CHECK_SIZEOF([double])

if test "$ac_cv_sizeof_double" -eq 8; then
  AC_DEFINE(DOUBLE8_TYPE, [double], [64 bit float])
else
  AC_MSG_ERROR([compiler has no 8 byte double])
fi

dnl Determine host system type
dnl AC_CANONICAL_HOST
AC_DEFINE_UNQUOTED(HOST, "$host", [The host system wmlppui was configured for])

AC_CANONICAL_HOST
# Check for which host we are on and setup a few things
# specifically based on the host
case $host_os in
  darwin* )
        AC_DEFINE(__OSX__, 1, [Apple OS X Brahms builds require this to be defined])
        AC_SUBST(BRAHMS_HOST_DEFINITION, [-D__OSX__])
        ;;
  linux*)
        # The AC_DEFINE appears in config.h which can be #included by your code
        AC_DEFINE(__GLN__, 1, [GNU Linux Brahms builds require this to be defined])
        # AC_SUBST variables are available for use in Makefile.am.
        AC_SUBST(BRAHMS_HOST_DEFINITION, [-D__GLN__])
        ;;
   *BSD*)
        AC_DEFINE(__NIX__, 1, [Unix Brahms builds require this to be defined])
        AC_SUBST(BRAHMS_HOST_DEFINITION, [-D__NIX__])
        ;;
    *)
        #Default Case
        AC_MSG_ERROR([Your platform is not currently supported])
        ;;
esac

dnl enable/disable compiler warnings (using gcc), if specified
AC_ARG_ENABLE(warnings-are-errors,
  [  --disable-warnings-are-errors      disable gcc all warnings are errors [default=no]],
  [case "${enableval}" in
    yes) brahms_warnings=yes ;; 
    no)  brahms_warnings=no ;;
    *) AC_MSG_ERROR(bad value ${enableval} for --enable-warnings-are-errors) ;;
  esac], brahms_warnings=yes)
AC_MSG_CHECKING(whether gcc should treat all warnings as errors)
AC_MSG_RESULT($brahms_warnings)
dnl Note: this could break some compilers which don't support -Wall.
if (test "$brahms_warnings" = yes && test "$GCC" = yes); then
   BRAHMS_WARNING_CPPFLAGS="-Wall -Werror"
   AC_SUBST([BRAHMS_WARNING_CPPFLAGS])
fi

dnl The CFLAGS which are preferred by Brahms. Added to CFLAGS in the Makefile.ams
AC_ARG_ENABLE(brahms-cflags,
  [  --enable-brahms-cflags      Add Brahms-preferred compiler flags [default=yes]],
  [case "${enableval}" in
    yes) brahms_cflags=yes ;; 
    no)  brahms_cflags=no ;;
    *) AC_MSG_ERROR(bad value ${enableval} for --enable-brahms-cflags) ;;
  esac], brahms_cflags=yes)
AC_MSG_CHECKING(whether to add Brahms-preferred compiler flags)
AC_MSG_RESULT($brahms_cflags)
dnl Note: this could break some compilers which don't support all of these flags
if (test "$brahms_cflags" = yes && test "$GCC" = yes); then
   BRAHMS_CFLAGS="-ffast-math"
   AC_SUBST([BRAHMS_CFLAGS])
fi

dnl Where to find Brahms headers
AC_ARG_WITH([brahms-include-path],
  [AS_HELP_STRING([--with-brahms-include-path=DIR],
    [location of the Brahms headers, defaults to /usr/include/brahms])],
  [BRAHMS_INCLUDE_DIR="$withval"],
  [BRAHMS_INCLUDE_DIR='/usr/include/brahms'])
AC_SUBST([BRAHMS_INCLUDE_DIR])

dnl Where to find Brahms libs
AC_ARG_WITH([brahms-lib-path],
  [AS_HELP_STRING([--with-brahms-lib-path=DIR],
    [location of the Brahms libs, especially libbrahms-engine.so. defaults to /usr/lib/brahms])],
  [BRAHMS_LIB_DIR="$withval"],
  [BRAHMS_LIB_DIR='/usr/lib/brahms'])
AC_SUBST([BRAHMS_LIB_DIR])

dnl Where to find the Brahms default/standard namespace
AC_ARG_WITH([brahms-namespace-path],
  [AS_HELP_STRING([--with-brahms-namespace-path=DIR],
    [location of the Brahms headers, defaults to /var/lib/brahms/Namespace])],
  [BRAHMS_NAMESPACE_DIR="$withval"],
  [BRAHMS_NAMESPACE_DIR='/var/lib/brahms/Namespace'])
AC_SUBST([BRAHMS_NAMESPACE_DIR])

dnl Always output certain files
AC_CONFIG_FILES([
Makefile
include/Makefile
xsl/Makefile
xsl/HL/Makefile
xsl/LL/Makefile
tools/Makefile
tools/allToAll/Makefile
tools/allToAll/brahms/Makefile
tools/allToAll/brahms/0/Makefile
tools/AnalogConstantInput/Makefile
tools/AnalogConstantInput/brahms/Makefile
tools/AnalogConstantInput/brahms/0/Makefile
tools/AnalogTimeVaryingInput/Makefile
tools/AnalogTimeVaryingInput/brahms/Makefile
tools/AnalogTimeVaryingInput/brahms/0/Makefile
tools/EventConstantInput/Makefile
tools/EventConstantInput/brahms/Makefile
tools/EventConstantInput/brahms/0/Makefile
tools/EventTimeVaryingInput/Makefile
tools/EventTimeVaryingInput/brahms/Makefile
tools/EventTimeVaryingInput/brahms/0/Makefile
tools/explicitList/Makefile
tools/explicitList/brahms/Makefile
tools/explicitList/brahms/0/Makefile
tools/externalInput/Makefile
tools/externalInput/brahms/Makefile
tools/externalInput/brahms/0/Makefile
tools/externalOutput/Makefile
tools/externalOutput/brahms/Makefile
tools/externalOutput/brahms/0/Makefile
tools/fixedProbability/Makefile
tools/fixedProbability/brahms/Makefile
tools/fixedProbability/brahms/0/Makefile
])

AC_OUTPUT
