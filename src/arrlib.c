#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>

typedef struct Node {
    void *data1;
    void *data2;
    struct Node *next;
}node_t;

typedef struct Array {
    struct Node *head;
    size_t size_key;
    size_t size_value;
    size_t length;
}Array;

struct Array *initArray(int size_k, int size_v)
{
    struct Array *ar = malloc(sizeof(struct Array));
    ar->head = 0;
    ar->size_key = size_k;
    ar->size_value = size_v;
    ar->length = 0;
    return ar;
}

struct Node *findNode(struct Array *array, const void *dataSought, int (*compar)(const void *, const void *))
{
    struct Node *node = array->head;
    while (node) {
        if (compar(dataSought, node->data1) == 0)
            return node;
        node = node->next;
    }
    return NULL;
}

void add(struct Array *array, void *data1, void *data2){
    struct Node *node;
    node = findNode(array, data1, (char (*)(const void *, const void *))&strcmp);
    
    if (node != NULL){
        node->data2 = data2;

    }else{
        //create a new node malloc but no free
        struct Node *newNode = malloc (sizeof(struct Node));
        
        //check malloc
        if(newNode == NULL){
            perror("melloc return NULL");
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
    }
}


const char * get(struct Array *array, const void *dataSought){
    //Lookup key
    struct Node *node;
    node = findNode(array, dataSought, (char (*)(const void *, const void *))&strcmp);
    char *value = node->data2;
    
    return value;
}

void set(struct Array *array, const void *dataSought, char *valueSet){
    //lookup key
    struct Node *node;
    node = findNode(array, dataSought, (char (*)(const void *, const void *))&strcmp);
    node->data2 = valueSet;
}

//#ifdef BUILD_TEST
int main() {
    //No default constructor
    Array *arr = initArray(8,8);
    
    //Adding an element
    add(arr,"Age","17");
    add(arr,"Birthday","");
    
    //Retrieve a value
    char *c = get(arr,"Age");
    printf(c);
    
    return 0;
}
//#endif


