(* This is free and unencumbered software released into the public domain. *)

open DRY.Core
open Drylang

module Stdlib = DRY__Stdlib
module Format = Stdlib.Format

let warn = Stdlib.Printf.eprintf

let main root (input : SourceFile.t) (output : Options.TargetOptions.t) (options : Options.CommonOptions.t) =
  let output_ext = match output.file.ext with "" -> "dry" | s -> s in
  let output_ext = match output.language with Some s -> s | None -> output_ext in
  let output_ppf = Format.formatter_of_out_channel output.file.channel in
  let input_lexbuf = Lexing.from_channel input.channel in
  while true do
    try
      match Reader.read_expression_from_lexbuf input_lexbuf with
      | None -> exit 0
      | Some expression ->
        begin match Target.by_extension output_ext with
        | None -> assert false
        | Some (module L : Target.Language) ->
          if not options.debug then () else begin
            Format.pp_open_hbox output_ppf ();
            Format.pp_print_char output_ppf ';';
            Node.print output_ppf expression;
            Format.pp_close_box output_ppf ();
            Format.pp_print_newline output_ppf ()
          end;
          Format.pp_open_hbox output_ppf ();
          L.compile_node output_ppf expression;
          Format.pp_close_box output_ppf ();
          Format.pp_print_newline output_ppf ()
        end
    with
    | Syntax.Error (Lexical, message) ->
      warn "lexical error: %s\n%!" message;
      exit 1
    | Syntax.Error (Syntactic, message) ->
      warn "syntax error: %s\n%!" message;
      exit 1
    | Syntax.Error (Semantic, message) ->
      warn "semantic error: %s\n%!" message;
      exit 1
  done

(* Command-line interface *)

open Cmdliner

let cmd =
  let name = "dry-translate" in
  let version = Version.string in
  let doc = "translate DRY code" in
  let exits = Term.default_exits in
  let envs = [] in
  let man = [
    `S Manpage.s_bugs; `P "File bug reports at <$(b,https://github.com/dryproject/drylang)>.";
    `S Manpage.s_see_also; `P "$(b,dry)(1), $(b,dry-compile)(1), $(b,dry-export)(1)" ]
  in
  let input  = Options.source_file 0 "The input file to translate." in
  Term.(const main $ Options.package_root $ input $ Options.target $ Options.common),
  Term.info name ~version ~doc ~exits ~envs ~man

let () = Term.(exit @@ eval cmd)
