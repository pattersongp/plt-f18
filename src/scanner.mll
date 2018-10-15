{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf }
| '=' { ASSN }
| ',' { COMMA }
| ';' { SEMI }
| '+' { PLUS }
| ':' { COLON }
| '-' { MINUS }
| '*' { TIMES }
| '/' { DIVIDE }
| '>' { GT }
| '<' { LT }
| '^' { CONCAT }
| '!' { NOT }
| '{' { LBRACE }
| '}' { RBRACE }
| '[' { LBRACKET }
| ']' { RBRACKET }
| '('      { LPAREN }
| ')'      { RPAREN }
| 'r'      { REGX }
| "=="     { EQ }
| "!="     { NEQ }
| ">="     { GTEQ }
| "<="     { LTEQ }
| "=>"     { FATARROW }
| "/*"     { comment lexbuf }
| "||"     { OR }
| "&&"     { AND }
| "true"     { TRUE }
| "false"     { FALSE }
| "if"     { IF }
| "print"  { PRINT }
| "else"   { ELSE }
| "elif"   { ELIF }
| "for"    { FOR }
| "map"    { MAP }
| "filter" { FILTER }
| "while"  { WHILE }
| "return" { RETURN }
| "break"  { BREAK }
| "array"  { ARRAY }
| "void"   { VOID }
| "func"   { FUNCTION }
| "int"    { INT }
| "bool"    { BOOL }
| "string" { STRING }
| ['0'-'9']+ as lit { LITERAL(int_of_string lit) }
| ['a'-'z']+ as id { VARIABLE(id) }
| eof { EOF }

and comment = parse
 "*/" { token lexbuf }
| _ { comment lexbuf }
