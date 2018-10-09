# Array Semantic

## Overview

FIRE provides a data structure, the array, which stores a flexible-size collection of elements of the same type. Array types are either integer or string. The `array` type is mutable. Our array is a combination of map in ocaml and hashmap in Java.

## Syntax
|      | Format|Explanation  |Example|
| -------------| -------------- | -------------- | :-------------: |
| Declaration |`array arr[<key_type>, <value_type>]` |`<key_type>` is the type of key, and `<value_type>` is the type of value | `array arr1[int, string];`    |
| Set |`arr[<key>]`|Return a reference to the new sub-array|  `arr[17] = "age17";`   |
| Get |`arr[<key>]`|Return an integer or a string| `string lastname = arr["John"];`  |

### Methods
| Methods     | Return Value        |Example       | Restriction    
| -------------| -------------- | :--------------: | -------------   |
| `.add` | Return a reference to the newly added element   |  `arr[1,"value"].add`        |
| `.contains` | Return 1 if a key exist in an array, else return 0| `arr["John"].contains`    |
| `.sort`         | Return the sorted array by its integer key type | `arr.sort`        |  Only accept arrays with integer key value type |

### Operator 
| Operator     | Purpose |Return Value   |Example       |
| -------------| -------------- | -------------- | :-------------: |
| `^` |Concatenating two arrays |Return a reference to the concated array| `arr1^arr2`    |
| `:` |Slicing an array into two arrays|Return a reference to the new sub-array| `arr[6:10]`     |

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
