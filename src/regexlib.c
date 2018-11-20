#include <stdlib.h>
#include <stdio.h>
#include <regex.h>
#include <string.h>
#include <sys/types.h>

#include "util.h"

/*
 * Simple wrapper for the regex GNU C interface
 *
 * returns 1 on match, otherwise 0
 */
int regex_compare(char *regex, char *operand) {
	char clean_regex[strlen(regex)-2];
	char clean_operand[strlen(operand)-2];
	int i;
	regex_t preg;

	if(regcomp(&preg, (const char *)regex, 0) != 0) {
		printf("regcomp() failed");
	}

	int ret = regexec((const regex_t *)&preg, operand, 0, 0, 0);

#ifdef DEBUG
	if(ret == 0) {
		printf("library says there is a match\n");
	} else {
		printf("library says there is NOT a match\n");
	}
#endif
	if(ret == 0) return 1;
	return 0;
}

#ifdef BUILD_TEST
int main() {
	regex_compare("[:alpha:]", "4115hello4115");
}
#endif
