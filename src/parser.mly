%{ open Ast %}

%token SEMI
%token PLUS MINUS TIMES DIVIDE EOF ASSN
%token <int> LITERAL
%token <string> VARIABLE

%left SEMI
%right ASSN
%left PLUS MINUS
%left TIMES DIVIDE

%start expr
%type < Ast.expr> expr

%%

expr:
  VARIABLE            { Variable($1)       }
| LITERAL             { Lit($1)            }
| expr SEMI   expr    { Seq($1, $3)        }
| expr PLUS   expr    { Binop($1, Add, $3) }
| VARIABLE ASSN expr  { Asn($1, $3)        }
| expr MINUS  expr    { Binop($1, Sub, $3) }
| expr TIMES  expr    { Binop($1, Mul, $3) }
| expr DIVIDE expr    { Binop($1, Div, $3) }
