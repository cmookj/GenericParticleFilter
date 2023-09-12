//
//  GenericParticleFilter.m
//  SequentialMonteCarlo
//
//  Created by Changmook Chun on Wed Nov 05 2003.
//  Copyright (c) 2003 Seoul National University. All rights reserved.
//

#import "GenericParticleFilter.h"
#import "MathMatrix.h"
#import "GenericSystem.h"
#import "random.h"
#import "MathUtil.h"
#import "stdlib.h"

#define CONST_DEFAULT_CAPACITY				200
#define CONST_DEFAULT_DOMAIN_LOWER_BOUND	0.0
#define CONST_DEFAULT_DOMAIN_UPPER_BOUND	10.0
#define CONST_DEFAULT_DOMAIN_NUM_STEP		100

enum {
	CONST_RESAMPLE_SCHEME_RESIDUAL = 0,
	CONST_RESAMPLE_SCHEME_SYSTEMATIC,
	CONST_RESAMPLE_SCHEME_MULTINOMIAL
};


// *****************************************************************************
//
//  PRIVATE METHODS
//
// *****************************************************************************
@interface GenericParticleFilter (PrivateMethods)

- (void) initializeParticleFilter;
// This function prepares simulation.
// It sets initial value of particles to 0.0
// and initial weights to 1.0.
// This function should be called before every particle filtering.

- (void) importanceSampleAtIndex:(unsigned)index;
// This function is the main engine of the particle filter.
// See the comments at the implementation of this function below.

- (void) resampleByMultinomialAtIndex:(unsigned)index;
// This function does multinomial resampling.

- (void) finishResamplingUsingNewIndices:(unsigned *)newIndices
                                 atIndex:(unsigned)index;
// This function calculates new indeces.
// It is called by resampleByMultinomialAtIndex:(unsigned) only.

- (void) setHistogram: (NSMutableArray *)theHistogram;
// An access method.

- (void) setInitialized: (BOOL)flag;
// An access method.
// This function is called when initializeParticleFilter: succeeded.

- (void) reallocResourcesWithNewCount;
// When time span has changed, the particle filter should
// re-allocated memory resources.
// This function does the work.

- (void) reallocResourcesWithNewSystem;
// When new system is attached to the particle filter,
// the filter should re-allocate memory resources accordingly.
// This function does the work.

- (void) estimateStatesAtIndex: (unsigned)index;
// This function estimates states at the index given.

- (BOOL) bernoulli;
// This function mimics Bernoulli trial.

@end



// *****************************************************************************
//
//  IMPLEMENTATION BEGINS HERE
//
// *****************************************************************************

@implementation GenericParticleFilter

#pragma mark Initialization & Deallocation

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOCATION
//
// *****************************************************************************

- (id) init {
	// the default number of particles is #define'd.
	return [self initWithCapacity: CONST_DEFAULT_CAPACITY
                      forSystem: nil
            withSelectionScheme: PF_CONST_RESAMPLE_MULTINOMIAL];
}

// this is the designated initializer of this class
- (id) initWithCapacity: (unsigned)num
              forSystem: (GenericSystem *)theSystem
    withSelectionScheme: (unsigned)theScheme {
  
	unsigned i, timeCount;
	unsigned dimX, dimY;
	double step;
	
	iterationLimit = 200UL;
	
	if (self = [super init]) {
		count = num;
		system = theSystem;
		scheme = theScheme;
		
		if ( theSystem ) { // system to estimate is given
			// get properties of the system
			timeCount = [[theSystem timeSpan] count];
			dimX = [theSystem dimX];
			dimY = [theSystem dimY];
      
			// set the domain of histogram to the default values
			domain = [[MathMatrix alloc] initWithType:@"double"
                                          width:(CONST_DEFAULT_DOMAIN_NUM_STEP + 1)
                                         height:1UL];
			
			step = (double)CONST_DEFAULT_DOMAIN_UPPER_BOUND
      - (double)CONST_DEFAULT_DOMAIN_LOWER_BOUND;
			step /= (double)CONST_DEFAULT_DOMAIN_NUM_STEP;
			
			for ( i = 0; i <= CONST_DEFAULT_DOMAIN_NUM_STEP; i++ ) {
				((double*)[domain elements])[i] = CONST_DEFAULT_DOMAIN_LOWER_BOUND
        + (step * (double)i);
			}
			
			// allocate resource for storage of estimated states
			estimate = [[MathMatrix alloc] initWithType:@"double"
                                            width:timeCount
                                           height:dimX];
			
			// allocate arrays
			particles = [[NSMutableArray alloc] init];
			weights = [[NSMutableArray alloc] init];
			particlesPredicted = [[NSMutableArray alloc] init];
			measurementsPredicted = [[NSMutableArray alloc] init];
			histogram = [[NSMutableArray alloc] init];
			
			// add data structures to corresponding arrays
			for ( i = 0; i < timeCount; i++ ) {
				// particles, particlesPredicted and histogram
				[particles addObject:
         [[MathMatrix alloc] initWithType:@"double"
                                    width:count
                                   height:dimX]];
				
				[particlesPredicted addObject:
         [[MathMatrix alloc] initWithType:@"double"
                                    width:count
                                   height:dimX]];
				
				[histogram addObject:
         [[MathMatrix alloc] initWithType:@"unsigned"
                                    width:CONST_DEFAULT_DOMAIN_NUM_STEP
                                   height:dimX]];
				
				[measurementsPredicted addObject:
         [[MathMatrix alloc] initWithType:@"double"
                                    width:count
                                   height:dimY]];
				
				[weights addObject:
         [[MathMatrix alloc] initWithType:@"double"
                                    width:count
                                   height:1UL]];
			}
		}
	}
	return self;
}

- (void) dealloc {
	[domain release];
	[estimate release];
	
	[particles removeAllObjects];
	[particles release];
	
	[weights removeAllObjects];
	[weights release];
	
	[particlesPredicted removeAllObjects];
	[particlesPredicted release];
	
	[measurementsPredicted removeAllObjects];
	[measurementsPredicted release];
	
	[histogram removeAllObjects];
	[histogram release];
  
  //	[system release];
	
	[super dealloc];
}



#pragma mark -
#pragma mark Accessors

// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
- (unsigned) count {
	return count;
}

- (void) setCount:(unsigned)theCount {
	if ( count != theCount ) {  // The number of particles will change.
    // We should reallocate data structures.
		count = theCount;
		if ( system ) { // The particle filter is connected to a system.
			[self reallocResourcesWithNewCount];
		}
	}
}

