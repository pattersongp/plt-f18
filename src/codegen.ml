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
(* open Ast (* This will change once we have Sast *) *)
open Sast

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
(*   and i8_ptr_t = L.pointer_type i8_t  *)
  in

  (* Convert Fire types to LLVM types *)
  let ltype_of_typ = function
      A.Int         -> i32_t
    | A.Bool        -> i1_t
    | A.Void        -> void_t
    | A.String      -> string_t
    | A.Regx        -> string_t
    | A.File        -> i32_ptr_t
    | A.Array(_, _) -> i32_ptr_t
    | A.Function    -> i32_ptr_t (* Not implemented*)
  in

  (* ---------------------- External Functions ---------------------- *)
  let regex_cmp_t : L.lltype =
    L.var_arg_function_type i1_t [| string_t; string_t |] in
  let regex_cmp_func : L.llvalue =
    L.declare_function "regex_compare" regex_cmp_t the_module in

  let sprint_t : L.lltype =
    L.var_arg_function_type i32_t [| string_t |] in
  let sprint_func : L.llvalue =
    L.declare_function "sprint" sprint_t the_module in

  let printf_t : L.lltype =
    L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func : L.llvalue =
    L.declare_function "printf" printf_t the_module in

  let strcat_t : L.lltype =
    L.function_type string_t [| string_t; string_t |] in
  let strcat_func : L.llvalue =
    L.declare_function "strcat_fire" strcat_t the_module in

  let strlen_t : L.lltype =
    L.function_type i32_t [| L.pointer_type i8_t |] in
  let strlen_func : L.llvalue =
    L.declare_function "strlen" strlen_t the_module in

  let open_file_t : L.lltype =
    L.function_type i32_ptr_t [| string_t; string_t |] in
  let open_file_func : L.llvalue =
    L.declare_function "open" open_file_t the_module in

  let read_file_t : L.lltype =
    L.function_type string_t [| i32_ptr_t |] in
  let read_file_func : L.llvalue =
    L.declare_function "readFire" read_file_t the_module in

  let init_arr_t : L.lltype =
    L.function_type i32_ptr_t [| i32_t; i32_t |] in
  let init_arr_func : L.llvalue =
    L.declare_function "initArray" init_arr_t the_module in

  let add_t : L.lltype =
    L.function_type i32_t [| string_t; i32_ptr_t; i32_ptr_t |] in
  let add_func : L.llvalue =
    L.declare_function "add" add_t the_module in

(*
 * Will eventually need this for Retrieve
  let get_t : L.lltype =
    L.function_type i32_t [| string_t; i32_t |] in
  let get_func : L.llvalue =
    L.declare_function "get" get_t the_module in
*)

  (* ---------------------- User Functions ---------------------- *)
  let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
    let function_decl m fdecl =
      let name = fdecl.sfname
      and formal_types =
        Array.of_list (List.map (fun (t,_,_) -> ltype_of_typ t) fdecl.sformals)
      in
        let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
          StringMap.add name (L.define_function name ftype the_module, fdecl) m
        in
    List.fold_left function_decl StringMap.empty functions
  in
  let build_function_body fdecl =

    let (the_function, _) = StringMap.find fdecl.sfname function_decls  in
    let builder = L.builder_at_end context (L.entry_block the_function) in

  (* ---------------------- Formatters ---------------------- *)
    let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder in

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
  let formals = List.fold_left2 add_formal StringMap.empty fdecl.sformals
    (Array.to_list (L.params the_function)) in
  List.fold_left add_local formals []
  in

(*     let print_map k v = print_string(k ^ "->" ^ "some value.." ^ "\n") in *)

    (* Return the value for a variable or formal argument.
       Check local names first, then global names *)
    let lookup n m = try
(*       print_string("MAP:\n"); StringMap.iter print_map m; print_string("\n\n"); *)
      StringMap.find n m
      with Not_found -> raise (Failure ("Variable [" ^ n ^ "] not declared"))
    in


    let add_vdecl (t, n, lvs) =
      let local_var = L.build_alloca (ltype_of_typ t) n builder
      in
