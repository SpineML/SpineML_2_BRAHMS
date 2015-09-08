/*
 * NB: This doesn't seem to work, and I don't think it was used.
 */

#include <stdio.h>
#include "rng.h"
#include <climits>

#define DUMMY 11

#define SERIES_LENGTH 16

// Return true if the series are the same
bool compareSeries (float* start, float* cur)
{
    bool rtn (true);
    int i = 0;
    while (i < SERIES_LENGTH) {
        if (i > 0) {
            printf ("Compare %f and %f\n", start[i], cur[i]);
        }
        if (start[i] != cur[i]) {
            printf ("false; start[i] = %f != cur[i] = %f\n", start[i], cur[i]);
            rtn = false;
            break;
        }
        ++i;
    }
    return rtn;
}

int main()
{
    RngData rd;
    float rn;
    long long int i;

    float fseries[32];
    float startseries[32];

    rngDataInit (&rd);
    zigset(&rd, DUMMY);
    rd.seed = 1;

    while (i < SERIES_LENGTH) {
        startseries[i%SERIES_LENGTH]=_randomNormal ((&rd));
        printf ("startseries[%lld] = %f\n", i%SERIES_LENGTH, startseries[i%SERIES_LENGTH]);
        i++;
    }
    while (i < LLONG_MAX) {
        rn = _randomNormal ((&rd));
        fseries[i%SERIES_LENGTH]=rn;
        if (!compareSeries (startseries, fseries)) {
            printf ("Cycle ended at %lld\n", i-SERIES_LENGTH);
            break;
        }
        i++;
    }
    return i;
}

// g++ -o testrng testrng.cpp -lm
