//
//  GenericSystem.m
//  GenericParticleFilter
//
//  Created by Changmook Chun on Wed Feb 18 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import "GenericSystem.h"
#import "time.h"
#import "random.h"

#define GENERIC_SYSTEM_DEFAULT_TIME_BEGIN       0.0
#define GENERIC_SYSTEM_DEFAULT_TIME_END         120.0
#define GENERIC_SYSTEM_DEFAULT_TIME_STEP        1.0
#define GENERIC_SYSTEM_DEFAULT_TIME_SPAN_SIZE		121


@interface GenericSystem (PrivateMethods)

- (void) reallocResourcesWithNewTimeSpan;

@end




// *****************************************************************************
//
//  IMPLEMENTATION
//
// *****************************************************************************

@implementation GenericSystem

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOCATION
//
// *****************************************************************************
#pragma mark Initializations & Deallocation

- (id) init {
	return [self initWithTimeSpan:nil
               systemParameters:nil
                 stateDimension:1UL
                 inputDimension:1UL
                outputDimension:1UL
          processNoiseDimension:0UL
           outputNoiseDimension:0UL ];
}

// Designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span
       systemParameters: (MathMatrix *)theParameters
         stateDimension: (unsigned)xdim
         inputDimension: (unsigned)udim
        outputDimension: (unsigned)ydim
  processNoiseDimension: (unsigned)xndim
   outputNoiseDimension: (unsigned)yndim
{
	if ( self = [super init] ) {
		unsigned i, capa;
		// 1. Check whether time span is given or not
		//    and allocate resource appropriately
		if ( !span ) { // time span NOT given
			double t = GENERIC_SYSTEM_DEFAULT_TIME_BEGIN;
			timeSpan = [[MathMatrix alloc]
                  initWithType:@"double"
                  width:GENERIC_SYSTEM_DEFAULT_TIME_SPAN_SIZE
                  height:1UL];
      
			for ( i = 0; i < GENERIC_SYSTEM_DEFAULT_TIME_SPAN_SIZE; i++ ) {
				((double *)[timeSpan elements])[i] = t;
				t += GENERIC_SYSTEM_DEFAULT_TIME_STEP;
			}
		} else {
			[self setTimeSpan:span];
		}
		
		// 2. set system parameters
		if ( !theParameters ) { // parameters NOT given
      // simply set 1.0 as the only one parameter
			parameters = [[MathMatrix alloc] initWithType: @"double"
                                              width: 1UL
                                             height: 1UL];
      
			[parameters setDoubleValue:1.0 atRow:1UL column:1UL];
		} else {
			[self setParameters: theParameters];
		}
		
		
		// 3. allocate other resources accordingly
		capa = [timeSpan count];
		X = [[MathMatrix alloc] initWithType:@"double"
                                   width:capa
                                  height:xdim];
		U = [[MathMatrix alloc] initWithType:@"double"
                                   width:capa
                                  height:udim];
		Y = [[MathMatrix alloc] initWithType:@"double"
                                   width:capa
                                  height:ydim];
		XNoise = [[MathMatrix alloc] initWithType:@"double"
                                        width:capa
                                       height:xndim];
		YNoise = [[MathMatrix alloc] initWithType:@"double"
                                        width:capa
                                       height:yndim];
		
	}
	
	return self;
}

- (void) dealloc {
	[timeSpan release];
	[parameters release];
	[X release];
	[U release];
	[Y release];
	[XNoise release];
	[YNoise release];
	
	[super dealloc];
}

// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************

#pragma mark -
#pragma mark Accessors

// time span
- (MathMatrix *)timeSpan {
	return timeSpan;
}

- (void)setTimeSpan: (MathMatrix *)span {
	[span retain];
	[timeSpan release];
	
	timeSpan = span;
	
	// realloc resources accordingly
	[self reallocResourcesWithNewTimeSpan];
}

- (MathMatrix *)parameters {
	return parameters;
}

- (void)setParameters: (MathMatrix *)theParameters {
	[theParameters retain];
	[parameters release];
	
	parameters = theParameters;
}

// dimension of states
- (unsigned)dimX {
	return [X height];
}

- (void)setDimX: (unsigned)dim {
	// realloc resources accordingly
	// 1. release previous resources
	[X release];
	
	// 2. allocate new resources
	X = [[MathMatrix alloc] initWithType:@"double"
                                 width:[timeSpan count]
                                height:dim];
}

// dimension of input
- (unsigned)dimU {
	return [U height];
}

- (void)setDimU: (unsigned)dim {
	// realloc resources accordingly
	// 1. release previous resources
	[U release];
	
	// 2. allocate new resources
	U = [[MathMatrix alloc] initWithType:@"double"
                                 width:[timeSpan count]
                                height:dim];
	
}

