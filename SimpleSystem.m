//
//  SimpleSystem.m
//  GenericParticleFilter
//
//  Created by Changmook Chun on Tue Mar 02 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import "SimpleSystem.h"
#import "random.h"

@implementation SimpleSystem
// *****************************************************************************
//
//  INITIALIZATIONs & DEALLOCATION
//
// *****************************************************************************
#pragma mark -
#pragma mark Initializations & Deallocation

- (id) init {
    return [self initWithTimeSpan: nil ];
}

// designated initializer
- (id) initWithTimeSpan: (MathMatrix *)span {
    if ( self = [super initWithTimeSpan: span
                       systemParameters: nil
                         stateDimension: 1UL
                         inputDimension: 0UL
                        outputDimension: 1UL
                  processNoiseDimension: 1UL
                   outputNoiseDimension: 1UL] ) {
        
        MathMatrix *params = [[MathMatrix alloc] initWithType:@"double"
                                                        width:1UL
                                                       height:3UL];
        
        [params setDoubleValue:0.5 atRow:1UL column:1UL];
        [params setDoubleValue:0.2 atRow:2UL column:1UL];
        [params setDoubleValue:0.5 atRow:3UL column:1UL];
        
        [self setParameters:params];
        [params release];
        
        [X setDoubleValue:0.0 atRow:1UL column:1UL];
        
        sigma = 0.5;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}


// *****************************************************************************
//
//  ACCESS METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Access Methods

// sigma
- (double)sigma {
    return sigma;
}

- (void)setSigma: (double)var {
    sigma = var;
}

// phi 1
- (double) phi1 {
    return [parameters doubleValueAtRow:1UL column:1UL];
}

- (void) setPhi1: (double)var {
    [parameters setDoubleValue:var atRow:1UL column:1UL];
}

// phi 2
- (double) phi2 {
    return [parameters doubleValueAtRow:2UL column:1UL];
}

- (void) setPhi2: (double)var {
    [parameters setDoubleValue:var atRow:2UL column:1UL];
}

// phi 3
- (double) phi3 {
    return [parameters doubleValueAtRow:3UL column:1UL];
}

- (void) setPhi3: (double)var {
    [parameters setDoubleValue:var atRow:3UL column:1UL];
}



// *****************************************************************************
//
//  SIMULATION RELATED METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Simulation Related Methods

- (void) simulateWithInitialState: (MathMatrix *)xInit
                          control: (MathMatrix *)control {
//    unsigned i;
    double xx, xm1, yy;
    [xInit getValue:&xx atRow:1UL column:1UL];
    [X setDoubleValue:xx atRow:1UL column:1UL];
    
    for (unsigned i = 1; i < [timeSpan count]; i++ ) {
        // propagate the system dynamics
        double t = ((double *)[timeSpan elements])[i];
        [X getValue:&xm1 atRow:1UL column:i];
        [RNGenerator setCurrentGenerator:XNoiseGenID];
        xx = 1.0 + sin(0.04*M_PI*t)
        + [self phi1]*xm1 + gengam(2.0f, 3.0f);
        [X setDoubleValue:xx atRow:1UL column:(i + 1UL)];
        
        // generate artificial measurement
        if ( i <= 30 ) {
            yy = [self phi2]*pow(xx, 2.0);
        } else {
            yy = -2.0 + xx*[self phi3];
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
    double _x = [x doubleValueAtRow:1UL column:1UL];
    double xx;
    
    [RNGenerator setCurrentGenerator:XNoiseGenID];
    xx = 1.0 + sin(0.04*M_PI*t) + [self phi1]*_x + gengam(2.0, 3.0);
    [next setDoubleValue:xx atRow:1UL column:1UL];
}

- (void) getNextState: (MathMatrix *)next
               atTime: (double)t
     withCurrentState: (MathMatrix *)x
              control: (MathMatrix *)control {
    
    double _x = [x doubleValueAtRow:1UL column:1UL];
    double xx;
    
    [RNGenerator setCurrentGenerator:XNoiseGenID];
    xx = 1.0 + sin(0.04*M_PI*t) + [self phi1]*_x + gengam(2.0, 3.0);
    [next setDoubleValue:xx atRow:1UL column:1UL];
}

- (void) getNoiseFreeMeasurement: (MathMatrix *)output
                     atTimeIndex: (unsigned)i
                withCurrentState: (MathMatrix *)x {
    
    double m;
    double _x = [x doubleValueAtRow:1UL column:1UL];
    
    if ( i <= 30 ) {
        m = [self phi2] * pow(_x, 2.0);
    } else {
        m = -2.0 + _x * [self phi3];
    }
    
    [output setDoubleValue:m atRow:1UL column:1UL];
}

- (void) getNextState: (MathMatrix *)next
          atTimeIndex: (unsigned)i
     withCurrentState: (MathMatrix *)x
           parameters: (MathMatrix *)params
              control: (MathMatrix *)control {
    
    double t = [timeSpan doubleValueAtRow:1UL column:(i + 1UL)];
    double _x = [x doubleValueAtRow:1UL column:1UL];
    double xx;
    
    [RNGenerator setCurrentGenerator:XNoiseGenID];
    xx = 1.0 + sin(0.04*M_PI*t)
    + [params doubleValueAtRow:1UL column:1UL]*_x
    + gengam(2.0, 3.0);
    [next setDoubleValue:xx atRow:1UL column:1UL];
}

- (void) getMeasurement: (MathMatrix *)output
            atTimeIndex: (unsigned)i
       withCurrentState: (MathMatrix *)x
             parameters: (MathMatrix *)params {
    
    double m;
    
    double _x = [x doubleValueAtRow:1UL column:1UL];
    
    if ( i <= 30 ) {
        m = [params doubleValueAtRow:2UL column:1UL] * pow(_x, 2.0);
    } else {
        m = -2.0 + _x * [params doubleValueAtRow:2UL column:1UL];
    }
    
    [RNGenerator setCurrentGenerator:YNoiseGenID];
    m += gennor(0.0, sigma);	// gennor( mean, standard deviation);
    
    [output setDoubleValue:m atRow:1UL column:1UL];
}

- (double) probabilityOf: (MathMatrix *)output
                   given: (MathMatrix *)state
             atTimeIndex: (unsigned)ti
          withParameters: (MathMatrix *)params {
    
    double y = [output doubleValueAtRow:1UL column:1UL];
    double x = [state doubleValueAtRow:1UL column:1UL];
    
    if ( ti <= 30 ) {
        y -= [params doubleValueAtRow:2UL column:1UL] * pow(x, 2.0);
    } else {
        y -= (-2.0 + x * [params doubleValueAtRow:3UL column:1UL]);
    }
    
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
