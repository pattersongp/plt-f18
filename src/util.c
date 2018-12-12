#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"
#include "arrlib.h"

char *strcat_fire(char *s1, char *s2) {
	char *s3 = (char *)malloc(sizeof(char *)*(strlen(s1)+strlen(s2)+1));
	int i = -1;
	int j = 0;

	while(s1[++i]) {
		s3[j] = s1[i];
		j ++;
	}

	i = -1;
	j = strlen(s1);

	while(s2[++i]) {
		s3[j] = s2[i];
		j ++;
	}
	s3[strlen(s1)+strlen(s2)] = '\0';

	return s3;
}


/*
 * Expects the delim to be of length 1
 * Expects the delimited string to be less than 1024
 */
struct Array *split(char *str, char *delim) {
	if(strlen(delim) != 1) {
		fprintf(stderr, "Failure: split delimiter length != 1");
		return NULL;
	}


	struct Array *arr = (struct Array *)malloc(sizeof(struct Array *));
	int indexIntoArray = 0;
	int indexIntoStr   = 0;
	int indexIntoBuff  = 0;

	char *buff = malloc(sizeof(char*)*1024);

	while(str[indexIntoStr]) {
		if(str[indexIntoStr] == *delim) {
			// copy over to the array
			buff[indexIntoBuff] ='\0';

			addIntString(arr, indexIntoArray, buff);

			// reset our values
			indexIntoArray ++;

			buff = malloc(sizeof(char*)*1024);
			indexIntoBuff = 0;
			indexIntoStr ++;
		}

		// keep copying...
		buff[indexIntoBuff] = str[indexIntoStr];
		indexIntoStr ++;
		indexIntoBuff ++;
	}

	buff[indexIntoBuff] ='\0';
	addIntString(arr, indexIntoArray, buff);

	return arr;
}

#ifdef BUILD_TEST
#include <assert.h>
char *printFunc(char *s) { printf("%s\n", s); return s; }

int main() {
	struct Array *a = split("Hello$World", "$");
	mapString(a, printFunc);
	assert(a->length == 2);

	a = split("Hello$World$Hello$World$Hello$World", "$");
	mapString(a, printFunc);
	assert(a->length == 6);

	return 0;
}
#endif
