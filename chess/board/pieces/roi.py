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
        return " \u2654" if self.white else " \u265A"

    @property
    def moves(self):
        moves = []
        def valid_step(step):
            return step[0] in range(8) and step[1] in range(8)
        for si in [-1, 0, 1]:
            for sj in [-1, 0, 1]:
                step = [self.pos[0]+si, self.pos[1]+sj]
                if valid_step(step) and (not self.board[step] or self.board[step].color != self.color):
                    moves.append(tuple(step))
        return moves
