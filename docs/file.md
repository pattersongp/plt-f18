# File Semantic


## Overview
(File will be used to refer to a File on the filesystem, file will refer to the file type in FIRE). 

The file type will open a specified File for reading and writing. A File on the filesystem, stdin and stdout all constitute valid Files. A delimiter (character) may be specified at instantiation allowing the File to be read in chunks delimited by the character.

## Syntax
`file f = file("filename.csv", "mode");`. Opens *filename* for reading, writing or both specified by *mode*. The *mode* argument can be `r` for read only, `w` for write only, and `rw` for both.  
Ex. `file f = file("test.csv", "rw");` will open the File named test.csv in the current directory for both reading and writing.  
  
`file f = file("filename.csv", "mode", "delim");`
An optional third argument *delim* may be provided to the constructer specifiying a delimiter for reading. If the *delim* argument is not supplied it will default to `\n`.  
Ex. `file f = file("test.csv", "rw", ";");` will open the File named test.csv in the current directory for both reading and writing. Calls to read() will read in chunks of the file delimited by the ';' character.  
  
`readline()` reads a chunk of the file from the current file pointer to the next `'\n'`.  
Ex. `string line = f.readline();` will read data from the file until it encounters a `'\n'` character.
  
  
`read()` reads a portion of the file delimited by the *delim* argument passed at instantiation. If *delim* is not passed this will default to `'\n'` giving `read()` the same functionality as `readline()`.  
Ex.```file f = file("test.csv", "rw", ";");   
string line = f.read();``` will read data from the file until it encounters a `';'` character.

`write()` takes a string and writes it to the file from the current file pointer. Returns the number of bytes written.  
Ex. `int bytes = f.write("String here");` will write `String here` to the file and return 11.

## Semantics

Multiple files can be opened referencing the same File on the file system. Each file maintains its own file pointer. Thus multiple files can be opened with different delimiters and each file will be read in using it's own delimiter. Writing to the same File from different file variables is unsafe and behavior is undefined.
