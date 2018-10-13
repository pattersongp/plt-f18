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
* ...


## 1: Introduction
\< introduction text >

## 2: Lexical Conventions 

#### 2.1 Comments

FIRE only supports the use the block comments. Comments are initiated with the `/*` symbol and terminated by the `*/` symbol. Everything in between the symbols will be ignored by FIRE during compilation

#### 2.2 Identifiers

Identifiers are a sequence of characters consisting of uppercase or lowercase letters,digits, underscores 
or dashes 

#### 2.3 Keywords

The following identifiers are restricted from use\:

int, str , regx, if, else , elif, else, for, while, break, return, func, array, file, print, return, map

The following sequences also count as keywords:

[, ], [, ], (, ), =, ==, ===, <, >, <=, >=, +, -, *, /, ;, ^, r', =>, ||, !, &&, :

#### 2.4 Constants

Do we want to support constants?

#### 2.5 Strings

Strings are sequences of characters surounded by double quotes `"`.  
As string has the type `str`.

#### 2.6 Regular Expressions

Regular expressions are a special sequence of characters used for pattern matching surounded by single quotes `'` and preceded by the keyword `r'`.  
Regular expressions are of type `regx`   


## 3: Syntax Notation

The syntax notation of this reference manual is to enclose any and all code in the follwing format\: `As such code will be clearly discernable`

## 4: Meaning of Identifiers

Identifiers are names that corelate to single values , functions, or arrays. The restrictions on valid identifers are found in section 2.3  

The scope of an identifier can be either global or local. local identifier's scope is limited to inside the brackets in which they are declared, where as global identifiers are declared outside any brackets.  

## 5: Conversions

*note: Do we want to have conversion of types supported?*

## 6 Expressions

#### 6.1 Primary expressions

 Similair to C, Primary expressions consist of identifiers, strings, and parenthesized expressions. 
 identifiers are described in 2.2 and strings are described in 2.5

#### 6.2 Assignement Operator

The assignment operators `=` returns the value of the expression that is evaluated on its right hand side.

#### 6.3 Function Calls

Function calls operate largely in the same manner as C. Functions take in arguments by value and support the use of assignment expressions. Functions need to be assigned before being called, but can be declared anonymously. 

#### 6.4 Logical Negation

Although FIRE does not directly support a boolean type, it equates true expressions to 1 and false expressions to 0. As such, the logical negation operator `!` will convert the result of the logical expression on which it is applied to the inverse of what would normally be expected. 

#### 6.5 Logical AND Operator

The logical AND `&&` is a short circuit operator, and returns 1 if and only if the expressions on its left and right both evaluate to 1.

#### 6.6 Logical OR Operator

The logical OR operator is a short circuit operator and returns 1 if either of the expressions on its left or right return 1.

#### 6.7 Relational Operators

The relational operators `<, >, <=, <=, ==` return 1 if the expression on the left side of the operator has the expected relation to the operator on the right hand side. 

these relationships amongst ints are determined by natural ordering, where as strings.....

*note: for strings are we going to support these? If so how do we determine natural ordering? lexicographically?*

#### 6.8 Pattern Match Operator

The pattern match operator `===` returns 1 if the regular expression or string on its right side conforms to the rules laid out by the regular expression on its left side.  
it will return 0 otherwise.  
the pattern match orperator must always have a regular expression on its left side.

#### 6.9 String Concatination Operator

The string concatination `^` operator returns a new string that is the concatination of the string on its left side and the string on its right side. 

#### 6.10 Bracket Operator

The bracket operator `[]` can be used with either strings or arrays.  

When used on arrays it is supplied a key and returns the coresponding element, or -1 if it does not exist.

When used on Strings it functions in a similar manner to character arrays in C. It is supplied an integer and returns the letter of that index, however unlike C FIRE does not support chars so it returns a string of length 1.

*note: how are we going to perform this indexing?* 

#### 6.11 Slice operator 

The slice operator ....

*note: same as above. if we have an array of type [string, string] how do you slice it by providing ints?*