- (NSMutableArray *) particles {
	return particles;
}

- (NSMutableArray *) weights {
	return weights;
}

- (NSMutableArray *) particlesPredicted {
	return particlesPredicted;
}

- (NSMutableArray *) measurementsPredicted {
	return measurementsPredicted;
}

- (NSMutableArray *) histogram {
	return histogram;
}

- (MathMatrix *)domain {
	return domain;
}

- (void) setDomain:(MathMatrix *)theDomain {
	[theDomain retain];
  
	if ( [theDomain count] == [domain count] ) {
		// The number of ticks in the domain vector does not change.
		[domain release];
		domain = theDomain;
	} else {
		// The number of ticks in the domain vector changed.
		// So, we should reallocate histogram.
		NSMutableArray *newHistogram;
		unsigned i;
		
		[domain release];
		domain = theDomain;
		
		newHistogram = [[NSMutableArray alloc] init];
		for ( i = 0; i < [[system timeSpan] count]; i++ ) {
			[newHistogram addObject:[[MathMatrix alloc]
                               initWithType:@"unsigned"
                               width:([domain count] - 1)
                               height:[system dimX]]];
		}
		
		[self setHistogram: newHistogram];
	}
	return;
}

- (GenericSystem *) system {
	return system;
}

- (void) setSystem:(GenericSystem *)theSystem {
	[theSystem retain];
	[system release];
	
	if ((theSystem != system) && (theSystem)) {
		system = theSystem;
		[self reallocResourcesWithNewSystem];
	}
}

- (unsigned) scheme {
	return scheme;
}

- (void) setScheme:(unsigned)theScheme {
	scheme = theScheme;
}

// random number generator
- (unsigned)RNGIDForResampler {
	return RNGIDForResampler;
}

- (void)setRNGIDForResampler: (unsigned)genId {
	if ( [RNGenerator occupySlot:genId] ) {
		RNGIDForResampler = genId;
	} else {
		NSLog(@"Setting RNG id for resampler failed.");
	}
}

- (unsigned)RNGIDForBernoulli {
	return RNGIDForBernoulli;
}

- (void)setRNGIDForBernoulli: (unsigned)genId {
	if ( [RNGenerator occupySlot:genId] ) {
		RNGIDForBernoulli = genId;
	} else {
		NSLog( @"Setting RNG id for estimator failed.");
	}
}

- (RandomNumberGenerator *)RNGenerator {
	return RNGenerator;
}

- (void)setRNGenerator: (RandomNumberGenerator *)gen {
	[gen retain];
	[RNGenerator release];
	
	RNGenerator = gen;
}

// accessors for windowSize
- (unsigned)windowSize {
	return windowSize;
}

- (void)setWindowSize:(unsigned)theSize {
	windowSize = theSize;
}

// accessors for iterationLimit
- (unsigned) iterationLimit {
	return iterationLimit;
}

- (void) setIterationLimit: (unsigned)il {
	iterationLimit = il;
}


- (BOOL)isStateEstimator {
	return isStateEstimator;
}

- (void)enableStateEstimator: (BOOL)flag {
	isStateEstimator = flag;
}

- (BOOL)isParameterEstimator {
	return isParameterEstimator;
}

- (void)enableParameterEstimator : (BOOL)flag {
	isParameterEstimator = flag;
}

// Note that GenericParticleFilter class does NOT have timeSpan as
// data member. These access methods returns the timeSpan of system and
// sets new timeSpan of the system, respectively.
// setTimeSpan:(MathMatrix *) method also reallocate resources accordingly.
- (MathMatrix *) timeSpan {
	return [system timeSpan];
}

- (void) setTimeSpan: (MathMatrix *)newTimeSpan {
	[system setTimeSpan: newTimeSpan];
	[self reallocResourcesWithNewSystem];
}


// *****************************************************************************
//
//  ENGINE METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Engine Methods

- (void) estimateStates {
	unsigned i, tmax;
	
	// 1. initialize particle filter
	[self initializeParticleFilter];
	[self estimateStatesAtIndex: 0];
	
	// 2. iterate importance sampling and resampling steps
	tmax = [[system timeSpan] count];
	for ( i = 1; i < tmax; i++ ) {  // i is 0-based index
		// 2a. importance sampling and resample step
		[self importanceSampleAtIndex:i];
		
		// 2b. estimate states by calculating the mean of particles
		[self estimateStatesAtIndex: i];
	}
}

- (void) estimateStatesAtIndex: (unsigned)index {
	unsigned i, j, ctr;
	double sum, val;
	
	// index means time
	MathMatrix *currentParticles = [particles objectAtIndex:index];
	
	for ( i = 1; i <= [system dimX]; i++ ) {	// estimate i'th component
		sum = 0.0;
		ctr = 0UL;
		for ( j = 1; j <= count; j++ ) {	// there are (count) particles
			val = [currentParticles doubleValueAtRow:i column:j];
			if ( isnan(val) ) {	// val is NaN
				NSLog(@"NaN occurred in [GenericParticleFilter estimateStatesAtIndex:");
				continue;
			} else {
				sum += val;
				ctr++;
			}
      
		}
		sum /= (double)ctr;
    
		// write the mean of the i'th component
		[estimate setDoubleValue:sum atRow:i column:(index + 1)];
	}
}

// parameter estimator (auxiliary particle filter)
- (void) estimateParametersUsingAuxParticleFilter {
	
}

