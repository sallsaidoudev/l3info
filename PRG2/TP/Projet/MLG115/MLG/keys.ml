(* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA *)

open Sdlkey;;
exception Unknown;;

let sdlkey_of_string = function
  | "a" -> KEY_a
  | "b" -> KEY_b
  | "c" -> KEY_c
  | "d" -> KEY_d
  | "e" -> KEY_e
  | "f" -> KEY_f
  | "g" -> KEY_g
  | "h" -> KEY_h
  | "i" -> KEY_i
  | "j" -> KEY_j
  | "k" -> KEY_k
  | "l" -> KEY_l
  | "m" -> KEY_m
  | "n" -> KEY_n
  | "o" -> KEY_o
  | "p" -> KEY_p
  | "q" -> KEY_q
  | "r" -> KEY_r
  | "s" -> KEY_s
  | "t" -> KEY_t
  | "u" -> KEY_u
  | "v" -> KEY_v
  | "w" -> KEY_w
  | "x" -> KEY_x
  | "y" -> KEY_y
  | "z" -> KEY_z
	   
  | "0" -> KEY_0
  | "1" -> KEY_1
  | "2" -> KEY_2
  | "3" -> KEY_3
  | "4" -> KEY_4
  | "5" -> KEY_5
  | "6" -> KEY_6
  | "7" -> KEY_7
  | "8" -> KEY_8
  | "9" -> KEY_9

  | "up" -> KEY_UP
  | "down" -> KEY_DOWN
  | "left" -> KEY_LEFT
  | "right" -> KEY_RIGHT
  | "insert" -> KEY_INSERT
  | "ins" -> KEY_INSERT
  | "home" -> KEY_HOME
  | "delete" -> KEY_DELETE
  | "del" -> KEY_DELETE
  | "end" -> KEY_END
  | "pageup" -> KEY_PAGEUP
  | "pgup" -> KEY_PAGEUP
  | "pagedown" -> KEY_PAGEDOWN
  | "pgdn" -> KEY_PAGEDOWN
  | "pgdown" -> KEY_PAGEDOWN
		
  | "f1" -> KEY_F1
  | "f2" -> KEY_F2
  | "f3" -> KEY_F3
  | "f4" -> KEY_F4
  | "f5" -> KEY_F5
  | "f6" -> KEY_F6
  | "f7" -> KEY_F7
  | "f8" -> KEY_F8
  | "f9" -> KEY_F9;
  | "f10" -> KEY_F10
  | "f11" -> KEY_F11
  | "f12" -> KEY_F12
	
  | "space" -> KEY_SPACE
  | "enter" -> KEY_RETURN
  | "backspace" -> KEY_BACKSPACE
  | "bksp" -> KEY_BACKSPACE
  | "bkspace" -> KEY_BACKSPACE
  | "tab" -> KEY_TAB
  | "escape" -> KEY_ESCAPE
  | "esc" -> KEY_ESCAPE
  | "minus" -> KEY_MINUS
  | "plus" -> KEY_EQUALS
  | "equal" -> KEY_EQUALS
  | "tilde" -> KEY_BACKQUOTE
  | "backquote" -> KEY_BACKQUOTE
  | "slash" -> KEY_SLASH
  | "backslash" -> KEY_BACKSLASH
  | "lbracket" -> KEY_LEFTBRACKET
  | "leftbracket" -> KEY_LEFTBRACKET
  | "rbracket" -> KEY_RIGHTBRACKET
  | "rightbracket" -> KEY_RIGHTBRACKET
  | "semicolon" -> KEY_SEMICOLON
  | "quote" -> KEY_QUOTE
  | "period" -> KEY_PERIOD
  | "comma" -> KEY_COMMA
	
  | "ralt" -> KEY_RALT
  | "lalt" -> KEY_LALT
  | "rctrl" -> KEY_RCTRL
  | "lctrl" -> KEY_LCTRL
  | "rshift" -> KEY_RSHIFT
  | "lshift" -> KEY_LSHIFT
  | "capslock" -> KEY_CAPSLOCK
	
  | "printscreen" -> KEY_PRINT
  | "sysrq" -> KEY_PRINT
  | "scrolllock" -> KEY_SCROLLOCK
  | "pause" -> KEY_BREAK
  | "break" -> KEY_BREAK

	
  | "pad0" -> KEY_KP0
  | "pad1" -> KEY_KP1
  | "pad2" -> KEY_KP2
  | "pad3" -> KEY_KP3
  | "pad4" -> KEY_KP4
  | "pad5" -> KEY_KP5
  | "pad6" -> KEY_KP6
  | "pad7" -> KEY_KP7
  | "pad8" -> KEY_KP8
  | "pad9" -> KEY_KP9
  | "numlock" -> KEY_NUMLOCK
  | "padslash" -> KEY_KP_DIVIDE
  | "grayslash" -> KEY_KP_DIVIDE
  | "padasterisk" -> KEY_KP_MULTIPLY
  | "grayasterisk" -> KEY_KP_MULTIPLY
  | "padminus" -> KEY_KP_MINUS
  | "grayminus" -> KEY_KP_MINUS
  | "padplus" -> KEY_KP_PLUS
  | "grayplus" -> KEY_KP_PLUS
  | "padenter" -> KEY_KP_ENTER
  | "grayenter" -> KEY_KP_ENTER
  | _ -> raise Unknown
;;

let key_of_string s =
  if s = "" then raise Unknown else
  match s.[0] with
  | '+' -> sdlkey_of_string (String.sub s 1 (String.length s - 1)), true
  | '-' -> sdlkey_of_string (String.sub s 1 (String.length s - 1)), false
  | _ -> sdlkey_of_string s, true
;;

let shifted_char = function
  | 'a' -> 'A'
  | 'b' -> 'B'
  | 'c' -> 'C'
  | 'd' -> 'D'
  | 'e' -> 'E'
  | 'f' -> 'F'
  | 'g' -> 'G'
  | 'h' -> 'H'
  | 'i' -> 'I'
  | 'j' -> 'J'
  | 'k' -> 'K'
  | 'l' -> 'L'
  | 'm' -> 'M'
  | 'n' -> 'N'
  | 'o' -> 'O'
  | 'p' -> 'P'
  | 'q' -> 'Q'
  | 'r' -> 'R'
  | 's' -> 'S'
  | 't' -> 'T'
  | 'u' -> 'U'
  | 'v' -> 'V'
  | 'w' -> 'W'
  | 'x' -> 'X'
  | 'y' -> 'Y'
  | 'z' -> 'Z'

  | '0' -> ')'
  | '1' -> '!'
  | '2' -> '@'
  | '3' -> '#'
  | '4' -> '$'
  | '5' -> '%'
  | '6' -> '^'
  | '7' -> '&'
  | '8' -> '*'
  | '9' -> '('

  | ',' -> '<'
  | '.' -> '>'
  | '/' -> '?'
  | ';' -> ':'
  | '[' -> '{'
  | ']' -> '}'
  | '\\' -> '|'
  | '-' -> '_'
  | '=' -> '+'
  | '`' -> '~'
  | '\'' -> '"'
  | x -> x
;;
