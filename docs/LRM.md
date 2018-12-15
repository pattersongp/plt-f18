# File Input Reinterpretation Engine - (FIRE) - Language Reference Manual


Graham Patterson (gpp2109)  
Frank Spano (fas2154)  
Ayer Chan (oc2237)  
Christopher Thomas (cpt2132)   
Jason Konikow (jk4057)  

## Table of contents

1. Introduction
2. Lexical Conventions
3. Meaning of Identifiers
4. Expressions
5. Declarations 
6. Statements
7. Code Sample


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

#### 2.2.1 Types
FIRE was designed for efficiency. Basic types, integer and string, are most efficient for scripting files. They ensure and eliminates certian runtime decisions. Void data type is used for functions that does not return a value. `true` and `false` are two predefined constants for `bool`.

* `int` 
* `str`
* `bool`
* `void`
* `func`

A function declaration begins with the `func` keyword.

#### 2.2.2 Control Flow 
The following keywords indicate keywords for control flow.

* `if` 
* `else`
* `elif`
* `else`
* `while`
* `break`
* `return`

#### 2.2.2 Built-in Functions
The following keywords are reserved for built-in functions.

* `print`
* `sprint`
* `map`
* `filter`

#### 2.2.3 Advance Data Types
The following keywords are reserved for advance data types. 

* `array`
* `file`
* `regx`

### 2.3 Constants

FIRE supports integer, string and boolean literals, inside expressions. 

#### Integer
Identifiers of type `int` represent positive integers. An `int` is a 32-bit singed integer, and consists of at least one digit. The following defines the regular expression of a decimal digit for `int`:

`digit = ['0' - '9']`

Example:

`int num = 32;`

`int` types can also be assigned to the result of expressions:

`int a = 34 * 2 + (2 / 1);`

#### String
Identifiers of type `str` are used to represent sequences of characters, strings. Strings can be declared in the following manner:

Example:

`str myString = "Hello World";`

Not all strings are in printable form. Some printable characters have conflicts with the lexical conventions. They are
specially marked with a backslash. FIRE also supports the following escape sequences:

`\n`
`\r`
`\t`
`\f`
`\b`
`\\`
`/`

In order to print out the raw forms of speically marked characters that are listed above, `\\` double backlash can cancel the escape sequences.

`\\\n`
`\\\r`
`\\\t`
`\\\f`
`\\\b`
`\\\\`
`\\/`

### 2.4 Punctuation
FIRE supports primary expressions using the previously-mentioned identifiers. Primary expressions also include expressions inside parentheses. In addition, parentheses can indicate a list of arguments in a function declaration or a function call:

`f()` 

Statement in blocks are indicated by braces. Braces imply blocks that make up function bodies:

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
Files are regarded as first-class citizens in FIRE. This is made apparent by the importance and centrality of files. A `file` type represents either an existing file or a file that is to be written. This allows the programmer to more easily perform operations on the file.

The syntax for instantiating a `file` object is as follows:

`file f;
f.open("filename.csv", "<delimiter>");
`

In the example provided above, two argument are fed into the `open(...)` argument: *filename* for reading, writing or both, and *delimiter*. *delimiter* may be provided to the constructor specifying a delimiter for reading. 

Example:

`file f; f.open("test.csv", ",");` will open the File named `test.csv` in the current directory for both reading and writing, and delimited by the `,` character.

#### 2.5.2 Array
The `array` type is a dynamic collection of elements. Inspired by AWK's associative arrays, an `array` collection maps keys of one type to values of one type. Keys and values do not have be the same type, but all keys must share the same type and all values must share the same type.

The structure of `array` variable declarations is as follows:

`array[<key_type>, <value_type>] arr;`

Example:

`array[str, str] arr;`

Note that arrays are initialized without pointing to a value.

The assignment of variables has the following structure:

`arr[<key_value>] = <element>;` 

Example:

 `arr["myAge"] = "28";`
 
As the above example demonstrates, keys do not have to be of the same type as the values they correspond with - but all keys in an array must be of the same type, and all values must be of the same type. 

There are strict restrictions on the types a key can be and a value can be. Please consult the table below:

| Legal Key Types | Legal Value Types |
|-----------------|-------------------|
| int             | int               |
| string          | string            |
|                 | array             |
 
 Finally, a programmer can retrieve a value associated with a key with the below syntax:
 
 `int element = arr[<key_value>];`
 
 Example:
 
 `int age = arr["myAge"];`
 
