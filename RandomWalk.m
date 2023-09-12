//
//  RandomWalk.m
//  GenericParticleFilter
//

#import "RandomWalk.h"
#import "random.h"

@implementation RandomWalk
- (id) init {
	return [self initWithTimeSpan: nil ];
}

// designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span {
	if ( self = [super initWithTimeSpan: span
					   systemParameters: nil
						 stateDimension: 4UL
						 inputDimension: 0UL
						outputDimension: 2UL
				  processNoiseDimension: 2UL
				   outputNoiseDimension: 2UL] ) {

//		parameters = [[MathMatrix alloc] initWithType:@"double" 
//												width:1UL 
//											   height:1UL];
		
//		beta = 0.5;
//		[parameters setDoubleValue:beta atRow:1UL column:1UL];

		processNoise = 0.5;
    measurementNoise = 1.;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (double)processNoise {
	return processNoise;
}

- (void)setProcessNoise: (double)var {
	processNoise = var;
}

- (double)measurementNoise {
  return measurementNoise;
}

- (void)setMeasurementNoise:(double)var {
  measurementNoise = var;
}


// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
- (void) simulateWithInitialState: (MathMatrix *)xInit
                          control: (MathMatrix *)control {
	unsigned i;

  double x[4];
  double x_n[4];
	
	[xInit getValue:&x[0] atRow:1UL column:1UL];
	[xInit getValue:&x[1] atRow:2UL column:1UL];
  [xInit getValue:&x[2] atRow:3UL column:1UL];
  [xInit getValue:&x[3] atRow:4UL column:1UL];

	[X setDoubleValue:x[0] atRow:1UL column:1UL];
	[X setDoubleValue:x[1] atRow:2UL column:1UL];
  [X setDoubleValue:x[2] atRow:3UL column:1UL];
	[X setDoubleValue:x[3] atRow:4UL column:1UL];
	
	for ( i = 1; i < [timeSpan count]; i++ ) {
		// propagate the system dynamics
		double t = ((double *)[timeSpan elements])[i];
    double dt = ((double *)[timeSpan elements])[i+1] - t;
		
		[X getValue:&x[0] atRow:1UL column:i];
		[X getValue:&x[1] atRow:2UL column:i];
    [X getValue:&x[2] atRow:3UL column:i];
    [X getValue:&x[3] atRow:4UL column:i];
		
		[RNGenerator setCurrentGenerator:XNoiseGenID];
    double noiseX = gennor(0.0, processNoise);
    double noiseY = gennor(0.0, processNoise);
    x_n[0] = x[0] + dt*x[2] + noiseX*dt*dt/2.;
    x_n[1] = x[1] + dt*x[3] + noiseY*dt*dt/2.;
    x_n[2] = x[2] + noiseX*dt;
    x_n[3] = x[3] + noiseY*dt;
		
		[X setDoubleValue:x_n[0] atRow:1UL column:(i + 1UL)];
		[X setDoubleValue:x_n[1] atRow:2UL column:(i + 1UL)];
    [X setDoubleValue:x_n[2] atRow:3UL column:(i + 1UL)];
		[X setDoubleValue:x_n[3] atRow:4UL column:(i + 1UL)];
		
		// generate artificial measurement
    [RNGenerator setCurrentGenerator:YNoiseGenID];
		double z1 = x_n[0] + gennor(0.0, measurementNoise);
    double z2 = x_n[1] + gennor(0.0, measurementNoise);
    
		[Y setDoubleValue:z1 atRow:1UL column:(i + 1UL)];
    [Y setDoubleValue:z2 atRow:2UL column:(i + 1UL)];
	}
}

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x_current
              control: (MathMatrix *)control
{
	double t = [timeSpan doubleValueAtRow:1UL column:(i + 1UL)];
  double dt = t - [timeSpan doubleValueAtRow:1UL column:i];;
  double x[4];
  for (unsigned i = 0; i != 4; ++i) {
    x[i] = [x_current doubleValueAtRow:(i+1) column:1UL];
  }
	
  double x_n[4];
  
  [RNGenerator setCurrentGenerator:XNoiseGenID];
	double noiseX = gennor(0.0, processNoise);
  double noiseY = gennor(0.0, processNoise);
  x_n[0] = x[0] + dt*x[2] + noiseX*dt*dt/2.;
  x_n[1] = x[1] + dt*x[3] + noiseY*dt*dt/2.;
  x_n[2] = x[2] + noiseX*dt;
  x_n[3] = x[3] + noiseY*dt;
  
  for (unsigned i = 0; i != 4; ++i) {
    [next setDoubleValue:x_n[i] atRow:(i+1) column:1UL];
  }
}

- (void) getNextState: (MathMatrix *)next
               atTime: (double)t
     withCurrentState: (MathMatrix *)x_current
              control: (MathMatrix *)control
{
  double dt = [timeSpan doubleValueAtRow:1UL column:2UL] -
    [timeSpan doubleValueAtRow:1UL column:1UL];
  
	double x[4];
  for (unsigned i = 0; i != 4; ++i) {
    x[i] = [x_current doubleValueAtRow:(i+1) column:1UL];
  }
	
  double x_n[4];
  
  [RNGenerator setCurrentGenerator:XNoiseGenID];
	double noiseX = gennor(0.0, processNoise);
  double noiseY = gennor(0.0, processNoise);
  x_n[0] = x[0] + dt*x[2] + noiseX*dt*dt/2.;
  x_n[1] = x[1] + dt*x[3] + noiseY*dt*dt/2.;
  x_n[2] = x[2] + noiseX*dt;
  x_n[3] = x[3] + noiseY*dt;
  
  for (unsigned i = 0; i != 4; ++i) {
    [next setDoubleValue:x_n[i] atRow:(i+1) column:1UL];
  }
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                     atTimeIndex: (unsigned)i
                withCurrentState: (MathMatrix *)x_current
{
  // generate noise-free measurement
  double x[4];
  for (unsigned i = 0; i != 4; ++i) {
    x[i] = [x_current doubleValueAtRow:(i+1) column:1UL];
  }
  
  double z1 = x[0];
  double z2 = x[1];
  
  [output setDoubleValue:z1 atRow:1UL column:1UL];
  [output setDoubleValue:z2 atRow:2UL column:1UL];
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
	
	double y1 = [output doubleValueAtRow:1UL column:1UL];
  double y2 = [output doubleValueAtRow:2UL column:1UL];
  
	double x1 = [state doubleValueAtRow:1UL column:1UL];
  double x2 = [state doubleValueAtRow:2UL column:1UL];
	
  y1 -= x1;
  y2 -= x2;
	
//	NSLog(@"Measurement noise is %f", y);
	return exp(-0.5*(y1*y1 + y2*y2)/(measurementNoise*measurementNoise))
    /sqrt(4.0*M_PI*M_PI*pow(measurementNoise,4));
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
                                                  height:2UL];
	
	[Y getVector:measure atColumn:(index + 1UL)]; // since index is 0-based.
	m = [measure doubleValueAtRow:1UL column:1UL];
  double z1 = [measure doubleValueAtRow:1UL column:1UL];
  double z2 = [measure doubleValueAtRow:2UL column:1UL];
  
  double pz1 = [pMeasure doubleValueAtRow:1UL column:1UL];
  double pz2 = [pMeasure doubleValueAtRow:2UL column:1UL];
  
	pm = [pMeasure doubleValueAtRow:1UL column:1UL];
	[measure release];

  return exp(-0.5*(pow(z1-pz1, 2) + pow(z2-pz2,2))/(measurementNoise*measurementNoise))
    /sqrt(4.0*M_PI*M_PI*pow(measurementNoise,4));
}

@end
