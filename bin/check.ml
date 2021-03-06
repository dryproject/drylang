(* This is free and unencumbered software released into the public domain. *)

open DRY.Core
open Drylang

let main root (output : Options.OutputOptions.t) options =
  Printf.eprintf "not implemented yet\n%!" (* TODO *)

(* Command-line interface *)

open Cmdliner

let cmd =
  let name = "dry-check" in
  let version = Version.string in
  let doc = "type-check DRY code" in
  let exits = Term.default_exits in
  let envs = [] in
  let man = [
    `S Manpage.s_bugs; `P "File bug reports at <$(b,https://github.com/dryproject/drylang)>.";
    `S Manpage.s_see_also; `P "$(b,dry)(1), $(b,dry-analyze)(1), $(b,dry-optimize)(1)" ]
  in
  Term.(const main $ Options.package_root $ Options.output $ Options.common),
  Term.info name ~version ~doc ~exits ~envs ~man

let () = Term.(exit @@ eval cmd)
