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
      A.Int    -> i32_t
    | A.Bool   -> i1_t
    | A.Void   -> void_t
    | A.String -> string_t
    | A.Regx   -> string_t
  in

  (* ---------------------- External Functions ---------------------- *)
  let print_t : L.lltype =
    L.var_arg_function_type i32_t [| i32_t |] in (* L.pointer_type i8_t is what we really want*)
  let print_func : L.llvalue =
    L.declare_function "print" print_t the_module in

  let sprint_t : L.lltype =
    L.var_arg_function_type i32_t [| string_t |] in (* L.pointer_type i8_t is what we really want*)
  let sprint_func : L.llvalue =
    L.declare_function "sprint" sprint_t the_module in

  let regex_cmp_t : L.lltype =
    L.var_arg_function_type i1_t [| string_t; string_t |] in (* L.pointer_type i8_t is what we really want*)
  let regex_cmp_func : L.llvalue =
    L.declare_function "regex_compare" regex_cmp_t the_module in

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
  List.fold_left add_local formals []
  in

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n m = try StringMap.find n m
      with Not_found -> raise (Failure ("Variable [ " ^ n ^ " ] not declared"))
    in

    let add_vdecl (t, n, lvs) =
      let local_var = L.build_alloca (ltype_of_typ t) n builder
      in
        StringMap.add n local_var lvs
    in

    let rec expr (builder, lvs) ((e) : expr) = match e with
        A.Literal i           -> L.const_int i32_t i
      | A.StringLit s         -> L.build_global_stringptr s "str" builder
      | A.Noexpr              -> L.const_int i32_t 0
      | A.BoolLit b           -> L.const_int i1_t (if b then 1 else 0)
      | A.Id s                -> L.build_load (lookup s lvs) s builder
      | Call("print", [e])    ->
        L.build_call print_func [| (expr (builder, lvs) e) |] "print" builder
      | Call("sprint", [e])    ->
        L.build_call sprint_func [| (expr (builder, lvs) e) |] "print" builder
      | Call (f, args) ->
         let (fdef, fdecl) = try StringMap.find f function_decls with Not_found -> raise (Failure "Function not found" )in
         let llargs = List.rev (List.map (expr (builder, lvs)) (List.rev args)) in
         let result = (match fdecl.typ with
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
      | RegexComp(e1, e2) ->
          let e1' = expr (builder, lvs) e1
          and e2' = expr (builder, lvs) e2 in
          L.build_call regex_cmp_func [| e1'; e2' |] "regex_compare" builder
      | Binop (e1, op, e2) ->
        let e1' = expr (builder, lvs) e1
        and e2' = expr (builder, lvs) e2 in
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
        ) e1' e2' "tmp" builder
      | _ -> raise (Failure "FAILURE at expr builder")
    in

  let add_terminal (builder, _) instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    let rec stmt (builder, lvs) = function
        Block sl -> List.fold_left stmt (builder, lvs) sl
      | Expr e -> ignore(expr (builder, lvs) e); builder, lvs
      | A.Vdecl (t, n, e) -> let lvs' = add_vdecl (t, n, lvs) in stmt (builder, lvs') (Assign(n,e))
      | A.Assign (s, e) -> let e' = expr (builder, lvs) e in
                           ignore(L.build_store e' (lookup s lvs) builder); builder, lvs
      | Return e -> ignore(match fdecl.typ with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder
                              (* Build return statement *)
                            | _ -> L.build_ret (expr (builder, lvs) e) builder );
                     builder, lvs
      | If (predicate, then_stmt, else_stmt) ->
         let bool_val = expr (builder, lvs) predicate in
         let merge_bb = L.append_block context "merge" the_function in
         let build_br_merge = L.build_br merge_bb in (* partial function *)
         let then_bb = L.append_block context "then" the_function in
           add_terminal (stmt ((L.builder_at_end context then_bb), lvs) then_stmt)
             build_br_merge;
         let else_bb = L.append_block context "else" the_function in
           add_terminal (stmt ((L.builder_at_end context else_bb), lvs) else_stmt)
             build_br_merge;
           ignore(L.build_cond_br bool_val then_bb else_bb builder);
          (L.builder_at_end context merge_bb), lvs
      | While (predicate, body) ->
        let pred_bb = L.append_block context "while" the_function in
          ignore(L.build_br pred_bb builder);

        let body_bb = L.append_block context "while_body" the_function in
          add_terminal (stmt ((L.builder_at_end context body_bb), lvs) body)
            (L.build_br pred_bb);

        let pred_builder = L.builder_at_end context pred_bb in
        let bool_val = expr (pred_builder, lvs) predicate in

        let merge_bb = L.append_block context "merge" the_function in
          ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
          (L.builder_at_end context merge_bb), lvs
(*
 * This is a special case because we have to get the array to iterate over it
      | For (e1, e2, e3, body) -> stmt builder
        ( Block [Expr e1 ; While (e2, Block [body ; Expr e3]) ] )
*)
      | _ -> raise (Failure "FAILURE at stmt builder")
    in
    (* Build the code for each statement in the function *)
    let builder, _ = stmt (builder, local_vars) (Block fdecl.body) in

    (* Add a return if the last block falls off the end *)
    add_terminal (builder, local_vars) (match fdecl.typ with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

List.iter build_function_body functions;
the_module