// parameter estimator (measurement comparison method)
- (void) estimateParametersUsingMeasurementComparison {
  
	// Here, I adopt Nelder-Mead simplex (amoeba) algorithm.
	// The summary of the algorithm is as follows:
	// =========================================================================
	// The amoeba algorithm maintains at each iteration a nondegenerate simplex,
	// a geometric figure in n dimensions of nonzero volume that is the
	// convex hull of n+1 vertices, x_0, x_1, ... , x_n, and their respective
	// function values.
	// In each iteration, new points are computed, along with their function values,
	// to form a new simplex. The algorithm terminates when the function values
	// at the vertices of the simplex satisfy a predetermined condition.
	//
	// One iteration of the amoeba algorithm consists of the following steps:
	//
	// 1. Order: Order and re-label the n+1 vertices as x_0, x_1, ... , x_n,
	//    such that F(x_0) <= F(x_1) <= ... <= F(x_n).
	//    Since we want to minimize, we refer to x_0 as the best vertex or point,
	//    to x_n as the worst point, and to x_{n-1} as the next-worst point.
	//    Let \overline{x} refer to the centroid of the n best points in the vertex
	//    (i.e., all vertices except for x_n.):
	//    \overline{x} = \sum_{i=x_0}^{x_{n-1}}x_i / n
	//
	// 2. Reflect: Compute the reflection point x_r,
	//    x_r = \overline{x} + \alpha(\overline{x} - x_n).
	//	  Evaluate F(x_r). If F(x_0) <= F(x_r) < F(x_n), accept the reflected
	//    point x_r and terminate the iteration.
	//
	// 3. Expand: If F(x_r) < F(x_0), compute the expansion point x_e,
	//    x_e = x_r + \beta (x_r - \overline{x}).
	//    If F(x_e) < F(x_r), accept x_e and terminate the iteration;
	//    otherwise (i.e., if F(x_r) <= F(x_e)) accept x_r and terminate the
	//    iteration.
	//
	// 4. Contract: If F(x_r) > F(x_{n-1}), perform a contraction between
	//    \overline{x} and x_n
	//    x_c = \overline{x} + \zeta (\overline{x} - x_n).
	//	  If F(x_c) <= F(x_n), accept x_c and terminate the iteration.
	//
	// 5. Shrink Simplex: Evaluate F at the n new vertices for i=1, ..., n.
	//    x_i = x_0 + \eta (x_i - x_0).
	//
	// For the four coefficients, the standard values reported in the
	// literature are: \alpha = 1, \beta = 1, \zeta = 0.5, \eta = 0.5.
  
	
	
	// Basic idea to calculate the value of objective function
	// =======================================================
	//
	// 1. Given a set of parameters,
	//    Run Particle Filtering.
	//    Now we have {x^_0, x^_1, ... , x^_n}.
	// 2. Generate noise-free measurements.
	//    Now we have {yb_0, yb_1, ... , yb_n} = Yb.
	// 3. Compare Yb with actual measurements Y.
	// 4. The difference between Y and Yb is the value of objective function.
	//    Hence, we should minimize it.
	
	
	
	//
	// 0. Preparation
	// ==============
	//
	//  Allocate resources and prepare simulation.
	//
  
	// For iteration indeces.
	unsigned i, j, ti;
	
	// RMS of the difference between actual measurements and
	// noise-free artificial measurements.
	double rms, temp;
	
	// number of iterations
	unsigned counter;
	
	// number of parameters (n)
	unsigned paramCount = [[system parameters] count];
	
	// Storage for (n + 1) sets of parameters.
	NSMutableArray *vertices = [NSMutableArray arrayWithCapacity:0UL];
	
	// Storage for one set of parameters.
	MathMatrix *vertex;
	
	// Storage for the history of optimization. It stores all values of the
	// objective function for each vertex.
	NSMutableArray *allObjectiveFunctionValues = [NSMutableArray arrayWithCapacity:0UL];
	
	// Storage for the values of the objective function for a specific time.
	MathMatrix *objectiveFunctionValues;
	
	// storage for noise-free measurements
	MathMatrix *noiseFreeMeasurements =
    [[MathMatrix alloc] initWithType:@"double"
                               width:[[system timeSpan] count]
                              height:[system dimY]];
	
	// temporary storage for current state and measurement
	MathMatrix *currentState =
    [[MathMatrix alloc] initWithType:@"double"
                               width:1UL
                              height:[system dimX]];
	MathMatrix *currentMeasurement =
    [[MathMatrix alloc] initWithType:@"double"
                               width:1UL
                              height:[system dimY]];
	
	//
	// 1. Initialize the vertices (sets of parameters).
	// ================================================
	//
	// The initial values of the sets of parameters, i.e., (n + 1) vertices.
	//
	//          1st vertex:   0.0   0.0   0.0   0.0   ...   0.0
	//          2nd vertex:   1.0   0.0   0.0   0.0   ...   0.0
	//          3rd vertex:   0.0   1.0   0.0   0.0   ...   0.0
	//          4th vertex:   0.0   0.0   1.0   0.0   ...   0.0
	//             ...                       ...
	//    (n + 1)th vertex:   0.0   0.0   0.0   0.0   ...   1.0
	//
	// Note that each vertex is column vector.
	
	vertex = [[MathMatrix alloc] initWithType:@"double"
                                      width:1UL
                                     height:paramCount];
	[vertices addObject:vertex];
	[vertex release];
	
	// The other sets of parameters has 1.0
	for ( i = 1UL; i <= paramCount; i++ ) {
		vertex = [[MathMatrix alloc] initWithType:@"double"
                                        width:1UL
                                       height:paramCount];
		[vertex setDoubleValue:1.0 atRow:i column:1UL];
		[vertices addObject:vertex];
		[vertex release];
	}
	
	//
	// Run through optimization process
	// ================================
	//
	for ( counter = 1UL; counter <= iterationLimit; counter++ ) {
		objectiveFunctionValues  =
      [[MathMatrix alloc] initWithType:@"double"
                                 width:1UL
                                height:(paramCount + 1)];
		//
		// For (n + 1) vertices ...
		//
		for ( i = 1UL; i <= (paramCount + 1); i++ ) {
			//
			// 2.1 Run particle filtering.
			// ===========================
			[self estimateStates];
			
			//
			// 2.2 Generate noise-free measurements
			// ====================================
			for ( ti = 1UL; ti <= [[system timeSpan] count]; ti++ ) {
				[estimate getVector:currentState atColumn:ti];
				[system getNoiseFreeMeasurement:currentMeasurement
                            atTimeIndex:ti
                       withCurrentState:currentState];
				[noiseFreeMeasurements setVector:currentMeasurement
                                atColumn:ti];
			}
			
			//
			// 2.3 Compare Yb with actual measurements
			// =======================================
			// For now, use RMS (root mean square) to compare actual measurements
			// with noise-free measurements.
			rms = 0.0;
			for ( ti = 1UL; ti <= [[system timeSpan] count]; ti++ ) {
				temp = 0.0;
				for ( j = 1UL; j <= [system dimY]; j++ ) {
					temp += pow(([[system Y] doubleValueAtRow:j column:ti] -
                       [noiseFreeMeasurements doubleValueAtRow:j column:ti]), 2);
				}
				rms += temp;
			}
			rms = sqrt(rms);
			
			[objectiveFunctionValues setDoubleValue:rms
                                        atRow:i
                                       column:1UL];
		}
		
		//
		// 3. Modify the vertices using Nelder-Mead simplex algorithm.
		//
		
		//
		// 3.1 Order
		// ---------
		
		
		
		[objectiveFunctionValues release];
	}
	
	//
	// 6. Cleanup
	// ==========
	//
	[vertices removeAllObjects];
	[vertices release];
	[allObjectiveFunctionValues removeAllObjects];
	[allObjectiveFunctionValues release];
  
	
	[noiseFreeMeasurements release];
	[currentState release];
	[currentMeasurement release];
}

