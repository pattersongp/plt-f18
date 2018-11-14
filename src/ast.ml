(* Abstract Syntax Tree *)

type op = Plus | Minus | Times | Divide | Eq | Neq | Lt | Lteq | Gt | Gteq |
          And | Or  | Req

type uop = Neg | Not

type mode = Read | Write | WriteRead

type typ =
          Int | Bool | Void | String | Array of typ * typ
        | Function | File of mode | Regx

type expr =
    Literal of int
  | BoolLit of bool
  | StringLit of string
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Retrieve of string * expr
  | Call of string * expr option list

type bind = typ * string * expr option

type stmt =
    Block of stmt list
  | Expr of expr
  | Assign of string * expr
  | Array_Assign of string * expr * expr
  | Return of expr option
  | If of expr * stmt * stmt
  | While of expr * stmt
  | For of typ * string * string * stmt
  | Map of string * string
  | Filter of string * string
  | Open of string * string
  | Vdecl of typ * string
  | Break

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type program = bind list * func_decl list

let string_of_uop = function
          Neg -> "-"
        | Not -> "!"

let string_of_mode = function
          Read -> "r"
        | Write -> "w"
        | WriteRead -> "wr"

let rec string_of_typ = function
          Int -> "int"
        | String -> "str"
        | Bool -> "bool"
        | Array(t1, t2) -> "array" ^ "[" ^ string_of_typ t1 ^ ", " ^
                string_of_typ t2 ^ "]"
        | Void -> "void"
        | Function -> "func"
        | Regx -> "regx"
        | File(mode) -> "file[" ^ string_of_mode mode ^ "]"

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
        | Req   -> "==="
        | And   -> "&&"
        | Or    -> "||"

let rec string_of_expr = function
          None -> ""
        | Some Literal(l) -> string_of_int l
        | Some Id(i) -> i
        | Some Unop(op, e1) -> string_of_uop op ^ string_of_expr (Some e1)
        | Some BoolLit(true) -> "true"
        | Some BoolLit(false) -> "false"
        | Some StringLit(s) ->  s
        | Some Assign(id, e1) ->  id ^ " = " ^ string_of_expr (Some e1)
        | Some Binop(e1, op, e2) -> string_of_expr (Some e1) ^ " " ^
                string_of_op op ^ " " ^ string_of_expr (Some e2)
        | Some Retrieve(id, e1) -> id ^ "[" ^ string_of_expr (Some e1) ^ "]"
        | Some Call(id, act) -> id ^ "(" ^
                String.concat ", "(List.map string_of_expr act) ^ ")"
        | Some Array_Assign(id, e1, e2) -> id ^ "[" ^ string_of_expr (Some e1) ^
                "]" ^ " = " ^ string_of_expr (Some e2)

let string_of_opt_assn = function
        None -> ""
        | _ as exp -> " = " ^ string_of_expr exp

let string_of_formal (typ, id, _) =
        string_of_typ typ ^ " " ^ id

let rec string_of_stmt = function
          Expr(e1) -> string_of_expr (Some e1) ^ ";"
        | Return(None) -> "return;"
        | Return(e1) -> "return " ^ string_of_expr e1 ^ ";"
        | Break -> "break;"
        | Block(stmts) ->  "{\n" ^
                String.concat "\n" (List.map string_of_stmt stmts) ^ "\n}\n"
        | If(e1, s1, Block([])) -> "if (" ^ string_of_expr (Some e1) ^ ")\n" ^
                string_of_stmt s1
        | If(e1, s1, s2) -> "if (" ^ string_of_expr (Some e1) ^ ")\n" ^
                string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
        | For(typ, id1, id2, s1) -> "for (" ^ string_of_typ typ ^ id1 ^ " : " ^
                id2 ^ ")" ^ string_of_stmt s1
        | While(e1, s1) -> "while (" ^ string_of_expr (Some e1) ^ ") " ^
                string_of_stmt s1
        | Map(a1, f1) -> "map(" ^ a1 ^ ", " ^ f1 ^ ");\n"
        | Filter(a1, f1) -> "filter(" ^ a1 ^ ", " ^ f1 ^ ");\n"
        | Open(filename, delim) -> "open(" ^ filename ^ ", " ^ delim ^ ");\n"

let string_of_vdecl (t, id, assn) =
        string_of_typ t ^ " " ^ id ^ (string_of_opt_assn assn) ^ ";\n"

let string_of_fdecl fdecl =
        "func " ^ string_of_typ fdecl.typ ^ " " ^ fdecl.fname ^ " = " ^ "(" ^
        String.concat ", " (List.map string_of_formal fdecl.formals) ^
        ") => {\n" ^ String.concat "" (List.map string_of_vdecl fdecl.locals) ^
        "\n" ^ String.concat "\n" (List.map string_of_stmt fdecl.body) ^ "\n}\n"

let string_of_program (vars, funcs) =
        String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
        String.concat "\n" (List.map string_of_fdecl funcs)

