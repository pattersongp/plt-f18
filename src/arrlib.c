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

struct Array {
    struct Node *head;
};

static inline void initArray(struct Array *array)
{
    array->head = 0;
}

void *add(struct Array *array, void *data1, void *data2){
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
    
    return newNode;
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

int compareInt(const void *data1, const void *data2)
{
    if (*(int *)data1 == *(int *)data2)
        return 0;
    else
        return 1;
}

const char * get(struct Array *array, const void *dataSought){
    //Lookup key
    struct Node *node;
    node = findNode(array, dataSought, (char (*)(const void *, const void *))&strcmp);
    char *value = node->data2;
    
    return value;
}

int main() {
    //No default constructor
    struct Array arr;
    initArray(&arr);
    
    //Adding an element
    add(&arr,"hey","1");
    
    //Retrieve an value
    char *c = get(&arr,"hey");
    printf(c);
    return 0;
}



/*long* init_arr(int* dims, int dimc){
 int static_offsets[dimc];
 int total = 0;
 for(int i = 0; i < dimc; i++) {
 static_offsets[i] = 1;
 for(int j = 0; j < i; j++) {
 static_offsets[i] *= dims[j];
 }
 static_offsets[i] *= dims[i] + 1;
 static_offsets[i] += total;
 total = static_offsets[i];
 }
 
 int indexes[dimc];
 for(int i = 0; i < dimc; i++) {
 indexes[i] = 0;
 }
 
 //Get total length of array
 int length = 0;
 for(int i = 0; i < dimc; i++) {
 int tmp = 1;
 for(int j = i - 1; j >= 0; j--) {
 tmp *= dims[j];
 }
 tmp *= dims[i] + 1;
 length += tmp;
 }
 
 //Malloc array
 long* arr = malloc(length);
 
 //Set all values to 0 initially
 for(int i = 0 ; i < length; i++) {
 arr[i] = 0;
 }
 
 //Initialize the entire array
 rec_init(arr, 0, static_offsets, indexes, dims, dimc, 0);
 
 return arr;
 }
 */