// parameter estimator (SPSA)
- (void)estimateParametersUsingSPSAWithAlpha: (double) alpha
                                       gamma: (double) gamma
                                           a: (double) a
                                           c: (double) c
                                           A: (double) A
{
	NSString *fileName;
	unsigned i, k, tmax, kmax, im1;
	double a_k, c_k;
	double di, theta_i;
	double grad1, grad2, grad3, grad4, grad;
	unsigned d = [[system parameters] count];	// number of parameters
  // to estimate
	unsigned xdim = [system dimX];
	unsigned ydim = [system dimY];
	
	MathMatrix* delta = [[MathMatrix alloc] initWithType:@"double"
                                                 width:1UL
                                                height:d];
  
	// theta: parameter estimated
	MathMatrix* theta = [[MathMatrix alloc] initWithType:@"double"
                                                 width:1UL
                                                height:d];
	
	// theta_p: theta + c_k*delta
	MathMatrix* theta_p = [[MathMatrix alloc] initWithType:@"double"
                                                   width:1UL
                                                  height:d];
	// theta_m: theta - c_k*delta
	MathMatrix* theta_m = [[MathMatrix alloc] initWithType:@"double"
                                                   width:1UL
                                                  height:d];
	
	// X_p: X+ (k-1)L+1:kL
	MathMatrix* X_p = [[MathMatrix alloc] initWithType:@"double"
                                               width:windowSize
                                              height:xdim];
	
	// X_m: X- (k-1)L+1:kL
	MathMatrix* X_m = [[MathMatrix alloc] initWithType:@"double"
                                               width:windowSize
                                              height:xdim];
	
	// X_pt: X+~ (k-1)L+1:kL
	MathMatrix* X_pt = [[MathMatrix alloc] initWithType:@"double"
                                                width:windowSize
                                               height:xdim];
	
	// Y_p: Y+ (k-1)L+1:kL
	MathMatrix* Y_p = [[MathMatrix alloc] initWithType:@"double"
                                               width:windowSize
                                              height:ydim];
	
	// X_mt: X-~ (k-1)L+1:kL
	MathMatrix* X_mt = [[MathMatrix alloc] initWithType:@"double"
                                                width:windowSize
                                               height:xdim];
	
	// Y_m: Y- (k-1)L+1:kL
	MathMatrix* Y_m = [[MathMatrix alloc] initWithType:@"double"
                                               width:windowSize
                                              height:ydim];
	
	// temporary storage
	MathMatrix* x_temp_i = [[MathMatrix alloc] initWithType:@"double"
                                                    width:1UL
                                                   height:xdim];
	
	MathMatrix* x_temp_o = [[MathMatrix alloc] initWithType:@"double"
                                                    width:1UL
                                                   height:xdim];
	
	MathMatrix* y_temp = [[MathMatrix alloc] initWithType:@"double"
                                                  width:1UL
                                                 height:ydim];
	
	MathMatrix* y = [[MathMatrix alloc] initWithType:@"double"
                                             width:1UL
                                            height:ydim];
	
	MathMatrix* x = [[MathMatrix alloc] initWithType:@"double"
                                             width:1UL
                                            height:xdim];
	
	MathMatrix* vecGrad = [[MathMatrix alloc] initWithType:@"double"
                                                   width:1UL
                                                  height:d];
	
	MathMatrix* allTheta;
  
	
	// The initial guess for the parameters are all assumed to be 1.0
	for ( i = 1; i <= d; i++ ) {
		[theta setDoubleValue:0.45 atRow:i column:1UL];
	}
  
	tmax = [[system timeSpan] count];
	kmax = tmax / windowSize;
	
	allTheta = [[MathMatrix alloc] initWithType: @"double"
                                        width: kmax
                                       height: d];
	
	for ( k = 1; k <= kmax; k++ ) {
		
		//
		// 1. Sampling step
		//
		// 1.a Build-up Delta vector using Bernoulli trials
		//
		[RNGenerator setCurrentGenerator:RNGIDForBernoulli];
		for ( i = 1; i <= d; i++ ) {
			if ( [self bernoulli] ) {
				[delta setDoubleValue:1.0
                        atRow:i
                       column:1UL];
			} else {
				[delta setDoubleValue:-1.0
                        atRow:i
                       column:1UL];
			}
		}
		
		a_k = a / pow(A + (double)k + 1.0, alpha);
		c_k = c / pow((double)k + 1.0, gamma);
		
		//
		// 1.b Calculate theta_p & theta_m
		//
		for ( i = 1; i <= d; i++ ) {
			di = [delta doubleValueAtRow:i column:1UL];
			theta_i = [theta doubleValueAtRow:i column:1UL];
			di *= c_k;
			[theta_p setDoubleValue:(theta_i + di) atRow:i column:1UL];
			[theta_m setDoubleValue:(theta_i - di) atRow:i column:1UL];
		}
		
		//
		// 1.c Sample X+, X-, X~+, Y+, X~-, Y-
		//
		for ( i = 0; i < windowSize; i++ ) {
			
			if ( i == 0 ) {
				im1 = windowSize;
			} else {
				im1 = i;
			}
			
			//
			// 1. X+
			// ------------------------
			// x_temp_i: previous state
			[X_p getVector:x_temp_i atColumn:im1];
			
			[system getNextState: x_temp_o
               atTimeIndex: ((k - 1)*windowSize + i)
          withCurrentState: x_temp_i
                parameters: theta_p
                   control: nil];
			
			// x_temp_o: next state
			[X_p setVector:x_temp_o atColumn:(i + 1)];
			
			//
			// 2. X-
			// ------------------------
			// x_temp_i: previous state
			[X_m getVector:x_temp_i atColumn:im1];
			
			[system getNextState: x_temp_o
               atTimeIndex: ((k - 1)*windowSize + i)
          withCurrentState: x_temp_i
                parameters: theta_m
                   control: nil];
			
			// x_temp_o: next state
			[X_m setVector:x_temp_o atColumn:(i + 1)];
			
			//
			// 3. X~+
			// ------------------------
			// x_temp_i: previous state
			[X_pt getVector:x_temp_i atColumn:im1];
			
			[system getNextState: x_temp_o
               atTimeIndex: ((k - 1)*windowSize + i)
          withCurrentState: x_temp_i
                parameters: theta_p
                   control: nil];
			
			// x_temp_o: next state
			[X_pt setVector:x_temp_o atColumn:(i + 1)];
			
			//
			// 4. Y+
			// ------------------------
			[system getMeasurement: y_temp
                 atTimeIndex: ((k - 1)*windowSize + i + 1)
            withCurrentState: x_temp_o
                  parameters: theta_p];
			
			[Y_p setVector:y_temp atColumn:(i + 1)];
			
			//
			// 5. X~-
			// ------------------------
			// x_temp_i: previous state
			[X_mt getVector:x_temp_i atColumn:im1];
			
			[system getNextState: x_temp_o
               atTimeIndex: ((k - 1)*windowSize + i)
          withCurrentState: x_temp_i
                parameters: theta_m
                   control: nil];
			
			// x_temp_o: next state
			[X_mt setVector:x_temp_o atColumn:(i + 1)];
			
			//
			// 6. Y-
			// ------------------------
			// x_temp_i: previous state
			[system getMeasurement: y_temp
                 atTimeIndex: ((k - 1)*windowSize + i + 1)
            withCurrentState: x_temp_o
                  parameters: theta_m];
			
			[Y_m setVector:y_temp atColumn:(i + 1)];
      
		}
		
		
		//
		// 2. Gradient estimation step
		// ===========================
		grad1 = grad2 = grad3 = grad4 = 1.0;
		for ( i = 1; i <= windowSize; i++ ) {
			// actual measurement of the system
			[[system Y] getVector:y atColumn:((k - 1)*windowSize + i)];
			
			// 1. g_{thata+}(Y+ | X+)
			[Y_p getVector:y_temp atColumn:i];
			[X_p getVector:x atColumn:i];
			
			grad1 *= [system probabilityOf: y_temp
                               given: x
                         atTimeIndex: ((k - 1)*windowSize + i)
                      withParameters: theta_p];
			
			// 2. g_{theta+}(Y | X+)
			grad2 *= [system probabilityOf: y
                               given: x
                         atTimeIndex: ((k - 1)*windowSize + i)
                      withParameters: theta_p];
			
			// 3. g_{theta-}(Y- | X-)
			[Y_m getVector:y_temp atColumn:i];
			[X_m getVector:x atColumn:i];
			
			grad3 *= [system probabilityOf: y_temp
                               given: x
                         atTimeIndex: ((k - 1)*windowSize + i)
                      withParameters: theta_m];
			
			// 4. g_{theta-}(Y | X-)
			grad4 *= [system probabilityOf: y
                               given: x
                         atTimeIndex: ((k - 1)*windowSize + i)
                      withParameters: theta_m];
			
		}
		grad = grad1 - grad2 - grad3 + grad4;
		
		for ( i = 1; i <= d; i++ ) {
			[vecGrad setDoubleValue: (grad/(c_k * [delta doubleValueAtRow:i column:1UL]) )
                        atRow: i
                       column: 1UL];
		}
		
		//
		// 3. Parameter updating step
		//
		for ( i = 1; i <= d; i++ ) {
			[theta setDoubleValue:
       ([theta doubleValueAtRow:i column:1UL]
				- a_k * [vecGrad doubleValueAtRow:i column:1UL])
       
                      atRow: i
                     column: 1UL];
		}
		[allTheta setVector:theta atColumn:k];
	}
	
	// print the result to file
	for ( i = 1; i <= d; i++ ) {
		fileName = [NSString stringWithFormat:@"param_est_%d", i];
		[allTheta writeRowTransposed: i
                          toFile: fileName ];
	}
  //	[allTheta writeMatrixToFile:@"parameter_estimated"];
	
	[delta release];
	
	[theta release];
	[theta_p release];
	[theta_m release];
	
	[X_p release];
	[X_pt release];
	[X_m release];
	[X_mt release];
	[Y_p release];
	[Y_m release];
	
	[x_temp_i release];
	[x_temp_o release];
	[y_temp release];
	[y release];
	[x release];
	
	[vecGrad release];
	[allTheta release];
}

