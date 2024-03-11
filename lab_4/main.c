#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

int Sum(int count, ...);


int main()
{
	int count = 0;
	char buffer[256];
	char* startString = buffer, *stopstring;
	
	fgets(buffer, 256, stdin);

	for (int i = 0; buffer[i] != '\0'; i++)
	{
		if (i == 0 && buffer[i] >= '0' && buffer[i] <= '9') {
			count++;			// first number
		}
		if (buffer[i] == ' ')
		{
			count++;			// next numbers	
		}
	}

	int* numbers = (int*)malloc(count * sizeof(int));

	for (int i = 0; i < count; i++)
	{
		numbers[i] = strtol(startString, &stopstring, 10);

		if (*stopstring == ' ')
		{
			startString = stopstring + 1;
		}
	}

	int sum = 0;
	switch(count)
	{
		case 0:
			sum = Sum(0);
			break;
		case 1:
			sum = Sum(count, numbers[0]);
			break;
		case 2:
			sum = Sum(count, numbers[0], numbers[1]);
			break;
		case 3:
			sum = Sum(count, numbers[0], numbers[1], numbers[2]);
			break;
		case 4:
			sum = Sum(count, numbers[0], numbers[1], numbers[2], numbers[3]);
			break;
		case 5:
			sum = Sum(count, numbers[0], numbers[1], numbers[2], numbers[3], numbers[4]);
			break;
		default:
			printf("Error: invalid count\n");
			break;
	}

	printf("Sum = %d\n", sum);

	free(numbers);
	return 0;
}
