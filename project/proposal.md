
<p align="center">
 <img src="https://cdn2.vectorstock.com/i/thumb-large/92/06/fire-logo-vector-13639206.jpg" alt="FIRE Logo"                      height="500px" width="500px" /></p>

 <p align="center">File Input Reinterpretation Engine</p>
# Fire
File Input Reinterpretation Engine

## Team Members

* [Jason Konikow](https://github.com/jkon1513) uni: jk4057
* [Frank Spano](https://github.com/fspano118) uni: fas2154
* [Graham Patterson](https://github.com/pattersongp) uni: gpp2109
* [Christopher Thomas](https://github.com/lord-left)uni: cpt2132
* [Ayer Chan](https://github.com/ochan4) uni: o2237

## Table of Contents
* [Introduction](#introduction)
* [Features](#features)
* [Documentation](#documentation)
* [Code Example](#codeexample)
* [FAQ](#faq)
* [Authors](#authors)

## Introduction

FIRE is a programming language designed for implementing algorithms which extract, mutate, process, and report text and structured data. FIRE is meant to be used in conjunction with large sets of structured and delimited data, like CSV's. At the core of the language is the motivation to intuitively iterate over, manipulate, and map functions to large sets of structured data.

## Motivation

Many programmers who use UNIX-based, command-line interfaces prefer to do their text manipulation with pipes and an array of UNIX tools, stringing together inputs and outputs in cumbersome, syntactically complex statements. Our language aspires to streamline and simplify text manipulation tasks by making files first-class citizens. FIRE is a scripting language, inspired by AWK and other languages, and aims to make the manipulation of files and text as easy as possible.

Additionally, the most common way for professional teams to share data between eachother is with a csv file. If a team receives some data and they want to quickly manipulate that data, how can we avoid the overhead of importing it into a relational database, then querying that database for the desired manipulation? Fire allows for such a manipulation.

## Features

### Primitive Data Types:

* `int` - Integer
* `float` - A floating point number
* `string` - A sequence of characters
* `bool` - {True or False}
* `array` - represented as associative arrays
* `file` - native file type for easily operating on files
* `func` - Treated like first class citizens, i.e. they may be passed as parameters and stored in variables

### Reserved Keywords:

* all data types
* all control statements - `{if, while, for}`
* in - syntactical sugar to iterate over every element in array or every line in file stream : `for (x in numbers)`
* print - used to print data to the screen
* return - used to return value from func
* map - operator keyword
* stream - operator keyword

## Documentation

### Syntax

Scope is bounded by `{...}` and `;` will delimit statements, ie indentation is not a syntactic enforcer.

### Regular Expressions

FIRE supports regular expressions for finding, replacing, and manipulating text. For example, if you're interested in accessing elements of an array whos indices take a particular form you can use a regular expression : `col = arr[r'[a-zA-Z]']`

### Basic Operators

| Operator             | Purpose                    | Example |
| ------------ | -------------- | :---------: |
|`=`                   | asssignment                 |`x=6`   |
| `+, -, *, /`         | basic arithmatic operators | `x = a {+, -, *, /} b` |
| `\|`                 | pipe output of a function to another |  `f(x) \| g()` |
|`==, >, >=, <, <=, !=`| comparison operators | `if (x == y) ...` |
|`++, --`              | {post, pre}fix increment and decrement        | `x++; ++x` `x--; --x`|
|`=>`                  | anonymous function that is assignable to a variable | `(param) => { body }`|
| `===`                | matches data to regex      | `if (String y === [a-zA-Z]*)`|

### Logical Operators
| Operator     | Purpose        | Example |
| -------------| -------------- | :-------------: |
| `||`         | logical or     | if(x||y)        |
| `&&`         | logical and    | if(x&&y)        |
| `!`          | logical not    | if(!x)          |

### Array Operators

| Operator      | Purpose       | Example |
| ------------- | ------------- | :--------------: |
| `[::]`        | slicing operators on arrays | `x = arr[3:5:]` |
| `del <arr>[<item>]`   | delete operator on an item in an array |  `del arr[3]` |
| `map <arr>(<func>)` | call passed func on each element in array | `map numbers(doubleFunction);`|

### File operators

| Operator      | Purpose       | Example |
| ------------- | ------------- | ----------------- |
| stream        | returns an array with lines of the file of elements | `f = file("roster.csv"); f.stream()` |
| extract       | returns an array of all matching fields in the file | String[] x = 

### Control Flows

FIRE provides the following set of control flow operators: `if`, `while`, and `for`.

## Code Example

```
PhoneNumbers.txt
//example file with list of phone numbers

201-445-9372
954-667-8990
312-421-0098
201-750-0911
783-444-7862
...


ColdCall.Fire
//using fire to extract NJ phone numbers and pipe into a "cold call" function

file f = file(PhoneNumbers.txt);

//first class citizen
func isNJ = (String phoneNumber) => {
    return phoneNumber === "201-/d{3}-/d{4}";
};


func extractRegion(func isRegion, file numbers) {
    String[] resultingNums;

    for(number in numbers.stream() ){
        if(isRegion(number)){
            resultingNums[number] = number;
        }
    }

    return resultingNums;
}



extractRegion(isNJ, f) | coldCallNumbers();
...
```

## FAQ

Q. Is this AWK?

A. No, it's only the best parts.

Q. Is this awk?

A. Depends what kind of files you use

Q. What the heck is an associative array?

A. An associative array is not that different from its more popular "indexed array" counterpart. The major difference is that in an associative array the indices are represented as strings rather than integers. With an associative array, we can pair information in way that “associates” the key to value so that the array is more informative to us than an indexed type. You are still allowed to use numbers as your indices should you choose, but in all actuality they are being stringified which means its possible to have numbers such as -1 or 2.55 as indices. 

example: 
```
int[] x; 
x["fireIsCool"] = 1; 
x["-987"] = 2; 
x["66.876"] = 3;  `
```
This means that the relationship between an array element and its index can be thought of in the same light as the key/value pair from java, or the object/property relationship from javascript.  