- (void) meanOfEstimationError: (MathMatrix *)error {
	unsigned i, j;
	double val;
	double *time = (double *)[[system timeSpan] elements];
	
	for ( i = 1; i <= [system dimX]; i++ ) {
		val = 0.0;
		for ( j = 1; j <= [[system timeSpan] count]; j++ ) {	// j means time
			val += ([estimate doubleValueAtRow:i column:j]
              - [[system X] doubleValueAtRow:i column:j]);
		}
		val /= (double)[[system timeSpan] count];
		
		[error setDoubleValue:val atRow:i column:1UL];
	}
}

// *****************************************************************************
//
//  DESCRIPTION
//
// *****************************************************************************
#pragma mark -
#pragma mark Description

- (NSString *)description {
	NSString* about = [NSString stringWithFormat:@"%@\n", [super description]];
	NSString* schemeString;
	
	about = [about stringByAppendingString:@"SUMMARY of GenericParticleFilter\n"];
	about = [about stringByAppendingFormat:@"\tNumber of Particles: %d\n", count];
	
	switch ( scheme ) {
		case PF_CONST_RESAMPLE_RESIDUAL:
			schemeString = @"Residual Resampling";
			break;
			
		case PF_CONST_RESAMPLE_SYSTEMATIC:
			schemeString = @"Systematic Resampling";
			break;
			
		case PF_CONST_RESAMPLE_MULTINOMIAL:
			schemeString = @"Multinomial Resampling";
			break;
	}
	about = [about stringByAppendingFormat:@"\tResampling Scheme: %@\n\n", schemeString];
  
	return about;
}

