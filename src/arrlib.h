#include <stdbool.h>

#ifndef _ARRAY_LIB_H_
#define _ARRAY_LIB_H_
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

struct Array *initArray();
struct Node *findNode(struct Array *array, const void *dataSought,
		int (*compar)(const void *, const void *));

int compareInt(const void *data1, const void *data2);
int compareArray(const void *data1, const void *data2);

struct Node *addNodeTail(struct Array *array);
void addSetData(struct Array *array, struct Node *node,
        void *data1, void *data2);

void addStringInt(struct Array *array, char *data1, int data2);
int getStringInt(struct Array *array, char *key);

void addStringString(struct Array *array, char *data1, char *data2);
char *getStringString(struct Array *array, char *key);

void addIntArray(struct Array *array, int data1, struct Array *data2);
struct Array *getIntArray(struct Array *array, int key);

void addIntString(struct Array *array, int data1, char *data2);
char *getIntString(struct Array *array, char *key);

void addIntInt(struct Array *array, int data1, int data2);
int getIntInt(struct Array *array, char *key);

void mapString(struct Array *array, char *(*f)(char *));
void mapInt(struct Array *array, int (*f)(int));

void filterString(struct Array *array, bool (*f)(char *));
void filterInt(struct Array *array, bool (*f)(int));

#endif
