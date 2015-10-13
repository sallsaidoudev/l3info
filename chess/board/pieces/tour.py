#!/usr/bin/python3
#-*- coding: utf8 -*-

from termcolor import colored

from . import Piece

class Tour(Piece):
	
	def __init__(self, color, x, y, board):
		Piece.__init__(self, color, x, y)
		self.board = board

	def __repr__(self):
		return "T"
	def __str__(self):
		return " \u2656" if self.white else " \u265C"

	@property
	def moves(self):
		moves = []
		for s in [-1, 1]:
			i = self.pos[0] + s
			while i in range(8) and not self.board[i, self.pos[1]]:
				moves.append((i, self.pos[1]))
				i += s
			if i in range(8) and self.board[i, self.pos[1]].color != self.color:
				moves.append((i, self.pos[1]))
			j = self.pos[1] + s
			while j in range(8) and not self.board[self.pos[0], j]:
				moves.append((self.pos[0], j))
				j += s
			if j in range(8) and self.board[self.pos[0], j].color != self.color:
				moves.append((self.pos[0], j))
		return moves
