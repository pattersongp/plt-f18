(* Abstract Syntax Tree *)

type op = Plus | Minus | Times | Divide | Eq | Neq | Lt | Lteq | Gt | Gteq |
          And | Or

type uop = Neg | Not

type typ =
          Int | Bool | Void | String | Array of typ * typ
        | Function | File | Regx

type expr =
    Literal of int
  | BoolLit of bool
  | StringLit of string
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | InitArray of typ * typ
  | Retrieve of string * expr
  | Array_Assign of string * expr * expr
  | Call of string * expr list
  | RegexComp of expr * expr
  | StrCat of expr * expr
  | Open of expr * expr
  | ReadFile of string
  | Noexpr

type bind = typ * string * expr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | While of expr * stmt
  | For of typ * string * string * stmt
  | Map of string * string
  | Filter of string * string
  | Vdecl of typ * string * expr
  | Assign of string * expr
  | Break

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    body : stmt list;
  }

type program = func_decl list

let string_of_uop = function
          Neg -> "-"
        | Not -> "!"

let rec string_of_typ = function
          Int -> "int"
        | String -> "str"
        | Bool -> "bool"
        | Array(t1, t2) -> "array" ^ "[" ^ string_of_typ t1 ^ ", " ^
                string_of_typ t2 ^ "]"
        | Void -> "void"
        | Function -> "func"
        | Regx -> "regx"
        | File -> "file"

let string_of_op = function
          Plus  -> "+"
        | Minus -> "-"
        | Times -> "*"
        | Divide-> "/"
        | Eq    -> "=="
        | Neq   -> "!="
        | Lt    -> "<"
        | Lteq  -> "<="
        | Gt    -> ">"
        | Gteq  -> ">="
        | And   -> "&&"
        | Or    -> "||"

let rec string_of_expr = function
          Noexpr -> ""
        |  Literal(l) -> string_of_int l
        |  Id(i) -> i
        |  Unop(op, e1) -> string_of_uop op ^ string_of_expr e1
        |  StrCat(e1, e2) -> string_of_expr e1 ^ " ^ " ^ string_of_expr e2
        |  RegexComp(e1, e2) -> string_of_expr e1 ^ "===" ^ string_of_expr e2
        |  ReadFile(id) -> id ^ ".read();\n"
        |  BoolLit(true) -> "true"
        |  BoolLit(false) -> "false"
        |  StringLit(s) ->  s
        |  Binop(e1, op, e2) -> string_of_expr ( e1) ^ " " ^
                string_of_op op ^ " " ^ string_of_expr ( e2)
        | Array_Assign(id, e1, e2) -> id ^ "[" ^ string_of_expr ( e1) ^
                "]" ^ " = " ^ string_of_expr ( e2)
        |  Retrieve(id, e1) -> id ^ "[" ^ string_of_expr ( e1) ^ "]"
        |  Open(filename, delim) -> "open(" ^ string_of_expr filename ^ ", " ^ string_of_expr delim ^ ");\n"
        |  Call(id, act) -> id ^ "(" ^
                String.concat ", "(List.map string_of_expr act) ^ ")"

let string_of_opt_assn = function
        Noexpr -> ""
        | _ as exp -> " = " ^ string_of_expr exp

let string_of_vdecl (t, id, assn) =
        string_of_typ t ^ " " ^ id ^ (string_of_opt_assn assn) ^ ";\n"

let string_of_formal (typ, id, _) =
        string_of_typ typ ^ " " ^ id

let rec string_of_stmt = function
          Expr(e1) -> string_of_expr ( e1) ^ ";"
        | Return(Noexpr) -> "return;"
        | Return(e1) -> "return " ^ string_of_expr e1 ^ ";"
        | Break -> "break;"
        | Block(stmts) ->  "{\n" ^
                String.concat "\n" (List.map string_of_stmt stmts) ^ "\n}\n"
        | If(e1, s1, Block([])) -> "if (" ^ string_of_expr ( e1) ^ ")\n" ^
                string_of_stmt s1
        | If(e1, s1, s2) -> "if (" ^ string_of_expr ( e1) ^ ")\n" ^
                string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
        | For(typ, id1, id2, s1) -> "for (" ^ string_of_typ typ ^ id1 ^ " : " ^
                id2 ^ ")" ^ string_of_stmt s1
        | While(e1, s1) -> "while (" ^ string_of_expr ( e1) ^ ") " ^
                string_of_stmt s1
        | Map(a1, f1) -> "map(" ^ a1 ^ ", " ^ f1 ^ ");\n"
        | Filter(a1, f1) -> "filter(" ^ a1 ^ ", " ^ f1 ^ ");\n"
        | Assign(id, e1) ->  id ^ " = " ^ string_of_expr ( e1)
        | Vdecl(t, id, e) -> string_of_vdecl (t, id, e)


let string_of_fdecl fdecl =
        "func " ^ string_of_typ fdecl.typ ^ " " ^ fdecl.fname ^ " = " ^ "(" ^
        String.concat ", " (List.map string_of_formal fdecl.formals) ^
        ") => {\n" ^
        "\n" ^ String.concat "\n" (List.map string_of_stmt fdecl.body) ^ "\n}\n"

let string_of_program (funcs) =
        String.concat "\n" (List.map string_of_fdecl funcs)

