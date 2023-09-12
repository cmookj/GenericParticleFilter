//
//  SimpleSystem2.m
//  GenericParticleFilter
//
//  Created by Changmook Chun on Tue Mar 02 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import "SimpleSystem2.h"
#import "random.h"

@implementation SimpleSystem2
- (id) init {
	return [self initWithTimeSpan: nil ];
}

// designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span {
	if ( self = [super initWithTimeSpan: span
					   systemParameters: nil
						 stateDimension: 2UL
						 inputDimension: 0UL
						outputDimension: 1UL
				  processNoiseDimension: 1UL
				   outputNoiseDimension: 1UL] ) {

//		parameters = [[MathMatrix alloc] initWithType:@"double" 
//												width:1UL 
//											   height:1UL];
		
//		beta = 0.5;
//		[parameters setDoubleValue:beta atRow:1UL column:1UL];

		sigma = 0.01;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (double)sigma {
	return sigma;
}

- (void)setSigma: (double)var {
	sigma = var;
}


// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
- (void) simulateWithInitialState: (MathMatrix *)xInit
						  control: (MathMatrix *)control {
	unsigned i;
	double xx1, xx2, xm1, xm2, yy;
	
	[xInit getValue:&xx1 atRow:1UL column:1UL];
	[xInit getValue:&xx2 atRow:2UL column:1UL];

	[X setDoubleValue:xx1 atRow:1UL column:1UL];
	[X setDoubleValue:xx2 atRow:2UL column:1UL];
	
	for ( i = 1; i < [timeSpan count]; i++ ) {
		// propagate the system dynamics
		double t = ((double *)[timeSpan elements])[i];
		
		[X getValue:&xm1 atRow:1UL column:i];
		[X getValue:&xm2 atRow:2UL column:i];
		
		[RNGenerator setCurrentGenerator:XNoiseGenID];
		
		xx1 = 1.0 + sin(0.04*M_PI*t) + xm2*xm1 + gengam(2.0, 3.0);
		xx2 = xm2;
		
		[X setDoubleValue:xx1 atRow:1UL column:(i + 1UL)];
		[X setDoubleValue:xx2 atRow:2UL column:(i + 1UL)];
		
		// generate artificial measurement
		if ( i <= 30 ) {
			yy = 0.2*pow(xx1, 2.0);
		} else {
			yy = -2.0 + xx1/2.0;
		}
		
		[RNGenerator setCurrentGenerator:YNoiseGenID];
		yy += gennor(0.0, sigma);
		[Y setDoubleValue:yy atRow:1UL column:(i + 1UL)];
	}
}

- (void) getNextState: (MathMatrix *)next
		  atTimeIndex: (unsigned)i
	 withCurrentState: (MathMatrix *)x
			  control: (MathMatrix *)control {
		
	double t = [timeSpan doubleValueAtRow:1UL column:(i + 1UL)];
	double _x1 = [x doubleValueAtRow:1UL column:1UL];
	double _x2 = [x doubleValueAtRow:2UL column:1UL];
	double xx1, xx2; 
	
	[RNGenerator setCurrentGenerator:XNoiseGenID];

	xx1 = 1.0 + sin(0.04*M_PI*t) + _x2*_x1 + gengam(2.0, 3.0);
	xx2 = _x2;

	[next setDoubleValue:xx1 atRow:1UL column:1UL];
	[next setDoubleValue:xx2 atRow:2UL column:1UL];
}

- (void) getNextState: (MathMatrix *)next
			   atTime: (double)t
	 withCurrentState: (MathMatrix *)x
			  control: (MathMatrix *)control {

	double _x1 = [x doubleValueAtRow:1UL column:1UL];
	double _x2 = [x doubleValueAtRow:2UL column:1UL];
	double xx1, xx2;
	
	[RNGenerator setCurrentGenerator:XNoiseGenID];
	
	xx1 = 1.0 + sin(0.04*M_PI*t) + _x2*_x1 + gengam(2.0, 3.0);
	xx2 = _x2;
	
	[next setDoubleValue:xx1 atRow:1UL column:1UL];
	[next setDoubleValue:xx2 atRow:2UL column:1UL];
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
					 atTimeIndex: (unsigned)i
				withCurrentState: (MathMatrix *)x {
	
	double m;
	double _x1 = [x doubleValueAtRow:1UL column:1UL];
	double _x2 = [x doubleValueAtRow:2UL column:1UL];
	
	if ( i <= 30 ) {
		m = 0.2 * pow(_x1, 2.0);
	} else {
		m = -2.0 + _x1/2.0;
	}
		
	[output setDoubleValue:m atRow:1UL column:1UL];
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
						  atTime: (double)t
				withCurrentState: (MathMatrix *)x {
	// not implemented
}

- (double) probabilityOf: (MathMatrix *)output
				   given: (MathMatrix *)state
			 atTimeIndex: (unsigned)ti
		  withParameters: (MathMatrix *)params {
	
	double y = [output doubleValueAtRow:1UL column:1UL];
	double x = [state doubleValueAtRow:1UL column:1UL];
	
	if ( ti <= 30 ) {
		y -= 0.2 * pow(x, 2.0);
	} else {
		y -= (-2.0 + x/2.0);
	}
	
//	NSLog(@"Measurement noise is %f", y);
	return exp(-0.5 * pow(y/sigma, 2.0))/(sigma * sqrt(2.0 * M_PI));
}





// *****************************************************************************
//
//  PARTICLE FILTERING SUPPORT METHODS
//
// *****************************************************************************
- (double) importanceWeightAtTimeIndex: (unsigned)index
			 withPredictedMeasurement: (MathMatrix *)pMeasure {
	
	double m, pm;
	MathMatrix* measure = [[MathMatrix alloc] initWithType:@"double" 
													 width:1UL 
													height:1UL];
	
	[Y getVector:measure atColumn:(index + 1UL)]; // since index is 0-based.
	m = [measure doubleValueAtRow:1UL column:1UL];
	pm = [pMeasure doubleValueAtRow:1UL column:1UL];
	[measure release];
	
	return exp(-0.5 * pow((m - pm)/sigma, 2.0))/sigma;
}

@end
