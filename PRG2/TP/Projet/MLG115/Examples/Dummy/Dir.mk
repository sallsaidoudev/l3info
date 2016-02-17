DIR:=Examples/Dummy
TARGET:=Dummy
FILES:=main
CFILES:=
-include Prepare.mk
${DIR}/${TARGET}: MLG/mlg.${LIB_SUF} $(addsuffix .$(OBJ_SUF),${FILES}) $(addsuffix .o,${CFILES})
	${OCAML_COMP} ${LFLAGS} -o $@ $^
