(* This is free and unencumbered software released into the public domain. *)

open DRY.Core

module type Language = sig
  val compile : Semantic.Node.t -> Buffer.t -> unit
end

(** C *)
module C : Language = struct
  let compile code buffer = () (* TODO *)
end

(** C++ *)
module Cpp : Language = struct
  let compile code buffer = () (* TODO *)
end

(** D *)
module D : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Dart *)
module Dart : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Elixir *)
module Elixir : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Go *)
module Go : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Java *)
module Java : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Julia *)
module Julia : Language = struct
  let compile code buffer = () (* TODO *)
end

(** JS *)
module JS : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Kotlin *)
module Kotlin : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Common Lisp *)
module Lisp : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Lua *)
module Lua : Language = struct
  let compile code buffer = () (* TODO *)
end

(** OCaml *)
module OCaml : Language = struct
  let compile code buffer = () (* TODO *)
end

(** PHP *)
module PHP : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Python *)
module Python : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Ruby *)
module Ruby : Language = struct
  let compile code buffer = () (* TODO *)
end

(** Rust *)
module Rust : Language = struct
  let compile code buffer = () (* TODO *)
end