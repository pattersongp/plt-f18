#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "util.h"

#define DEFAULT_DELIM \n

typedef struct fileData {
	int offset;			// might be sufficient to have FILE *fd
	char *delim;		// delimiter for this file interactions
	char *filename;		//
	FILE *fd;
} file_t;

file_t *openFire(char *filename, char *delim) {
	file_t *ft = malloc(sizeof(file_t));
	ft->delim = delim;
	ft->filename = filename;
	ft->fd = fopen(filename, "r+");

#if 0
	struct stat buffer;
    int exist = stat(filename, &buffer);
	if (exist == -1) {
		printf("File doesn't exist, creating it... %s\n", filename);
		if (creat(filename, 666) < 0 ) { printf("creat() failed"); }
		ft->fd = fopen(filename, "r+");
	} else {
		printf("File exists... %s\n", filename);
		ft->fd = fopen(filename, "r+");
	}
#endif


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

void writeFire(file_t *ft, char *toWrite) {
#ifdef DEBUG
	printf("Writing: [%s]\n", toWrite);
#endif

	if (ft->fd == NULL) { printf("fd is null"); }

	int ret;
	if ((ret = fprintf(ft->fd, "%s", toWrite)) < 0) {
		fprintf(stderr, "fprintf() failed\n");
		exit(-1);
	}

#ifdef DEBUG
	printf("Wrote: [%d]\n", ret);
#endif
}

#ifdef BUILD_TEST
int main(int argc, char **argv) {
	file_t *ft = openFire("testfile", ",");
	printf("ft->delim: %s\nft->filename: %s\n", ft->delim, ft->filename);

	char *ret = readFire(ft);
	printf("read() returned: %s\n", ret);

	writeFire(ft, *argv);

	fclose(ft->fd);

	return 0;
}
#endif
