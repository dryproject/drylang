(* This is free and unencumbered software released into the public domain. *)

open DRY.Core

module PHP    = DRY.Code.PHP
module Target = (val (Drylang.Target.get "php") : Drylang.Target.Language)

let compile code =
  let buffer = Buffer.create 16 in
  let ppf = Format.formatter_of_buffer buffer in
  Target.compile_node ppf code;
  Format.pp_print_flush ppf ();
  Buffer.contents buffer

let dry input =
  match Drylang.Parser.parse_from_string input with
  | None -> assert false
  | Some syntax -> Drylang.Semantic.analyze syntax

let () = assert (compile @@ dry "true" = "true")

let () = assert (compile @@ dry "false" = "false")

let () = assert (compile @@ dry "1.23" = "1.23")

let () = assert (compile @@ dry "42" = "42")
