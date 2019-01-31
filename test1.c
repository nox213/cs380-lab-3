#include <stdio.h>

int main(int argc, char *argv[])
{
	int x, y, z;
	
	x = 1;
	y = 2;
	z = 3;

	printf("This is a test programm\n");
	printf("x: %d\n", x);
	printf("y: %d\n", y);
	printf("z: %d\n", z);
	printf("argc: %d\n", argc);

	for (int i = 0; i < argc; i++) 
		printf("%s: \n", argv[i]);

	return 0;
}
