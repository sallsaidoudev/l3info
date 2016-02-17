#!/usr/bin/python3
# -*- coding: utf-8 -*-

import re
from crazy import *

alphabet = ['\d+', '+', '*', ';', '/']
@lex_attr('\d+')
def numval(s):
    return int(s)

transitions = [
    [1, -1],
    [-1, 0]
]

register_vars(cur=0, a=0)
@action((0, '\d+'))
def init(var, lex):
    var.cur += lex.numval

run(alphabet, transitions)
