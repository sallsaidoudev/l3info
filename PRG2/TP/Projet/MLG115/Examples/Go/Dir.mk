DIR:=Examples/Go
TARGET:=Go
FILES:=init board go main
CFILES:=
-include Prepare.mk
${DIR}/${TARGET}: MLG/mlg.${LIB_SUF} $(addsuffix .$(OBJ_SUF),${FILES}) $(addsuffix .o,${CFILES})
	${OCAML_COMP} ${LFLAGS} -o $@ $^
