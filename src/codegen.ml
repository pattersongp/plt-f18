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
let translate functions =
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

  (* ---------------------- External Functions ---------------------- *)
  let print_t : L.lltype =
    L.var_arg_function_type i32_t [| i32_t |] in (* L.pointer_type i8_t is what we really want*)
  let print_func : L.llvalue =
    L.declare_function "print" print_t the_module in

  (* ---------------------- User Functions ---------------------- *)
  let function_decls : (L.llvalue * func_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.fname
      and formal_types =
        Array.of_list (List.map (fun (t,_,_) -> ltype_of_typ t) fdecl.formals)
      in
        let ftype = L.function_type (ltype_of_typ fdecl.typ) formal_types in
          StringMap.add name (L.define_function name ftype the_module, fdecl) m
        in
    List.fold_left function_decl StringMap.empty functions
  in
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.fname function_decls  in
    let builder = L.builder_at_end context (L.entry_block the_function) in

  (* Local variables for a function *)
  let local_vars =
    let add_formal m (t, n, _) p = L.set_value_name n p;
    let local = L.build_alloca (ltype_of_typ t) n builder
    in
      ignore (L.build_store p local builder); StringMap.add n local m
    and add_local m (t, n, _) =
      let local_var = L.build_alloca (ltype_of_typ t) n builder
      in
        StringMap.add n local_var m
    in
  let formals = List.fold_left2 add_formal StringMap.empty fdecl.formals
    (Array.to_list (L.params the_function)) in
    List.fold_left add_local formals fdecl.formals
  in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n local_vars
    in

    let add_local (t, n, _) =
      let local_var = L.build_alloca (ltype_of_typ t) n builder
      in
        StringMap.add n local_var local_vars
    in


    let rec expr builder ((e) : expr) = match e with
        A.Literal i           -> L.const_int i32_t i
      | A.StringLit s         -> L.build_global_stringptr (Scanf.unescaped s) "str" builder
      | A.BoolLit b           -> L.const_int i1_t (if b then 1 else 0)
      | A.Id s                -> L.build_load (lookup s) s builder
      | Call("print", [e]) ->
        L.build_call print_func [| (expr builder e) |] "print" builder
      | Call (f, args) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
         let llargs = List.rev (List.map (expr builder) (List.rev args)) in (* Will remove map o.get *)
         let result = (match fdecl.typ with
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
      | Binop (e1, op, e2) ->
        let e1' = expr builder e1
        and e2' = expr builder e2 in
        (match op with
          Plus      -> L.build_add
        | Minus     -> L.build_sub
        | Times     -> L.build_mul
        | Divide    -> L.build_sdiv
        | And       -> L.build_and
        | Or        -> L.build_or
        | Eq        -> L.build_icmp L.Icmp.Eq
        | Neq       -> L.build_icmp L.Icmp.Ne
        | Lt        -> L.build_icmp L.Icmp.Slt
        | Lteq      -> L.build_icmp L.Icmp.Sle
        | Gt        -> L.build_icmp L.Icmp.Sgt
        | Gteq      -> L.build_icmp L.Icmp.Sge
(*      | Req     -> L.build_icmp L.Icmp.Ne  REGEX COMPARE *)
        ) e1' e2' "tmp" builder
      | _ -> raise (Failure "FAILURE at expr builder")
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
      | Vdecl (t, n, e) -> add_local (t, n, e); stmt builder (Assign(n,e))
      | A.Assign (s, e) -> let e' = expr builder e in
                           ignore(L.build_store e' (lookup s) builder); builder
      | Return e -> ignore(match fdecl.typ with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder
                              (* Build return statement *)
                            | _ -> L.build_ret (expr builder e) builder );
                     builder
      | If (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
         let merge_bb = L.append_block context "merge" the_function in
         let build_br_merge = L.build_br merge_bb in (* partial function *)
         let then_bb = L.append_block context "then" the_function in
           add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
             build_br_merge;
         let else_bb = L.append_block context "else" the_function in
           add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
             build_br_merge;
           ignore(L.build_cond_br bool_val then_bb else_bb builder);
           L.builder_at_end context merge_bb
      | While (predicate, body) ->
        let pred_bb = L.append_block context "while" the_function in
          ignore(L.build_br pred_bb builder);

        let body_bb = L.append_block context "while_body" the_function in
          add_terminal (stmt (L.builder_at_end context body_bb) body)
            (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb in
        let bool_val = expr pred_builder predicate in

        let merge_bb = L.append_block context "merge" the_function in
          ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
          L.builder_at_end context merge_bb
(*
 * This is a special case because we have to get the array to iterate over it
      | For (e1, e2, e3, body) -> stmt builder
        ( Block [Expr e1 ; While (e2, Block [body ; Expr e3]) ] )
*)
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
