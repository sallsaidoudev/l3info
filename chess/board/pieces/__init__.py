#!/usr/bin/python3
#-*- coding: utf8 -*-

from termcolor import colored

class Piece:
	
	def __init__(self, color, x, y):
		self.color = color
		self.pos = [x, y]
		self.board = None

	def __repr__(self):
		raise NotImplementedError
	def __str__(self):
		raise NotImplementedError

	@property
	def x(self):
		return self.pos[0]
	@x.setter
	def x(self, value):
		self.pos[0] = value

	@property
	def y(self):
		return self.pos[1]
	@x.setter
	def y(self, value):
		self.pos[1] = value

	@property
	def white(self):
		return self.color == "white"

	@property
	def moves(self): # returns tuple list
		raise NotImplementedError

	def colorize(self, string):
		on_white = (self.pos[0]+self.pos[1]) % 2 == 1
		return colored(string, "grey" if on_white else "white",
				"on_white" if on_white else "on_grey")
