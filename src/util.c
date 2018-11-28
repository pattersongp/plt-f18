#include <stdlib.h>
#include <string.h>

#include "util.h"

char *strcat_fire(char *s1, char *s2) {
	char *s3 = (char *)malloc(sizeof(char *)*(strlen(s1)+strlen(s2)+1));
	int i = -1;
	int j = 0;

	while(s1[++i]) {
		s3[j] = s1[i];
		j ++;
	}

	i = -1;
	while(s2[++i]) {
		s3[j] = s2[i];
		j ++;
	}

	return s3;
}
