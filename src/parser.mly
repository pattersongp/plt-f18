/* FIRE PARSER */

%{
open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA                      /* Grouping */
%token PLUS MINUS TIMES DIVIDE ASSN                    /* Arithmetic Operators */
%token EQ NEQ LT LTEQ GT GTEQ REQ OR AND NOT TRUE FALSE   /* Logical Operators */
%token IF ELSE WHILE RETURN BREAK FOR IN
%token LBRACKET RBRACKET CONCAT COLON
%token REGX INT FUNCTION STRING VOID ARRAY BOOL FILE
%token FATARROW FILTER MAP PRINT OPEN
%token READ WRITE WRITEREAD

%token <int> INT_LIT
%token <string> ID
%token <string> STRING_LIT

%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%left SEMI
%right ASSN
%left OR
%left AND
%left EQ NEQ REQ
%left LT GT LTEQ GTEQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT NEG

%start program
%type <Ast.program> program

%%

program:
  decls EOF { $1 }

decls:
   /* nothing */ { [], [] }
 | decls vdecl { ($2 :: fst $1), snd $1 }
 | decls fdecl { fst $1, ($2 :: snd $1) }

fdecl:
   FUNCTION typ ID ASSN LPAREN formals_opt RPAREN FATARROW LBRACE vdecl_list stmt_list RBRACE SEMI
     { { typ = $2;
	 fname = $3;
	 formals = $6;
	 locals = List.rev $10;
	 body = List.rev $11 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2, None)] }
  | formal_list COMMA typ ID { ($3,$4, None) :: $1 }

typ:
          concrete_typ { $1 }
        | ARRAY LBRACKET concrete_typ COMMA typ RBRACKET { Array($3, $5) }

concrete_typ:
          INT       { Int    }
        | STRING    { String }
        | BOOL      { Bool }
        | VOID      { Void   }
        | FUNCTION  { Function   }
        | REGX      { Regx }
        | FILE LBRACKET mode RBRACKET { File($3) }

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
         typ ID assign_opt SEMI { ($1, $2, $3) }

assign_opt:
        /*nothing*/ { None }
        | ASSN expr { Some $2 }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }
  | RETURN SEMI { Return None }
  | BREAK SEMI { Break }
  | OPEN LPAREN STRING_LIT COMMA STRING_LIT RPAREN { Open($3, $5) }
  | RETURN expr SEMI { Return (Some $2) }
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN typ ID COLON ID RPAREN stmt
        { For($3, $4, $6, $8) }
  | MAP LPAREN ID COMMA ID RPAREN SEMI { Map($3, $5)  }
  | FILTER LPAREN ID COMMA ID RPAREN SEMI { Filter($3, $5)  }
  | WHILE LPAREN expr RPAREN stmt { While($3, $5) }

mode:
          READ { Read }
        | WRITE { Write }
        | WRITEREAD { WriteRead }

expr:
    INT_LIT          { Literal($1) }
  | STRING_LIT       { StringLit($1) }
  | TRUE             { BoolLit(true) }
  | FALSE            { BoolLit(false) }
  | ID               { Id($1) }
  | expr PLUS   expr { Binop($1, Plus,   $3) }
  | expr MINUS  expr { Binop($1, Minus,   $3) }
  | expr TIMES  expr { Binop($1, Times,  $3) }
  | expr DIVIDE expr { Binop($1, Divide,   $3) }
  | expr EQ     expr { Binop($1, Eq, $3) }
  | expr NEQ    expr { Binop($1, Neq,   $3) }
  | expr LT     expr { Binop($1, Lt,  $3) }
  | expr LTEQ   expr { Binop($1, Lteq,   $3) }
  | expr GT     expr { Binop($1, Gt, $3) }
  | expr GTEQ   expr { Binop($1, Gteq,   $3) }
  | expr REQ    expr { Binop($1, Req,   $3) }
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | MINUS expr %prec NEG { Unop(Neg, $2) }
  | NOT expr         { Unop(Not, $2) }
  | ID ASSN expr   { Assign($1, $3) }
  | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN { $2 } /* this is for grouped expressions */
  | ID LBRACKET expr RBRACKET { Retrieve($1, $3)}
  | ID LBRACKET expr RBRACKET ASSN expr {Array_Assign($1, $3, $6)}

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [Some $1] }
  | actuals_list COMMA expr { Some $3 :: $1 }

