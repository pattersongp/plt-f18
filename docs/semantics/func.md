# Func Semantic

## Overview

The `func` type will reference a function in FIRE. The `func` type can be passed around as a parameter, or called on by other code in a given program. 

## Syntax

#### Declaration

the `func` type is declared in the following format\:
`func <return type> <name> = (<parameters>) => { <function body> };`

where:
 * `<return type>` is the type returned by the function
 * `<name>` is the variable name of the function
 * `<paramters>` are the expected parameters for the function
 * `<function body>` is the body of the function
 
Once a function has been assigined to a `func` type it becomes a "named function" that is callable using that name e.g `funcName();`

#### Paramaterization

Both named functions can be passed to other functions as a parameter as follows\:

```
// named
func void saySomething = () =>{ print("something"); };
func void doSomething = (func f) => { f(); };
doSomething(saySomething);
```

## Semantics

* Fire does not support function overloading
* Fire does not support genericity in functions
