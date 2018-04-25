(* This is free and unencumbered software released into the public domain. *)

open DRY.Core
open Drylang

let printf = Printf.printf

let iter_term (term : Local.Term.t) =
  printf "%s\t%s\n%!" term.path "term"

let rec iter_module (module_ : Local.Module.t) =
  printf "%s\t%s\n%!" module_.path "module";
  Local.Module.iter_modules module_ iter_module;
  Local.Module.iter_terms module_ iter_term

let iter_package (package : Local.Package.t) =
  printf "%s\t%s\n%!" package.path "package";
  Local.Package.iter_modules package iter_module

let iter_index index =
  Local.Index.iter_packages index iter_package

let main root =
  iter_index (Local.Index.open_path root)

(* Command-line interface *)

open Cmdliner

let root =
  let doc = "Overrides the default package index (\\$HOME/.dry)." in
  let env = Arg.env_var "DRY_ROOT" ~doc in
  let doc = "The package index root." in
  let def = Local.Index.default_path () in
  Arg.(value & opt dir def & info ["root"] ~env ~docv:"ROOT" ~doc)

let cmd =
  let name = "dry-index" in
  let version = Version.string in
  let doc = "show the package index" in
  let exits = Term.default_exits in
  let envs = [] in
  let man = [
    `S Manpage.s_bugs; `P "File bug reports at <$(b,https://github.com/dryproject/drylang)>.";
    `S Manpage.s_see_also; `P "$(b,dry)(1), $(b,dry-describe)(1)" ]
  in
  Term.(const main $ root),
  Term.info name ~version ~doc ~exits ~envs ~man

let () = Term.(exit @@ eval cmd)