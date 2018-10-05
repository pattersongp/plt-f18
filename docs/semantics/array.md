# Array Semantic

## Overview

An array type is an expression to store a set of values. 
An array expression type is declared using `array` identifier, is bounded by `[<key_type>,<value_type>]` and is followed by an array name. The two arguments in `[]` are separate by `,`. The data structure `array` type is mutable.

## Syntax

An `array` type declaration in general takes the form of `array[<key_type>, <value_type>] arr;`, where `<key_type>` is the type of key, and `<value_type>` is the type of value.

## Semantics

A `regx` matches against an entire `string`. Therefore any attempt to `filter` against an array of strings will return all strings that the `regx` matches against.

### Methods

*find --- .mem --- return bool
*sort --- only for int --- return void
*get --- int value = arr["John"]; --- return int or string or array
*set --- arr[2] = value --- return int or string
*add --- arr.add[1,"value"]; --- return a pointer
*head --- string word = arr.head; --- return a pointer

### Operator 
concat ^
slice :

### Character Ranges

A character range consists of `[R1-R2]` where `R1` is lower than `R2` in the ASCII table. A descending range is a syntax error. The range boundaries are both inclusive.

## Example

```
//Declaration with <key_type> int and <value_type> 
array[int, string] arr;

//Set Value
arr[1] = "Last Name";
arr[-987] = "two";

array [int, int] arrint;
arrint[2] = 10;
arrint[66] = 3;

arr1[1]=
arr1["String"]=


for (e : arr) {
	print e;
}
```
