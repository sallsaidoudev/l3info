# This file is part of MLGame (OCaml Game System).
#
# MLGame is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA 02111-1307 USA *)

# author Cezary Kaliszyk
# Initial caml config borrowed from Jean-Christophe Filliâtre
# Who borrowed it from a first script by Georges Mariano 

AC_INIT(MLG/log.ml)
AC_CONFIG_AUX_DIR(./Config)
AC_PROG_CC
AC_PROG_LIBTOOL
AC_CANONICAL_TARGET

AC_CHECK_PROG(OCAMLC,ocamlc,ocamlc,no)
if test "$OCAMLC" = no ; then AC_MSG_ERROR(Cannot find ocamlc.) fi

OCAMLVERSION=`$OCAMLC -v | sed -n -e 's|.*version *\(.*\)$|\1|p' `
echo "ocaml version is $OCAMLVERSION"

OCAMLLIB=`$OCAMLC -v | tail -1 | cut -f 4 -d " "`
echo "ocaml library path is $OCAMLLIB"

AC_ARG_ENABLE(bytecode,
[  --enable-bytecode       Compile to bytecode          [default=no]],
BYTECODE=YES,BYTECODE=NO)

AC_ARG_ENABLE(profile,
[  --enable-profile        Compile profiled binaries    [default=no]],
MY_PROFILE="YES",MY_PROFILE="NO")

AC_ARG_ENABLE(all-static,
[  --enable-all-static     Compile static binaries      [default=no]],
MY_STATIC=" -all-static ",MY_STATIC="")

if test "$BYTECODE" = YES ; then
   if test "$MY_PROFILE" = YES ; then
      AC_CHECK_PROG(OCAMLCP,ocamlcp,ocamlcp,no)
      if test "$OCAMLCP" = no ; then
         AC_MSG_WARN(Cannot find ocamlcp; profiling bytecode unavailable.)
         PROFILE=NO
      fi
   fi
   if test "$MY_STATIC" = " -all-static " ; then
      AC_MSG_WARN(Bytecode, static compilation not available.)
      MY_STATIC=""
   fi
else
   AC_CHECK_PROG(OCAMLOPT,ocamlopt,ocamlopt,no)
   if test "$OCAMLOPT" = no ; then
      AC_MSG_WARN(Cannot find ocamlopt; bytecode compilation only.)
      BYTECODE=YES
   fi
fi

# Check for ".opt" versions

if test "$BYTECODE" = YES ; then
   if test "$MY_PROFILE" = NO ; then
      AC_CHECK_PROG(OCAMLCDOTOPT,ocamlc.opt,ocamlc.opt,no)
      if test "$OCAMLCDOTOPT" != no ; then
         OCAMLC=$OCAMLCDOTOPT
      fi
   else
      AC_CHECK_PROG(OCAMLCPDOTOPT,ocamlcp.opt,ocamlcp.opt,no)
      if test "$OCAMLCPDOTOPT" != no ; then
         OCAMLCP=$OCAMLCPDOTOPT
      fi
   fi
else
   AC_CHECK_PROG(OCAMLOPTDOTOPT,ocamlopt.opt,ocamlopt.opt,no)
   if test "$OCAMLOPTDOTOPT" != no ; then
      OCAMLOPT=$OCAMLOPTDOTOPT
   fi
fi

AC_ARG_ENABLE(gl-sdl,
[  --enable-gl-sdl         Compile with glSDL           [default=no]],
CFLAGS="$CFLAGS -DUSE_GLSDL" OCAMLSDL="sdl-gl",OCAMLSDL="sdl")

AC_CHECK_PROG(OCAMLDEP,ocamldep,ocamldep,no)
if test "$OCAMLDEP" = no ; then
   AC_MSG_ERROR(Cannot find ocamldep.) 
else
   AC_CHECK_PROG(OCAMLDEPDOTOPT,ocamldep.opt,ocamldep.opt,no)
   if test "$OCAMLDEPDOTOPT" != no ; then
      OCAMLDEP=$OCAMLDEPDOTOPT
   fi
fi

AC_CHECK_PROG(OCAMLLEX,ocamllex,ocamllex,no)
if test "$OCAMLLEX" = no ; then
   AC_MSG_ERROR(Cannot find ocamllex.)
else
   AC_CHECK_PROG(OCAMLLEXDOTOPT,ocamllex.opt,ocamllex.opt,no)
   if test "$OCAMLLEXDOTOPT" != no ; then
      OCAMLLEX=$OCAMLLEXDOTOPT
   fi
fi

AC_CHECK_PROG(OCAMLYACC,ocamlyacc,ocamlyacc,no)
if test "$OCAMLYACC" = no ; then AC_MSG_ERROR(Cannot find ocamlyacc.) fi

# platform
AC_MSG_CHECKING(platform)
if echo "let _ = Sys.os_type" | ocaml | grep -q Win32; then
    AC_MSG_RESULT(Win32)
    OCAMLWIN32=yes
    EXE=.exe
else
    AC_MSG_RESULT(ok)
    OCAMLWIN32=no
    EXE=
fi

dnl Check for SDL
SDL_VERSION=1.2.4
AM_PATH_SDL($SDL_VERSION,
            :,
            AC_MSG_ERROR([*** SDL version $SDL_VERSION not found!])
)
CFLAGS="$CFLAGS $SDL_CFLAGS"
CLIBS="$LIBS $SDL_LIBS"

# substitutions to perform
AC_SUBST(OCAMLC)
AC_SUBST(OCAMLCP)
AC_SUBST(OCAMLOPT)
AC_SUBST(OCAMLDEP)
AC_SUBST(OCAMLLEX)
AC_SUBST(OCAMLYACC)
AC_SUBST(BYTECODE)
AC_SUBST(MY_STATIC)
AC_SUBST(MY_PROFILE)
AC_SUBST(OCAMLVERSION)
AC_SUBST(OCAMLLIB)
AC_SUBST(OCAMLWIN32)
AC_SUBST(EXE)
AC_SUBST(CLIBS)
AC_SUBST(CC)
AC_SUBST(OCAMLSDL)

# Finally create the output file
AC_OUTPUT(Common.mk)
