#import <Foundation/Foundation.h>
#import "SimpleSystem.h"
#import "HullWhiteOne.h"
#import "MathUtil.h"
#import "GenericParticleFilter.h"
#import "random.h"
#import "RandomNumberGenerator.h"
#import "MathMatrix.h"

#define CONST_DOMAIN_NUM_STEP		400
#define CONST_DOMAIN_LOWER_BOUND	-10.0
#define CONST_DOMAIN_UPPER_BOUND	10.0

#define SYSTEM_DEFAULT_TIME_BEGIN			0.0
#define SYSTEM_DEFAULT_TIME_END				5000.0
#define SYSTEM_DEFAULT_TIME_STEP			1.0
#define SYSTEM_DEFAULT_TIME_SPAN_SIZE		5001


int main (int argc, const char * argv[]) {
	//
	//  Definitions of Variables
	//
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	MathMatrix *domain = [[MathMatrix alloc] initWithType:@"double" 
													width:(CONST_DOMAIN_NUM_STEP + 1) 
												   height:1UL];
	
	RandomNumberGenerator* RNGen = [[RandomNumberGenerator alloc] init];
	
	MathMatrix* span = [[MathMatrix alloc] initWithType:@"double"
												  width:SYSTEM_DEFAULT_TIME_SPAN_SIZE
												 height:1UL];
	
	double t = SYSTEM_DEFAULT_TIME_BEGIN;
	
	GenericSystem* sys;
	MathMatrix* xinit = [[MathMatrix alloc] initWithType:@"double" 
												   width:1UL 
												  height:1UL];
	
	
	
	GenericParticleFilter* pf;
	unsigned i;
	double step;
	
	// make time span
	for ( i = 0; i < SYSTEM_DEFAULT_TIME_SPAN_SIZE; i++ ) {
		((double *)[span data])[i] = t;
		t += SYSTEM_DEFAULT_TIME_STEP;
	}

	// Use SimpleSystem as an example
//	sys = [[SimpleSystem alloc] initWithTimeSpan:span];	
	sys = [[HullWhiteOne alloc] init];
	[sys setRNGenerator: RNGen];
	[sys setXNoiseGenID: 2UL];
	[sys setYNoiseGenID: 3UL];

	
	[xinit setDoubleValue:0.0 atRow:1UL column:1UL];
	
	step = CONST_DOMAIN_UPPER_BOUND - CONST_DOMAIN_LOWER_BOUND;
	step /= (double)CONST_DOMAIN_NUM_STEP;
	for ( i = 0; i <= CONST_DOMAIN_NUM_STEP; i++ ) {
		((double*)[domain data])[i] = CONST_DOMAIN_LOWER_BOUND + (step * (double)i);
	}
	
	
	NSLog(@"Simulation of the system begins.");
	[sys simulateWithInitialState:xinit control:nil];
	NSLog(@"Simulation of the system ends.");
	
	[sys writeStateComponent:1UL toFile:@"states.data"];
	[sys writeOutputComponent:1UL toFile:@"measurements1.data"];	
//	[sys writeOutputComponent:2UL toFile:@"measurements2.data"];
//	[sys writeOutputComponent:3UL toFile:@"measurements3.data"];
	
	pf = [[GenericParticleFilter alloc] initWithCapacity:200 
											   forSystem:sys 
									 withSelectionScheme:PF_CONST_RESAMPLE_MULTINOMIAL];
	
	NSLog(@"Particle filtering for state estimation begins.");
	[pf initializeParticleFilter];
	[pf setRNGenerator: RNGen];
	[pf setRngIdForResampler: 1UL];
	[pf rpfStateEstimator];
	NSLog(@"Particle filtering for state estimation ends.");

	// write estimate of the state to file
	[pf writeEstimateToFile:@"estimate.data"];

	// write estimation error to file
	[pf writeEstimationErrorToFile:@"estimation_error"];
	
	NSLog(@"Particle filtering for parameter estimation begins.");
	[pf setWindowSize: 2UL];
	[pf rpfParameterEstimator];
	NSLog(@"Particle filtering for parameter estimation ends.");

		
	[pf setDomain:domain];
	
//	NSLog(@"Making histogram begins.");
//	[pf makePosteriorDistributionHistogram];
//	[pf writeHistogramForGnuplotToFile:@"posterior.data"];
//	
//	[pf makePredictiveDistributionHistogramForMeasurementComponent:1];
//	[pf writeHistogramForGnuplotToFile:@"predictive.data"];
//	NSLog(@"Making histogram ends.");
	
//	[pf writeParticlesToFile: @"particles.data"];
	
	
	[domain release];
	[pool release];
	[sys release];
	[pf release];
	[span release];
    
	return 0;
}