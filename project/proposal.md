# Language Proposal

FIRE - File Input Reinterpretation Engine

## Table of Contents
* [Introduction](#introduction)
* [Features](#features)
* [Documentation](#documentation)
* [Code Example](#codeexample)
* [FAQ](#faq)
* [Authors](#authors)

## Introduction

FIRE is a programming language designed for implementing algorithms which extract, mutate, process, and report text and structured data. FIRE is meant to be used in conjunction with large sets of structured and delimited data, like CSV's.

## Motivation

Many programmers who use UNIX-based, command-line interfaces prefer to do their text manipulation with pipes and an array of UNIX tools, stringing together inputs and outputs in cumbersome, syntactically complex statements. Our language aspires to streamline and simplify text manipulation tasks by making files first-class citizens. FIRE is a scripting language, inspired by AWK and other languages, and aims to make the manipulation of files and text as easy as possible.

## Features

FIRE supports the following data types:
* `int` - Integer
* `float` - A floating point number
* `string` - A sequence of characters
* `bool` - {True or False}
* `array` - represented as assoc
* `file` - native file type for easily operating on files
* `func` - Treated like first class citizens, i.e. they may be passed as parameters and stored in variables

## Documentation

### Syntax

Scope is bounded by `{...}` and `;` will delimit statements, ie indentation is not a syntactic enforcer.

### Regular Expressions

FIRE supports regular expressions for finding, replacing, and manipulating text. For example, if you're interested in accessing elements of an array, which might be strings, a concise expression of that would be:
```
...
col = arr[r'[a-zA-Z]']
...
```

### Basic Operators

| Operator             | Purpose                    | Exmaple |
| -------------------- |:--------------------------:| :-----:|
|`=`                   |asssignment                 |`x=6`   |
| `+, -, *, /`         | basic arithmatic operators | `x = a {+, -, *, /} b` |
| `\|`                 | pipe, streaming output of one function to another |  `f(x) \| g()` |
|`==, >, >=, <, <=, !=`| traditional comparison operators| `if (x == y) ...` |

### Array Operators

| Operator      | Purpose       | Exmaple |
| ------------- |:-------------:| :-----: |
| `[::]`        | slicing operators on arrays | `x = arr[3:5:]` |
| `del <arr>[<item>]`   | delete operator on an item in an array |  `del arr[3]` |
  
### File operators

| Operator      | Purpose       | Exmaple |
| ------------- |:-------------:| :------:|
| stream        | opens a stream to the file | `f = file("roster.csv"); x = f.stream()` | 

### Control Flows

FIRE provides the following set of control flow operators: `if`, `while`, and `for`.

## Code Example

```
...
func lessThanThree(string filename) {
    file f = file(filename);
    stream s = f.stream();
    
    string[] words;
    
    for word in s {
        if word.length < 5 { 
           words[word] = word.length;
        }
    }
    
    for short in words {
        print short " is length " words[short];
    }
}

lessThanThree("myBookWithShortWords.txt") | someOtherFunction()
...
```

## FAQ

Q. Is this awk?

A. No, it's only the best parts.

## Authors

* [Jason Konikow](https://github.com/jkon1513)
* [Frank Spano](https://github.com/fspano118)
* [Graham Patterson](https://github.com/pattersongp)
* [Christopher Thomas](https://github.com/lord-left)
* [Ayer Chan](https://github.com/ochan4)
