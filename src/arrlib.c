#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "arrlib.h"

typedef struct Node {
	void *data1;
	void *data2;
	struct Node *next;
} node_t;

typedef struct Array {
	struct Node *head;
	struct Node *tail;
	int length;
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
struct Array *initArray() {
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

/**
 * Comparator for Array *
 */
int compareArray(const void *data1, const void *data2)
{
	struct Array *a = (struct Array *)data1;
	struct Array *b = (struct Array *)data2;
	if (a == b) return 0;
	else return 1;
}

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
 * Functions for Array[int, Array[ ... ]]
 */
void addIntArray(struct Array *array, int data1, struct Array *data2) {
	struct Node *node = findNode(array, data1, &compareInt);
	addSetData(array, node, (void *)data1, (void *)data2);
}

struct Array *getIntArray(struct Array *array, int key) {
	struct Node *node = findNode(array, key, &compareInt);
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

void mapString(struct Array *array, char *(*f)(char *)) {
	struct Node *node = array->head;
	while(node) {
		node->data2 = f((char *)node->data2);
		node = node->next;
	}
}

void mapInt(struct Array *array, int (*f)(int)) {
	struct Node *node = array->head;
	while(node) {
		node->data2 = f((int)node->data2);
		node = node->next;
	}
}

void filterString(struct Array *array, bool (*f)(char *)) {
	struct Node *head = array->head;
	while (head) {
		if (f((char *)head->data2)) break;
		else array->head = head->next;
	}
	struct Node *prev = array->head;
	head = prev->next;
	while(head){
		if (!(f((char *)head->data2))) prev->next = head->next;
		prev = prev->next;
		head = prev->next;
	}
}

void filterInt(struct Array *array, bool (*f)(int)) {
	struct Node *head = array->head;
	while (head) {
		if (f((int)head->data2)) break;
		else array->head = head->next;
	}
	struct Node *prev = array->head;
	head = prev->next;
	while(head){
		if (!(f((int)head->data2))) prev->next = head->next;
		prev = prev->next;
		head = prev->next;
	}
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
