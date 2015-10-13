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
		try:
			cb.log.cancel(cb)
		except KeyError:
			print("Impossible d'annuler")
	elif move == "r":
		try:
			cb.log.redo(cb)
		except KeyError:
			print("Impossible de refaire")
	elif move.startswith("s"):
		try:
			cb.log.save(move.split()[1])
		except Exception as e:
			print("Erreur :", e)
	elif move.startswith("l"):
		try:
			cb.log.load(move.split()[1])
		except FileNotFoundError:
			print("Partie introuvable")
		except Exception as e:
			print("Erreur :", e)
	elif move.startswith("h"):
		try:
			cb.highlight = cb[move.split()[1]]
		except KeyError:
			print("Pas de pièce à ces coordonnées")
	else:
		if not cb.move(move):
			print("coup invalide")
