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
module O = Batteries.Option
open Ast (* This will change once we have Sast *)
(* open Sast *)

module StringMap = Map.Make(String)

(* Code Generation from the SAST. Returns an LLVM module if successful,
   throws an exception if something is wrong. *)
let translate (globals, functions) =
  let context    = L.global_context () in
  let the_module = L.create_module context "Fire" in

  (* ---------------------- Types ---------------------- *)
  let i32_t      = L.i32_type    context
  and i8_t       = L.i8_type     context
  and i1_t       = L.i1_type     context
  and void_t     = L.void_type   context
  in

  let string_t = L.pointer_type i8_t
  and i32_ptr_t = L.pointer_type i32_t
  and i8_ptr_t = L.pointer_type i8_t in

  (* Convert Fire types to LLVM types *)
  let ltype_of_typ = function
      A.Int   -> i32_t
    | A.Bool  -> i1_t
    | A.Void  -> void_t
    | A.String -> string_t
  in

(* need to revisit this *)
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
    List.fold_left global_var StringMap.empty globals in

  (* ---------------------- External Functions ---------------------- *)
  let print_t : L.lltype =
    L.var_arg_function_type i32_t [| i32_t |] in (* L.pointer_type i8_t is what we really want*)
  let print_func : L.llvalue =
    L.declare_function "print" print_t the_module in

  (* ---------------------- User Functions ---------------------- *)
  let function_decls : (L.llvalue * func_decl) StringMap.t =                    (* Will become sfunc_decl *)
    let function_decl m fdecl =
      let name = fdecl.fname                                                    (* will become sfname *)
      and formal_types =
        Array.of_list (List.map (fun (t,_,_) -> ltype_of_typ t) fdecl.formals)  (* will become sformals*)
      in
        let ftype = L.function_type (ltype_of_typ fdecl.typ) formal_types in    (* will become styp *)
          StringMap.add name (L.define_function name ftype the_module, fdecl) m
        in
    List.fold_left function_decl StringMap.empty functions
  in
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.fname function_decls  in        (* Change for Sast *)
    let builder = L.builder_at_end context (L.entry_block the_function) in

  (* Local variables for a function *)
  let local_vars =
    let add_formal m (t, n, _) p = L.set_value_name n p;
    let local = L.build_alloca (ltype_of_typ t) n builder
    in
      ignore (L.build_store p local builder); StringMap.add n local m
    and add_local m (t, n, _) =                                                 (* Underscore wildcard here is Some value *)
      let local_var = L.build_alloca (ltype_of_typ t) n builder
      in
        StringMap.add n local_var m
    in
  let formals = List.fold_left2 add_formal StringMap.empty fdecl.formals        (* Change for Sast *)
    (Array.to_list (L.params the_function)) in
    List.fold_left add_local formals fdecl.locals                               (* Change for Sast *)
  in
    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

    let rec expr builder ((e) : expr) = match e with
        A.Literal i           -> L.const_int i32_t i
      | A.StringLit s         -> L.build_global_stringptr (Scanf.unescaped s) "str" builder
      | A.BoolLit b           -> L.const_int i1_t (if b then 1 else 0)
      | Call("print", [e]) ->
        L.build_call print_func [| (expr builder (O.get(e))) |] "print" builder
    in

    let rec elevate builder e = match e with
      Some _ -> expr builder (O.get e)
      | None -> L.const_int i1_t 0
    in

  let add_terminal builder instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in
(*
 * ...
     Lots more code here to parse expressions and statements etc...
 * ...
 *)
    let rec stmt builder = function
      Block sl -> List.fold_left stmt builder sl
      | Expr e -> ignore(expr builder e); builder
      | Return e -> ignore(match fdecl.typ with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder
                              (* Build return statement *)
                            | _ -> L.build_ret (elevate builder e) builder );
                     builder
      | _ -> raise (Failure "FAILURE at stmt builder")
    in
    (* Build the code for each statement in the function *)
    let builder = stmt builder (Block fdecl.body) in                           (* Change for Sast *)


    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.typ with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

List.iter build_function_body functions;
the_module
