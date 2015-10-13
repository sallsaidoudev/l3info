#!/usr/bin/python3
#-*- coding: utf8 -*-

from termcolor import colored

from . import Piece

class Pion(Piece):
	
	def __init__(self, color, x, y, board):
		Piece.__init__(self, color, x, y)
		self.board = board

	def __repr__(self):
		return ""
	def __str__(self):
		return " \u2659" if self.white else " \u265F"

	@property
	def moves(self):
		moves = []
		# devant
		front = [self.pos[0], self.pos[1] + (1 if self.white else -1)]
		if 0 <= front[1] and front[1] <= 8:
			if not self.board[front]:
				moves.append(tuple(front))
			# départ
			start = [self.pos[0], self.pos[1] + (2 if self.white else -2)]
			if self.pos[1] in [1, 6] and not self.board[start]:
				moves.append(tuple(start))
			# prises
			for ofs in [-1, 1]:
				if 0 <= front[0]+ofs and front[0]+ofs <= 8 and self.board[front[0]+ofs, front[1]]:
					moves.append((front[0]+ofs, front[1]))
		moves = [m for m in moves if not self.board.check(self.board.to_coup(self.pos, m))]
		return moves
