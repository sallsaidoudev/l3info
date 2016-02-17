#!/usr/bin/python3
# -*- coding: utf-8 -*-

import re

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

####################

class Container:
    pass

lex_attrs = {} # lex: attrs_dict
def lex_attr(token):
    def decorated(attr):
        if not token in lex_attrs:
            lex_attrs[token] = {}
        lex_attrs[token][attr.__name__] = attr
        return attr
    return decorated

register = {}
def register_vars(**kwargs):
    register = kwargs

actions = {} # edge: action
def action(*edges):
    def decorated(act):
        actions.update({e: act for e in edges})
        return act

class State:
    def __init__(self, no):
        self.no = no
        self.succ = {}
        self.final = False
    def __setitem__(self, token, s):
        self.succ[token] = s
    def __getitem__(self, token):
        return self.succ[token]
class Automata:
    def __init__(self):
        self.states = [State(i) for i, t in enumerate(transitions)]
        self.init = self.states[0]
        self.states[-1].final = True
        for state, t_state in zip(self.states, transitions):
            for i, succ in enumerate(t_state):
                if succ != -1:
                    state[alphabet[i]] = self.states[succ]
    def read(self, string):
        tokens = string.split()
        s = self.init
        while tokens:
            t = tokens.pop(0)
            matching = ''
            match = None
            for reg in alphabet:
                match = re.match(reg, t)
                if match:
                    matching = reg
                    break
            if not match:
                print("erreur: "+t)
                return False
            lex = Container()
            lex.__attrs__ = {a: v() for a, v in lex_attrs[matching]}
            var = Container()
            var.__attrs__ = register
            if (s.no, matching) in actions:
                actions[(s.no, matching)](var, lex)
                register = var.__attrs__
            try:
                s = s[t]
            except KeyError:
                return False
        return s.final

def main():
    auto = Automata()
    go = True
    while (go):
        word = input("> ")
        if word == "/q":
            go = False
        else:
            print("Mot" + ("" if auto.read(word) else " non") + " reconnu")

if __name__ == "__main__":
    main()
    exit(0)
