//
//  HullWhiteOne.m
//  GenericParticleFilter
//
//  Created by Changmook Chun on Fri Feb 20 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import "HullWhiteOne.h"
#import "random.h"

#include <cmath>

#define HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_BEGIN			0.0
#define HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_END				20.0
#define HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_STEP				0.25
#define HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_SPAN_SIZE		81
#define HULL_WHITE_ONE_SYSTEM_DEFAULT_NUM_MEASUREMENTS		12UL

using namespace std;

// *****************************************************************************
//
//  PRIVATE METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Private Methods

@interface HullWhiteOne (PrivateMethods)

- (double) pureMeasurementAtTime: (double)t
               withMaturityIndex: (unsigned)idx
                       OUProcess: (double)x;

@end


@implementation HullWhiteOne

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOCATION
//
// *****************************************************************************
#pragma mark -
#pragma mark Initializations & Deallocation

- (id) init {
	unsigned i;
	
	double mat[] = { // default maturities
		0.25, 0.5, 0.75, 1.0, 1.5, 2.0,
		2.5, 3.0, 5.0, 7.0, 10.0, 20.0
	};
	
	double its[] = { // default initial term structures
		6.52, 6.66, 6.68, 6.72, 6.74, 6.75,
		6.77, 6.84, 7.11, 7.21, 7.24, 7.24
	};
	
	double t = HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_BEGIN;
	
	MathMatrix* ts =
  [[MathMatrix alloc]
   initWithType:@"double"
   width:HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_SPAN_SIZE
   height:1UL];
	
	for ( i = 0; i < HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_SPAN_SIZE; i++ ) {
		((double *)[ts elements])[i] = t;
		t += HULL_WHITE_ONE_SYSTEM_DEFAULT_TIME_STEP;
	}
	
	self = [self initWithTimeSpan: ts
                meanRevertSpeed: 0.5
                     volatility: 0.1
              numberOfSpotRates: 3UL
              numberOfInitialSR: HULL_WHITE_ONE_SYSTEM_DEFAULT_NUM_MEASUREMENTS
                     maturities: mat
                      initialTS: its
                        volBSRM: 0.001];
	
	[ts release];
	return self;
}

// Designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span
        meanRevertSpeed: (double)m
             volatility: (double)v
      numberOfSpotRates: (unsigned)ydim
      numberOfInitialSR: (unsigned)numISR
             maturities: (double *)mat
              initialTS: (double *)its
                volBSRM: (double)v2 {
	
	if ( self = [super initWithTimeSpan: span
                     systemParameters: nil
                       stateDimension: 1UL
                       inputDimension: 0UL
                      outputDimension: ydim
                processNoiseDimension: 1UL
                 outputNoiseDimension: 1UL ] ) {
		
		mrs = m;
		vol = v;
		lambda = 1.0;		// typical value
		volBSRM = v2;
		
		// set initial value of x to 0
		[X setDoubleValue:0.0 atRow:1UL column:1UL];
		
		// build up storage for maturities and
		// interpolate initial term structure data with cubic spline
		maturity = [[MathMatrix alloc] initWithType:@"double"
                                          width:numISR
                                         height:1UL];
		std::vector<Point2D> data;
		for ( unsigned i = 0; i < numISR; i++ ) {
			((double *)[maturity elements])[i] = mat[i];
			data.push_back( Point2D(mat[i], its[i]) );
		}
		CubicSpline2D::Parametrization param = CubicSpline2D::kFunctionSpline;
		initialTS = new CubicSpline2D;
		initialTS -> InterpolateNotAKnotEndCondition( data, param );
		
		//
		//  TEST CODE
		//
		initialTS -> DrawPSAll( 200, 1.0, "initial_TS.ps", "w", true, 20.0 );
	}
	return self;
}

- (void) dealloc {
	[maturity release];
	delete initialTS;
	
	[super dealloc];
}


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (double) mrs {
	return mrs;
}

- (void) setMrs: (double)a {
	mrs = a;
}

- (double) vol {
	return vol;
}

- (void) setVol: (double)s {
	vol = s;
}

- (double) lambda {
	return lambda;
}

- (void) setLambda: (double)l {
	if ( l <= 0.0 ) {
		NSLog(@"Lambda must be greater than 0");
		return;
	}
	lambda = l;
}

- (double) volBSRM {
	return volBSRM;
}

- (void) setVolBSRM: (double)v {
	volBSRM = v;
}

- (double) tau: (unsigned)i {
	return ((double*)[maturity elements])[i];
}


// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Simulation Related Methods

- (void) simulate {
	unsigned i, j;
	double tmp1;		// e^{-a \delta t}
	double sr;		// short rate
  // Note that x[i] is Ornstein-Uhlenbeck process
	double y, z, s;
  
	double* t = (double *)[timeSpan elements];
	double* x = (double *)[X elements];
	double* xn = (double *)[XNoise elements];
	FILE* FP = fopen("short_rates.data", "w");
	
	if ( !FP ) {	// file open error
		NSLog(@"Openining a new file short_rates.data failed.\n");
		return;
	}
	fprintf( FP, "#\n# Short Rates\n#\n\n" );
	
	[RNGenerator setCurrentGenerator:XNoiseGenID];
	
	// set x_0 to 0 and z_0 to a random number satisfying N(0,1)
	x[0] = 0.0;
	xn[0] = gennor(0.0, 1.0);
	
	// drive the system from x_1
	for ( i = 1; i < [timeSpan count]; i++ ) { // 0-based index
		// generate process noises (normal distribution)
		[RNGenerator setCurrentGenerator:XNoiseGenID];
		xn[i] = gennor(0.0, 1.0);
		
		// calculate x_i from x_{i-1}
		tmp1 = exp(-mrs * (t[i] - t[i-1]));
		x[i] = tmp1*x[i-1]
    + vol*sqrt((1.0 - tmp1*tmp1)/(2.0 * mrs))*xn[i];
		
		
		//
		// calculate artificial measurements (spot rates)
		//
    
		for ( j = 0; j < [self dimY]; j++ ) {
			y = [self pureMeasurementAtTime:t[i]
                    withMaturityIndex:j
                            OUProcess:x[i]];
			
			[RNGenerator setCurrentGenerator:YNoiseGenID];
			s = pow(lambda, [self tau:j]/[self tau:0])*volBSRM; // sigma_{hi}
			z = sqrt(s) * gennor(0.0, 1.0);
			y += z;
			[Y setDoubleValue:y atRow:(j+1) column:(i+1)];
		}
    
		// calculate short rate from O-U process
		sr = [self shortRateForOUPState:x[i] atTime:t[i]];
		
		// file output
		fprintf( FP, "%f\t%f\n", t[i], sr );
	}
	
	fclose( FP );
}

