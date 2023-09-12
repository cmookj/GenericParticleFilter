//
//  SimpleSystem2.h
//  GenericParticleFilter
//
//  Created by Changmook Chun on Tue Mar 02 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericSystem.h"
#import "MathMatrix.h"
#import "RandomNumberGenerator.h"

@interface SimpleSystem2 : GenericSystem {
	double sigma;
}

- (id) init;
- (id) initWithTimeSpan: (MathMatrix *)span;	// designated initializer
- (void) dealloc;

- (double)sigma;
- (void)setSigma: (double)var;

@end
