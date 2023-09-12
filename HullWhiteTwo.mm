//
//  HullWhiteTwo.mm
//  Cocoa GPF
//
//  Created by Changmook Chun on 11/22/04.
//  Copyright 2004 Seoul National University. All rights reserved.
//

#import "HullWhiteTwo.h"
#import "random.h"

#include <cmath>

#define HULL_WHITE_SYSTEM_DEFAULT_TIME_BEGIN			0.0
#define HULL_WHITE_SYSTEM_DEFAULT_TIME_END				20.0
#define HULL_WHITE_SYSTEM_DEFAULT_TIME_STEP				0.25
#define HULL_WHITE_SYSTEM_DEFAULT_TIME_SPAN_SIZE		81
#define HULL_WHITE_SYSTEM_DEFAULT_NUM_MEASUREMENTS		12UL

using namespace std;

// *****************************************************************************
//
//  PRIVATE METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Private Methods

@interface HullWhiteTwo (PrivateMethods)

- (double) pureMeasurementAtTime: (double)t
               withMaturityIndex: (unsigned)idx
                       OUProcess: (double)x;

@end



@implementation HullWhiteTwo

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOCATION
//
// *****************************************************************************
#pragma mark -
#pragma mark Initializations & Deallocation
- (id) init {
	
}

// Designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span
       meanRevertSpeed1: (double)mrs1
       meanRevertSpeed2: (double)mrs2
            volatility1: (double)vol1
            volatility2: (double)vol2
             covariance: (double)cov
      numberOfSpotRates: (unsigned)ydim
      numberOfInitialSR: (unsigned)numISR
             maturities: (double *)mat
              initialTS: (double *)its {
	
}

- (void) dealloc {
  [super dealloc];
}


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (double) mrs1 {
	return _alpha;
}

- (void) setMrs1: (double)a {
	_alpha = a;
}

- (double) mrs2 {
	return _beta;
}

- (void) setMrs2: (double)a {
	_beta = a;
}

- (double) vol1 {
	return _gamma;
}

- (void) setVol1: (double)v {
	_gamma = v;
}

- (double) vol2 {
	return _eta;
}

- (void) setVol2: (double)v {
	_eta = v;
}

- (double) cov {
	return _kappa;
}

- (void) setCov: (double)v {
	_kappa = v;
}



// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Simulation Related Methods

- (void) simulate {
	
}

- (void) simulateWithInitialState: (MathMatrix *)xInit
                          control: (MathMatrix *)control {
	[self simulate];
}

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control {
	
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                     atTimeIndex: (unsigned) index
                withCurrentState: (MathMatrix *)x {
	
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                          atTime: (double)t
                withCurrentState: (MathMatrix *)x {
	
}

- (double) initialTermStructure: (double)t {
	return 0;
}

- (double) shortRateForOUPState: (double)oup
                         atTime: (double)t {
	return 0;
}

// *****************************************************************************
//
//  PARTICLE FILTERING SUPPORT METHODS
//
// *****************************************************************************
- (double) importanceWeightAtTimeIndex: (unsigned)index
              withPredictedMeasurement: (MathMatrix *)pMeasure {
	return 0;
}


// *****************************************************************************
//
//  Private Methods
//
// *****************************************************************************
- (double) pureMeasurementAtTime: (double)t
               withMaturityIndex: (unsigned)idx
                       OUProcess: (double) x {
  
	return 0;
}

@end
