//
//  HullWhiteTwo.h
//  Cocoa GPF
//
//  Created by Changmook Chun on 11/22/04.
//  Copyright 2004 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenericSystem.h"
#import "MathMatrix.h"
#import "CubicSpline2D.h"

@interface HullWhiteTwo : NSObject {
@private
	double _alpha;	// mean reversion 1
	double _beta;	// mean reversion 2
	double _gamma;	// volatility 1
	double _eta;		// volatility 2
	double _kappa;	// covariance
	
}

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOCATION
//
// *****************************************************************************
#pragma mark -
#pragma mark Initializations & Deallocation
- (id) init;

// Designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span
       meanRevertSpeed1: (double)mrs1
       meanRevertSpeed2: (double)mrs2
            volatility1: (double)vol1
            volatility2: (double)vol2
             covariance: (double)v
      numberOfSpotRates: (unsigned)ydim
      numberOfInitialSR: (unsigned)numISR
             maturities: (double *)mat
              initialTS: (double *)its;

- (void) dealloc;


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (double) mrs1;
- (void) setMrs1: (double)a;

- (double) mrs2;
- (void) setMrs2: (double)a;

- (double) vol1;
- (void) setVol1: (double)v;

- (double) vol2;
- (void) setVol2: (double)v;

- (double) cov;
- (void) setCov: (double)v;

// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Simulation Releated Methods

- (void) simulate;
- (double) initialTermStructure: (double)t;

// calculates short rate from the related
// state of Ornstein-Uhlenbeck process, oup
- (double) shortRateForOUPState: (double)oup
                         atTime: (double)t;	

@end
