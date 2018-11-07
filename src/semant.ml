open Ast

module StringMap = Map.Make(String)

let check (vdec,fdec) = 

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

(* check variable declarations *)
check_binds "variable declarations" vdec;

(* begin checking functions *)

(* function declaration for built-in FIRE functions - print, map, filter *)
(* re-write for FIRE bind type? *)
let built_in_func_decls = 
    let add_bind map (name, typ, expr) = StringMap.add name {
        (* object between brackets is func_decl object? *)
        typ = Void; (* all built in functions are of type void *)
        fname = name;
        formals = [(typ, "x", 0)]; 
        locals = []; (* empty list *)
        body = []; (* empty list *)
    } map 
    (* REVISE following line !!!*)
    in List.fold_left add_bind StringMap.empty [("print", String, 0); ("map", Void, 0); ("filter", Void, 0)]
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

(* dud statement to resolve let...in express *)
in print_string function_decls;