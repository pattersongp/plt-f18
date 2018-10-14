# File Input Reinterpretation Engine (FIRE) Reference Manual

Graham Patterson  
Frank Spano  
Ayer Chan  
Christopher Thomas  
Jason Konikow

## Table of contents

* Introduction
* Lexical Conventions
* Syntax Notation
* Meaning of Identifiers
* Conversions
* Expressions
* Statements 
* Semantics
* ....


## 1: Introduction

FIRE, an initialism of "File Input Reinterpretation Engine", is a scripting language inspired by AWK and bash. These languages are renowed for their ability to robustly extract, pattern-match and manipulate text files, and FIRE. seeks to emulate this functionality with a more attractive, C-inspired syntax and intuitive semantics. 

FIRE is intended to be utilized with large sets of delimited data, like `csv` files. FIRE is also animated by the premise that files are first class citizens. 

FIRE was built by a team of Columbia University undergraduates for Professor Stephen Edward's Programming Language and Translators course. FIRE is written in OCaml , utilizing libraries built in `C`, and leveraging the `LLVM` compiler back-end.

## 2: Lexical Conventions 

#### 2.1 Comments

FIRE only supports the use the block comments. Comments are initiated with the `/*` symbol and terminated by the `*/` symbol. Everything in between the symbols will be ignored by FIRE during compilation

#### 2.2 Identifiers

Identifiers are a sequence of characters consisting of uppercase or lowercase letters, digits, underscores 
or dashes 

#### 2.3 Keywords

The following identifiers are restricted from use\:

int, str , regx, if, else , elif, else, for, while, break, return, func, array, file, print, return, map

The following sequences also count as keywords:

[, ], [, ], (, ), =, ==, ===, <, >, <=, >=, +, -, *, /, ;, ^, r', =>, ||, !, &&, :

#### 2.4 Constants

Do we want to support constants?

#### 2.5 Strings

Strings are sequences of characters surrounded by double quotes `"`.  
As string has the type `str`.

#### 2.6 Regular Expressions

Regular expressions are a special sequence of characters used for pattern matching surounded by single quotes `'` and preceded by the keyword `r'`.  
Regular expressions are of type `regx`   


## 3: Syntax Notation

The syntax notation of this reference manual is to enclose any and all code in the following format\: `As such code will be clearly discernable`

## 4: Meaning of Identifiers

Identifiers are names that correlate to a single value, a function, or an array. The restrictions on valid identifiers are found in section 2.3  

The scope of an identifier can be either global or local. local identifier's scope is limited to inside the brackets in which they are declared, whereas global identifiers are declared outside any brackets.  

## 5: Conversions

*note: Do we want to have conversion of types supported?*

## 6 Expressions

#### 6.1 Primary expressions

 Similar to C, Primary expressions consist of identifiers, strings, and parenthesized expressions. 
 identifiers are described in 2.2 and strings are described in 2.5

#### 6.2 Assignement Operator

The assignment operators `=` returns the value of the expression that is evaluated on its right-hand side.

#### 6.3 Function Calls

Function calls operate largely in the same manner as C. Functions take in arguments by value and support the use of assignment expressions. Functions need to be assigned before being called but can be declared anonymously. 

#### 6.4 Logical Negation

Although FIRE does not directly support a boolean type, it equates true expressions to 1 and false expressions to 0. As such, the logical negation operator `!` will convert the result of the logical expression on which it is applied to the inverse of what would normally be expected. 

#### 6.5 Logical AND Operator

The logical AND `&&` is a short circuit operator, and returns 1 if and only if the expressions on its left and right both evaluate to 1.

#### 6.6 Logical OR Operator

The logical OR operator is a short circuit operator and returns 1 if either of the expressions on its left or right return 1.

#### 6.7 Relational Operators

The relational operators `<, >, <=, <=, ==` return 1 if the expression on the left side of the operator has the expected relation to the operator on the right-hand side. 

these relationships amongst ints are determined by natural ordering, where as strings.....

*note: for strings are we going to support these? If so how do we determine natural ordering? lexicographically?*

#### 6.8 Pattern Match Operator

The pattern match operator `===` returns 1 if the regular expression or string on its right side conforms to the rules laid out by the regular expression on its left side.  
it will return 0 otherwise.  
the pattern match operator must always have a regular expression on its left side.

ex:  

`r'[a-z]+' === word`

#### 6.9 String Concatination Operator

The string concatenation `^` operator returns a new string that is the concatenation of the string on its left side and the string on its right side. 

#### 6.10 Bracket Operator

