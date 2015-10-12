#!/usr/bin/python3
#-*- coding: utf8 -*-

from board import ChessBoard

cb = ChessBoard()

while True:
	print(cb)
	move = input("Les %s jouent : " % ("blancs" if cb.turn=="white" else "noirs"))
	if move == "q":
		break
	elif move == "a":
		cb.log.cancel(cb)
	elif move == "r":
		cb.log.redo(cb)
	elif move.startswith("s"):
		cb.log.save(move.split()[1])
	elif move.startswith("l"):
		cb.log.load(move.split()[1])
	else:
		cb.move(move)
