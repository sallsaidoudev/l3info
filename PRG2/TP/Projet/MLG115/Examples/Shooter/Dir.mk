DIR:=Examples/Shooter
TARGET:=Shooter
FILES:=init nick ammo players enemy main
CFILES:=
-include Prepare.mk
${DIR}/${TARGET}: MLG/mlg.${LIB_SUF} $(addsuffix .$(OBJ_SUF),${FILES}) $(addsuffix .o,${CFILES})
	${OCAML_COMP} ${LFLAGS} -o $@ $^
