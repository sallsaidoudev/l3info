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
{
 open Lexing;;
 type token = Eol | Semi | Begin | End | Word of string | Var of string;;
}

let skip = [' ' '\t']+
let eol  = '\r'?'\n'
let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let sign = letter | digit | '_' | '.' | '/' | '+' | '-'
let word = sign+
let any = [^ '\r' '\n']
let special = [^ '"']+ '"'

rule lex = parse
| skip            {lex lexbuf}
| eol             {Eol}
| eof             {Eol} (* End of string *)
| ';'             {Semi}
| '{'             {Begin}
| '}'             {End}
| '$'             {lex_var lexbuf}
| word            {Word (Lexing.lexeme lexbuf)}
| '#' any+        {lex lexbuf}
| '\"'            {lex_special lexbuf}

and lex_special = parse
| special         {let tmp = Lexing.lexeme lexbuf in
                   Word (String.sub tmp 0 ((String.length tmp) - 1))}

and lex_var = parse
| word            {Var (Lexing.lexeme lexbuf)}
| skip            {Var ""}
| eol             {Var ""}
| eof             {Var ""}

and lex_skip = parse
| skip            {0}

{
}