// dimension of measurements
- (unsigned)dimY {
	return [Y height];
}

- (void)setDimY: (unsigned)dim {
	// realloc resources accordingly
	// 1. release previous resources
	[Y release];
	
	// 2. allocate new resources
	Y = [[MathMatrix alloc] initWithType:@"double"
                                 width:[timeSpan count]
                                height:dim];
	
}

// dimension of process noise
- (unsigned)dimXNoise {
	return [XNoise height];
}

- (void)setDimXNoise: (unsigned)dim {
	// realloc resources accordingly
	// 1. release previous resources
	[XNoise release];
	
	// 2. allocate new resources
	XNoise = [[MathMatrix alloc] initWithType:@"double"
                                      width:[timeSpan count]
                                     height:dim];
	
}

// dimension of output noise
- (unsigned)dimYNoise {
	return [YNoise height];
}

- (void)setDimYNoise: (unsigned)dim {
	// realloc resources accordingly
	// 1. release previous resources
	[YNoise release];
	
	// 2. allocate new resources
	YNoise = [[MathMatrix alloc] initWithType:@"double"
                                      width:[timeSpan count]
                                     height:dim];
	
}

// states
- (MathMatrix *)X {
	return X;
}

- (void)setX: (MathMatrix *)x {
	[x retain];
	[X release];
	
	X = x;
}

// inputs
- (MathMatrix *)U {
	return U;
}

- (void)setU: (MathMatrix *)u {
	[u retain];
	[U release];
	
	U = u;
}

// measurements
- (MathMatrix *)Y {
	return Y;
}

- (void)setY: (MathMatrix *)y {
	[y retain];
	[Y release];
	
	Y = y;
}

// process noise
- (MathMatrix *)XNoise {
	return XNoise;
}

- (void)setXNoise: (MathMatrix *)noise {
	[noise retain];
	[XNoise release];
	
	XNoise = noise;
}

// measurement noise
- (MathMatrix *)YNoise {
	return YNoise;
}

- (void)setYNoise: (MathMatrix *)noise {
	[noise retain];
	[YNoise release];
	
	YNoise = noise;
}

- (RandomNumberGenerator *)RNGenerator {
	return RNGenerator;
}

- (void)setRNGenerator: (RandomNumberGenerator *)gen {
	[gen retain];
	[RNGenerator release];
	
	RNGenerator = gen;
}

- (unsigned)XNoiseGenID {
	return XNoiseGenID;
}

- (void)setXNoiseGenID: (unsigned)id {
	if ( [RNGenerator occupySlot:id] ) {
		XNoiseGenID = id;
	} else {
		NSLog (@"Occupying a slot failed!");
	}
}

- (unsigned)YNoiseGenID {
	return YNoiseGenID;
}

- (void)setYNoiseGenID: (unsigned)id {
	if ( [RNGenerator occupySlot:id] ) {
		YNoiseGenID = id;
	} else {
		NSLog (@"Occupying a slot failed!");
	}
}

// initial value
- (void) getInitialX: (MathMatrix *)mat {
	// Check dimension first.
	if ( [self dimX] != [mat height] ) {
		NSLog( @"Dimension mismatch in [GenericSystem getInitialX:]" );
		return;
	}
	
	[X getVector:mat atColumn:1UL];
}

- (void) setInitialX: (MathMatrix *)mat {
	// Check dimension first.
	if ( [self dimX] != [mat height] ) {
		NSLog( @"Dimension mismatch in [GenericSystem setInitialX:]" );
		return;
	}
	
	[X setVector:mat atColumn:1UL];
}



// *****************************************************************************
//
//  PRIVATE METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Private Methods

- (void) reallocResourcesWithNewTimeSpan {
	unsigned capa;
	unsigned xdim = [X height];
	unsigned udim = [U height];
	unsigned ydim = [Y height];
	unsigned xndim = [XNoise height];
	unsigned yndim = [YNoise height];
  
	// release previous resources
	[X release];
	[U release];
	[Y release];
	[XNoise release];
	[YNoise release];
	
	// allocate new resources
	capa = [timeSpan count];
	X = [[MathMatrix alloc] initWithType:@"double"
                                 width:capa
                                height:xdim];
	U = [[MathMatrix alloc] initWithType:@"double"
                                 width:capa
                                height:udim];
	Y = [[MathMatrix alloc] initWithType:@"double"
                                 width:capa
                                height:ydim];
	XNoise = [[MathMatrix alloc] initWithType:@"double"
                                      width:capa
                                     height:xndim];
	YNoise = [[MathMatrix alloc] initWithType:@"double"
                                      width:capa
                                     height:yndim];
}


