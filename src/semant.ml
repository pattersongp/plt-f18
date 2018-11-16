open Ast
open Sast

module StringMap = Map.Make(String)

let check fdec = 

  (* note, bind is a triple of typ, string and expr *)
  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	(Void, b, c) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
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
  

  let rec expr = function
      Literal l -> (Int, SLiteral l)
    | BoolLit l -> (Bool, SBoolLit l)
    | StringLit l -> (String, SStringLit l)
    | Id s -> (type_of_identifier s, SId s)
(*PLACEHOLDER entire line*) in print_string "testing" in
   (* | Unop(op, e) as ex -> 
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
         Add | Sub | Mult | Div when same && t1 = Int   -> Int
       | Equal | Neq            when same               -> Bool
       | Less | Leq | Greater | Geq
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
            else let check_call (ft, _) e = 
                let (et, e') = expr e in 
                let err = "illegal argument found " ^ string_of_typ et ^
                " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
          in 
          let args' = List.map2 check_call fd.formals args
          in (fd.typ, SCall(fname, args'))
*)  
 
(* next line will eventually become final line of semant *)
List.map check_function fdec;


print_string "fucking work\n"
