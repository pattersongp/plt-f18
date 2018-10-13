# File Input Reinterpretation Engine (FIRE) Reference Manual

Graham Patterson  
Frank Spano  
Ayer Chan  
Christopher Thomas  
Jason Konikow

## Table of contents

* Introduction
* Lexical Conventions
* Syntax
* Identifiers
* Expressions
* Statements 
* Scope 
* Grammer


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

### 2.6 Regular Expressions
Regular expressions are a special sequence of characters used for pattern matching surounded by single quotes `'` and preceded by the keyword `r'`.  
Regular expressions are of type `regx`   


##3: Syntax Notation
The syntax notation of this reference manual is to enclose any and all code in the follwing format\: `As such code will be clearly discernable`

## 4: Meaning Of Identifiers
Identifiers are names that corelate to single values , functions, or arrays. The restrictions on valid identifers are found in section 2.3  

The scope of an identifier can be either global or local. local identifier's scope is limited to inside the brackets in which they are declared, where as global identifiers are declared outside any brackets.  

