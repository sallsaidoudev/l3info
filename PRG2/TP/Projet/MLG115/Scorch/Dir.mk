DIR:=Scorch
TARGET:=Scorch
FILES:=color widget utils menu options mouse landgen exgen explosion score weapon missle block tank colisions flow control shop loop main
CFILES:=
DIST_DELETE+=$(DIR)/gfx/*.exp
-include Prepare.mk
${DIR}/${TARGET}: MLG/mlg.${LIB_SUF} $(addsuffix .$(OBJ_SUF),${FILES}) $(addsuffix .o,${CFILES})
	${OCAML_COMP} ${LFLAGS} -o $@ $^
