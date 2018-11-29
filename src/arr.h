#ifndef _ARRAY_H_
#define _ARRAY_H_
#include <stdio.h>
#include <stdlib.h>

/*
 * A node in a linked list.
 */
struct Node {
    void *data;
    struct Node *next;
};

/*
 * A linked list.
 * 'head' points to the first node in the list.
 */
struct List {
    struct Node *head;
};

/*
 * Initialize an empty list.
 */
static inline void initList(struct List *list)
{
    list->head = 0;
}
#endif
