(* This is free and unencumbered software released into the public domain. *)

module Source = Semantic
module Target = DRY.Code.Wasm

let not_implemented () = failwith "not implemented yet"

let word = function
  | Word.Word8 _ -> not_implemented ()
  | Word.Word16 _ -> not_implemented ()
  | Word.Word32 _ -> not_implemented ()
  | Word.Word64 _ -> not_implemented ()

let number = function
  | Number.Float (Float32 r) -> Target.f32 r
  | Number.Float (Float64 r) -> Target.f64 r
  | Number.Int (Int8 z) -> Target.i32 (Int8.as_int32 z)
  | Number.Int (Int16 z) -> Target.i32 (Int16.as_int32 z)
  | Number.Int (Int32 z) -> Target.i32 z
  | Number.Int (Int64 z) -> Target.i64 z
  | Number.Int (Int128 _) -> not_implemented ()
  | _ -> not_implemented ()

let scalar = function
  | Scalar.Bool b -> Target.i32 (if b then 1l else 0l)
  | Scalar.Char c -> Target.i32 (Char.as_int32 c)
  | Scalar.Number n -> number n
  | Scalar.Word w -> word w

let tensor = function
  | Tensor.Scalar x -> scalar x
  | Tensor.Vector _ -> not_implemented ()
  | Tensor.Matrix _ -> not_implemented ()

let datum = function
  | Datum.Symbol _ -> not_implemented ()
  | Datum.Tensor x -> tensor x
  | _ -> not_implemented ()

let compile_node ppf = function
  | Source.Node.Const x -> Target.print ppf (datum x)
  | _ -> not_implemented ()

let compile_module ppf (code : Source.Module.t) =
  let output = Target.Module.create () in (* TODO *)
  Target.Module.print ppf output

let compile_program ppf code =
  not_implemented ()