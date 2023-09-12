//
//  GenericParticleFilter.h
//  SequentialMonteCarlo
//
//  Created by Changmook Chun on Wed Nov 05 2003.
//  Copyright (c) 2003 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericSystem.h"
#import "MathMatrix.h"
#import "RandomNumberGenerator.h"

//  Enumeration constants for resample scheme
enum {
	PF_CONST_RESAMPLE_RESIDUAL = 0,
	PF_CONST_RESAMPLE_SYSTEMATIC,
	PF_CONST_RESAMPLE_MULTINOMIAL
};

//
//  DESCRIPTION OF DATA STRUCTURE
//

//  particles: NSMutableArray* that stores the history of all particles.
//
//    particles[0]: particles at time 0
//    particles[1]: particles at time 1
//    particles[2]: particles at time 2
//                  ...
//
//    Each element of the array is of type MathMatrix*. The number of rows
//    in the matrix is the dimension of the state vector.
//    For example, if the state space of the system that this
//    particle filter treats is 3 dimensional vector space, the structure 
//    of one element is as follows:
//
//      X_1(0), X_1(1), X_1(2), X_1(3), ...
//      X_2(0), X_2(1), X_2(2), X_2(3), ...
//      X_3(0), X_3(1), X_3(2), X_3(3), ...
//
//    where X_i denotes the i'th element of the state vector. 
//
//    Please note that
//    particlesPrd, measurePrd and histogram have the same structure as particles.

//  weights: a pointer to NSMutableArray that stores all weights correspoing
//    to the particles. That is, weights[i] is a MathMatrix whose elements
//    are the weights of particles[i].
//    Hence, the structure of it is similar to that of particles.

//  histogram: a pointer to NSMutableArray that stores the histogram of particles.
//    The structure of it is similar to that of particles.
//

@interface GenericParticleFilter : NSObject {
@private
	BOOL isStateEstimator;		// flag which shows whether the particle filter
								// estimates state
	BOOL isParameterEstimator;	// flag which shows whether the particle filter
								// estimates parameters
	
	unsigned count;		// number of particles (and weights)
	
	NSMutableArray *particles;		// particles (see description above)
	NSMutableArray *weights;		// weights (see description above)
	NSMutableArray *particlesPredicted;			// predicted particles
	NSMutableArray *measurementsPredicted;		// predicted measurements

	NSMutableArray *histogram;  // histogram of particles (see description above)
	MathMatrix *domain;			// domain of histogram

	// system: the system to estimate (filter) using this particle filter
	GenericSystem* system;	
	
	// estimate: estimated states of the system
	// Its data structure is similar to that of the state of the system
	//
	//							----  time  ---->
	//
	//					E(1,1)  E(1,2)  E(1,3)  ...		E(1,T)
	//		:			E(2,1)  E(2,2)  E(2,3)  ...		E(2,T)
	//		:
	//		dim			:		:		E(i,t)	:		:
	//		:		
	//		v			E(n,1)  E(n,2)  E(n,3)  ...		E(n,T)
	//
	//
	//		n is the dimension of state and T is the last index of timeSpan.
	
	MathMatrix *estimate;
	
	// resample scheme
	unsigned scheme;
	
	// window size
	unsigned windowSize;

	// maximum number of iterations
	unsigned iterationLimit;
	
	//
	//  Miscellaneous data structure
	//
	RandomNumberGenerator* RNGenerator;
	unsigned RNGIDForResampler;	// random number generator id
	unsigned RNGIDForBernoulli;	// random number generator id
								// see http://www.netlib.org/random/index.html
	
}

// *****************************************************************************
//
//  INITIALIZATION AND DEALLOCATION
//
// *****************************************************************************

#pragma mark Initialization & Deallocation

- (id) init;

// designated initializer
- (id) initWithCapacity:(unsigned)num
			  forSystem:(GenericSystem *)theSystem
	withSelectionScheme:(unsigned)theScheme;

- (void) dealloc;


	
	
// *****************************************************************************
//
//  FOUNDATION FRAMEWORK METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Description

- (NSString *)description;



// *****************************************************************************
//
//  ACCESS METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (unsigned) count;
- (void) setCount:(unsigned)theCount;

- (NSMutableArray *) particles;
- (NSMutableArray *) weights;
- (NSMutableArray *) particlesPredicted;
- (NSMutableArray *) measurementsPredicted;
- (NSMutableArray *) histogram;

- (MathMatrix *)domain;
- (void) setDomain:(MathMatrix *)theDomain;

- (GenericSystem *) system;
- (void) setSystem:(GenericSystem *)theSystem;

- (unsigned)scheme;
- (void) setScheme:(unsigned)theScheme;

- (unsigned)RNGIDForResampler;
- (void)setRNGIDForResampler: (unsigned)genId;

- (unsigned)RNGIDForBernoulli;
- (void)setRNGIDForBernoulli: (unsigned)genId;

- (RandomNumberGenerator *)RNGenerator;
- (void)setRNGenerator: (RandomNumberGenerator *)gen;

- (BOOL)isStateEstimator;
- (void)enableStateEstimator: (BOOL)flag;

- (BOOL)isParameterEstimator;
- (void)enableParameterEstimator: (BOOL)flag;

- (unsigned) windowSize;
- (void) setWindowSize: (unsigned)ws;

- (unsigned) iterationLimit;
- (void) setIterationLimit: (unsigned)il;

- (MathMatrix *) timeSpan;
- (void) setTimeSpan: (MathMatrix *)newTimeSpan;
	// Note that GenericParticleFilter class does NOT have timeSpan as 
	// data member. These access methods returns the timeSpan of system and
	// sets new timeSpan of the system, respectively.
	// setTimeSpan:(MathMatrix *) method also reallocate resources accordingly.
	
// *****************************************************************************
//
//  ENGINE METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Engine Methods

// initialization of particle filter
- (void) initializeParticleFilter;

// state estimator
- (void) estimateStates;

// parameter estimator (auxiliary particle filter)
- (void) estimateParametersUsingAuxParticleFilter;

// parameter estimator (measurement comparison method)
- (void) estimateParametersUsingMeasurementComparison;

// parameter estimator (SPSA)
- (void) estimateParametersUsingSPSAWithAlpha: (double) alpha
										gamma: (double) gamma 
											a: (double) a
											c: (double) c
											A: (double) A; 

- (void) meanOfEstimationError:(MathMatrix *)error;

- (void) makePosteriorDistributionHistogramForStateComponent: (unsigned)i;
- (void) makePredictiveDistributionHistogramForMeasurementComponent: (unsigned)i;

// Use these methods only for scalar state & scalar output systems
- (void) makePosteriorDistributionHistogram;
- (void) makePredictiveDistributionHistogram;







// *****************************************************************************
//
//  WRITING TO FILES
//
// *****************************************************************************
#pragma mark -
#pragma mark Writing to Files

- (void)writeParticlesToFile:(NSString *)fName;
- (void)writeWeightsToFile:(NSString *)fName;
- (void)writeHistogramToFile:(NSString *)fName;
- (void)writeHistogramForGnuplotToFile:(NSString *)fName;
- (void)writeEstimateToFile:(NSString *)fName;
- (void)writeEstimationErrorToFile:(NSString *)fName;
- (void)writeStateToFile:(NSString *)fName;

@end
