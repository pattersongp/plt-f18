# Func Semantic

## Overview

The `func` type will reference a function in FIRE. The `func` type can be passed around as a parameter, or called on by other code in a given program. 

## Syntax

#### Declaration
the `func` type is declared in the following format\:
`func <name> = (<parameters>) => { <function body> };`

where:  
 `<name>` is the variable name of the func.  
 `<paramters>` are the expected parameters for the function
 `<function body>` is the body of the function.
 
 once a function has been assigined to a `func` type it becomes a "named function" that is callable using that name e.g `funcName();`

#### Anonymous Functions
Annoynomous functions are functions that have not been assigned to a `func` variable. They are entirely interchangabe with named functions every where a func is expected, but can not be called unless assigned to a func type. This happens implicitly when passed as a parameter.

`(<parameters>) => {<function body>}`
#### Paramaterization
Both named and annonymous functions can be passed to other functions as a parameter as follows\:

```
// named
func saySomething () =>{ print("something"); };
func doSomething = (func f) => { f(); };
doSomething(saySomething);

//anonymous
doSomething( () => { print("something"); } );
```

## Semantics

* Fire does not support function overloading
* Fire does not support genericity in functions