The bracket operator `[]` can be used with either strings or arrays.  

When used on arrays it is supplied a key and returns the corresponding element, or -1 if it does not exist.

When used on Strings it functions in a similar manner to character arrays in C. It is supplied an integer and returns the letter of that index, however unlike C FIRE does not support chars so it returns a string of length 1.

```
str hello = "hello"
str o = hello[4]; 
```
#### 6.11 Slice operator 

The slice operator `[x:y]` is used on a string and returns a substring

## 7: Declarations  

Objects are instantiated via declarations, which explicitly assign a data type to a variable. In Fire a variable cannot be declared without also being assigned to a value. Types are explicit in FIRE. The format of a declaration is as follows: 

`{type} {variable name} = {value};`.

#### 7.1 Data Types

#### 7.1.1. int

Objects of type `int` represent integers and include negative values. The upper and lower bounds for int are defined by the architechtural constraints of the computer, in the manner of C and OCaml. 

Example: 

`int num = 32;`

int objects can also be assigned to the result of expressions:

`int a = 34 * 2 + (2 / 1);`

Floating point values are **not** supported in FIRE.

#### 7.1.2. str

Objects of type `str` objects are used to represent sequences of characters, i.e. strings. Strings are immutable and can be declared in the following manner:

Example: 

`str myString = "Hello World";`

char values are **not** supported in FIRE, but a string of length 0 or 1, can be returned via the bracket operator discussed in section 6.10 

#### 7.1.3. file

Files are regarded as first-class citizens in FIRE. This is made apparent by the importance and centrality of files. A `file` object represents either an existing file or a file that is to be written to, and allows the programmer to more easily perform operations on the file.

The semantics for instantiating a `file` object is as follows:

`file f = file("filename.csv", "mode");`

In the example provided above, two arguments are fed into the `file()` argument: *filename* for reading, writing or both, and *mode*. The *mode* argument can be `r` for read only, `w` for write only, and `rw` for both.  

Example:  

`file f = file("test.csv", "rw");` will open the File named test.csv in the current directory for both reading and writing.  
  
`file f = file("filename.csv", "mode", "delim");`

An optional third argument *delim* may be provided to the constructor specifying a delimiter for reading. If the *delim* argument is not supplied it will default to `\n`. 

Example: 

`file f = file("test.csv", "rw", ";");` will open the File named test.csv in the current directory for both reading and writing. Calls to read() will read in chunks of the file delimited by the ';' character. 

#### 7.1.4. func

`func` objects reference functions and are treated as first class citizens.  
The structure of `func` variable declarations is as follows:

`func <name> = (<parameters>) => { <function body> };`

Example: 
```
func saySomething () =>{ print("something"); };
func doSomething = (func f) => { f(); };
doSomething(saySomething);
```
#### 7.1.4. array

The `array` type is a dynamic collection of elements. Inspired by AWK's associative arrays, an `array` object maps keys of one type to values of one type. Keys and values do not have be the same type, but all keys must share the same type and all values must share the same type. 

The structure of `array` variable declarations is as follows:

`array arr[<key_type>, <value_type>];`

Example: 

`array arr[int, string];` 

The assignment of variables has the following structure:

`arr[<key_value>] = <element>;` 

Example: 

 `arr[17] = "age17";`
 
 Finally, a programmer can retrieve a value associated with a key with the below syntax:
 
 `int element = arr[<key_value>];`
 
 Example:
 
 `int age = arr["age"];`
 
#### 7.1.5. regx

Regular expressions are supported in FIRE. Via the `regx` type, which assigns an object to a regular expression. That object can then be passed as a parameter to functions that utilize regular expressions to a pattern match or extract data.

The structure of a `regx` declaration is as follows:

`regx myPattern = r'<pattern>'`

Example:

```
regx myPattern = r'[a-z]';
myFunction(someString, myPattern);
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


## 8: Statements 

#### 8.1 Print Statement

The print statement prints a literal value, or the value returned by an expression. 

`print("i will be printed");`

#### 8.2 Conditional Statements

Conditional statements evaluate expressions and execute code based on the truth values of those expressions.

```
if (expression) {code block}
elif {code block}
else {code block}
```

#### 8.3 For Statements

For statements iterate over an array and execute a code block for every iteration. The code block can mutate the array elements, but can not add or remove elements from the array.  
ex:

```
for(str current : stringArray){
    print(current);
}
``` 

#### 8.4 While Statements 

While statements execute a code block  until its provided condition fails to be met.  

```
while(condition) {
	code block
}
```

