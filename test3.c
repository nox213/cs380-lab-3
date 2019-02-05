#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char *argv[])
{
	int a, b, c;
	char *p;

	p = malloc(100);

	*p = 'a';
	*(p + 1) = '\0';

	puts(p);

	a = 3;
	b = 7;
	c = 8;

	printf("%d\n", a + b + c);

	srand(time(NULL));
	for (int i = 0; i < a; i++)
		printf("%d\n", rand());

	free(p);
	p = NULL;

	*p = 77;

	return 0;
}

