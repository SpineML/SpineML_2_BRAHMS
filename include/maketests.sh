#!/bin/sh

# Compile the little testing programs

g++ -o testpoisson testpoisson.cpp -lm -O0 -g
g++ -o testnormal testnormal.cpp -lm -O0 -g
g++ -o testuniform testuniform.cpp -lm -O0 -g
g++ -o testexponential testexponential.cpp -lm -O0 -g
g++ -o testuniformGCC testuniformGCC.cpp -lm -O0 -g
