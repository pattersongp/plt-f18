# Array Semantic

## Overview

FIRE provides a data structure, the array, which stores a flexible-size collection of elements of the same type. Array types are either integer or string. The `array` type is mutable, but the type of all keys and all elements must follow the original initialization. Our array is a combination of map in ocaml and hashmap in Java.

## Syntax
the `array` type is declared in the following format\:  
`array arr[<key_type>, <value_type>];`

where:  
 * `<key_type>` is the type of the key used to access elements in array.  
 * `<value_type>` is the type of the element in array.  
  
for example:  
`array arr[int, string];` 
### Setting
 the `array` can be set with following example\:  

 `arr[17] = "age17";`  

### Retrieving
elements in `array` can be retrieve with following example\:  

`string lastname = arr["John"];`

### Processing Array
When processing array elements, FIRE use foreach loop to iterate all array, because all of the elements in an array are of the same type.  
Below is an example showing how foreach loop works:  

```
//Interate the array
for (e : arrint) {
	print e;
}
```

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
