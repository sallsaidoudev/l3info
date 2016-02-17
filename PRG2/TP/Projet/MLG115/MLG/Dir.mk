DIR:=MLG
FILES=vector log lexer parser video sprite serialize keys \
	input input_edit font console tcp udp protocol \
	socket net helpers
CFILES=sprite_col
TARGET:=mlg.${LIB_SUF} mlg.a
-include Prepare.mk
${DIR}/${TARGET}: $(addsuffix .$(OBJ_SUF),${FILES}) $(addsuffix .o,${CFILES})
	${OCAML_COMP} -a -o $@ $^