- (void)makePosteriorDistributionHistogramForStateComponent: (unsigned)i {
	//
	//  NOTE
	//    i is a 1 based index
	//
	int ti;
	MathMatrix* row = [[MathMatrix alloc] initWithType:@"double"
                                               width:count
                                              height:1UL];
	
	if ( !domain ) { // domain is not specified yet
		NSLog(@"The domain of the histogram is not defiend.\n");
		[row release];
		return;
	}
	
	for ( ti = 0; ti < [[system timeSpan] count]; ti++ ) {
		[[particles objectAtIndex:ti] getVector:row atRow:i];
		Hist ( (double *)[row elements], count,
          (double *)[domain elements], [domain count],
          (unsigned *)[[histogram objectAtIndex:ti] elements] );
	}
	
	[row release];
}

- (void)makePredictiveDistributionHistogramForMeasurementComponent: (unsigned)i {
	//
	//  NOTE
	//    i is a 1 based index
	//
	int ti;
	MathMatrix* row = [[MathMatrix alloc] initWithType:@"double"
                                               width:count
                                              height:1UL];
	
	if ( !domain ) { // domain is not specified yet
		NSLog(@"The domain of the histogram is not defiend.\n");
		[row release];
		return;
	}
  
	for ( ti = 0; ti < [[system timeSpan] count]; ti++ ) {
		[[measurementsPredicted objectAtIndex:ti] getVector:row atRow:i];
		Hist ( (double *)[row elements], count,
          (double *)[domain elements], [domain count],
          (unsigned *)[[histogram objectAtIndex:ti] elements] );
	}
	
	[row release];
}

// Only for scalar state systems
- (void)makePosteriorDistributionHistogram {
	int i;
	
	if ( !domain ) { // domain is not specified yet
		NSLog(@"The domain of the histogram is not defined.\n");
		return;
	}
	
	for ( i = 0; i < [[system timeSpan] count]; i++ ) {
		Hist ( (double *)[[particles objectAtIndex:i] elements], count,
          (double *)[domain elements], [domain count],
          (unsigned *)[[histogram objectAtIndex:i] elements] );
	}
	
}

// Only for scalar measurement systems
- (void)makePredictiveDistributionHistogram {
	int i;
	
	if ( !domain ) { // domain is not specified yet
		NSLog(@"The domain of the histogram is not defined.\n");
		return;
	}
	
	for ( i = 0; i < [[system timeSpan] count]; i++ ) {
		Hist ( (double *)[[measurementsPredicted objectAtIndex:i] elements], count,
          (double *)[domain elements], [domain count],
          (unsigned *)[[histogram objectAtIndex:i] elements] );
	}
	
}


// *****************************************************************************
//
//  WRITING TO FILES
//
// *****************************************************************************

#pragma mark -
#pragma mark Writing to Files

- (void)writeParticlesToFile:(NSString *)fName {
	unsigned i, j, k;
	MathMatrix *theArray;
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
	for ( k = 0; k < [system dimX]; k++ ) { // k'th component of particles
		for ( i = 0; i < [particles count]; i++ ) { // number of sets of particles
			theArray = [particles objectAtIndex:i];
			for ( j = k*count; j < (k + 1)*count; j++ ) { // number of particles in a set
				fprintf(FP, " %9.4f", ((double *)[theArray elements])[j]);
			}
			fprintf(FP, "\n");
		}
		fprintf(FP, "\n\n");
	}
	fclose(FP);
}

- (void)writeWeightsToFile:(NSString *)fName {
	unsigned i, j;
	MathMatrix *theArray;
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
	for ( i = 0; i < [weights count]; i++ ) { // number of sets of weights
		theArray = [weights objectAtIndex:i];
		for ( j = 0; j < count; j++ ) { // number of weights in a set
			fprintf(FP, " %9.4f", ((double *)[theArray elements])[j]);
		}
		fprintf(FP, "\n");
	}
	
	fclose(FP);
}

- (void)writeHistogramToFile:(NSString *)fName {
	unsigned i, j;
	MathMatrix *theArray;
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
	for ( i = 0; i < [histogram count]; i++ ) { // number of sets of histogram
		theArray = [histogram objectAtIndex:i];
		for ( j = 0; j < [theArray count]; j++ ) { // number of data in a set
			fprintf(FP, " %u", ((unsigned *)[theArray elements])[j]);
		}
		fprintf(FP, "\n");
	}
	
	fclose(FP);
}

- (void)writeHistogramForGnuplotToFile:(NSString *)fName {
	unsigned i, j;
	MathMatrix *theArray;
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
	for ( i = 0; i < [histogram count]; i++ ) { // number of sets of histogram
		theArray = [histogram objectAtIndex:i];
		for ( j = 0; j < [theArray count]; j++ ) { // number of data in a set
			fprintf(FP, " %9.4f %9.4f %u\n",
              ((double *)[domain elements])[j]
                  + (((double *)[domain elements])[j+1]
                     - ((double *)[domain elements])[j])/2.0,
              ((double *)[[system timeSpan] elements])[i],
              ((unsigned *)[theArray elements])[j]);
		}
		fprintf(FP, "\n\n\n");
	}
	
	fclose(FP);
}

- (void)writeStateToFile:(NSString *)fName {
	unsigned i, j;
	double val;
	double *time = (double *)[[system timeSpan] elements];
    
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
	FILE *FP = fopen(filepath, "w");
  
  fprintf(FP, "#\n#  States\n#\n\n");
  for ( i = 1; i <= [[system timeSpan] count]; i++ ) {	// time
    fprintf(FP, "  %9.4f", time[i-1]);
    
		for ( j = 1; j <= [system dimX]; j++ ) {	// j means state component
			val = [[system X] doubleValueAtRow:j column:i];
			fprintf(FP, "  %9.4f", val);
		}
		fprintf(FP, "\n");
	}
  
	fclose(FP);
}

- (void)writeEstimateToFile:(NSString *)fName {
	unsigned i, j;
	double val;
	double *time = (double *)[[system timeSpan] elements];
	
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
  /*
   for ( i = 1; i <= [system dimX]; i++ ) {	// i'th component
   fprintf(FP, "#\n#  %d'th component\n#\n\n", i);
   for ( j = 1; j <= [[system timeSpan] count]; j++ ) {	// j means time
   val = [estimate doubleValueAtRow:i column:j];
   fprintf(FP, "  %9.4f  %9.4f\n", time[j-1], val);
   }
   fprintf(FP, "\n\n");
   }
   */
	
  fprintf(FP, "#\n#  Estimation Result\n#\n\n");
  for ( i = 1; i <= [[system timeSpan] count]; i++ ) {	// time
    fprintf(FP, "  %9.4f", time[i-1]);
    
		for ( j = 1; j <= [system dimX]; j++ ) {	// j means state component
			val = [estimate doubleValueAtRow:j column:i];
			fprintf(FP, "  %9.4f", val);
		}
		fprintf(FP, "\n");
	}
  
	fclose(FP);
}

