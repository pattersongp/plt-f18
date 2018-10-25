(* Abstract Syntax Tree *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or  | Req

type uop = Neg | Not

type typ = Int | Bool | Void | String | Array | Function | File | Regx

type expr =
    Literal of int
  | BoolLit of bool
  | StringLit of string
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Retrieve of string * expr
  | Array_Assign of string * expr * expr
  | Call of string * expr list

type bind = typ * string * expr option

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr option
  | If of expr * stmt * stmt
  | While of expr * stmt
  | For of string * string * stmt
  | Map of string * string
  | Filter of string * string
  | Break

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

let string_of_typ = function
        Int -> "int"
        | String -> "str"
        | Bool -> "bool"
        | Array -> "array"
        | Void -> "void"
        | Function -> "func"
        | Regx -> "regx"
        | File -> "file"

let string_of_expr = function
          Some Literal(l) -> " = " ^ string_of_int l
        | Some Id(i) -> i
        | Some BoolLit(true) -> " = " ^ "true"
        | Some BoolLit(false) -> " = " ^ "false"
        | Some StringLit(s) -> " = " ^ s

let string_of_opt_assn = function
        None -> ""
        | _ as exp -> string_of_expr exp

let string_of_vdecl (t, id, assn) =
        string_of_typ t ^ " " ^ id ^ (string_of_opt_assn assn) ^ ";\n"

let string_of_program (vars, _) =
        String.concat "" (List.map string_of_vdecl vars)
