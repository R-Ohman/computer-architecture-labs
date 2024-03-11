#include <stdio.h>
#include <math.h>

double objetosc_cysterny(double l, double d);

float compute(float a, float b, float* wynik);

float compute2(int r);

int main()
{
	{
		int a = 3;
		float wynik = compute2(a);

	}

	float a = 1.0 + pow(2.0, -23);
	float b = 10.75f;
	float wynik = 0.0f;
	compute(a, b, &wynik);

	double l;
	double d;

	scanf_s("%lf", &l);
	scanf_s("%lf", &d);

	double v = objetosc_cysterny(l, d);

	printf("Objetosc (l=%f, d=%f) = %lf\n", l, d, v);

	return 0;
}