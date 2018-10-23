(* Abstract Syntax Tree *)

(* NOT YET IMPLEMENTED *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or  | Req

type uop = Neg | Not

type typ = Int | Bool | Void | String | Array | Function | File | Regx

type bind = typ * string

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
  | Noexpr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | While of expr * stmt
  | For of string * string * stmt
  | Map of string * string
  | Filter of string * string

  (* How do we represent no expr here? *)

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

