//Array Library C++ for Fire Language
#include <cstdlib>
#include <iostream>
#include "arrlib.h"

using namespace std;

int main(){
    
}

template<typename AnyType>
void Array::add(AnyType data1, AnyType data2){
    struct Node newNode = malloc(sizeof(struct Node));
    
    //check malloc
    if(newNode == NULL){
        thow "melloc return NULL";
        exit(1);
    }
    
    //assign new node's all property
    newNode->data1 = data1;
    newNode->data2 = data2;
    newNode->next = this->head;    //pointing to same as head's
    
    //assign head
    this->head = newNode;
}
