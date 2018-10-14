%{ open Ast %}

%token SEMI LPAREN RPAREN LBRACE RBRACE     /* Grouping */
%token PLUS MINUS TIMES DIVIDE ASSN         /* Arithmetic Operators */
%token EQ NEQ LT LTEQ GT GTEQ OR AND NOT    /* Logical Operators */
%token IF ELIF ELSE WHILE RETURN BREAK FOR
%token LBRACKET RBRACKET CONCAT COLON
%token REGX INT FUNCTION STRING VOID ARRAY
%token FATARROW FILTER MAP PRINT

%token <int> INT
%token <string> ID
%token EOF

%nonassoc NOELSE
%nonassoc ELSE
%left SEMI
%right ASSN
%left OR
%left AND
%left EQ NEQ
%left LT GT LTEQ GTEQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT

%start program
%type < Ast.program> program

%%

program:
        decls EOF { $1 }

decls:
        /*nothing*/   { [] }
        | decls vdecl {($2 :: fst $1), snd $1}
        | decls fdecl {fst $1, ($2 :: snd $1)}

vdecl:
        typ ID assign_opt SEMI { ($1, $2, $3) }

assign_opt:
        /*nothing*/ { Noexpr }
        | ASSN expr { $2 }

typ:
          INT    { Int    }
        | STRING { String }
        | ARRAY  { Array  }
        | VOID   { Void   }

stmt:
    | expr SEMI { Expr $1 }
    | RETURN expr SEMI { Return($2) }
    | LBRACE stmt_list RBRACE { Block(List.rev $2) }
    | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
    | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
    | IF LPAREN expr RPAREN stmt ELIF elif    { (* Not sure how to parse *) }
    | FOR LPAREN typ ID IN ARRAY RPAREN stmt
        { For($3, $5, $7, $9) }
    | WHILE LPAREN expr RPAREN stmt { While($3, $5) }

elif:
      IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
    | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }

expr:
      STRING_L          { String_Lit(quote_remover($1)) }
    | LBRACK kvps_f RBRACK { Array_F_Lit($2) }
    | LBRACK kvps_s RBRACK { Array_S_Lit($2) }
    | ID               { Id($1) }
    | expr PLUS   expr { Binop($1, Add,   $3) }
    | expr MINUS  expr { Binop($1, Sub,   $3) }
    | expr TIMES  expr { Binop($1, Mult,  $3) }
    | expr DIVIDE expr { Binop($1, Div,   $3) }
    | expr EQ     expr { Binop($1, Equal, $3) }
    | expr NEQ    expr { Binop($1, Neq,   $3) }
    | expr LT     expr { Binop($1, Less,  $3) }
    | expr LTEQ    expr { Binop($1, Leq,   $3) }
    | expr GT     expr { Binop($1, Greater, $3) }
    | expr GTEQ    expr { Binop($1, Geq,   $3) }
    | expr AND    expr { Binop($1, And,   $3) }
    | expr OR     expr { Binop($1, Or,    $3) }
    | NOT expr         { Unop(Not, $2) }
    | ID ASSIGN expr   { Assign($1, $3) }
    | ID LPAREN actuals_opt RPAREN { Call($1, $3) }
    | LPAREN expr RPAREN { $2 }
    | ID LBRACK expr RBRACK { Retrieve($1, $3)}
    | ID LBRACK expr RBRACK ASSIGN expr {Array_Assign($1, $3, $6)}
