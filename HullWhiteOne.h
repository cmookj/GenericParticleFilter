//
//  HullWhiteOne.h
//  GenericParticleFilter
//
//  Created by Changmook Chun on Fri Feb 20 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenericSystem.h"
#import "MathMatrix.h"
#import "CubicSpline2D.h"

@interface HullWhiteOne : GenericSystem {
@private
	double mrs;		// mean reverting speed
	double vol;		// volatility (standard deviation)
	double lambda;   // user-assigned constant (set between 0 and 1 to
                   // emphasize shorter maturities, and greater than 1 to
                   // emphasize longer maturities; typical values are usually
                   // set to 0.94 or greater)
	double volBSRM;  // sigma_h. volatility associated with the benchmark
                   // spot rate maturity
	
	unsigned numInitialSR;  // number of initial spot rates to degine
                          // initial term structure
	MathMatrix* maturity;   // maturities of spot rates
	CubicSpline2D* initialTS;	// initial term structure
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
        meanRevertSpeed: (double)m
             volatility: (double)v
      numberOfSpotRates: (unsigned)ydim
      numberOfInitialSR: (unsigned)numISR
             maturities: (double *)mat
              initialTS: (double *)its
                volBSRM: (double)v2;

- (void) dealloc;


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (double) mrs;
- (void) setMrs: (double)a;

- (double) vol;
- (void) setVol: (double)s;

- (double) lambda;
- (void) setLambda: (double)l;

- (double) volBSRM;
- (void) setVolBSRM: (double)v;

- (double) tau: (unsigned)i;

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
