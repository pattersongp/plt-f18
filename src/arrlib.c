#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <stdio.h>
#include "arrlib.h"

typedef struct Node {
    void *data1;
    void *data2;
    struct Node *next;
} node_t;

typedef struct Array {
    struct Node *head;
    size_t size_key;
    size_t size_value;
    int length;
    char type_key;
    char type_value;
} Array;

char checktypefromcodegen (int codegensize){
    //s = string, i = int, a = array, b = bool
    char type;
    switch (codegensize) {
        case 8:
            type = 'i';
            break;
        case 7:
            type = 's';
            break;
        case 4:
            type = 'b';
            break;
        default:
            type = 'a';
            break;
    }
    return type;
}

int size(char type){
    int realsize;
    switch (type) {
        case 'i':
            realsize = 8;
            break;
        case 's':
            realsize = 8;
            break;
        case 'b':
            realsize = 4;
            break;
        default:
            realsize = 8;
            break;
    }
    return realsize;
}


struct Array *initArray(int size_k, int size_v) {
    struct Array *ar = malloc(sizeof(struct Array));
    ar->head = 0;
    ar->length = 0;
    
    ar->type_key = checktypefromcodegen(size_k);
    ar->type_value = checktypefromcodegen(size_v);
    
    ar->size_key = size(ar->type_key);
    ar->size_value = size(ar->type_value);
    
    //printf("Type value: %c\n", ar->type_value);
    //printf("Size value: %d\n", (int)ar->size_value);
    
    return ar;
}

struct Node *findNode(struct Array *array, const void *dataSought, int (*compar)(const void *, const void *)) {
    
    struct Node *node = array->head;
    while (node) {
        if (compar(dataSought, node->data1) == 0) { return node; }
        node = node->next;
    }
    return NULL;
}

int compareInt(const void *data1, const void *data2)
{
    int a = (int)data1;
    int b = (int)data2;
    if (a == b)
        return 0;
    else
        return 1;
}

int compareString(const void *data1, const void *data2)
{
    if (*(char *)data1 == *(char *)data2)
        return 0;
    else
        return 1;
}

int setsizeofarrayinarray(const struct Array *array){
    int len = array->length;
    int ks = (int)array->size_key;
    int vs = (int)array->size_value;
    int arraysize = (ks+vs)*len;
    return arraysize;
}

void add(struct Array *array, void *data1, void *data2) {
    struct Node *node;
    
    // compare function
    if (array->type_key == 'i') {
        node = findNode(array, data1, &compareInt);
    }else{
        node = findNode(array, data1, &compareString);
        //node = findNode(array, data1, (int (*)(const void *, const void *))&strcmp);
    }
    
    if (node != NULL) {
        node->data2 = data2;
        if (array->type_value == 'a') {
            Array *arr = (struct Array*)node->data2;
            arr->size_value = setsizeofarrayinarray(arr);
        }
    } else {
        //create a new node malloc but no free
        struct Node *newNode = malloc(sizeof(struct Node));
        
        //check malloc
        if(newNode == NULL) {
            perror("malloc return NULL");
            exit(1);
        }
        
        //assign new node's all property
        newNode->data1 = data1;
        newNode->data2 = data2;
        newNode->next = array->head;    //pointing to same as head's
        
        //assign head
        array->head = newNode;
        node = newNode;
        
        //add length
        array->length = array->length + 1;
        
        //update size of mother array
        if (array->type_value == 'a') {
            Array *ar = (struct Array*)node->data2;
            array->size_value += setsizeofarrayinarray(ar);
        }

    }
}

void *get(struct Array *array, const void *key) {
    //Lookup key
    struct Node *node;
    // compare function
    if (array->type_key == 'i') {
        node = findNode(array, key, &compareInt);
    }else{
        node = findNode(array, key, &compareString); //node = findNode(array, data1, (int (*)(const void *, const void *))&strcmp);
    }
    
    return node->data2;
}

//#ifdef BUILD_TEST
int main() {
    //No default constructor
    Array *arr;
    arr = initArray(7,8);   //init(string,int);
    
    //Adding an element
    add(arr,"Age",17);
    add(arr,"Birthday",1959);
    
    //Array *arr2;
    //arr2 = initArray(7,10);
    //add(arr, "1", arr2);
    
    //Retrieve a value
    int c = (int)get(arr,"Age");
    printf("Age: %d\n", c);
    
    return 0;
}
//#endif



