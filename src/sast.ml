(* semantically-validated AST. generated by semant.ml, sent to codegen *)

open Ast

type sexpr = typ * sx
and sx =
    SLiteral of int
  | SBoolLit of bool
  | SStringLit of string
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SInitArray of typ * typ
  | SRetrieve of string * sexpr
  | SArray_Assign of string * sexpr * sexpr
  | SMap of string * string
  | SFilter of string * string
  | SCall of string * sexpr list
  | SRegexComp of sexpr * sexpr
  | SStrCat of sexpr * sexpr
  | SOpen of sexpr * sexpr
  | SReadFile of string
  | SWriteFile of string * sexpr
  | SRegexGrab of string * sexpr
  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SWhile of sexpr * sstmt
  | SFor of typ * string * string * sstmt
  | SVdecl of typ * string * sexpr
  | SAssign of string * sexpr
  | SBreak

type sfunc_decl = {
    styp : typ;
    sfname : string;
    sformals : bind list;
    sbody : sstmt list;
}

type sprogram = sfunc_decl list

(* pretty printer *)
let rec string_of_sexpr (t, e) =
  "( " ^ string_of_typ t ^ " : " ^ (match e with
    SLiteral(l) -> string_of_int l
  | SStringLit(s) -> s
  | SBoolLit(true) -> "true"
  | SBoolLit(false) -> "false"
  | SStrCat(e1, e2) -> string_of_sexpr e1 ^ " ^ " ^ string_of_sexpr e2
  | SRegexComp(e1, e2) -> string_of_sexpr e1 ^ "===" ^ string_of_sexpr e2
  | SRegexGrab(id, e2) -> id ^ ".grab(" ^ string_of_sexpr e2 ^ ");"
  | SReadFile(id) -> id ^ ".read();\n"
  | SWriteFile(id, e) -> id ^ ".write(" ^ string_of_sexpr e ^ ");\n"
  | SInitArray(t1, t2) -> "init(" ^ string_of_typ t1 ^ " " ^ string_of_typ t2 ^ ");\n"
  | SId(s) -> s
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SRetrieve(id, e1) -> id ^ "[" ^ string_of_sexpr e1 ^ "]"
  | SArray_Assign(id, e1, e2) -> id ^ "[" ^ string_of_sexpr e1 ^
                "]" ^ " = " ^ string_of_sexpr e2
  | SMap(a1, f1) -> "map(" ^ a1 ^ ", " ^ f1 ^ ");\n"
  | SFilter(a1, f1) -> "filter(" ^ a1 ^ ", " ^ f1 ^ ");\n"
  | SOpen(filename, delim) -> "open(" ^ string_of_sexpr filename ^ ", "
    ^ string_of_sexpr delim ^ ");"
  | SNoexpr -> ""
                ) ^ ")"

let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s, SBlock([])) ->
      "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s
  | SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SFor(typ, id1, id2, s) ->
      "for (" ^ string_of_typ typ ^ id1  ^ " : " ^ id2 ^ ")" ^ string_of_sstmt s
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s
  | SBreak -> "break;"
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  | SVdecl(t, id, e) -> string_of_typ t ^ " " ^ id ^ " = "^ string_of_sexpr e ^ ";\n"


let string_of_sfdecl fdecl =
"func " ^ string_of_typ fdecl.styp ^ " " ^ fdecl.sfname ^ " = " ^ "(" ^
        String.concat ", " (List.map string_of_formal fdecl.sformals) ^
        ") => {\n" ^
        "\n" ^ String.concat "\n" (List.map string_of_sstmt fdecl.sbody) ^ "\n}\n"

let string_of_sprogram (funcs) =
        String.concat "\n" (List.map string_of_sfdecl funcs)
