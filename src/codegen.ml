(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

(* We'll refer to Llvm and Ast constructs with module names *)
module L = Llvm
module A = Ast
(* open Sast *)

module StringMap = Map.Make(String)

(* Code Generation from the SAST. Returns an LLVM module if successful,
   throws an exception if something is wrong. *)
let translate (globals, functions) =
  let context    = L.global_context () in

  (* Add types to the context so we can use them in our LLVM code *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and void_t     = L.void_type   context
  (* Create an LLVM module -- this is a "container" into which we'll
     generate actual code *)
  and the_module = L.create_module context "Fire" in

  let pointer_t  = L.pointer_type i8_t in

  (* Convert Fire types to LLVM types *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Void  -> void_t
(*     | A.String -> pointer_t *)
  in

  let rec global_expr = function
      A.Literal i -> i
    | A.BoolLit b -> (if b then 1 else 0)
(*     | A.StringLit s -> s *)
  in

  (* Declare each global variable; remember its value in a map *)
  let global_vars : L.llvalue StringMap.t =
    let global_var m (typ, n, v) =
      let init = match typ with
        | A.Int -> (let v' = match v with
                None -> 0
                | Some v -> global_expr v
                in L.const_int (ltype_of_typ typ) v')
        | A.Bool -> let v' = match v with
                None -> 0
                | Some v -> global_expr v
                in L.const_int (ltype_of_typ typ) v'
(*
        | A.StringLit -> let v' = match v with
                None -> ""
                | Some v -> global_expr v
                in L.const_pointer_null (ltype_of_typ typ) v'
*)
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in  the_module

