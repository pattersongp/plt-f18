#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>

#define DEFAULT_DELIM \n

typedef struct fileData {
	int offset;			// might be sufficient to have FILE *fd
	char *delim;		// delimiter for this file interactions
	char *filename;		//
	FILE *fd;
} file_t;

file_t *open(char *filename, char *delim) {
	printf("entered function\n");
	file_t *ft = malloc(sizeof(file_t));
	printf("malloced\n");
	ft->delim = delim;
	ft->filename = filename;
	ft->fd = fopen(filename, "rw");
	printf("ft->delim: %s\nft->filename: %s\n", ft->delim, ft->filename);
	return ft;
}

/*
 * Note: This function removes the delimiter from the chunk read
 */
char *read(file_t *ft) {
	int i = 0;
	char *buff = malloc(1024);
	fread(buff+i, 1, 1, ft->fd);

#ifdef DEBUG
	printf("fread: %s\n", buff);
#endif

	while (buff[i] != *ft->delim) {
		i ++;
		fread(buff+i, 1, 1, ft->fd);
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

	char *ret = read(ft);

	printf("read() returned: %s\n", ret);

	return 0;
}
#endif
