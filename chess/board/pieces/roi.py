#!/usr/bin/python3
#-*- coding: utf8 -*-

from termcolor import colored

from . import Piece

class Roi(Piece):
	
	def __init__(self, color, x, y, board):
		Piece.__init__(self, color, x, y)
		self.board = board

	def __repr__(self):
		return "R"
	def __str__(self):
		return self.colorize(" \u2654" if self.white else " \u265A")
