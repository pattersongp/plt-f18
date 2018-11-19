#include <stdio.h>
#include <regex.h>
#include <string.h>
#include <sys/types.h>

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

#ifdef DEBUG
	printf("{%s}\n", regex);
	printf("{%s}\n", operand);
#endif

	for(i=1; i < strlen(regex)-1; i++) { clean_regex[i-1] = regex[i]; }
	clean_regex[i-1] = '\0';
	for(i=1; i < strlen(operand)-1; i++) { clean_operand[i-1] = operand[i]; }
	clean_operand[i-1] = '\0';

#ifdef DEBUG
	printf("{%s}\n", clean_regex);
	printf("{%s}\n", clean_operand);
#endif

	if(regcomp(&preg, (const char *)clean_regex, 0) != 0) {
		printf("regcomp() failed");
	}

	int ret = regexec((const regex_t *)&preg, clean_operand, 0, 0, 0);

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
	regex_compare("\"[:alpha:]\"", "4115hello4115");
}
#endif