(*         print_string("MAP:\n"); StringMap.iter print_map lvs; print_string("\n\n"); *)
        StringMap.add n local_var lvs
    in

    (* Function for matching lltype to size in c for array lib *)
    let size_of_ltype = function
        i32_t     -> L.const_int i32_t 8
      | i1_t      -> L.const_int i32_t 4
      | string_t  -> L.const_int i32_t 7
      | _ -> raise (Failure "Error! Invalid array type.")
    in

    let rec expr (builder, lvs) ((_, e) : sexpr) = match e with
        SLiteral i           -> L.const_int i32_t i
      | SStringLit s         -> L.build_global_stringptr s "str" builder
      | SNoexpr              -> L.const_int i32_t 0
      | SBoolLit b           -> L.const_int i1_t (if b then 1 else 0)
      | SId s                -> L.build_load (lookup s lvs) s builder
      | SReadFile (id)       ->
          L.build_call read_file_func [| (expr (builder, lvs) (A.String, SId(id))) |] "readFire" builder
      | SOpen (e1, e2)       ->
          let e1' = expr (builder, lvs) e1
          and e2' = expr (builder, lvs) e2 in
          L.build_call open_file_func [| e1'; e2' |] "open" builder
      | SInitArray(t1, t2) ->
          let t1' = (size_of_ltype (ltype_of_typ t1))
          and t2' = (size_of_ltype (ltype_of_typ t2)) in
            L.build_call init_arr_func [| t1'; t2' |] "initArray" builder
      | SArray_Assign (id, e1, e2)       ->
          let e1' = expr (builder, lvs) e1
          and e2' = expr (builder, lvs) e2
          and id' = (expr (builder, lvs) (A.Void, SId(id))) in
          L.build_call add_func [| id'; e1'; e2' |] "add" builder
      | SRetrieve(id, e) ->
          let e' = expr (builder, lvs) e
          and id' = (expr (builder, lvs) (A.Void, SId(id))) in
            L.build_call init_arr_func [| id'; e'  |] "get" builder
      | SCall("strlen", [e])    ->
          L.build_call strlen_func [| (expr (builder, lvs) e) |] "strlen" builder
      | SCall("sprint", [e])    ->
          L.build_call sprint_func [| (expr (builder, lvs) e) |] "sprint" builder
      | SCall("print", [e])     ->
          L.build_call printf_func [| int_format_str; (expr (builder, lvs) e) |] "printf" builder
      | SCall (f, args) ->
         let (fdef, fdecl) = try StringMap.find f function_decls with Not_found -> raise (Failure "Function not found" )in
         let llargs = List.rev (List.map (expr (builder, lvs)) (List.rev args)) in
         let result = (match fdecl.styp with
                        A.Void -> ""
                      | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list llargs) result builder
      | SRegexComp(e1, e2) ->
          let e1' = expr (builder, lvs) e1
          and e2' = expr (builder, lvs) e2 in
          L.build_call regex_cmp_func [| e1'; e2' |] "regex_compare" builder
      | SStrCat(e1, e2) ->
          let e1' = expr (builder, lvs) e1
          and e2' = expr (builder, lvs) e2 in
          L.build_call strcat_func [| e1'; e2' |] "strcat_fire" builder
      | SBinop (e1, op, e2) ->
        let e1' = expr (builder, lvs) e1
        and e2' = expr (builder, lvs) e2 in
        (match op with
          A.Plus      -> L.build_add
        | A.Minus     -> L.build_sub
        | A.Times     -> L.build_mul
        | A.Divide    -> L.build_sdiv
        | A.And       -> L.build_and
        | A.Or        -> L.build_or
        | A.Eq        -> L.build_icmp L.Icmp.Eq
        | A.Neq       -> L.build_icmp L.Icmp.Ne
        | A.Lt        -> L.build_icmp L.Icmp.Slt
        | A.Lteq      -> L.build_icmp L.Icmp.Sle
        | A.Gt        -> L.build_icmp L.Icmp.Sgt
        | A.Gteq      -> L.build_icmp L.Icmp.Sge
        ) e1' e2' "tmp" builder
      | _ -> raise (Failure "FAILURE at expr builder")
    in

  let add_terminal (builder, _) instr =
      match L.block_terminator (L.insertion_block builder) with
        Some _ -> ()
      | None -> ignore (instr builder) in

    let rec stmt (builder, lvs) = function
        SBlock sl -> List.fold_left stmt (builder, lvs) sl
      | SExpr e -> ignore(expr (builder, lvs) e); builder, lvs
      | SVdecl (t, n, e) -> let assn' = match t with
          Array(t1, t2) ->
            let lvs' = add_vdecl (t, n, lvs) in stmt (builder, lvs') (SAssign(n, (Array(t1,t2), SInitArray(t1,t2))))
        | _ -> let lvs' = add_vdecl (t, n, lvs) in stmt (builder, lvs') (SAssign(n, e))
        in assn'
      | SAssign (s, e)   -> let e' = expr (builder, lvs) e in
                           ignore(L.build_store e' (lookup s lvs) builder); builder, lvs
      | SReturn e -> ignore(match fdecl.styp with
                              (* Special "return nothing" instr *)
                              A.Void -> L.build_ret_void builder
                              (* Build return statement *)
                            | _ -> L.build_ret (expr (builder, lvs) e) builder );
                     builder, lvs
      | SIf (predicate, then_stmt, else_stmt) ->
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
      | SWhile (predicate, body) ->
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
    let builder, _ = stmt (builder, local_vars) (SBlock fdecl.sbody) in

    (* Add a return if the last block falls off the end *)
    add_terminal (builder, local_vars) (match fdecl.styp with
        A.Void -> L.build_ret_void
      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  in

List.iter build_function_body functions;
the_module
