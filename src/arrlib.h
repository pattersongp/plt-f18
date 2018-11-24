
#ifndef arrlib_h
#define arrlib_h

#include <string>
#include <stdio.h>

class Array{
    // The type of a value
    enum Type{
        TYPE_INT,     // integer
        TYPE_STRING,  // string
    };
    enum KeyType{
        KEY_INT,
        KEY_STRING
    };
    
    struct Value{
        Type type;
        union{
            int val_int;
            std::string *val_str;
        } value;
        
        Value();
        
        ~Value();
    };
    
public:
    Array();
};
#endif /* arrlib_h */

