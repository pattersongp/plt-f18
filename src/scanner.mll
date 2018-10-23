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
| "==="    { REQ }
| "!="     { NEQ }
| ">="     { GTEQ }
| "<="     { LTEQ }
| "=>"     { FATARROW }
| "/*"     { comment lexbuf }
| "||"     { OR }
| "&&"     { AND }
| "true"   { TRUE }
| "false"  { FALSE }
| "if"     { IF }
| "print"  { PRINT }
| "else"   { ELSE }
| "for"    { FOR }
| "map"    { MAP }
| "filter" { FILTER }
| "while"  { WHILE }
| "return" { RETURN }
| "break"  { BREAK }
| "array"  { ARRAY }
| "void"   { VOID }
| "file"   { FILE }
| "func"   { FUNCTION }
| "int"    { INT }
| "bool"    { BOOL }
| "string" { STRING }
| ['0'-'9']+ as lit { INT_LIT(int_of_string lit) }
| ['a'-'z']+ as id { ID(id) }
| eof { EOF }

and comment = parse
 "*/" { token lexbuf }
| _ { comment lexbuf }