An error will be thrown if `"myAge"` does not exit.

##### Arrays of Arrays
In certain cases you may create an Array of Arrays. Any value of a type array must specify the types of the array. For example:

`array[str, array[int, str]] b;`
 
In this case, array b will be initialized but not array[int,str].
 
#### 2.5.3 Regular Expression
Regular expressions are supported in FIRE. Via the `regx` type, which assigns an object to a regular expression. That object can then be passed as a parameter to functions that utilize regular expressions to a pattern match or extract data.

The structure of a `regx` declaration is as follows:

`regx myPattern = "<pattern>"

Example:

```
str s = "token";
regx r = "ok";
str ret = s.grab(r);	/* ret is 'ok' */
```

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



#### 2.4 Comments
FIRE only supports the use the block comments. Comments are initiated with the `/*` symbol and terminated by the `*/` symbol. Everything in between the symbols will be ignored by FIRE during compilation:

 `/* This is a comment. */`

#### 2.5 Value Binding
A single equal sign indicates assignment in an assignment or declaration statement:

 `=`
 
#### 2.6 Operators
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

#### Primary Expressions
The grammar of the two primitive literals are INT_LIT and STRING_LIT. 

#### Function Calls
Functions take in arguments by value except in the case of other functions which are passed by reference. Functions, other than build-in functions, need to be assigned before being called, but FIRE does not support prototyping. The scope of a function is the top level.

#### Logical Negation
FIRE provides `true` and `false` values. The logical negation operator `!` evalutates to the parity of the operand.

#### AND Operator
The logical AND `&&` is a short circuit operator, and returns `true` if and only if the expressions on its left and right both evaluate to `true`, otherwise `false`.

#### OR Operator
The logical OR `||` operator is a short circuit operator and returns `true` if either of the expressions on its left or right return `true`, otherwise `false`.

#### Relational Operators
The relational operators `<, >, <=, <=, ==` return `true` if the expression on the left side of the operator has the expected relation to the operator on the right-hand side, otherwise `false`.

These relationships amongst ints are determined by natural ordering. Strings can only be evaluated using the `==` operator.

#### String Concatenation Operator
The string concatenation `^` operator returns a new string that is the concatenation of the string on its left side and the string on its right side. This operator cannot be chained without parenthesis - as a binary operator, if you wish to concatenate multiple strings into a larger string, you must group operands. 

Example:

```
str x = "hello";
str y = " world";
str z = x ^ y;
str a = (x ^ y) ^ y; // evaluates to 'hello world world'
```

#### Bracket Operator
The bracket operator `[]` are operators on `array`.

When used on `array` it is supplied a key and returns the corresponding element. Indexing a key using the bracket operator  assigns an element to the corresponding key.

##### Typing
The type enforcement for the bracket operator is as follows:

```
arry [int,str] arr;
arr[0] = "cat";
arr[1] = "dog";
arr[2] = "dog";
str animal = arr[0];
```

where `arr` is a type of `[int,str]` array, `arr` can only accpet integer keys and elements.

#### Boolean

Boolean objects contain a value of either `true` or `false`. They can be declared on their own, and are used in conditional statements.

The structure of a boolean declaration:

```
bool switch = true; // or false
```

Example: 

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

## 4:Statements 

### 4.1 Assignments

The assignment operators `=` returns the value of the expression that is evaluated on its right-hand side and stores it in the identifier on the left hand side. The scope of that identifier is described in [section 2](#Identifiers)

### 4.2 Blocks and Control Flow 

#### Block 
A block is defined inside curly braces, which can include a possibly-empty list of statements.

#### Conditional Statement 
A Conditional statement is an if, if-else, or if-elif-else statement that takes an expression that evaluates to a
bool value. It only executes code based on a `true` value.
```
\*    if   *\
if (<expression>) {
	<code block>
}

\* if-else *\

if (<expression>) {
	<code block>
}
else {
	<code block>
}

\* if-elif-else *\

