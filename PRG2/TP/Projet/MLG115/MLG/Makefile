include ../Common.mk
CUR_DIR=`pwd`

all:
	make -C .. MLG/mlg.${LIB_SUF}
clean:
	rm -rf ../out/MLG mlg.${LIB_SUF} mlg.a

.PHONY: doc

doc:
	ocamldoc -html -d doc ${OINCLUDES} ${OINCLUDES_GEN} -I ../out/MLG *.mli *.ml
#console.mli font.mli helpers.mli input_edit.mli input.mli keys.mli log.mli net.mli parser.mli protocol.mli serialize.mli socket.mli sprite.mli tcp.mli udp.mli vector.mli video.mli vector.ml log.ml parser.ml video.ml sprite.ml serialize.ml keys.ml input.ml input_edit.ml font.ml console.ml tcp.ml udp.ml protocol.ml socket.ml net.ml helpers.ml
