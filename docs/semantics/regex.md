# Regex Semantic

## Overview

A regular expression type is an expression used for pattern matching. A regular expression type is declared using `regx` identifier, always begins with `r`, and is bounded by two single quotes `'<pattern>'` where `<pattern>` is the desired pattern to be matched. `regx` type is constant once initialized and cannot be changed.

There are no operations on `regx` type but there are native functions that require a `regx` type as an argument, ie `filter`

## Syntax

A `regx` type declaration in general takes the form of `regx myPattern = r'<pattern>'` where `<pattern>` is the desired pattern.

## Semantics

A `regx` matches against an entire `string`. Therefore any attempt to `filter` against an array of strings will return all strings that the `regx` matches against.

### Operators

* `\` escapes any of the operators for the literal character
* `^` matches only the beginning of the string
* `$` matches only the end of the string
* `.` matches any single character
* `[ ... ]` defines a character list, where the character list can also be character range. This matches any string containing these characters
* `[^ ... ]` defines a character list, but negates them. This matches any string *not* containing these characters
* `|` matches either expression `e1` or `e2`
* `( ... )` groups expressions together where `...` is some regular expression
* `*` matches the preceding character 0 or many times
* `+` matches the preceding character at least once

### Operator Precedence

1. Escaped characters
1. Character list
1. Grouping with parentheses
1. Single character operations like `*, +, .`
1. Concatenation
1. Anchoring operators like `^, $`
1. Alternation

### Character Ranges

A character range consists of `[R1-R2]` where `R1` is lower than `R2` in the ASCII table. A descending range is a syntax error. The range boundaries are both inclusive.

## Example

```
regx myPattern = r'[a-z]';
myFunction(someString, myPattern);
```

## Notes

We're providing this functionality with [this](https://www.gnu.org/software/libc/manual/html_node/Regular-Expressions.html#Regular-Expressions) library.
