#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>

#include "util.h"

#define DEFAULT_DELIM \n

typedef struct fileData {
	int offset;			// might be sufficient to have FILE *fd
	char *delim;		// delimiter for this file interactions
	char *filename;		//
	FILE *fd;
} file_t;

file_t *open(char *filename, char *delim) {
	file_t *ft = malloc(sizeof(file_t));
	ft->delim = delim;
	ft->filename = filename;
	ft->fd = fopen(filename, "rw");
#ifdef DEBUG
	printf("ft->delim: %s\nft->filename: %s\n", ft->delim, ft->filename);
#endif
	return ft;
}

/*
 * Note: This function removes the delimiter from the chunk read
 */
char *readFire(file_t *ft) {
	int i = 0;
	int n = 0;
	char *buff = (char *)malloc(1024);
	n = fread(buff+i, 1, 1, ft->fd);

#ifdef DEBUG
	printf("fread: %s\n", buff);
#endif

	while (n > 0 && buff[i] != *ft->delim) {
		i ++;
		n = fread(buff+i, 1, 1, ft->fd);
#ifdef DEBUG
		printf("fread: %s\n", buff);
#endif
	}
	buff[i] = '\0';
	return buff;
}

#ifdef BUILD_TEST
int main() {
	file_t *ft = open("Makefile", "\n");
	printf("ft->delim: %s\nft->filename: %s\n", ft->delim, ft->filename);

	char *ret = readFire(ft);

	printf("read() returned: %s\n", ret);

	return 0;
}
#endif