// *****************************************************************************
//
//  FILE OUTPUT METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark File Output Methods

- (void)writeAllStatesToFile {
	unsigned i;
	NSString* ffName;
	for ( i = 1; i <= [X height]; i++ ) {
		ffName = [NSString stringWithFormat:@"state_%d.txt", i];
		[self writeStateComponent:i toFile:ffName];
	}
}

- (void)writeStateComponent: (unsigned)compo
                     toFile: (NSString *)fileName {
	unsigned i;
	double* t = (double *)[timeSpan elements];
	double xx;
    NSLog(@"%s", [fileName cStringUsingEncoding:NSASCIIStringEncoding]);
	
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fileName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
	
	if ((compo < 1) || ([self dimX] < compo)) {
		NSLog(@"The argument \'compo\' is out of range");
		return;
	}
  
	fprintf(FP, "#\n# Time and %u'th component of state\n#\n", compo);
	
	for ( i = 0; i < [timeSpan count]; i++ ) {
		[X getValue:&xx atRow:compo column:(i+1)];
		fprintf(FP, " %9.4f\t %9.4f\n", t[i], xx);
	}
	
	fclose(FP);
}

- (void)writeInputComponent: (unsigned)compo
                     toFile: (NSString *)fileName {
	unsigned i;
	double* t = (double *)[timeSpan elements];
	double* ui;
	
    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fileName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
  
	if ((compo < 1) || ([self dimU] < compo)) {
		NSLog(@"The argument \'compo\' is out of range");
		return;
	}
	
	// i'th row of U
	ui = ((double *)[U elements]) + [U width]*(compo - 1);
	
	fprintf(FP, "#\n# Time and %u'th component of input\n#\n", compo);
	
	for ( i = 0; i < [timeSpan count]; i++ ) {
		fprintf(FP, " %9.4f\t %9.4f\n", t[i], ui[i]);
	}
	
	fclose(FP);
	
}

- (void)writeOutputComponent: (unsigned)compo
                      toFile: (NSString *)fileName {
	unsigned i;
	double* t = (double *)[timeSpan elements];
	double* yi;

    NSString* dir = @"/tmp/";
    NSString* path = [dir stringByAppendingString:fileName];
    const char* filepath = [path cStringUsingEncoding:NSASCIIStringEncoding];
    FILE *FP = fopen(filepath, "w");
  
	if ((compo < 1) || ([self dimY] < compo)) {
		NSLog(@"The argument \'compo\' is out of range");
		return;
	}
	
	// i'th row of Y
	yi = ((double *)[Y elements]) + [Y width]*(compo - 1);
	
	fprintf(FP, "#\n# Time and %u'th component of output\n#\n", compo);
	
	for ( i = 0; i < [timeSpan count]; i++ ) {
		fprintf(FP, " %9.4f\t %9.4f\n", t[i], yi[i]);
	}
	
	fclose(FP);
	
}


// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Simulation Related Methods

//- (void) initializeRandomNumberGenerator {
//	//
//	//  PREPARE RANDOM NUMBER GENERATOR
//	//
//
//	// 1. initialize
//	long now = time(NULL);
//	setall(now, now - 10000);
//
//	// 2. set current generator
//	currentGenerator = 1;
//	gscgn(1, &currentGenerator);
//}

- (void) simulateWithInitialState: (MathMatrix *)xInit
                          control: (MathMatrix *)control {
	// do nothing for this base class
}

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control {
	// do nothing for this base class
}

- (void) getNextState: (MathMatrix *)next
               atTime: (double)t
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control {
	// do nothing for this base class
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                     atTimeIndex: (unsigned)i
                withCurrentState: (MathMatrix *)x {
	// do nothing for this base class
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                          atTime: (double)t
                withCurrentState: (MathMatrix *)x {
	// do nothing for this base class
}

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
           parameters: (MathMatrix *)params
              control: (MathMatrix *)control {
	// do nothing for this base class
}

- (void) getMeasurement: (MathMatrix *)output
            atTimeIndex: (unsigned)i
       withCurrentState: (MathMatrix *)x
             parameters: (MathMatrix *)params {
	// do nothing for this base class
}

- (double) probabilityOf: (MathMatrix *)output
                   given: (MathMatrix *)state
             atTimeIndex: (unsigned)ti
          withParameters: (MathMatrix *)params {
	// do nothing but return 0.0 for this base class
	return 0.0;
}






// *****************************************************************************
//
//  PARTICLE FILTERING SUPPORT METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Particle Filtering Support Methods

- (double) importanceWeightAtTimeIndex: (unsigned)i
              withPredictedMeasurement: (MathMatrix *)pMeasure {
	return 0.0;
}


@end
