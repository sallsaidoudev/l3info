MODULES:=MLG Examples/Dummy Examples/Snake Examples/Shooter Examples/Go Scorch ..
OFLAGS=
CFLAGS=
LFLAGS=unix.${LIB_SUF} bigarray.${LIB_SUF} sdl.${LIB_SUF} sdlloader.$(LIB_SUF)
###
PROFILE  = NO
STATIC   = 
BYTECODE = NO
OCAMLSDL = sdl
OCAMLC   = ocamlc
OCAMLCP  = 
OCAMLOPT = ocamlopt
OCAMLDEP = ocamldep
OCAMLLEX = ocamllex
OCAMLYACC= ocamlyacc
OCAMLLIB = /usr/lib/ocaml
OCAMLVERSION = 4.01.0
OCAMLWIN32 = no
###
CLIBS= -L/usr/lib/x86_64-linux-gnu -lSDL
CC = gcc
CFLAGS  += -g -O2 -I/usr/include/SDL -D_GNU_SOURCE=1 -D_REENTRANT -I$(OCAMLLIB) -I$(OCAMLLIB)/$(OCAMLSDL)
CAMLP4=
LFLAGS+= -cc "$(TOP)/libtool --mode=link $(CC) $(STATIC) $(CLIBS) -lSDL_image -L$(TOP)/MLG"

OINCLUDES_GEN=+$(OCAMLSDL) /tmp/SDL/ocamlsdl
OINCLUDES_GEN :=$(addprefix -I ,$(OINCLUDES_GEN))
OFLAGS+=$(OINCLUDES_GEN)
###
ifeq ($(BYTECODE),NO)
  ifeq ($(PROFILE),YES)
    OCAML_COMP=${OCAMLOPT} -p ${CAMLP4} ${OFLAGS} -I out ${OINCLUDES}
  else
    OCAML_COMP=${OCAMLOPT} ${CAMLP4} ${OFLAGS} -I out ${OINCLUDES}
  endif
  OBJ_SUF=cmx
  LIB_SUF=cmxa
else
  ifeq ($(PROFILE),YES)
    OCAML_COMP=${OCAMLCP} -custom -p a ${CAMLP4} ${OFLAGS} -I out ${OINCLUDES}
  else
    OCAML_COMP=${OCAMLC} -custom ${CAMLP4} ${OFLAGS} -I out ${OINCLUDES}
  endif
  OBJ_SUF=cmo
  LIB_SUF=cma
endif