- (void) simulateWithInitialState: (MathMatrix *)xInit
                          control: (MathMatrix *)control {
  
	[self simulate];
}

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control {
	
	double* t = (double *)[timeSpan elements];
	double _x = ((double *)[x elements])[0];
	double xx, tmp1;
	
	[RNGenerator setCurrentGenerator:XNoiseGenID];
	tmp1 = exp(-mrs*(t[i] - t[i-1]));
	xx = tmp1*_x + vol*sqrt((1.0 - tmp1*tmp1)/(2.0*mrs))*gennor(0.0, 1.0);
	[next setDoubleValue:xx atRow:1UL column:1UL];
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                     atTimeIndex: (unsigned)index
                withCurrentState: (MathMatrix *)x {
	
	double t = ((double *)[timeSpan elements])[index];
	double _x = ((double *)[x elements])[0];
	double y;
  
	for ( unsigned j = 0; j < [self dimY]; j++ ) {
		y = [self pureMeasurementAtTime:t
                  withMaturityIndex:j
                          OUProcess:_x];
    
		[output setDoubleValue:y atRow:(j+1) column:1UL];
	}
	return;
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                          atTime: (double)t
                withCurrentState: (MathMatrix *)x {
	
	double _x = ((double *)[x elements])[0];
	double y;
	
	for ( unsigned j = 0; j < [self dimY]; j++ ) {
		y = [self pureMeasurementAtTime:t
                  withMaturityIndex:j
                          OUProcess:_x];
		
		[output setDoubleValue:y atRow:(j+1) column:1UL];
	}
	return;
}

- (double) initialTermStructure: (double)t {
	double last;
	[maturity getValue:&last atRow:1UL column:[maturity count]];
	
	if ( t > last ) t = last;
	
	return (initialTS -> deBoor(t)).y;
}

// calculates short rate from the related
// state of Ornstein-Uhlenbeck process, oup
- (double) shortRateForOUPState: (double)oup
                         atTime: (double)t {
	
	// instantaneous forward rate
	double f =  t * (initialTS -> Derivative(t)).y
  + [self initialTermStructure:t];
	return oup + f + 0.5*pow(vol/mrs, 2.0)*pow(1.0 - exp(-mrs*t), 2.0);
}


// *****************************************************************************
//
//  PARTICLE FILTERING SUPPORT METHODS
//
// *****************************************************************************
- (double) importanceWeightAtTimeIndex: (unsigned)index
              withPredictedMeasurement: (MathMatrix *)pMeasure {
	
	double m, pm, s;
	double pdf = 1.0;
  //	double tmp1, tmp2;
	
	MathMatrix* measure = [[MathMatrix alloc] initWithType:@"double"
                                                   width:1UL
                                                  height:[self dimY]];
	[Y getVector:measure atColumn:(index + 1)]; // since index is 0-based.
	
	for ( unsigned j = 0; j < [self dimY]; j++ ) {
		s = pow(lambda, [self tau:j]/[self tau:0])*volBSRM; // sigma_{hi}, variance
    
		[measure getValue:&m atRow:(j+1) column:1UL];
		[pMeasure getValue:&pm atRow:(j+1) column:1UL];
		
    //		NSLog(@"The value of simualted measurement is %f, predicted is %f", m, pm);
    //		if ( tmp1 != tmp2 ) {
    //			NSLog(@"They are Different!");
    //			NSLog(@"tmp1 is %f, tmp2 is %f", tmp1, tmp2);
    //		}
		
		pdf *= (double)exp(-0.25 * pow((m - pm), 2.0) / s)/sqrt(s);
    //		NSLog(@"The pdf = %f", pdf);
	}
	[measure release];
	
  //	NSLog(@"the weight: %f", pdf);
	return pdf;
}

// *****************************************************************************
//
//  Private Methods
//
// *****************************************************************************
- (double) pureMeasurementAtTime: (double)t
               withMaturityIndex: (unsigned)idx
                       OUProcess: (double) x {
	
	// instantaneous forward rate
	double f = t * (initialTS -> Derivative(t)).y + [self initialTermStructure:t];
	double tau = [self tau:idx];
	double B = (1.0 - exp( -mrs*tau ))/mrs;
	double logA = -0.25*vol*vol/(pow(mrs,3.0))
  *pow(exp(-mrs*(t + tau)) - exp(-mrs*t), 2.0)*(exp(2.0*mrs*t) - 1.0)
  + B*f + t*[self initialTermStructure:t] 
  - (t + tau)*[self initialTermStructure:(t + tau)];
	double y = B/tau*x + (B/tau*(f + 0.5*pow((vol/mrs*(1.0 - exp(-mrs*t))), 2.0))
                        - logA/tau);
	return y;
}


@end
