# String Semantics

## Overview

The string type encapsulates sequences of characters. Strings are declared via the `str` keyword. 

## Syntax

A string type declaration in general takes the form of `str myString = "Text";`.  

## Semantics

Initalized string objects are immutable. Future support for a mutable string class, in the manner of `StringBuilder` in Java, may be supported in our standard library. 

### Operators

For the purposes of the below documentation, `str1` is the string consisting of the character sequence "first" and `str2` is the string consisting of the character sequence "second" .

* `^` allows for string concatenation, e.g: `str newString = str1 ^ str2;`. Returns a new string whose contents are "firstsecond". 
* `[i]` returns a string of length 1 consisting of the character at index _i_, e.g. `str char4 = str1[4];`. Returns "t" (as indexes begin at 0 in FIRE).
* `[:]` allows for string slicing, e.g: `str slicedString = str1[3:4];`. Returns "st".


### Char

Characters or the `Char` data type does not exist in FIRE; instead, individual characters are represented with strings of 0 or 1 elements.


## Example

```
string myString = "Hello";
string myString2 = "World";
myString = myString + " "; 
myString = myString + myString2; // returns a new string with "Hello World"
myString = myString[0:4]; // returns "Hello"

```
