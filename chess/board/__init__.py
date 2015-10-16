#!/usr/bin/python3
#-*- coding: utf8 -*-

import re
import termcolor

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
        #moves = [m for m in self.highlight.moves if not self.check(self.to_coup(self.highlight.pos, m))]
        ret = ["   a b c d e f g h"]
        ret += [str(8-k)+" " for k in range(8)]
        for i in range(8):
            for j in range(8):
                ret[8 - j] += (self.black if (i+j)%2==0 else self.white).colorize("  " if not self[i, j] else str(self[i, j]))
                        #bg="on_yellow" if (i, j) in moves else "")
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
        else:
            self.board[x][y] = value

    def check(self, coup): # returns True if current player is check after coup
        self.move(coup)
        is_check = False
        king_pos = tuple(self.wking.pos if self.turn=="black" else self.bking.pos)
        for i in range(8):
            for j in range(8):
                if self[i, j] and self[i, j].color == self.turn and king_pos in self[i, j].moves:
                    is_check = True
        self.log.cancel(self, noredo=True)
        return is_check

    def move(self, coup, log=True):
        if coup in ("O-O", "O-O-O"):
            self.rook(coup)
        coup_re = re.match(r"^([TCFDR]?)([a-h1-8]?)x?([a-h][1-8])([TCFDR]?)[#+]?$", coup)
        if not coup_re:
            return False
        playing = coup_re.group(1) # playing = repr(piece)
        doubt = coup_re.group(2)
        dest = coup_re.group(3)
        prom = coup_re.group(4)
        can_move = []
        for col in self.board:
            for p in col:
                if p and playing==repr(p) and p.color==self.turn and self.to_coords(*dest) in p.moves:
                    can_move.append(p)
        if not can_move or (len(can_move) > 1 and not doubt):
            return False
        if len(can_move) > 1:
            i = int(doubt) - 1 if doubt.isdigit() else "abcdefgh".index(doubt)
            can_move = [p for p in can_move
                    if (doubt.isdigit() and i==p.pos[1]) or (doubt in "abcdefgh" and i==p.pos[0])]
        if len(can_move) != 1:
            return False
        piece = can_move[0]
        print(piece, piece.pos, dest)
        if log:
            self.log.move(coup, self[dest], piece.pos, dest)
        self[dest] = piece
        self[piece.pos] = None
        piece.pos = self.to_coords(*dest)
        self.turn = "white" if self.turn=="black" else "black"
        return True
