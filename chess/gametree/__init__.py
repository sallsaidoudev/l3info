#!/usr/bin/python3
#-*- coding: utf8 -*-

class GameTree:

	def __init__(self):
		self.log = {}
		self.cursor = -1

	def move(self, coup, taken):
		self.cursor += 1
		self.log[self.cursor] = (coup, taken)

	def cancel(self, board):
		coup, taken = self.log[self.cursor]
		board.move(coup.strip("TCFDR")[-2:] + coup.strip("TCFDR")[:2], log=False)
		board[coup.strip("TCFDR")[-2:]] = taken
		self.cursor -= 1

	def redo(self, board):
		self.cursor += 1
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
				self.log[2*i] = (coup.split()[1].strip(), None)
				try:
					self.log[2*i+1] = (coup.split()[2].strip(), None)
				except IndexError:
					pass