- (void)writeEstimationErrorToFile:(NSString *)fName {
	unsigned i, j;
	double val;
	double *time = (double *)[[system timeSpan] elements];
	
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
  /*
   for ( i = 1; i <= [system dimX]; i++ ) {	// i'th component
   fprintf(FP, "#\n#  Error of %d'th component\n#\n\n", i);
   for ( j = 1; j <= [[system timeSpan] count]; j++ ) {	// j means time
   val = [estimate doubleValueAtRow:i column:j]
   - [[system X] doubleValueAtRow:i column:j];
   fprintf(FP, "  %9.4f  %9.4f\n", time[j-1], val);
   }
   fprintf(FP, "\n\n");
   }
   */
  
  fprintf(FP, "#\n#  Estimation Error\n#\n\n");
  for ( i = 1; i <= [[system timeSpan] count]; i++ ) {	// time
    fprintf(FP, "  %9.4f", time[i-1]);
    
		for ( j = 1; j <= [system dimX]; j++ ) {	// j means state component
			val = [estimate doubleValueAtRow:j column:i]
      - [[system X] doubleValueAtRow:j column:i];
			fprintf(FP, "  %9.4f", val);
		}
		fprintf(FP, "\n");
	}
  
	fclose(FP);
}

// *****************************************************************************
//
//  PRIVATE METHODS
//
// *****************************************************************************

#pragma mark -
#pragma mark Private Methods

- (void) initializeParticleFilter {
	unsigned i, j;
	MathMatrix* p = [particles objectAtIndex:0];	// particles at t_0
	MathMatrix* w = [weights objectAtIndex:0];		// weights at t_0
	unsigned* data;
	
	if ( !system ) {	// system is NOT specified yet
		NSLog(@"Initialization of ParticleFilter failed.");
		NSLog(@"System is not specified yet.");
		return;
	}
	
	for ( i = 1; i <= [system dimX]; i++ ) {
		for ( j = 1; j <= count; j++ ) {
			[p setDoubleValue:0.0	// 0 is set to the initial guess
                  atRow:i
                 column:j];
		}
	}
	
	// set all the weights at t_0 to 1.0/(number of particles)
	for ( j = 1; j <= count; j++ ) {
		[w setDoubleValue:1.0/(double)count
                atRow:1UL
               column:j];
	}
	
	// set all the elements of histogram (for all time t_i) to 0
	for ( i = 0; i < [[system timeSpan] count]; i++ ) {
		data = (unsigned*)[[histogram objectAtIndex:i] elements];
		for ( j = 0; j < [[histogram objectAtIndex:i] count]; j++ ) {
			data[j] = 0UL;
		}
	}
}

- (void)importanceSampleAtIndex:(unsigned)index {
	//
	//  DESCRIPTION of the algorithm
	//  ========================================================================
	//
	//		t = t_{i-1}				--->>			t = t_{i}
	//
	//		particles				--->>			Predicted states
	//		(as initial states)						& measurements		----\
	//																		|
	//													   (resampling) --> |
	//																		|
	//												New particles		<---/
	//
	//		Hence, we should integrate the state dynamics of a given system
	//		from t_{i-1} to t_{i} and make virtual measurements at t_{i}.
	//		(If the system dynamics is in discrete form, we calculate
	//		x_{i} from x_{i-1} by using the equation.)
	//
	
	//
	//		<<< NOTE >>>
	//
	//		The input argument, ``index'' is 0-based.
	
	// predicted states & measurements
	MathMatrix *predStates, *predMeasure, *prevParticles;
	MathMatrix *state, *pState, *pMeasure;
	unsigned i, j;
	double val, wSum, t, lik;
	double *weightVal;
	double kEPS = 2.2204e-16;
  
	predStates = [particlesPredicted objectAtIndex:index];
	predMeasure = [measurementsPredicted objectAtIndex:index];
	
	t = ((double *)[[system timeSpan] elements])[index];
	prevParticles = [particles objectAtIndex:(index-1)];
	
	// current state
	state = [[MathMatrix alloc] initWithType:@"double"
                                     width:1UL
                                    height:[system dimX]];
	// predicted state
	pState = [[MathMatrix alloc] initWithType:@"double"
                                      width:1UL
                                     height:[system dimX]];
	// predicted measurement
	pMeasure = [[MathMatrix alloc] initWithType:@"double"
                                        width:1UL
                                       height:[system dimY]];
	
	//  PREDICTION STEP:
	//  ================
	//  We use the transition prior as proposal
	for ( i = 1; i <= count; i++ ) {
		[prevParticles getVector: state
                    atColumn: i];
		
		// calculate x_{index} from x_{index-1} (particles at t_{index-1})
		[system getNextState: pState
             atTimeIndex: index		// it means t_{index}
        withCurrentState: state
                 control: nil];
		
		// copy the states calculated above to predicted particle storage
		for ( j = 1; j <= [system dimX]; j++ ) {
			[pState getValue:&val atRow:j column:1UL];
			[predStates setDoubleValue:val
                           atRow:j
                          column:i];
		}
	}
	
	//  EVALUATE IMPORTANCE WEIGHTS:
	//  ============================
	//  For our choice of proposal, the importance weights are given by:
	wSum = 0.0;
	weightVal = (double *)[[weights objectAtIndex:index] elements];
	
	for ( i = 0; i < count; i++ ) {
		// retrieve a state vector from the predicted particle storage
		[predStates getVector:pState atColumn:(i + 1)];
		
		// make fictitious measurement from the state (at t_{index})
		// note that this measurement does NOT contain measurement noise
		[system getNoiseFreeMeasurement: pMeasure
                        atTimeIndex: index
                   withCurrentState: pState];
		
		// copy the virtual measurements to predicted measurement storage
		for ( j = 1; j <= [system dimY]; j++ ) {
			[pMeasure getValue:&val atRow:j column:1UL];
			[predMeasure setDoubleValue:val atRow:j column:(i + 1)];
		}
		
		// calculate importance weights
		lik = [system importanceWeightAtTimeIndex: index
                     withPredictedMeasurement: pMeasure] + kEPS;
		
		weightVal[i] = lik;
		wSum += lik;
	}
	
	//  normalise the weights
	for ( i = 0; i < count; i++ ) {
		weightVal[i] /= wSum;
	}
	
	//  SELECTION STEP:
	//  ===============
	//  Here, we give you the choice to try three different types of
	//  resampling algorithms. Note that the code for these algorithms
	//  applies to any problem!
	switch ( scheme ) {
		case CONST_RESAMPLE_SCHEME_RESIDUAL:
			//
			// NOT IMPLEMENTED YET !!!
			//
			break;
			
		case CONST_RESAMPLE_SCHEME_SYSTEMATIC:
			//
			// NOT IMPLEMENTED YET !!!
			//
			break;
			
		case CONST_RESAMPLE_SCHEME_MULTINOMIAL:
			[self resampleByMultinomialAtIndex:index];
			break;
	}
	
	[state release];
	[pState release];
	[pMeasure release];
}

