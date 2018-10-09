# Array Semantic

## Overview

An array type is an expression to store a set of values. 
An array expression type is declared using `array` identifier, is bounded by `[<key_type>,<value_type>]` and is followed by an array name. The two arguments in `[]` are separate by `,`. The data structure `array` type is mutable.

## Syntax

An `array` type declaration in general takes the form of `array[<key_type>, <value_type>] arr;`, where `<key_type>` is the type of key, and `<value_type>` is the type of value.

### Methods

* find --- .mem --- return bool
* sort --- only for int --- return void
* get --- int value = arr["John"]; --- return int or string or array
* set --- arr[2] = value --- return int or string
* add --- arr.add[1,"value"]; --- return a reference to array
* head --- string word = arr.head; --- return a reference to array

| Methods     | Return Value        | Restriction    |Example       |
| -------------| -------------- | -------------- | :-------------:   |
| `.contains` | Return 1 if a key exist in an array, else return 0|N/A| `arr["John"].contains`    |
| `.sort`         | Return the sorted array by its integer key type | Only accept arrays with integer key value type  | `arr.sort`        |
| `.head`          | Return the first element of an array  | N/A | `arr.head`          |

### Operator 

* concat ^
* slice :

## Example

```
//Declaration
array[int, string] arr;

//Set Value
arr[1] = "Last Name";
arr[-987] = "two";

//Declaration 
array [int, int] arrint;
arrint[2] = 10;
arrint[66] = 3;

//

//Interate the array
for (e : arrint) {
	print e;
}
```
