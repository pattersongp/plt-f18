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

let string_of_program (vars, funcs) = "Hello from the AST"
