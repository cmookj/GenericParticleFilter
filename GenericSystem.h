//
//  GenericSystem.h
//  GenericParticleFilter
//
//  Created by Changmook Chun on Wed Feb 18 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MathMatrix.h"
#import "RandomNumberGenerator.h"

//
//  Basic structures of data
//
//  ============================================================================
//
//							----  time  ---->
//
//					X(1,1)  X(1,2)  X(1,3)  ...		X(1,T)
//		:			X(2,1)  X(2,2)  X(2,3)  ...		X(2,T)
//		:
//		dim			:		:		X(i,t)	:		:
//		:
//		v			X(n,1)  X(n,2)  X(n,3)  ...		X(n,T)
//
//
//		n is the dimension of X and T is the last index of timeSpan.
//
//		Other data have the same structure as X.

@interface GenericSystem : NSObject {
@protected
	//
	//  Primary data structure
	//
	MathMatrix *timeSpan;   // time span
	MathMatrix *parameters;	// parameters of the system
	MathMatrix *X;			// states
	MathMatrix *U;			// input
	MathMatrix *Y;			// output
	MathMatrix *XNoise;		// process noise
	MathMatrix *YNoise;		// output noise
  
	//
	//  Miscellaneous data structure
	//
	RandomNumberGenerator* RNGenerator;
	unsigned XNoiseGenID;
	unsigned YNoiseGenID;
}

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOCATION
//
// *****************************************************************************

#pragma mark Initializations & Deallocation

- (id) init;

// Designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span
       systemParameters: (MathMatrix *)theParameters
         stateDimension: (unsigned)xdim
         inputDimension: (unsigned)udim
        outputDimension: (unsigned)ydim
  processNoiseDimension: (unsigned)xndim
   outputNoiseDimension: (unsigned)yndim;

- (void) dealloc;


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (MathMatrix *)timeSpan;
- (void)setTimeSpan: (MathMatrix *)span;

- (MathMatrix *)parameters;
- (void)setParameters: (MathMatrix *)theParameters;

- (unsigned)dimX;
- (void)setDimX: (unsigned)dim;

- (unsigned)dimU;
- (void)setDimU: (unsigned)dim;

- (unsigned)dimY;
- (void)setDimY: (unsigned)dim;

- (unsigned)dimXNoise;
- (void)setDimXNoise: (unsigned)dim;

- (unsigned)dimYNoise;
- (void)setDimYNoise: (unsigned)dim;

- (MathMatrix *)X;
- (void)setX: (MathMatrix *)x;

- (MathMatrix *)U;
- (void)setU: (MathMatrix *)u;

- (MathMatrix *)Y;
- (void)setY: (MathMatrix *)y;

- (MathMatrix *)XNoise;
- (void)setXNoise: (MathMatrix *)noise;

- (MathMatrix *)YNoise;
- (void)setYNoise: (MathMatrix *)noise;

- (RandomNumberGenerator *)RNGenerator;
- (void)setRNGenerator: (RandomNumberGenerator *)gen;

- (unsigned)XNoiseGenID;
- (void)setXNoiseGenID: (unsigned)id;

- (unsigned)YNoiseGenID;
- (void)setYNoiseGenID: (unsigned)id;

- (void) getInitialX: (MathMatrix *)mat;
- (void) setInitialX: (MathMatrix *)mat;


// *****************************************************************************
//
//  FILE OUTPUT METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark File Output Methods

- (void)writeAllStatesToFile;

- (void)writeStateComponent: (unsigned)compo
                     toFile: (NSString *)fileName;

- (void)writeInputComponent: (unsigned)compo
                     toFile: (NSString *)fileName;

- (void)writeOutputComponent: (unsigned)compo
                      toFile: (NSString *)fileName;


// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Simulation Related Methods

- (void) simulateWithInitialState: (MathMatrix *)xInit
                          control: (MathMatrix *)control;

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control;

- (void) getNextState: (MathMatrix *)next
               atTime: (double)t
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control;

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
           parameters: (MathMatrix *)params
              control: (MathMatrix *)control;

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                     atTimeIndex: (unsigned)i
                withCurrentState: (MathMatrix *)x;

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                          atTime: (double)t
                withCurrentState: (MathMatrix *)x;

- (void) getMeasurement: (MathMatrix *)output
            atTimeIndex: (unsigned)i
       withCurrentState: (MathMatrix *)x
             parameters: (MathMatrix *)params;

- (double) probabilityOf: (MathMatrix *)output
                   given: (MathMatrix *)state
             atTimeIndex: (unsigned)ti
          withParameters: (MathMatrix *)params;



// *****************************************************************************
//
//  PARTICLE FILTERING SUPPORT METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Particle Filtering Support Methods

- (double) importanceWeightAtTimeIndex: (unsigned)i
              withPredictedMeasurement: (MathMatrix *)pMeasure;


@end
