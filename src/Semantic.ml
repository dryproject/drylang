(* This is free and unencumbered software released into the public domain. *)

open DRY.Core

module Datum   = DRY.Core.Datum
module Symbol  = DRY.Core.Symbol
module Comment = DRY.Code.DRY.Comment

let not_implemented () = failwith "not implemented yet"

module Node = struct
  open Format

  type t =
    | Const of Datum.t
    | Var of Symbol.t
    | Name of Symbol.t * Symbol.t list
    | Apply of t * t list
    | MathNeg of t
    | MathAdd of t * t
    | MathSub of t * t
    | MathMul of t * t
    | MathDiv of t * t
    | LogicNot of t
    | LogicAnd of t * t
    | LogicOr of t * t
    | If of t * t * t
    | Loop of t list

  let rec print ppf = function
    | Const d ->
      pp_print_char ppf '(';
      pp_print_char ppf '#';
      pp_print_string ppf "const";
      pp_print_char ppf ' ';
      pp_print_string ppf (Datum.to_string d);
      pp_print_char ppf ')'
    | Var s ->
      pp_print_char ppf '(';
      pp_print_char ppf '#';
      pp_print_string ppf "var";
      pp_print_char ppf ' ';
      pp_print_string ppf (Symbol.to_string s);
      pp_print_char ppf ')'
    | Name (pkg, path) ->
      pp_print_char ppf '(';
      pp_print_char ppf '#';
      pp_print_string ppf "name";
      pp_print_char ppf ' ';
      pp_print_string ppf (Symbol.to_string pkg);
      pp_print_char ppf ':';
      pp_print_list ~pp_sep:(fun ppf () -> pp_print_char ppf '/') pp_print_string ppf (List.map Symbol.to_string path);
      pp_print_char ppf ')'
    | Apply (f, args) -> pp_opn ppf "apply" (f :: args)
    | MathNeg a -> pp_op1 ppf "neg" a
    | MathAdd (a, b) -> pp_op2 ppf "add" a b
    | MathSub (a, b) -> pp_op2 ppf "sub" a b
    | MathMul (a, b) -> pp_op2 ppf "mul" a b
    | MathDiv (a, b) -> pp_op2 ppf "div" a b
    | LogicNot a -> pp_op1 ppf "not" a
    | LogicAnd (a, b) -> pp_op2 ppf "and" a b
    | LogicOr (a, b) -> pp_op2 ppf "or" a b
    | If (a, b, c) -> pp_op3 ppf "if" a b c
    | Loop body -> pp_opn ppf "loop" body

  and pp_op1 ppf op a =
    pp_print_char ppf '(';
    pp_print_char ppf '#';
    pp_print_string ppf op;
    pp_print_space ppf ();
    print ppf a;
    pp_print_char ppf ')'

  and pp_op2 ppf op a b =
    pp_print_char ppf '(';
    pp_print_char ppf '#';
    pp_print_string ppf op;
    pp_print_space ppf ();
    print ppf a;
    pp_print_space ppf ();
    print ppf b;
    pp_print_char ppf ')'

  and pp_op3 ppf op a b c =
    pp_print_char ppf '(';
    pp_print_char ppf '#';
    pp_print_string ppf op;
    pp_print_space ppf ();
    print ppf a;
    pp_print_space ppf ();
    print ppf b;
    pp_print_space ppf ();
    print ppf c;
    pp_print_char ppf ')'

  and pp_opn ppf op args =
    pp_print_char ppf '(';
    pp_print_char ppf '#';
    pp_print_string ppf op;
    pp_print_space ppf ();
    pp_print_list ~pp_sep:pp_print_space print ppf args;
    pp_print_char ppf ')'

  let to_string node =
    let buffer = Buffer.create 16 in
    let ppf = Format.formatter_of_buffer buffer in
    Format.pp_open_hbox ppf ();
    print ppf node;
    Format.pp_close_box ppf ();
    Format.pp_print_flush ppf ();
    Buffer.contents buffer
end

module Module = struct
  open Format

  type t =
    { name: Symbol.t;
      comment: Comment.t option;
      code: Node.t list; }

  let make ?(comment = "") ~name ~code =
    { name = Symbol.of_string name;
      comment = (match comment with "" -> None | s -> Some (Comment.of_string comment));
      code = code; }

  let print ppf module_ =
    pp_print_char ppf '(';
    pp_print_string ppf "#module";
    pp_print_space ppf ();
    pp_print_list ~pp_sep:pp_print_space Node.print ppf module_.code;
    pp_print_char ppf ')';
end

module Program = struct
  open Format

  type t =
    { code: Node.t list; }

  let make args =
    { code = args; }

  let print ppf program =
    pp_print_char ppf '(';
    pp_print_string ppf "#program";
    pp_print_space ppf ();
    pp_print_list ~pp_sep:pp_print_space Node.print ppf program.code;
    pp_print_char ppf ')';
end

let analyze_identifier symbol =
  match Symbol.to_string symbol with
  | "true" -> Node.Const (Datum.of_bool true)
  | "false" -> Node.Const (Datum.of_bool false)
  | "/" -> Node.Var symbol
  | s ->
    begin match String.contains s '/' with
    | false -> Node.Var symbol
    | true  -> Node.Name (Symbol.of_string "dry", List.map Symbol.of_string (String.split_on_char '/' s))
    end

let analyze_operation operator operands =
  match operator with
  | Node.Var symbol -> begin
      match (Symbol.to_string symbol, operands) with
      | "neg", a :: [] -> Node.MathNeg a
      | "+",   a :: b :: [] -> Node.MathAdd (a, b)
      | "-",   a :: b :: [] -> Node.MathSub (a, b)
      | "*",   a :: b :: [] -> Node.MathMul (a, b)
      | "/",   a :: b :: [] -> Node.MathDiv (a, b)
      | "not", a :: [] -> Node.LogicNot a
      | "and", a :: b :: [] -> Node.LogicAnd (a, b)
      | "or",  a :: b :: [] -> Node.LogicOr (a, b)
      | "if",  a :: b :: c :: [] -> Node.If (a, b, c)
      | "loop", _ -> Node.Loop operands
      | _, _ -> Node.Apply (operator, operands)
    end
  | Node.Name (pkg, path) -> Node.Apply (operator, operands)
  | _ -> Syntax.semantic_error "invalid operation"

let rec analyze_node = function
  | Syntax.Node.Atom (Datum.Symbol symbol) ->
    analyze_identifier symbol

  | Syntax.Node.Atom datum ->
    Node.Const datum

  | Syntax.Node.List (hd :: tl) ->
    analyze_operation (analyze_node hd) (List.map analyze_node tl)

  | Syntax.Node.List [] ->
    Syntax.semantic_error "invalid expression"

let optimize_node = function
  | node -> node (* TODO *)

let optimize_module (source : SourceFile.t) (module_ : Module.t) =
  module_ (* TODO *)

let optimize_program (source : SourceFile.t) (program : Program.t) =
  program (* TODO *)
