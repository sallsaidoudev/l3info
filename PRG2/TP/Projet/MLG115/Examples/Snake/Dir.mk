DIR:=Examples/Snake
TARGET:=Snake
FILES:=main
CFILES:=
-include Prepare.mk
${DIR}/${TARGET}: MLG/mlg.${LIB_SUF} $(addsuffix .$(OBJ_SUF),${FILES}) $(addsuffix .o,${CFILES})
	${OCAML_COMP} ${LFLAGS} -o $@ $^
