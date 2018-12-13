#include <stdlib.h>
#include <stdio.h>
#include <regex.h>
#include <string.h>
#include <sys/types.h>

#include "util.h"

/**
 * Simple wrapper for the regex GNU C interface
 *
 * returns 1 on match, otherwise 0
 */
int regex_compare(char *regex, char *operand) {
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

	//regfree(&preg);
	if(ret == 0) return 1;
	return 0;
}

/**
 * Grabs exactly {0,1} sub string matched from @operand
 *
 * If no substring is matched, then returns empty string.
 */
char *regex_grab(char *regex, char *operand) {
	int i, ret;
	char *result;
	regex_t preg;
	char buff[100];

#ifdef DEBUG
	printf("Regx [%s][%d] Operand [%s][%d]\n", regex, strlen(regex),
			operand, strlen(operand));
#endif

#if 0
	if(regcomp(&preg, (const char *)regex, 0) != 0) {
		printf("regcomp() failed");
	}
#endif

	if (0 != (ret = regcomp(&preg, regex, 0))) {
		regerror(ret, &preg, buff, 100);
		printf("regcomp() failed, returning nonzero (%d) --> (%s)\n", ret, buff);
		return "";
	}

	// pmatch will hold the matched string
	regmatch_t pmatch[2];
	if (0 != (ret = regexec((const regex_t *)&preg, operand, 2, pmatch, 0))) {
		regerror(ret, &preg, buff, 100);
		printf("regexec('%s', '%s') failed with '%s'\n", regex, operand, buff);
		return "";
	}

	// store the string to copy over to fire
	result = malloc(sizeof(char *)*(pmatch[1].rm_eo - pmatch[1].rm_so));
	if(result == NULL) { printf("malloc() failed\n"); exit(-1); }

	// copy the string over
	strncpy(result, &operand[pmatch[1].rm_so],
			pmatch[1].rm_eo - pmatch[1].rm_so);
	result[pmatch[0].rm_eo] = '\0';

#ifdef DEBUG
	printf("lib Result: %s is length %d\n", result, strlen(result));
	printf("lib matched: \"%s\" at %lld to %lld\n",
			result, pmatch[0].rm_so, pmatch[0].rm_eo - 1);
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
	printf("Expecting 1 -- 7\n");
	char *ret = regex_grab("hello", "5hello4");
	printf("%s\n", ret);
}
#endif
