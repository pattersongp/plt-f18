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

	regfree(&preg);
	if(ret == 0) return 1;
	return 0;
}

char *regex_grab(char *regex, char *operand) {
	char clean_regex[strlen(regex)-2];
	char clean_operand[strlen(operand)-2];
	int i;
	regex_t preg;

	if(regcomp(&preg, (const char *)regex, 0) != 0) {
		printf("regcomp() failed");
	}


	regmatch_t pmatch[2];
	int ret = regexec((const regex_t *)&preg, operand, 1, pmatch, 0);

	char *result = (char*)malloc(pmatch[0].rm_eo - pmatch[0].rm_so);
	strncpy(result, &operand[pmatch[0].rm_so], pmatch[0].rm_eo - pmatch[0].rm_so);

#ifdef DEBUG
	printf("matched: \"%s\"\n at %lld to %lld\n", result, pmatch[0].rm_so, pmatch[0].rm_eo - 1);

	if(ret == 0) {
		printf("library says there is a match\n");
	} else {
		printf("library says there is NOT a match\n");
	}
#endif
	if(ret == 0) { return result; }
	return "";
}

#ifdef BUILD_TEST
int main() {
	regex_compare("[:alpha:]", "4115hello4115");
	regex_grab("hello", "4115hello4115");
}
#endif
