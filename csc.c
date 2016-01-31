
#include <stdio.h>

int main()
{
    double x = 0.1;
    printf("%e\n", x);
    for (long i = 0; i < 20; ++i)
    {
        x = 3.7 * x * (1 - x);
        printf("%e\n", x);
    }
    return 0;
}
