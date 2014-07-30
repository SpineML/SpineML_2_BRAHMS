#include <cstdlib>
#include <cmath>
#include <iostream>
#include <ctime>
#include <sys/time.h>

int seed = 0;
int a_RNG = 1103515245;
int c_RNG = 12345;

int getTime() {
	struct timeval currTime;
	gettimeofday(&currTime, NULL);
	return time(0) | currTime.tv_usec;
}

float uniformGCC() {
	
	seed = abs(seed*a_RNG+c_RNG);
	//float val;
	float seed2 = seed/2147483648.0;
	return seed2;
}

// RANDOM NUMBER GENERATOR 
#define SHR3 (jz=seed, seed^=(seed<<13), seed^=(seed>>17), seed^=(seed<<5),jz+seed)
#define UNI uniformGCC()//(.5 + (signed) SHR3 * .2328306e-9)
#define RNOR (hz=SHR3, iz=hz&127, (abs(hz)<kn[iz])? hz*wn[iz] : nfix())
#define REXP (jz=SHR3, iz=jz&255, ( jz <ke[iz])? jz*we[iz] : efix())
#define RPOIS -log(1.0-UNI)

static unsigned int iz,jz,jsr=123456789,kn[128],ke[256];
static int hz; static float wn[128],fn[128], we[256],fe[256];

float nfix(void) { /*provides RNOR if #define cannot */
    const float r = 3.442620f; static float x, y;
    for(;;){ x=hz*wn[iz];
    if(iz==0){ do{x=-log(UNI)*0.2904764; y=-log(UNI);} while(y+y<x*x);
    return (hz>0)? r+x : -r-x;
    }
    if( fn[iz]+UNI*(fn[iz-1]-fn[iz]) < exp(-.5*x*x) ) return x;
    hz=SHR3; iz=hz&127;if(abs(hz)<(int)kn[iz]) return (hz*wn[iz]);
    }
}
float efix(void) { /*provides REXP if #define cannot */
    float x;
    for(;;){
        if(iz==0) return (7.69711-log(UNI));
        x=jz*we[iz];
        if( fe[iz]+UNI*(fe[iz-1]-fe[iz]) < exp(-x) ) return (x);
        jz=SHR3; iz=(jz&255);
        if(jz<ke[iz]) return (jz*we[iz]);
    }
}



// == This procedure sets the seed and creates the tables ==
void zigset(unsigned int jsrseed) {

    clock();

    const double m1 = 2147483648.0, m2 = 4294967296.;
    double dn=3.442619855899,tn=dn,vn=9.91256303526217e-3, q;
    double de=7.697117470131487, te=de, ve=3.949659822581572e-3;
    int i; jsr=jsrseed;
    
   /* Tables for RNOR: */
    q=vn/exp(-.5*dn*dn);
    kn[0]=(dn/q)*m1; kn[1]=0;
    wn[0]=q/m1; wn[127]=dn/m1;
    fn[0]=1.; fn[127]=exp(-.5*dn*dn);
    for(i=126;i>=1;i--) {
        dn=sqrt(-2.*log(vn/dn+exp(-.5*dn*dn)));
        kn[i+1]=(dn/tn)*m1; tn=dn;
        fn[i]=exp(-.5*dn*dn); wn[i]=dn/m1;
    }
     /* Tables for REXP */
    q = ve/exp(-de);
    ke[0]=(de/q)*m2; ke[1]=0;
    we[0]=q/m2; we[255]=de/m2;
    fe[0]=1.; fe[255]=exp(-de);
    for(i=254;i>=1;i--) {
        de=-log(ve/de+exp(-de));
        ke[i+1]= (de/te)*m2; te=de;
        fe[i]=exp(-de); we[i]=de/m2;
    }
}

int slowBinomial(int N, float p) {
	
	int num = 0;
	for (int i = 0; i < N; ++i) {
		if (UNI < p)
			++num;
	}
	
	return num;
}

float qBinVal = -1;
float sBinVal;
float rBinVal;
float aBinVal;

int fastBinomial(int N, float p) {
	
	// setup the computationally intensive vals
	if (qBinVal == -1) {
		qBinVal = 1-p;
		sBinVal = p/qBinVal;
		aBinVal = (N+1)*sBinVal;
		rBinVal = pow(qBinVal,N);
	}
	
	float r = rBinVal;
	float u = UNI;
	int x = 0;

	while (u>r) {
		u=u-rBinVal;
		x=x+1;
		r=((aBinVal/float(x))-sBinVal)*r;
	}
	
	return x;
}




#define randomUniform uniformGCC()
#define randomNormal RNOR
#define randomExponential REXP
#define randomPoisson RPOIS
#define HACK_MACRO(N,p) 1;int spks=fastBinomial(N,p);for(unsigned int i=0;i<spks;++i) {DATAOutspike.push_back(num);}
