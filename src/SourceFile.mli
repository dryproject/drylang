(* This is free and unencumbered software released into the public domain. *)

type t =
  { channel: in_channel;
    path:    string;
    name:    string;
    package: string;
    module_: string;
    term:    string; }

val stdin : t

val open_user_program : string -> t

val open_package_term : index:string -> package:string -> string -> t

val to_string : t -> string
