# Test Suite 

## How to use

You can run the full test suite by running `./testall.sh` from the porject root. The test suite operates by testing the output of a given .fire file against a "gold standard" reference file that consist of what the expected output should be.
if any tests fail they will generate a .diff file in the root directory that displays the differences between expected and actual output. to delete all of these files from root use the -c option

## tests for not yet implemented checks

some tests are in place for failures that might not yet be implmented in the semant. once these cases are implemented all we need to do is paste the expected error message in the .err ref file for that case. 
for example if `fail-for1.fire` is a case that is not yet implemented, then once it is we paste the expected error message in `fail-for1.err`. 

the unconvered tests:

* `fail-for1.fire` ( using for with non array on right side of : )
* `fail formals3.fire` ( missing comma in formals ) 
* `fail-if5.fire` ( else without if )
* `fail-if6.fire` ( elif without if )
