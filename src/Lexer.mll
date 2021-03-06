(* This is free and unencumbered software released into the public domain. *)

{
open DRY.Core

let lexical_error = Syntax.lexical_error

let format_lexbuf_pos lexbuf =
  let pos = (Lexing.lexeme_start_p lexbuf) in
  let fname = pos.pos_fname in
  let lnum = pos.pos_lnum in
  let cnum = ((pos.pos_cnum - pos.pos_bol) + 1) in
  match fname with
  | "" -> Printf.sprintf "%d:%d" lnum cnum
  | _  -> Printf.sprintf "%s:%d:%d" fname lnum cnum

let unexpected_eof lexbuf =
  lexical_error (Printf.sprintf "unexpected end of input at %s" (format_lexbuf_pos lexbuf))

let unexpected_lf lexbuf =
  lexical_error (Printf.sprintf "unexpected line break at %s" (format_lexbuf_pos lexbuf))

let unexpected_char lexbuf =
  lexical_error (Printf.sprintf "unexpected character at %s" (format_lexbuf_pos lexbuf))
}

let digit       = ['0'-'9']
let letter      = ['A'-'Z' 'a'-'z']

let hexdigit    = ['0'-'9' 'A'-'F' 'a'-'f']
let hexdigit2   = hexdigit hexdigit
let hexdigit4   = hexdigit hexdigit hexdigit hexdigit
let hexdigit8   = hexdigit hexdigit hexdigit hexdigit hexdigit hexdigit hexdigit hexdigit
let hexdigit12  = hexdigit8 hexdigit4

let complex     = '-'? digit+ ['-' '+'] digit+ 'i'

let rational    = '-'? digit+ '/' digit+
let integer     = '-'? digit+

let fraction    = '.' digit*
let exponent    = ['e' 'E'] ['-' '+']? digit+
let float       = '-'? digit* fraction? exponent?

let percentage  = '-'? digit+ fraction? '%'

let binary      = '0' 'b' ['0' '1']+
let octal       = '0' 'o' ['0'-'7']+
let hexadecimal = '0' 'x' hexdigit+

let xchar       = '\\' 'x' hexdigit2
let uchar_short = '\\' 'u' hexdigit4
let uchar_long  = '\\' 'U' hexdigit8
let char        = xchar | uchar_short | uchar_long

let uri         = '<' [^'>']* '>'
let uuid        = hexdigit8 '-' hexdigit4 '-' hexdigit4 '-' hexdigit4 '-' hexdigit12

let special_initial     = '!' | '$' | '%' | '&' | '*' | '/' | ':' | '<' | '=' | '>' | '?' | '~' | '_' | '^'
let special_subsequent  = '.' | '+' | '-'
let peculiar_identifier = '+' | '-'

let initial     = letter | special_initial
let subsequent  = initial | digit | special_subsequent
let identifier  = initial subsequent* | peculiar_identifier

let whitespace  = [' ' '\t']+
let newline     = '\n'

rule lex = parse
  | whitespace       { lex lexbuf }
  | newline          { Lexing.new_line lexbuf; lex lexbuf }
  | ';'              { lex_comment lexbuf; lex lexbuf }
  | '('              { Token.LPAREN }
  | ')'              { Token.RPAREN }
  | '\''             { Token.QUOTE }
  | '`'              { Token.BACKQUOTE }
  | "\n\"\"\""       { Lexing.new_line lexbuf; lex_doc_begin (Buffer.create 16) lexbuf }
  | '"'              { lex_string (Buffer.create 16) lexbuf }
  | char as s        { Token.CHAR (String.sub s 2 ((String.length s) - 2)) }
  | binary as s      { Token.WORD_BIN (String.sub s 2 ((String.length s) - 2)) }
  | octal as s       { Token.WORD_OCT (String.sub s 2 ((String.length s) - 2)) }
  | hexadecimal as s { Token.WORD_HEX (String.sub s 2 ((String.length s) - 2)) }
  | percentage as s  { Token.PERCENT (String.sub s 0 ((String.length s) - 1)) }
  | complex as s     { Token.COMPLEX s }
  | rational as s    { Token.RATIONAL s }
  | integer as s     { Token.INTEGER s }
  | float as s       { Token.FLOAT s }
  | uri as s         { Token.URI (String.sub s 1 ((String.length s) - 2)) }
  | uuid as s        { Token.UUID s }
  | identifier as s  { Token.SYMBOL s }
  | _                { unexpected_char lexbuf }
  | eof              { Token.EOF }

and lex_comment = parse
  | '\n'             { Lexing.new_line lexbuf }
  | _                { lex_comment lexbuf }
  | eof              { () }

and lex_string buf = parse
  | newline          { unexpected_lf lexbuf }
  | '"'              { Token.STRING (Buffer.contents buf) }
  | [^ '"']          { Buffer.add_string buf (Lexing.lexeme lexbuf); lex_string buf lexbuf }
  | eof              { unexpected_eof lexbuf }

and lex_doc_begin buf = parse
  | '"'*             { lex_doc_begin buf lexbuf }
  | "\n\"\"\""       { Lexing.new_line lexbuf; lex_doc_end buf lexbuf } (* empty docstring *)
  | newline          { Lexing.new_line lexbuf; lex_doc_string buf lexbuf }
  | _                { unexpected_char lexbuf }
  | eof              { unexpected_eof lexbuf }

and lex_doc_string buf = parse
  | "\n\"\"\""       { Lexing.new_line lexbuf; lex_doc_end buf lexbuf }
  | newline          { Buffer.add_string buf (Lexing.lexeme lexbuf); Lexing.new_line lexbuf; lex_doc_string buf lexbuf }
  | _                { Buffer.add_string buf (Lexing.lexeme lexbuf); lex_doc_string buf lexbuf }
  | eof              { unexpected_eof lexbuf }

and lex_doc_end buf = parse
  | '"'*             { lex_doc_end buf lexbuf }
  | newline          { Lexing.new_line lexbuf; Token.STRING (Buffer.contents buf) }
  | _                { unexpected_char lexbuf }
  | eof              { unexpected_eof lexbuf }

{
let lex_from_string input =
  Lexing.from_string input |> lex

let tokenize input =
  let lexbuf_to_list lexbuf =
    let rec consume input output =
      match lex input with
      | Token.EOF -> output
      | token -> consume input (token :: output)
    in List.rev (consume lexbuf [])
  in
  Lexing.from_string input |> lexbuf_to_list
}
