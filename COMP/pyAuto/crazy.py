#!/usr/bin/python3
# -*- coding: utf-8 -*-

import re

class Container:
    pass

lex_attrs = {} # lex: attrs_dic
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
    return decorated

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
    def __init__(self, alphabet, transitions):
        self.alphabet = alphabet
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
            for reg in self.alphabet:
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

def run(alph, trns):
    auto = Automata(alph, trns)
    go = True
    while (go):
        word = input("> ")
        if word == "/q":
            go = False
        else:
            print("Mot" + ("" if auto.read(word) else " non") + " reconnu")
