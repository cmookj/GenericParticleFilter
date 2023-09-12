//
//  RandomWalk.h
//  GenericParticleFilter
//

#import <Foundation/Foundation.h>
#import "GenericSystem.h"
#import "MathMatrix.h"
#import "RandomNumberGenerator.h"

@interface RandomWalk : GenericSystem {
	double processNoise;
  double measurementNoise;
}

- (id) init;
- (id) initWithTimeSpan: (MathMatrix *)span;	// designated initializer
- (void) dealloc;

- (double)processNoise;
- (void)setProcessNoise: (double)var;

- (double)measurementNoise;
- (void)setMeasurementNoise: (double)var;

@end
