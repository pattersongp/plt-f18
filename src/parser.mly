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
%token FATARROW FILTER MAP OPEN
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
   /* nothing */ { [] }
 | decls fdecl { $2 :: $1 }

fdecl:
   FUNCTION typ ID ASSN LPAREN formals_opt RPAREN FATARROW LBRACE stmt_list RBRACE
     { { typ = $2;
	 fname = $3;
	 formals = $6;
	 body = List.rev $10 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { List.rev $1 }

formal_list:
    typ ID                   { [($1,$2, Noexpr)] }
  | formal_list COMMA typ ID { ($3,$4, Noexpr) :: $1 }

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

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }
  | RETURN SEMI { Return Noexpr }
  | BREAK SEMI { Break }
  | OPEN LPAREN STRING_LIT COMMA STRING_LIT RPAREN { Open($3, $5) }
  | RETURN expr SEMI { Return $2 }
  | LBRACE stmt_list RBRACE { Block(List.rev $2) }
  | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
  | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
  | FOR LPAREN typ ID COLON ID RPAREN stmt
        { For($3, $4, $6, $8) }
  | MAP LPAREN ID COMMA ID RPAREN SEMI { Map($3, $5)  }
  | FILTER LPAREN ID COMMA ID RPAREN SEMI { Filter($3, $5)  }
  | WHILE LPAREN expr RPAREN stmt { While($3, $5) }
  | ID ASSN expr SEMI { Assign($1, $3) }
  | typ ID ASSN expr SEMI { Vdecl($1, $2, $4) }
  | typ ID SEMI { Vdecl($1, $2, Noexpr) }
  | ID LBRACKET expr RBRACKET ASSN expr SEMI {Array_Assign($1, $3, $6)}

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
  | expr AND    expr { Binop($1, And,   $3) }
  | expr OR     expr { Binop($1, Or,    $3) }
  | expr REQ    expr { RegexComp($1, $3) }
  | MINUS expr %prec NEG { Unop(Neg, $2) }
  | NOT expr         { Unop(Not, $2) }
  | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
  | LPAREN expr RPAREN { $2 } /* this is for grouped expressions */
  | ID LBRACKET expr RBRACKET { Retrieve($1, $3)}

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }

