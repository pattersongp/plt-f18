# File Input Reinterpretation Engine - (FIRE) - Language Reference Manual


Graham Patterson (gpp2109)  
Frank Spano (fas2154)  
Ayer Chan (oc2237)  
Christopher Thomas (cpt2132)   
Jason Konikow (jk4057)  

## Table of contents

1. Introduction
2. Lexical Conventions
3. Syntax
4. Statements


## 1: Introduction

File Input Reinterpretation Engine (FIRE) is a scripting language inspired by AWK, bash, and other syntactically light languages. These languages are renowned for their ability to robustly extract, pattern-match, and manipulate text files. FIRE seeks to emulate this functionality with a more attractive, C-Family inspired syntax and intuitive semantics.

FIRE is intended to be utilized with large sets of delimited data, like `.csv` files. FIRE is also animated by the premise that files are first class citizens. 

FIRE is written in OCaml , utilizing libraries built in `C`, and leveraging the `LLVM` compiler back-end.

This manual describes in detail the lexical conventions, types, scoping rules, built-in functions, and grammar of the FIRE language.



## 2: Lexical Conventions 

### 2.1 Identifiers

An identifier is a token correlate to a single variable, a function, an array, or a file. Identifiers are a sequence of characters consisting of uppercase or lowercase letters, digits, underscores or dashes. They must starts with a character or an underscore, and is optionally followed by characters, numbers and underscores. The scope of an identifier can only be local and limited inside the braces `{ ... }` in which they are declared. The regular expression for identifiers is:

['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']



### 2.2 Keywords

FIRE has a set of identifiers that are restricted from use.

#### 2.2.1 Basic Types
FIRE was designed for efficiency. Basic types, integer and string, are most efficient for scripting files. They ensure and eliminates certain runtime decisions. Void data type is used for functions that do not return a value. `true` and `false` are two predefined constants for `bool`. A function declaration begins with the `func` keyword.

* `int` 
* `str`
* `bool`
* `void`
* `func`


#### 2.2.2 Control Flow 
The following keywords indicate keywords for control flow.

* `if` 
* `else`
* `while`
* `return`

#### 2.2.2 Built-in Functions
The following keywords are reserved for built-in functions.

* `print`
* `sprint`
* `map`
* `filter`
* `strlen`
* `len`
* `keys`
* `atoi`

#### 2.2.3 Advance Data Types
The following keywords are reserved for advance data types. 

* `array`
* `file`
* `regx`

### 2.3 Constants

FIRE supports integer, string and boolean literals, inside expressions. 


#### 2.3.1 Integer
Identifiers of type `int` represent positive integers. An `int` is a 32-bit integer, and consists of at least one digit. The following defines the regular expression of a decimal digit for `int`.

`digit = ['0' - '9']`

#### Example

`int num = 32;`

#### Example
`int` type can also be assigned to the result of expressions. 

`int a = 34 * 2 + (2 / 1);`

#### 2.3.2 String
Identifiers of type `str` are used to represent sequences of characters, strings. Strings can be declared in the following manner.

#### Example

`str myString = "Hello World";`

checkout the length of a string using: `strlen(<str>)`

Not all strings are in printable form. Some printable characters have conflicts with lexical conventions. They are
specially marked with a backslash. FIRE supports the following escape sequences.

`\n`
`\r`
`\t`
`\f`
`\b`
`\\`
`/`

To print out the raw forms of specially marked characters listed above, `\\` double backlash cancels escape sequences.

`\\\n`
`\\\r`
`\\\t`
`\\\f`
`\\\b`
`\\\\`
`\\/`

#### 2.3.3 Boolean
Boolean objects contain a value of either `true` or `false`. They can be declared on their own and are used in conditional statements. The structure of a boolean declaration is as follow.
#### Example
```
bool switch = true; // or false
```

#### Example

```
func void main = () => {
	int x = 0;
	bool switch = true;


	// infinite loop
	while(switch) {
		x = x + 1;
	}
}
```

### 2.4 Punctuation
FIRE supports primary expressions using the previously-mentioned identifiers. Primary expressions also include expressions inside parentheses. In addition, parentheses can indicate a list of arguments in a function declaration or a function call:

`f()` 

Blocks are indicated by braces. Braces imply blocks that makeup function bodies:

`{  \* This is a block *\  }`

Brackets indicate array types and access to array elements:

