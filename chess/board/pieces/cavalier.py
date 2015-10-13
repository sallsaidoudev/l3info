#!/usr/bin/python3
#-*- coding: utf8 -*-

from termcolor import colored

from . import Piece

class Cavalier(Piece):
    
    def __init__(self, color, x, y, board):
        Piece.__init__(self, color, x, y)
        self.board = board

    def __repr__(self):
        return "C"
    def __str__(self):
        return " \u2658" if self.white else " \u265E"

    @property
    def moves(self):
        moves = []
        def valid_step(step):
            return step[0] in range(8) and step[1] in range(8)
        for gp in [2, -2]:
            for pp in [1, -1]:
                step = (self.pos[0] + gp, self.pos[1] + pp)
                if valid_step(step) and (not self.board[step] or self.board[step].color != self.color):
                    moves.append(step)
                step = (self.pos[0] + pp, self.pos[1] + gp)
                if valid_step(step) and (not self.board[step] or self.board[step].color != self.color):
                    moves.append(step)
        return moves
