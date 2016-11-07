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
    rd.seed = 123;

    printf ("Test randomUniform.\nseed = %d\n---------\n", rd.seed);
    while (i < 1000) {
        rn = _randomUniform ((&rd));
        printf ("%f\n", rn);
        i++;
    }
    return i;
}

//  g++ -o testnormal testnormal.cpp -lm
