# FIRE
File Input Reinterpretation Engine

## Team Members

* Language Guru[Christopher Thomas](https://github.com/lord-left)uni: cpt2132
* Language Architect [Jason Konikow](https://github.com/jkon1513) uni: jk4057
* Language Architect [Frank Spano](https://github.com/fspano118) uni: fas2154
* Tester [Ayer Chan](https://github.com/ochan4) uni: oc2237
* Manager [Graham Patterson](https://github.com/pattersongp) uni: gpp2109

## Table of Contents
* [Introduction](#introduction)
* [Motivation](#motivation)
* [Features](#features)
* [Documentation](#documentation)
* [Code Example](#codeexample)

## Introduction

FIRE is a statically typed programming language designed for implementing algorithms which extract, mutate, process, and report text and structured data. FIRE is meant to be used in conjunction with large sets of structured and delimited data, like CSV's. At the core of the language is the motivation to intuitively iterate over, manipulate, and map functions to large sets of structured data.

## Motivation

Many programmers who use UNIX-based, command-line interfaces prefer to do their text manipulation with pipes and an array of UNIX tools, stringing together inputs and outputs in cumbersome, syntactically complex statements. Our language aspires to streamline and simplify text manipulation tasks by making files first-class citizens. FIRE is a scripting language, inspired by AWK and other languages, and aims to make the manipulation of files and text as easy as possible.

Additionally, the most common way for professional teams to share data between eachother is with a csv file. If a team receives some data and they want to quickly manipulate that data, how can we avoid the overhead of importing it into a relational database, then querying that database for the desired manipulation? Fire allows for such a manipulation.

## Features

### Primitive Data Types:

* `int` - Integer
* `float` - A floating point number
* `string` - A sequence of characters
* `bool` - {True or False}
* `file` - Native file type for easily operating on files
* `func` - Treated like first class citizens, i.e. they may be passed as parameters and stored in variables
* `array` - An associative array of possibly heterogeneous data

### Reserved Keywords:

* all data types
* all control statements - `{if, while, for}`
* `in` - syntactic sugar to iterate over every element in array or every line in file stream : `for (x in numbers)`
* `print` - used to print data to `stdout`
* `return` - used to return value from `func`
* `map` - `file` operator keyword
* `stream` - `file` type operator keyword
* `extract` - `file` file type operator keyword

## Documentation

### Syntax

Statements are delimited by `;` and scope is bounded by `{...}`.

### Regular Expressions

FIRE supports regular expressions for finding, replacing, and manipulating text. For example, if you're interested in accessing elements of an array whos indices take a particular form you can use a regular expression : `col = arr[r'[a-zA-Z]']`

### Arrays

FIRE supports the use of associative arrays, similar to the awk implementation. The major difference between associative arrays and indexed arrays is that in an associative array the indices are converted to strings under the hood allowing for any valid string (including numbers) to be used as an index. Additionally, arrays are not stored in any particular order. The order in which elements are produced in an expression `for (element in array)` is undefined.

The associative array allows FIRE to pair information in a way that “associates” the key to a value so that the array is more flexibly intuitive than traditional indexing. You can simulate indexed arrays in FIRE by simply using sequential numbers as your indices, but the keys are being stringified which means its possible to have numbers such as -1 or 2.55 as indices.

Arrays are declared using the `array <variable name>` keyword and do not require an initial size.

Example:
```
array arr;
arr["fireIsCool"] = 1;
arr[-987] = 2;
arr[66.876] = 3;

for (e in arr) {
		print e
}
```

### Basic Operators

| Operator             | Purpose                    | Example |
| ------------ | -------------- | :---------: |
|`=`                   | asssignment                 |`x=6`   |
| `+, -, *, /`         | basic arithmatic operators | `x = a {+, -, *, /} b` |
|`==, >, >=, <, <=, !=`| comparison operators | `if (x == y) ...` |
|`++, --`              | {post, pre}fix increment and decrement        | `x++; ++x` `x--; --x`|
|`=>`                  | anonymous function that is assignable to a variable | `(param) => { body }`|
| `===`                | matches data to regex      | `if (String y === [a-zA-Z]*)`|

### Logical Operators
| Operator     | Purpose        | Example |
| -------------| -------------- | :-------------:   |
| `\|\|`       | logical or     | `if(x\|\|y)`    |
| `&&`         | logical and    | `if(x&&y)`        |
| `!`          | logical not    | `if(!x)`          |

### Array Operators

| Operator      | Purpose       | Example |
| ------------- | ------------- | :--------------: |
| `[::]`        | slicing operators on arrays | `x = arr[3:5:]` |
| `del <arr>[<item>]`   | delete operator on an item in an array |  `del arr[3]` |
| `map <arr>(<func>)` | the passed func is called on each element in the array | `map numbers(doubleFunction);`|

### File operators

| Operator      | Purpose       | Example |
| ------------- | ------------- | ----------------- |
| `stream`        | returns an array with lines of the file of elements | `f = file("roster.csv"); f.stream()` |
| `extract`       | returns an array of all matching fields in the file | `array x = file.extract("/w{5}")` |

### Control Flows

FIRE provides the following set of control flow operators: `if`, `while`, and `for`.

## Code Example

```
user:~ $ cat PhoneNumbers.txt
Dennis 201-445-9372
Kenneth 954-667-8990
Richie 312-421-0098
Thomas 201-750-0911
Albert 783-444-7862

user:~ $ cat nj_numbers.fire
//
// Program that determintes if a number if from NJ based on 201 area code
//
file f = file(PhoneNumbers.txt);

//first class citizen
func isNJ = (String phoneNumber) => {
    return phoneNumber === "201-/d{3}-/d{4}";
};

func extractRegion(func isRegion, file numbers, array resultingNums) {
    for(number in numbers.stream()) {
        if(isRegion(number)){
            resultingNums[number] = number;
        }
    }
    return resultingNums;
}

print extractRegion(isNJ, f);

user:~ $ cut -d' ' -f2 | fire nj_numbers.fire
201-445-9372
201-750-0911
```

