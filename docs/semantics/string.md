# String Semantics

## Overview

The string type encapsulates sequences of characters. Strings are declared via the `str` keyword. 

## Syntax

A string type declaration in general takes the form of `str myString = "Text";`.  

## Semantics

Initalized string objects are immutable. Future support for a mutable string class, in the manner of `StringBuilder` in Java, may be supported in our standard library. 

### Operators

* `^` allows for string concatenation, e.g: `str newString = str1 ^ str2;`
* `[i]` returns a string of length 1 consisting of the character at index _i_, e.g. `str char4 = str1[4];`
* `[:]` allows for string slicing, e.g: `str slicedString = str1[3:4];`



### Operator Precedence

### Character Ranges

A character range consists of `[R1-R2]` where `R1` is lower than `R2` in the ASCII table. A descending range is a syntax error. The range boundaries are both inclusive.

## Example

```
regx myPattern = r'[a-z]';
myFunction(someString, myPattern);
```
