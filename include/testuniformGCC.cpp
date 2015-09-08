#include <stdio.h>
#include "rng.h"

#define DUMMY 11

int main()
{
    RngData rd;
    float rn;
    int i=0;

    rngDataInit (&rd);
    zigset(&rd, DUMMY);
    rd.seed = 1;

    printf ("seed = %d\n---------\n", rd.seed);
    while (i < 10) {
        rn = uniformGCC ((&rd));
        printf ("%f\n", rn);
        i++;
    }
    return i;
}

//  g++ -o testuniformGCC testuniformGCC.cpp -lm
