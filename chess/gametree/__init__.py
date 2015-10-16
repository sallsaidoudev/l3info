#!/usr/bin/python3
#-*- coding: utf8 -*-

class GameTree:

	def __init__(self):
		self.log = {}
		self.cursor = -1

	def move(self, coup, taken, ori, dest):
		self.cursor += 1
		self.log[self.cursor] = (coup, taken, ori, dest)

	def cancel(self, board, noredo=False):
		_, taken, ori, dest = self.log[self.cursor]
		board[ori] = board[dest]
		board[dest] = taken
		if noredo:
			del self.log[self.cursor]
		self.cursor -= 1

	def redo(self, board):
		self.cursor += 1
		print(self.log[self.cursor])
		board.move(self.log[self.cursor][0], log=False)

	def save(self, file_name):
		with open(file_name, "w") as f:
			for i in range(self.cursor + 1):
				if i%2 == 0:
					f.write("%d. %s" % (i/2+1, self.log[i][0]))
				else:
					f.write(" %s\n" % self.log[i][0])

	def load(self, file_name):
		self.log = {}
		self.cursor = -1
		with open(file_name, "r") as f:
			for i, coup in enumerate(f):
				self.log[2*i] = (coup.split()[1].strip(), None, None, None)
				try:
					self.log[2*i+1] = (coup.split()[2].strip(), None, None, None)
				except IndexError:
					pass
		print(self.log)