if (<expression>) {
	<code block>
}
elif(<expression>) {
	<code block>
}
else {
	<code block>
}
```
		
#### Iteration Statement 
An iteration statement begins with the `while` keyword. The expressions must evaluate to a `bool` value. While statements execute a code block until its provided condition fails to be met:

```
while(<condition>) {
	<code block>
}
```

#### Jump Statements 
The return statement takes an expression at the end of a function and exit out of that function. 
```
return expression
```

### 4.3 Built-in Functions
#### 4.3.1 Map 
The map keyword allows a programmer to apply a function to every element of an array and modifies values of that array. 

`map(arr,f);` 

The `map` keyword applies the function to the array passed as the first argument and mutates that array.

The return type of `map` is `void`.

#### Typing
The return type of the function `f` in `map(arr,f);` must match the type of value in `a`. Additionally, the only argument of `f` must be the type of the value in the array. A function used in `map` must take exactly 1 argument. It is also the case that the return type and only argument type of `f` are the same. A valid `function`, `map`, and `array` use might be:

```
func int f = (int i) => { ... }
func void main = () => {
array[string, int] a;
...
map(a,f);
}
```

### 4.3.2 Filter 
The filter keyword takes any function that returns a boolean and applies it to elements of an array. This allows filter to quickly generate a new array that consists of elements that match whatever member criteria your function tests for.

Example: `filter(arr,f);`


In the above 4.2.9 example, arr contains an array of strings that are either `dog` or `cat`. func `f` returns `true` if any elements is equal to `dog`. The above expression would return an array that contains `dog` element.

#### Typing
The return type of the function `f` in `filter(a,f);` must be a `bool`. Additionally, the only argument of `f` must be the type of the value in the array. A function used in a `filter` must take exactly 1 argument. A valid `function`, `filter`, and `array` use might be:

```
func bool f = (int i) => { ... }
...
array[string, int] a;
...
filter(a,f);
```

### 4.4 Print & SPrint Statement

The print statement prints integers. To give more explicit typing constraints, print() can only print integers and sprint() can only print strings. The syntax and semantics of the print function are inspired by C. In C, the printf() function requires a format specifier inside printf(), and the function pass it as an argument. To make it more explicit, FIRE intended to call a different printing function to print strings. 
```
print(10);
```
```
sprint("i will be printed to stdout");
```

### 4.5 Functions
`func` objects reference functions and are treated as first class citizens. The structure of `func` variable declarations is as follows:

`func <return type> <name> = (<parameters>) => { <function body> };`

Where:
 * `<return type>` is the type returned by the function
 * `<name>` is the variable name of the function
 * `<paramters>` are the expected parameters for the function
 * `<function body>` is the body of the function
 
Once a function has been assigined to a `func` type it becomes a "named function" that is callable using that name e.g `funcName();`

A function that does not return anything has a return type of `void`.  The void return type allows for programmers to create functions that are useful for their side effects. 

#### Paramaterization

Named functions can be passed to other functions as a parameter as follows\:
```
func void saySomething = () => { print("something"); };
func void doSomething = (func f) => { f(); };
doSomething(saySomething);
```

#### Caveats

* Fire does not support function overloading
* Fire does not support genericity in functions


### 7: Code Sample

The below is an example of `FIRE` in action. In the snippet below, a `FIRE` program is used to extract phone numbers that begin with a particular area code:


```
user:~ $ cat PhoneNumbers.csv
Dennis,201-445-9372
Kenneth,954-667-8990
Richie,312-421-0098
Thomas,201-750-0911
Albert,783-444-7862

user:~ $ cat nj_numbers.fire
/*
 Program that determines if a number is from NJ based on 201 area code
*/

func string isNJ = (str phoneNumber) => {
    return phoneNumber === r'201-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]';
};

func array extractRegion = (func isRegion, file f) {
    
    array[int, str] njnums;
    
    str number = f.readLine();
    int i = 0;
    
    while(number != "") {
        if(isNJ(number)){
            njnums[i,number].add;
	         i = i + 1;
	         number = f.readLine();
        }
    }
    return njnums;
}

func void main = () => {

	file[rw] f;
	f = open("PhoneNumbers.csv", ",");

	/* Calling a function */
	extractRegion(isNJ, f);
}

user:~ $ make
user:~ $ ./fire.native < nj_numbers.fire
201-445-9372
201-750-0911
```

### 8: Other Code Requirements

Programs in FIRE mandate a main function of type `void` or `int`. If int, convention has `0` returned if the program executes successfully and `1` in the event of an error.

