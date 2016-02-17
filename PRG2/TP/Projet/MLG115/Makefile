include Common.mk

TARGETS:=
TOP=$(shell pwd)
TOP_SED:=$(subst /,[/],${TOP})
#ifndef CUR_DIR
CUR_DIR=$(shell pwd)
#endif

all:	all-redir

include $(patsubst %,%/Dir.mk,${MODULES})

distclean: clean
	rm -rf out doc autom4te.cache config.* aclocal.m4 Common.mk libtool ${DIST_DELETE}
	find . -name "*~" -o -name ".libs" -o -name "*.o" -o -name "*.cm*" \
	  -o -name "ocamlprof.dump" -o -name "gmon.out" |xargs rm -rf

INCLUDES:=$(addprefix -I ,$(MODULES))
OINCLUDES:=$(addprefix -I out/,$(MODULES))

OCAML_DEP_FLAGS:= ${CAMLP4} ${INCLUDES}
ifeq ($(BYTECODE),NO)
	OCAML_DEP_FLAGS+=-native
endif

out/%.dm: %.ml
	@mkdir -p `dirname $@`
	@echo Calculating dependencies of: $<
	@$(OCAMLDEP) $(OCAML_DEP_FLAGS) ${TOP}/$< | sed -e "s/${TOP_SED}[/]//g;s/^\([^ ]\)/out\/\\1/;s/[ ^]*$$//;s/\([^ ]\) /\\1 out\//g;s/out[/][\\]/\\\\/g;s/^    /    out\//" > $@

out/%.di: %.mli
	@mkdir -p `dirname $@`
	@echo Calculating dependencies of: $<
	@$(OCAMLDEP) $(OCAML_DEP_FLAGS) ${TOP}/$< | sed -e "s/${TOP_SED}[/]//g;s/^\([^ ]\)/out\/\\1/;s/[ ^]*$$//;s/\([^ ]\) /\\1 out\//g;s/out[/][\\]/\\\\/g;s/^    /    out\//" > $@

all-redir: ${TARGETS}

clean:
	rm -rf out ${TARGETS}

out/%.cmi: %.mli
	@echo Compiling: $<
	@$(OCAML_COMP) -c ${TOP}/$<
	@mkdir -p `dirname $@`
	@mv -f $(subst .mli,.cmi,$<) `dirname $@`

out/%.$(OBJ_SUF): %.ml
	@echo Compiling: $<
	@$(if $(subst ..,,$(shell ls -d .. $(subst .ml,.mli,$<) 2> /dev/null)), cp $(subst .$(OBJ_SUF),.cmi,$@) $(subst .ml,.cmi,$<), true)
	@$(OCAML_COMP) -c $(TOP)/$<
	@$(if $(subst ..,,$(shell ls -d .. $(subst .ml,.mli,$<) 2> /dev/null)), rm -f $(subst .ml,.cmi,$<), true)
	@mkdir -p `dirname $@`
ifeq ($(BYTECODE),NO)
	@mv -f $(subst .ml,.cm[iox],$<) $(subst .ml,.o,$<) `dirname $@`
else
	@mv -f $(subst .ml,.cm[iox],$<) `dirname $@`
endif

%.ml: %.mll
	$(OCAMLLEX) $<

%.ml: %.mly
	$(OCAMLYACC) $<
	@rm -f $(subst .mly,.mli,$<)
#	$(OCAML_COMP) -c $(subst .mly,.mli,$<)
#	@mv -f $(subst .mly,.cmi,$<) .libs

%.a: %.cma
	@true

out/%.o: %.c
	@echo Compiling: $<
	@$(CC) $(CFLAGS) -c $< -o $@
