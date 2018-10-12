{ open Parser }

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf }
| '=' { ASSN }
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
| ">="     { GTEQ }
| "<="     { LT }
| "=>"     { FATARROW }
| "/*"     { comment lexbuf }
| "||"     { OR }
| "&&"     { AND }
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
| "func"   { FUNCTION }
| "int"    { INT }
| "string" { STRING }

| ['0'-'9']+ as lit { LITERAL(int_of_string lit) }
| ['a'-'z']+ as id { VARIABLE(id) }
| eof { EOF }

and comment = parse
 "*/" { token lexbuf }
| _ { comment lexbuf }
