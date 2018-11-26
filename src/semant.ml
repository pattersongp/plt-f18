open Ast
open Sast

module StringMap = Map.Make(String)

  type env = {
    mutable lvs: typ StringMap.t;
    stmts: sstmt list;
  } 

let check fdec = 

  (* note, bind is a triple of typ, string and expr *)
  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	(Void, b, _ ) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
      | _ -> ()) binds; 
    let rec dups = function
        [] -> ()
      |	((_,n1,_) :: (_,n2,_) :: _) when n1 = n2 ->
	  raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a,_) (_,b,_) -> compare a b) binds)
in

(* begin checking functions *)

(* function declaration for built-in FIRE functions - print, map, filter *)
(* re-write for FIRE bind type? *)
let built_in_func_decls = 
    let add_bind map (name, rType) = StringMap.add name {
        (* object between brackets is func_decl object? *)
        typ = Void; (* all built in functions are of type void *)
        fname = name;
        formals = [(rType, "x", Noexpr)]; 
        body = []; (* empty list *)
    } map 
    (* REVISE following line !!!*)
    in List.fold_left add_bind StringMap.empty [("print", String); ("map", String); ("filter", String)]
in

(* build up symbol table - global scope ONLY for now *)
let add_func map fd=
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
         _ when StringMap.mem n built_in_func_decls -> make_err built_in_err
       | _ when StringMap.mem n map -> make_err dup_err  
       | _ ->  StringMap.add n fd map 
  in

  (* collect all function names into symbol table *)
let function_decls = List.fold_left add_func built_in_func_decls fdec

in

  (* Return a function from our symbol table *)
let find_func s = 
  try StringMap.find s function_decls
  with Not_found -> raise (Failure ("unrecognized function " ^ s))
in

let _ = find_func "main" in (* Ensure "main" is defined *)

(* code that vets functions below *)

let check_function func =
  (* Make sure no formals are void or duplicates *)
  check_binds "formal" func.formals;

 (* if expressions are symmetric, it is invalid; e.g. int x = int x; *)
  let check_assign lvaluet rvaluet err =
    if lvaluet = rvaluet then lvaluet else raise (Failure err)
  in  

  (* build local symbol table - '@' in OCaml represents list concat *)
  let symbols = List.fold_left (fun m (typ, name, _ ) -> StringMap.add name typ m)
                StringMap.empty func.formals
  in 

  let type_of_identifier s =
    try StringMap.find s symbols
    with Not_found -> raise (Failure ("undeclared identifier " ^ s))
  in
  
