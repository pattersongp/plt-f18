type token =
  | SEMI
  | LPAREN
  | RPAREN
  | LBRACE
  | RBRACE
  | COMMA
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | ASSN
  | EQ
  | NEQ
  | LT
  | LTEQ
  | GT
  | GTEQ
  | REQ
  | OR
  | AND
  | NOT
  | TRUE
  | FALSE
  | IF
  | ELSE
  | WHILE
  | RETURN
  | BREAK
  | FOR
  | IN
  | LBRACKET
  | RBRACKET
  | CONCAT
  | COLON
  | REGX
  | INT
  | FUNCTION
  | STRING
  | VOID
  | ARRAY
  | BOOL
  | FILE
  | FATARROW
  | FILTER
  | MAP
  | PRINT
  | OPEN
  | READ
  | WRITE
  | WRITEREAD
  | INT_LIT of (int)
  | ID of (string)
  | STRING_LIT of (string)
  | EOF

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
