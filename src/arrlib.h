#ifndef ARRLIB_H_
#define ARRLIB_H_

#include <iostream>

class Array {
public:
    template<typename AnyType>
    Array(AnyType key1, AnyType key2);
    template<typename AnyType>
    void add(AnyType data1, AnyType data2);
    
    ~Array();
private:
    template<typename AnyType>
    AnyType key1;
    template<typename AnyType>
    AnyType key2;
    struct Node *head;
};


template<typename AnyType>
struct Node {
    AnyType *data1;
    AnyType *data2;
    struct Node *next;
};


#endif /* defined(__TemplatesClass__Template__) */
