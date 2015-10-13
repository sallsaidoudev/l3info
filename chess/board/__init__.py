#!/usr/bin/python3
#-*- coding: utf8 -*-

import termcolor
from termcolor import colored

from gametree import GameTree
from .pieces import Piece
from .pieces.pion import Pion
from .pieces.tour import Tour
from .pieces.cavalier import Cavalier
from .pieces.fou import Fou
from .pieces.dame import Dame
from .pieces.roi import Roi

class ChessBoard:

	@staticmethod
	def to_coords(x, y):
		return ("abcdefgh".index(x), int(y) - 1)

	@staticmethod
	def to_coup(ori, dest):
		abs = "abcdefgh"
		return abs[ori[0]] + str(ori[1] + 1) + "-" + abs[dest[0]] + str(dest[1] + 1)

	def __init__(self):
		self.white = Piece("white", 0, 1)
		self.black = Piece("black", 0, 0)
		self.turn = "white"
		self.board = []
		for i in range(8):
			self.board.append([None] * 8)
		order = {"a":Tour, "b":Cavalier, "c":Fou, "d":Dame,
				"e":Roi, "f":Fou, "g":Cavalier, "h":Tour}
		for i, c in enumerate("abcdefgh"):
			self[c+"1"] = order[c]("white", i, 0, self)
			self[c+"2"] = Pion("white", i, 1, self)
			self[c+"7"] = Pion("black", i, 6, self)
			self[c+"8"] = order[c]("black", i, 7, self)
		self.wking = self["e1"]
		self.bking = self["e8"]
		self.log = GameTree()
		self.highlight = self["a1"]

	def __str__(self):
		ret = ["   a b c d e f g h"]
		ret += [str(8-k)+" " for k in range(8)]
		for i in range(8):
			for j in range(8):
				ret[8 - j] += (self.black if (i+j)%2==0 else self.white).colorize("  " if not self[i, j] else str(self[i, j]),
						bg="on_yellow" if (i, j) in self.highlight.moves else "")
		for k in range(8):
			ret[1+k] += " "+str(8-k)
		ret += ["   a b c d e f g h"]
		return "\n".join(ret)

	def __getitem__(self, key):
		try:
			x, y = key
			if type(x) != int:
				x, y = self.to_coords(x, y)
			assert x in range(8) and y in range(8)
			ret = self.board[x][y]
		except (ValueError, IndexError, AssertionError):
			raise KeyError("coordonnées invalides : %s" % str(key))
		else:
			return ret

	def __setitem__(self, key, value):
		try:
			x, y = key
			if type(x) != int:
				x, y = self.to_coords(x, y)
			assert x in range(8) and y in range(8)
			self.board[x][y] = value
		except (ValueError, IndexError, AssertionError):
			raise KeyError("coordonnées invalides : %s" % str(key))

	def check(self, coup): # returns True if current player is check after coup
		return False

	def move(self, coup, log=True):
		dest = coup.rstrip("TCFDR")[-2:]
		ori = coup.lstrip("TCFDR")[0:2]
		if log:
			self.log.move(coup, self[dest])
		self[dest] = self[ori]
		self[dest].pos = self.to_coords(*dest)
		self[ori] = None
		self.turn = "white" if self.turn=="black" else "black"