- (void)resampleByMultinomialAtIndex:(unsigned)index {
	
	unsigned *N_babies =	(unsigned *)malloc(count * sizeof(unsigned));
	unsigned *out_index =   (unsigned *)malloc(count * sizeof(unsigned));
	double *cumDist =	(double *)malloc(count * sizeof(double));
	double *u =			(double *)malloc(count * sizeof(double));
	double *cumProd =	(double *)malloc(count * sizeof(double));
	double *randNum =	(double *)malloc(count * sizeof(double));
	
	double *currentWeights = (double *)[[weights objectAtIndex:index] elements];
	unsigned i, j, k;
	
	// make a vector containing cumulative sum
	CumulativeSum(currentWeights, cumDist, count);
	
	// generate ``count'' ordered random variables uniformly distributed in [0,1]
	// high speed Niclas Bergman Procedure
	[RNGenerator setCurrentGenerator:RNGIDForResampler];
	for ( i = 0; i < count; i++ ) {
		N_babies[i] = 0;
		randNum[i] = pow(genunf(0.0, 1.0), 1.0/((double)(count - i)));
	}
	CumulativeProduct( randNum, cumProd, count);
	FlipLR( cumProd, u, count);
  
	
	j = 0;
	for ( i = 0; i < count; i++ ) {
		while ( u[i] > cumDist[j] ) {
			j++;
		}
		N_babies[j]++;
	}
	
	// COPY resampled trajectories
	k = 0;
	for ( i = 0; i < count; i++ ) {
		if ( N_babies[i] > 0 ) {
			for ( j = k; j < (k + N_babies[i]); j++ ) {
				out_index[j] = i;
			}
		}
		k += N_babies[i];
	}
  
	[self finishResamplingUsingNewIndices:out_index
                                atIndex:index];
	
	free(N_babies);
	free(out_index);
	free(cumDist);
	free(u);
	free(cumProd);
	free(randNum);
}

- (void)finishResamplingUsingNewIndices:(unsigned *)newIndices
                                atIndex:(unsigned)index {
	
	unsigned i, j;
	MathMatrix *predStates = [particlesPredicted objectAtIndex:index];
	MathMatrix *newParticles = [[MathMatrix alloc] initWithType:@"double"
                                                        width:count
                                                       height:[system dimX]];
	MathMatrix *theState = [[MathMatrix alloc] initWithType:@"double"
                                                    width:1UL
                                                   height:[system dimX]];
	
	for ( i = 0; i < count; i++ ) {
		// get a column vector from predicted states according to new indices
		// Note that newIndices has 0-based indices, hence +1 is required
		// to use getVector:atColumn: which uses 1-based index.
		[predStates getVector:theState atColumn:((newIndices[i] + 1))];
		for ( j = 1; j <= [system dimX]; j++ ) {
			// copy the vector to new particles
			[newParticles setDoubleValue:((double *)[theState elements])[j - 1]
                             atRow:j
                            column:(i + 1)];
		}
    //		[newParticles values][i] = [theStates valueAtIndex:(newIndices[i])];
	}
	[particles replaceObjectAtIndex:index withObject:newParticles];
  
	[newParticles release];
	[theState release];
}

- (void) setHistogram:(NSMutableArray *)theHistogram {
	[theHistogram retain];
	[histogram release];
	
	histogram = theHistogram;
}

- (void) reallocResourcesWithNewCount {
	unsigned timeCount, dimX, dimY, i;
	
	// Release previous structures.
	[particles removeAllObjects];
	[weights removeAllObjects];
	[particlesPredicted removeAllObjects];
	[measurementsPredicted removeAllObjects];
	
	// Realloc new structures
	
	// Get properties of the system
	timeCount = [[system timeSpan] count];
	dimX = [system dimX];
	dimY = [system dimY];
	
	// add data structures to corresponding arrays
	for ( i = 0; i < timeCount; i++ ) {
		// particles, particlesPredicted and histogram
		[particles addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:dimX]];
		
		[particlesPredicted addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:dimX]];
		
		[measurementsPredicted addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:dimY]];
		
		[weights addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:1UL]];
	}
	
	// ask system to initialize the particle filter
	[self initializeParticleFilter];
}

- (void) reallocResourcesWithNewSystem {
	unsigned timeCount, dimX, dimY, i;
	
	// Release previous structures.
	[particles removeAllObjects];
	[weights removeAllObjects];
	[particlesPredicted removeAllObjects];
	[measurementsPredicted removeAllObjects];
	[histogram removeAllObjects];
	[estimate release];
  
	// Realloc new structures
	
	// Get properties of the system
	timeCount = [[system timeSpan] count];
	dimX = [system dimX];
	dimY = [system dimY];
  
	// add data structures to corresponding arrays
	for ( i = 0; i < timeCount; i++ ) {
		// particles, particlesPredicted and histogram
		[particles addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:dimX]];
		
		[weights addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:1UL]];
		
		[particlesPredicted addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:dimX]];
		
		[measurementsPredicted addObject:
     [[MathMatrix alloc] initWithType:@"double"
                                width:count
                               height:dimY]];
		
		[histogram addObject:
     [[MathMatrix alloc] initWithType:@"unsigned"
                                width:([domain count] - 1)
                               height:dimX]];
	}
	
	estimate = [[MathMatrix alloc] initWithType: @"double"
                                        width: timeCount
                                       height: dimX];
  
	// ask system to initialize the particle filter
	[self initializeParticleFilter];
}

- (BOOL) bernoulli {
	float rn = genunf( 0.0, 1.0 );
	if ( rn >= 0.5 ) {
		return YES;
	} else {
		return NO;
	}
}


@end

