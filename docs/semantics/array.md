# Array Semantic

## Overview

An array type is an expression to store a set of values. 
An array expression type is declared using `array` identifier, is bounded by `[<key_type>,<value_type>]` and is followed by an array name. The two arguments in `[]` are separate by `,`. The data structure `array` type is mutable.

## Syntax

An `array` type declaration in general takes the form of `array[<key_type>, <value_type>] arr;`, where `<key_type>` is the type of key, and `<value_type>` is the type of value.

### Methods
* get --- int value = arr["John"]; --- return int or string or array
* set --- arr[2] = value --- return int or string

| Methods     | Return Value        | Restriction    |Example       |
| -------------| -------------- | -------------- | :-------------:   |
| `.add` | Return a reference to the newly added element   | | `arr[1,"value"].add`        |
| `.contains` | Return 1 if a key exist in an array, else return 0|N/A| `arr["John"].contains`    |
| `.sort`         | Return the sorted array by its integer key type | Only accept arrays with integer key value type  | `arr.sort`        |
| `.head`          | Return the first element of an array  | N/A | `arr.head`          |

### Operator 

| Operator     | Return Value   |Example       |
| -------------| -------------- | :-------------: |
| `^` | Return 1 if a key exist in an array, else return 0| `arr["John"].contains`    |
| `:` | Return the sorted array by its integer key type   | `arr.sort`        |

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
