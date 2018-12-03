#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include "arrlib.h"

typedef struct Node {
	void *data1;
	void *data2;
	struct Node *next;
} node_t;

typedef struct Array {
	struct Node *head;
	struct Node *tail;
	size_t size_key;
	size_t size_value;
	int length;
	char type_key;
	char type_value;
} Array;

#if 0 // don't need this anymore, keeping for reference
char checktypefromcodegen (int codegensize){
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
			realsize = sizeof(int);
			break;
		case 's':
			realsize = sizeof(char *);
			break;
		case 'b':
			realsize = sizeof(int);
			break;
		default:
			realsize = 8;
			break;
	}
	return realsize;
}
#endif

/**
 * Initializes array data structure
 */
struct Array *initArray(/*int size_k, int size_v*/) {
	struct Array *ar = (struct Array *)malloc(sizeof(struct Array));
	ar->tail= 0;
	ar->head = ar->tail;
	ar->length = 0;
	return ar;
}

/**
 * Uses the comparator @compar to locate a node in the array's values
 */
struct Node *findNode(struct Array *array, const void *dataSought,
		int (*compar)(const void *, const void *)) {

	struct Node *node = array->head;
	while (node) {

#if DEBUG
		printf("comparing [%s] ?= [%s]\n", node->data1, dataSought);
#endif
		if (compar(dataSought, node->data1) == 0) {
#if DEBUG
			printf("returning %s\n", node->data1);
#endif
			return node; }
		node = node->next;
	}
#if DEBUG
	printf("Didn't find it\n");
#endif
	return NULL;
}

/**
 * Comparator for int
 */
int compareInt(const void *data1, const void *data2)
{
	int a = (int)data1;
	int b = (int)data2;
	if (a == b) return 0;
	else return 1;
}

#if 0
int setsizeofarrayinarray(const struct Array *array){
	int len = array->length;
	int ks = (int)array->size_key;
	int vs = (int)array->size_value;
	int arraysize = (ks+vs)*len;
	return arraysize;
}
#endif

struct Node *addNodeTail(struct Array *array) {
		//create a new node malloc but no free
		struct Node *newNode = (struct Node *)malloc(sizeof(struct Node));
		if(newNode == NULL) {
			perror("malloc return NULL");
			exit(1);
		}

		// Add the new node to the end of the list
		if(array->tail == NULL) {
			array->head = newNode;
			array->tail = newNode;
		} else {
			array->tail->next = newNode;
			array->tail = newNode;
		}

		//add length
		array->length ++;

		return newNode;
}

void addSetData(struct Array *array, struct Node *node, void *data1, void *data2) {
	if(node != NULL) {
		node->data1 = data1;
		node->data2 = data2;
	} else {
		node = addNodeTail(array);
		node->data1 = data1;
		node->data2 = data2;
	}
}

/**
 * Functions for Array[String, int]
 */
void addStringInt(struct Array *array, char *data1, int data2) {
	struct Node *node;

	node = findNode(array, data1, &strcmp);
	addSetData(array, node, (void *)data1, (void *)data2);
}

int getStringInt(struct Array *array, char *key) {
	struct Node *node = findNode(array, key, &strcmp);
	if(node == NULL) return 0;
	return node->data2;
}

/**
 * Functions for Array[String, String]
 */
void addStringString(struct Array *array, char *data1, char *data2) {
	struct Node *node;

	node = findNode(array, data1, &strcmp);
	addSetData(array, node, (void *)data1, (void *)data2);
}

char *getStringString(struct Array *array, char *key) {
	struct Node *node = findNode(array, key, &strcmp);
	return node->data2;
}

/**
 * Functions for Array[int, String]
 */
void addIntString(struct Array *array, int data1, char *data2) {
	struct Node *node;

	node = findNode(array, data1, &compareInt);
	addSetData(array, node, (void *)data1, (void *)data2);
}

char *getIntString(struct Array *array, char *key) {
	struct Node *node = findNode(array, key, &compareInt);
	return node->data2;
}

/**
 * Functions for Array[Int, Int]
 */
void addIntInt(struct Array *array, int data1, int data2) {
	struct Node *node;

	node = findNode(array, data1, &compareInt);
	addSetData(array, node, (void *)data1, (void *)data2);
}

int getIntInt(struct Array *array, char *key) {
	struct Node *node = findNode(array, key, &compareInt);
	if(node == NULL) return 0;
	return node->data2;
}

#ifdef BUILD_TEST
#include <assert.h>
int main() {
	//No default constructor
	Array *arr;
	arr = initArray(0,0);
	int ret;

	//Adding an element
	addStringInt(arr,"age",17);
	addStringInt(arr,"birthday", 1776);

	ret = getStringInt(arr, "age");
	assert(ret == 17);

	ret = getStringInt(arr, "birthday");
	assert(ret == 1776);

	ret = getStringInt(arr, "badkey");
	assert(ret == 0);

	assert(arr->length == 2);

	//Array *arr2;
	//arr2 = initArray(7,10);
	//add(arr, "1", arr2);

	//Retrieve a value
	// int c = (int)get(arr,"Age");
	// printf("Age: %d\n", c);

	return 0;
}
#endif