```
array[int, int]		//this is a data type
a[0] 			//access to element 0 in array arr
```

Strings and Regular Expressions are sequences of characters surrounded by double quotes `"`,:

` "This is a string or regx expression" `

Semicolon is used to separate statement:

`str b = "bee"; int c = 3;`

### 2.5 Advance Data Type

#### 2.5.1 File
Files are regarded as first-class citizens in FIRE. This is made apparent by the importance and centrality of files. A `file` type represents an existing file. This allows the programmer to more easily perform operations on the file. The syntax for instantiating a `file` object is as follows:

#### Syntax
```
file f = open("filename.csv", "<delimiter>");
```
#### Where
* two arguments are fed into `open(...)`
* `<filename>` for reading, writing or both on an existing file. 
* `<delimiter>` may be provided to the constructor specifying a delimiter for reading. The length of <delimiter> is expected to be exactly 1. An error will be thrown if a file does not exist.

#### Example
`file f; f.open("test.csv", ",");` will open the File named `test.csv` in the current directory for both reading and writing, and delimited by the `,` string.

#### Reading and Writing
`read()` function returns the whole text of a delimited file. `write()` function takes in a string and does not return anything. 

#### Syntax
The syntax for reading and writing a `file` is as follows
```
<file name>.read();
<file name>.write(<str>);
```

#### 2.5.2 Array
Arrays are dynamic sequence containers: they hold any number of elements ordered in a linear sequence. Inspired by AWK's associative arrays, an `array` collection maps keys of one type to values of one type. Keys and values do not have to be the same type, but all keys must share the same type and all values must share the same type. The structure of `array` variable declarations is as follows.

#### Syntax
```
array[<key_type>, <value_type>] arr;
```

#### Where
* `arr` is initialized without pointing to a value.
* `<key_type>` do not have to be of the same type as the `<value_type>` they correspond with - but all keys in an array must have the same type, and all values must be of the same type. 
* There are strict restrictions on the types a key can be and a value can be. Please consult the table below:

| Legal Key Types | Legal Value Types |
|-----------------|-------------------|
| int             | int               |
| str             | str               |
|                 | array             |

#### Example 
`array[str, str] arr;`

#### Assignment
The assignment of variables has the following syntax:

```
arr[<key_value>] = <element>;
```

#### Example

 `arr["myAge"] = "28";`
 
#### Retrieve
Retrieving an element of an array has the following syntax:
 ```
 int element = arr[<key_value>];
 ```

#### Example
 
 `int age = arr["myAge"];`
 
A key error will be thrown if `"myAge"` does not exist.

#### Arrays of Arrays
A multidimensional array in FIRE is an array of arrays, declared by using syntax like the following:
```
array[<key_type1>, array[<key_type2>, <value_type2>]] myArray;
```

#### Where
* `myArray` is initialized but not the anonymous `array[<type>, <type>]`. The anonymous array will not be initialized until assignment.
* arrays that assign to `myArray` must follow the type `array[<key_type2>, <value_type2>]`. 


#### Example
`array[str, array[int, str]] b;`
 
In this case, array b will be initialized but not array[int,str]. 
 
#### 2.5.3 Regular Expression
Regular expressions are supported in FIRE. Via the `regx` type, which assigns an object to a regular expression. That object can then be passed as a parameter to functions that utilize regular expressions to a pattern match or extract data.

#### Syntax
`regx myPattern = "<pattern>"`

#### Example
```
str s = "token";
regx r = "ok";
str ret = s.grab(r);	/* ret is 'ok' */
```
#### Example
The syntax for the regex patterns are as follows:

* `\` escapes any of the operators for the literal character
* `^` matches only the beginning of the string
* `$` matches only the end of the string
* `.` matches any single character
* `[ ... ]` defines a character list, where the character list can also be character range. This matches any string containing these characters
* `[^ ... ]` defines a character list, but negates them. This matches any string *not* containing these characters
* `|` matches either expression `e1` or `e2`
* `( ... )` groups expressions together where `...` is some regular expression
* `*` matches the preceding character 0 or many times
* `+` matches the preceding character at least once


### 2.4 Comments
FIRE only supports the use the block comments. Comments are initiated with the `/*` symbol and terminated by the `*/` symbol. Everything in between the symbols will be ignored by FIRE during compilation. A nested comment gets a parsing error. Comments have the following syntax:

 `/* This is a comment. */`

### 2.5 Value Binding
A single equal sign indicates assignment in an assignment or declaration statement: 
 `=`
 
### 2.6 Operators
FIRE supports the following binary operators:
```
+ - * /
== != 
> >= < <= 
&& ||
^
```

FIRE also supports the follow unary negations:

`!`


## 3: Syntax

### 3.1 Program Structure
A FIRE program will mainly consist of functions. The main=() function is the starting point of a FIRE program. FIRE does not support global variables, all variables must be initialized inside function bodies:
```
program:
	function declaration
	main function declaration
	function declaration
