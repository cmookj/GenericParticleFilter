//
//  SimpleSystem.h
//  GenericParticleFilter
//
//  Created by Changmook Chun on Tue Mar 02 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericSystem.h"
#import "MathMatrix.h"
#import "RandomNumberGenerator.h"

@interface SimpleSystem : GenericSystem {
@private	
	double sigma;
}

- (id) init;
- (id) initWithTimeSpan: (MathMatrix *)span;	// designated initializer
- (void) dealloc;

- (double) sigma;
- (void) setSigma: (double)var;

// parameter 1, a.k.a. beta
- (double) phi1;
- (void) setPhi1: (double)var;

// parameter 2
- (double) phi2;
- (void) setPhi2: (double)var;

// parameter 3
- (double) phi3;
- (void) setPhi3: (double)var;

@end
