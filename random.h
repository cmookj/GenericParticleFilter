/* Prototypes for all user accessible RANLIB routines */

#ifndef __NETLIB_RANDOM__
#define __NETLIB_RANDOM__

#ifdef __cplusplus
extern "C" {
#endif
	
	void advnst(long k);
	float genbet(float aa,float bb);
	float genchi(float df);
	float genexp(float av);
	float genf(float dfn, float dfd);
	float gengam(float a,float r);
	void genmn(float *parm,float *x,float *work);
	void genmul(long n,float *p,long ncat,long *ix);
	float gennch(float df,float xnonc);
	float gennf(float dfn, float dfd, float xnonc);
	float gennor(float av,float sd);
	void genprm(long *iarray,int larray);
	float genunf(float low,float high);
	void getsd(long *iseed1,long *iseed2);
	void gscgn(long getset,long *g);
	long ignbin(long n,float pp);
	long ignnbn(long n,float p);
	long ignlgi(void);
	long ignpoi(float mu);
	long ignuin(long low,long high);
	void initgn(long isdtyp);
	long mltmod(long a,long s,long m);
	void phrtsd(char* phrase,long* seed1,long* seed2);
	float ranf(void);
	void setall(long iseed1,long iseed2);
	void setant(long qvalue);
	void setgmn(float *meanv,float *covm,long p,float *parm);
	void setsd(long iseed1,long iseed2);
	float sexpo(void);
	float sgamma(float a);
	float snorm(void);
	
#ifdef __cplusplus
}
#endif

#endif 

/* Original Contents

extern void advnst(long k);
extern float genbet(float aa,float bb);
extern float genchi(float df);
extern float genexp(float av);
extern float genf(float dfn, float dfd);
extern float gengam(float a,float r);
extern void genmn(float *parm,float *x,float *work);
extern void genmul(long n,float *p,long ncat,long *ix);
extern float gennch(float df,float xnonc);
extern float gennf(float dfn, float dfd, float xnonc);
extern float gennor(float av,float sd);
extern void genprm(long *iarray,int larray);
extern float genunf(float low,float high);
extern void getsd(long *iseed1,long *iseed2);
extern void gscgn(long getset,long *g);
extern long ignbin(long n,float pp);
extern long ignnbn(long n,float p);
extern long ignlgi(void);
extern long ignpoi(float mu);
extern long ignuin(long low,long high);
extern void initgn(long isdtyp);
extern long mltmod(long a,long s,long m);
extern void phrtsd(char* phrase,long* seed1,long* seed2);
extern float ranf(void);
extern void setall(long iseed1,long iseed2);
extern void setant(long qvalue);
extern void setgmn(float *meanv,float *covm,long p,float *parm);
extern void setsd(long iseed1,long iseed2);
extern float sexpo(void);
extern float sgamma(float a);
extern float snorm(void);

*/