(* need to implement Req for regular expression matching in binop *)
  let rec expr = function
      Literal l -> (Int, SLiteral l)
    | BoolLit l -> (Bool, SBoolLit l)
    | StringLit l -> (String, SStringLit l)
    | Id s -> (type_of_identifier s, SId s)
    | Unop(op, e) as ex -> 
       let (t, e') = expr e in
       let ty = match op with
         Neg when t = Int -> t
       | Not when t = Bool -> Bool
       | _ -> raise (Failure ("illegal unary operator " ^ 
                              string_of_uop op ^ string_of_typ t ^
                              " in " ^ string_of_expr ex))
       in (ty, SUnop(op, (t, e')))
    | Binop(e1, op, e2) as e -> 
       let (t1, e1') = expr e1 
       and (t2, e2') = expr e2 in
       (* All binary operators require operands of the same type *)
       let same = t1 = t2 in
       (* Determine expression type based on operator and operand types *)
       let ty = match op with
         Plus | Minus | Times | Divide when same && t1 = Int   -> Int
       | Eq | Neq            when same               -> Bool
       | Lt | Lteq | Gt | Gteq
                  when same && (t1 = Int ) -> Bool
       | And | Or when same && t1 = Bool -> Bool
       | _ -> raise (
 	  Failure ("illegal binary operator " ^
                    string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                    string_of_typ t2 ^ " in " ^ string_of_expr e))
       in (ty, SBinop((t1, e1'), op, (t2, e2')))
    | Call(fname, args) as call -> 
        let fd = find_func fname in
        let param_length = List.length fd.formals in
        if List.length args != param_length then
            raise (Failure ("expecting " ^ string_of_int param_length ^ 
                            " arguments in " ^ string_of_expr call))
        else let check_call (ft, _ , _) e = 
            let (et, e') = expr e in
            let err = "illegal argument found " ^ string_of_typ et ^
                    " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
        in 
        let args' = List.map2 check_call fd.formals args
        in (fd.typ, SCall(fname, args'))
  in

  let check_bool_expr e = 
    let (t', e') = expr e
    and err = "expected Boolean expression in " ^ string_of_expr e
    in if t' != Bool then raise (Failure err) else (t', e') 
  in

  let check_array id  = 
    let t = type_of_identifier id in
    match t with
    Array(t1, t2)  -> (t1, t2)
    | _ -> raise (Failure ( id ^ " is not of type array" ))
  in 

  let check_array_type (t1, t2) =
    if ((t1 = Int || t1 = String) && (t2 = Int || t2 = String) ) then true else false
  in
(*
  let rec check_stmt_list (stmts, lvs) = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (stmts, lvs) (sl @ ss) (* Flatten blocks *)
            | Block sl :: ss  -> let sl' = check_stmt_list (stmts, lvs) sl in sl' @ (check_stmt_list (stmts, lvs) ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
  in*)
  (*    | For(t1, id1, id2, st) ->
	        (SFor(t1, id1, id2, check_stmt st), lvs)*)

       (* Expr e -> (SExpr(expr e) :: stmts, lvs)*)
(*      | If(p, b1, b2) -> (SIf(check_bool_expr p, check_stmt b1, check_stmt b2) :: stmts. lvs)*)
(*      | While(p, s) -> (SWhile(check_bool_expr p, check_stmt s), lvs)*)
	    (* A block is correct if each statement is correct and nothing
	       follows any Return statement.  Nested blocks are flattened. *)
      (*| Block sl ->  SBlock(check_stmt_list sl)*)
(*      | Open (s1, s2) -> (SOpen(s1, s2), lvs)*)
let rec check_stmt envs = function
      Expr e -> let x = envs.stmts in envs{stmts = SExpr(expr e) :: x}
      | Block sl -> let e' = List.fold_left check_stmt env sl in envs{stmts = e'.stmts}
      | If(p, b1, b2) -> let env1 = check_stmt envs{stmts = []} b1 in let env2 = check_stmt envs{stmts = []} b2 in envs{stmts = SIf(check_bool_expr p, SBlock(env1.stmts), SBlock(env2.stmts)) :: stmts}
      | For(t1, id1, id2, st) -> let env1 = check_stmt envs{stmts = []} st in envs{stmts = SFor(t1, id1, id2, SBlock(env1.stmts)) :: envs.stmts}
      | While(p, s) -> let env1 = check_stmt envs{stmts = []} s in envs{stmts = SWhile(check_bool_expr p, SBlock(env1.stmts)) :: envs.stmts}
      | Return e -> let (t, e') = expr e in
        if t = func.typ then envs{stmts = SReturn(t, e') :: envs.stmts}
        else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_expr e))
      | Break -> envs{stmts = SBreak :: envs.stmts}
      | Open (s1, s2) -> envs{stmts = SOpen(s1, s2) :: envs.stmts}
      | Map(id, f1) -> 
        let fd = find_func f1 in
        let param_length = List.length fd.formals in
        if 1 != param_length then
            raise (Failure ("expecting " ^ "1" ^ 
                        " arguments in " ^ "usage of map"))
        else 
            let t1 = fd.typ
            and (t2, _, _) = List.hd fd.formals
            and (_, t3) = check_array id in
            if t1 = t2 && t2 = t3 then envs{stmts = SMap(id, f1) :: envs.stmts}
            else raise (Failure (" Map called with out matching types ") )
      | Filter(id, f1) -> 
        let fd = find_func f1 in
        let param_length = List.length fd.formals in
        if 1 != param_length then
          raise (Failure ("expecting " ^ "1" ^ 
                        " arguments in " ^ "usage of map"))
        else
            let t1 = fd.typ in
            let m2 = function
            Bool -> let (t2, _, _) = List.hd fd.formals
                    and (_, t3) = check_array id in
                    if (t2 = t3) then envs{stmts = SFilter(id, f1) :: envs.stmts}
                    else raise (Failure (" Map called with out matching types ") ) 
            | _ -> raise (Failure (" Function must return Bool to be applied with Filter"))
            in m2 t1
      | Array_Assign(id, e1, e2) -> 
        let (t1, t2) = check_array id 
        and (rt1, e1') = expr e1
        and (rt2, e2') = expr e2 in
        if ((rt1 = t1) && (rt2 = t2)) then envs{stmts = SArray_Assign(id, (rt1, e1'), (rt2, e2')) :: envs.stmts}
        else raise (Failure (" Improper types for Array Assign"))
      | Assign(var, e) as ex -> 
        let lt = type_of_identifier var
        and (rt, e') = expr e in
        let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
          string_of_typ rt ^ " in " ^  string_of_stmt ex
        in check_assign lt rt err; envs{stmts = SAssign(var, (rt, e')) :: envs.stmts}
      | Vdecl(t, id, e) -> 
          let f = function
          Noexpr -> 
            let f2 = function
              Some t -> raise (Failure ("trying to redeclare variable"))
              | None -> 
                let f3 = function
                  Array(t1, t2) -> 
                    if (check_array_type (t1, t2)) then let lvs' = StringMap.add id t envs.lvs in  
                    envs{stmts = SVdecl(t, id, e) :: e.stmts, lvs = lvs'}
                    else raise(Failure("array key must be int or string"))
                  | _ ->  let lvs' = StringMap.add id t symbols in envs{stmts = SVdecl(t, id, e) :: e.stmts, lvs = lvs'}
                in f3 t
            in f2 (StringMap.find_opt id lvs)
          | _ -> 
              let f4 = function
              Some t -> raise (Failure ("trying to redeclare variable"))
              | None -> 
                  let f5 = function
                    Array(_, _) -> raise (Failure("cant assign and declare array"))
                    | _ -> let lvs' = StringMap.add id t envs.lvs; print_string("past"); 
                      let (rt, e') = expr e in envs{stmts = SVdecl(t, id, e) :: envs.stmts, lvs = lvs'}
                  in f5 t
              in f4 (StringMap.find_opt id envs.lvs)
          in f e

in (* body of check_function *) 
    { styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
(*      sbody = match check_stmt (Block func.body) with*) 
      sbody = let env = {stmts = []; lvs = StringMap.empty} in let e' = List.fold_left check_stmt env (Block func.body) in SBlock(e'.stmts) 
    }
in
(* next line will eventually become final line of semant *)
List.map check_function fdec;

