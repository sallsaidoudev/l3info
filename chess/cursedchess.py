#!/usr/bin/python3
#-*- coding: utf8 -*-

import curses
from curses import wrapper

from board import ChessBoard

def disp_board(board):
    pad = curses.newpad(10, 20)
    pad.addstr(0, 3, "a b c d e f g h")
    pad.addstr(9, 3, "a b c d e f g h")

        # ret = ["   a b c d e f g h"]
        # ret += [str(8-k)+" " for k in range(8)]
        # for i in range(8):
        #     for j in range(8):
        #         if not self[i, j]:
        #             ret[8 - j] += (self.black if (i+j)%2==0 else self.white).colorize("  ")
        #         else:
        #             ret[8 - j] += str(self[i, j])
        # for k in range(8):
        #     ret[1+k] += " "+str(8-k)
        # ret += ["   a b c d e f g h"]
        # return "\n".join(ret)
    return pad


def main(stdscr):
    c = 0
    cb = ChessBoard()
    while True:
        if c == 113: # Q
            break
        #stdscr.clear()
        #stdscr.addstr(0, 0, str(c))

        board = disp_board(cb)
        board.refresh(0,0, 0,0, 10,10)

        c = board.getch()

if __name__ == "__main__":
    wrapper(main)
    exit(0)
