(* This is free and unencumbered software released into the public domain. *)

type t =
  | EOF
  | FLOAT of float
  | INTEGER of int
  | SYMBOL of string
