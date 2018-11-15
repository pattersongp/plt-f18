#include <stdio.h>

void print(int x) {
	printf("PRINT LIB ::: %d\n", x);
}

#ifdef BUILD_TEST
int main() {
	return 0;
}
#endif
