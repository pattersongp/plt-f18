#include "arrlib.h"
#include <sstream>
#include <fstream>
#include <cmath>

Array::Array(){
}

Array::Value::~Value(){
    switch(type){
        case TYPE_STRING:
            delete value.val_str;
            break;
        default:
            break;
    }
}