```

### 3.2 Variable Declarations  
Objects are instantiated via declarations, which explicitly assign a data type to a variable. In FIRE, a variable is only allowed to be declared locally anywhere within a function. Types are explicit in FIRE. The format of declarations are as follows:
```
{type} {variable name};
{type} {variable name} = {value};
```

### 3.3 Expressions

#### 3.3.1 Primary Expressions
The grammars of the two primitive literals are INT_LIT and STRING_LIT. 

#### 3.3.2 Function Calls
Functions take in arguments by value except in the case of other functions which are passed by reference. Functions, other than build-in functions, need to be assigned before being called, but FIRE does not support prototyping. The scope of a function is the top level.

#### 3.3.3 Logical Negation
FIRE provides `true` and `false` values. The logical negation operator `!` evaluates to the parity of the operand.

#### 3.3.4 AND Operator
The logical AND `&&` is a short circuit operator, and returns `true` if and only if the expressions on its left and right both evaluate to `true`, otherwise `false`.

#### 3.3.5 OR Operator
The logical OR `||` operator is a short circuit operator and returns `true` if either of the expressions on its left or right return `true`, otherwise `false`.

#### 3.3.6 Relational Operators
The relational operators `<, >, <=, <=, ==` return `true` if the expression on the left side of the operator has the expected relation to the operator on the right-hand side, otherwise `false`.

These relationships amongst ints are determined by natural ordering. Strings can only be evaluated using the `==` operator.

#### 3.3.7 String Concatenation Operator
The string concatenation `^` operator returns a new string that is the concatenation of the string on its left side and the string on its right side. `^` operator can concat multiple strings into a larger string. 

#### Example
```
str x = "hello";
str y = " world";
str z = x ^ y;
str a = x ^ y ^ y; // evaluates to 'hello world world'
```

#### 3.3.8 Bracket Operator
The bracket operator `[]` are operators on `array`. When `[]` is used on an `array`, it is supplied with a key and returns the corresponding element. Indexing a key using the bracket operator assigns an element to the corresponding key.

#### Example
where `arr` is a type of `[int,str]` array, `arr` can only accept integer keys and elements.

```
arry [int,str] arr;
arr[0] = "cat";
arr[1] = "dog";
arr[2] = "dog";
str animal = arr[0];
```




## 4:Statements 

### 4.1 Assignments

The assignment operators `=` returns the value of the expression that is evaluated on its right-hand side and stores it in the identifier on the left-hand side. The scope of that identifier is described in [section 2](#Identifiers)

### 4.2 Function Declaration
`func` objects reference functions and are treated as first class citizens. The structure of `func` variable declarations is as follows.

#### Syntax
```
func <return type> <name> = (<parameters>) => { <function body> };
```

#### Where
 * `<return type>` is the type returned by the function (NOTE: A function that does not return anything has a return type of `void`.  The void return type allows for programmers to create functions that are useful for their side effects)
 * `<name>` is the variable name of the function
 * `<parameters>` are the expected parameters for the function
 * `<function body>` is the body of the function

 

#### Parameterization
We originally aimed to provide parameterization, so that named functions can be passed to other functions as a parameter. However, this functionality is not implemented in FIRE at this point. Inspired by JavaScript, we wanted to be able to pass anonymous functions and also use functions as first class citizens as follows.
 
#### Example
```
func void saySomething = () => { print("something"); };
func void doSomething = (func f) => { f(); };
doSomething(saySomething);
```

#### Caveats

* FIRE does not support function overloading
* FIRE does not support genericity in functions


### 4.3 Blocks and Control Flow 

#### Block 
A block is defined inside curly braces, which can include a possibly-empty list of statements.

#### Conditional Statement 
A conditional statement is an if or if-else statement that takes an expression and evaluates to a
bool value. It only executes `<code block>` based on a `true` value. 

#### Syntax
```
if (<expression>) {
	<code block>
}
```
#### Syntax
```
if (<expression>) {
	<code block>
}
else {
	<code block>
}
``` 
		
#### Iteration Statement 
An iteration statement begins with the `while` keyword. The expressions must evaluate to a `bool` value. While statements execute a code block until its provided condition fails to be met:

#### Syntax
```
while(<condition>) {
	<code block>
}
```

#### Jump Statements 
The return statement takes an expression at the end of a function and exits out of that function

#### Syntax
```
func <return type> main = () => {
	return <expression>
}
```

#### Where
* `<expression>` the type of expression needs to meet the return type in function declaration.



### 4.3 Built-in Functions
#### 4.3.1 Map 
Strongly influenced by Python and OCaml, the map built-in function allows a programmer to apply a function to every element of an array and modifies values of that array.
 
#### Syntax
```
map(<array>,<function>);
```

#### Where
* `<function>` is the name of the function, no need to specify an argument. 
The return type of `<function>` must match the type of element in `<array>`. A function used in `map()` must take exactly 1 argument. 
* return type of `map` is `void` 

#### Example
```
func int f = (int i) => { return print(i); }
func void main = () => {
  array[str, int] arr;
  ...
  map(arr,f);		/* print all elements in array arr */
}
```

#### 4.3.2 Filter 
The filter function creates an array with elements for which a function returns true. It takes any function that returns a boolean and applies the function to each element of the array. This allows the filter to quickly generate a new array that consists of elements that match whatever member criteria your function tests for.

#### Syntax
```
filter(<array>,<function>);
```

#### Where
* `<function>` is the name of the function, no need to specify an argument. The return type of `<function>` must be a boolean.  Additionally, the only argument of `<function>` must be the type of the value in the array. `<function>` must take exactly 1 argument.   
* return type of `filter` is `void` 
* `<array>` is pointed to a new array after it gets filtered


#### Example
```
func bool f = (int i) => { ... }
...
array[str, int] a;
...
filter(a,f);
```
```
func bool f = (int i) => { return false; }
func void main = () => {
  array[str, int] arr;
  ...
  filter(arr,f);		/* arr is now an empty array */
}
```

### 4.4 Print & SPrint Statement
The print statement prints integers. To give more explicit typing constraints, print() can only print integers and sprint() can only print strings. The syntax and semantics of the print function are inspired by C. In C, the printf() function requires a format specifier inside printf(). To make it more explicit, FIRE intended to call a different printing function to print strings. 

#### Syntax
```
print(<int>);
sprint(<str>);
```
 
#### Example
```
print(10);
sprint("i will be printed to stdout");
```

### 4.6 Strlen
Like C, the strlen() function calculates the length of a given string. The function takes a single argument, a string variable, whose length is to be found, and returns the length of the string passed.

#### Syntax
```
strlen(<str>);
```

#### Example
```
strlen("FIRE");		/* "FIRE" is length of 4 */
```

### 4.7 Split
Inspired by Javascript's str.split() method, FIRE also supports splitting a string. split() function is used to split the given string into an array of strings by separating it into substrings using a specified separator provided in the argument. The syntax of the function is as follows.

#### Syntax
```
split(<str>, <delimiter>);
```

#### Arguments and Return value
The first argument is the string to be split. The second argument is a string, the delimiter, which specifies the points where the split has to take place. The delimiter string is expected to be a length of 1 and less than 1024
 
This function returns an array of strings, `array[int,str]`, that is formed after splitting the given string at each point where the separator occurs.
 
#### Example 
```
array arr [int, str];
arr = split("Hello$World", "$");		/* arr[0]=Hello, arr[1]=World */`
```
### 4.8 Len
`len(<array>)` is a built-in function that returns the number of elements in a given array. 
 
#### Syntax
```
len(<array>);
```

### 4.9 Keys
Inspired by PHP's associative array function array_keys($arr), FIRE designs `keys()` function to get all the keys out of an array. The `keys()` function takes in an array as an argument and returns a new array containing the keys.

#### Syntax
```
keys(<array>);
```
### 4.10 Atoi
Inspired by C, `atoi()` parses a string `str` interpreting its content as an integral number, which is returned as a value of type `int`.

#### Syntax
```
atoi(<str>);
```
#### Example
`int x = atoi("3") + 3;		/* x = 6 */`
