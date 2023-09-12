//
//  Controller.m
//  Cocoa GPF
//
//  Created by Changmook Chun on 11/10/04.
//  Copyright 2004 Seoul National University. All rights reserved.
//

#import "Controller.h"

//  ============================================================================
//  Private Methods
//  ============================================================================
#pragma mark -
#pragma mark Private Methods

@interface Controller (PrivateMethods)

- (void)readSimulationVariablesToSystem;
- (void)readInitialValues: (MathMatrix *)xi;
- (void)reopenDrawerWithView:(NSView *)theView;
- (void)buildTimeSpanBeginsAt: (double) begin
                       endsAt: (double) end
                 withStepSize: (double) step;

// Parameter estimation methods.
- (void) estimateParametersUsingMeasurementComparison;
- (void) estimateParametersUsingAuxParticleFilter;
- (void) estimateParametersUsingSPSA;

@end




@implementation Controller

//  ============================================================================
//  Initialization & Deallocation
//  ============================================================================
#pragma mark -
#pragma mark Initialization & Deallocation

- (id) init {
    self = [super init];
    if ( self ) {
        unsigned i;
        double t = SYSTEM_DEFAULT_TIME_BEGIN;
        double step;
        
        domain = [[MathMatrix alloc] initWithType:@"double"
                                            width:(CONST_DOMAIN_NUM_STEP + 1)
                                           height:1UL];
        
        span = [[MathMatrix alloc] initWithType:@"double"
                                          width:SYSTEM_DEFAULT_TIME_SPAN_SIZE
                                         height:1UL];
        
        RNGenerator = [[RandomNumberGenerator alloc] init];
        
        // make time span
        for ( i = 0; i < SYSTEM_DEFAULT_TIME_SPAN_SIZE; i++ ) {
            ((double *)[span elements])[i] = t;
            t += SYSTEM_DEFAULT_TIME_STEP;
        }
        
        // default system for simulation is SimpleSystem
        systems = [[NSMutableDictionary alloc] init];
        
        // Initially set currentSystem to SimpleSystem
        currentSystem = [[SimpleSystem alloc] init];
        [currentSystem setRNGenerator: RNGenerator];
        [(SimpleSystem *)currentSystem setXNoiseGenID: CONST_RNG_ID_SIMPLE_TEST_X];
        [(SimpleSystem *)currentSystem setYNoiseGenID: CONST_RNG_ID_SIMPLE_TEST_Y];
        
        [systems setObject:currentSystem
                    forKey:CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM];
        [currentSystem release];
        
        // setup domain for the histogram
        step = CONST_DOMAIN_UPPER_BOUND - CONST_DOMAIN_LOWER_BOUND;
        step /= (double)CONST_DOMAIN_NUM_STEP;
        for ( i = 0; i <= CONST_DOMAIN_NUM_STEP; i++ ) {
            ((double*)[domain elements])[i] = CONST_DOMAIN_LOWER_BOUND
            + (step * (double)i);
        }
        
        pf = [[GenericParticleFilter alloc]
              initWithCapacity:CONST_DEFAULT_NUMBER_OF_PARTICLES
              forSystem:currentSystem
              withSelectionScheme:PF_CONST_RESAMPLE_MULTINOMIAL];
        [pf setRNGenerator: RNGenerator];
        [pf setRNGIDForResampler: CONST_RNG_ID_GPF_RESAMPLER];
        [pf setRNGIDForBernoulli: CONST_RNG_ID_GPF_BERNOULLI];
        
        return self;
    } else {
        NSLog( @"Initialization of Controller object failed." );
        return nil;
    }
}

- (void) dealloc {
    [domain release];
    [span release];
    [RNGenerator release];
    [systems release];
    [pf release];
    
    [super dealloc];
}

- (void)awakeFromNib {
    MathMatrix* initialState;
    
    // Set "State estimation" check button checked
    [estimationCheckButtonMatrix setState:1 atRow:0 column:0];
    // Set "Parameter estimation" check button un-checked
    [estimationCheckButtonMatrix setState:0 atRow:1 column:0];
    // Disable spsa parameter estimation coefficients matrix
    [spsaCoefficientsForm setEnabled:NO];
    // Disable parameter estimation method popup button
    [parameterEstimationMethodPopUpButton setEnabled:NO];
    // Select the first menu item of parameter estimation method popup button
    [parameterEstimationMethodPopUpButton selectItemAtIndex:0];
    
    // set initial values to coefficients form
    [[spsaCoefficientsForm cellAtIndex:0] setDoubleValue: 0.602]; // alpha
    [[spsaCoefficientsForm cellAtIndex:1] setDoubleValue: 0.101]; // gamma
    [[spsaCoefficientsForm cellAtIndex:2] setDoubleValue: 0.16]; // a
    [[spsaCoefficientsForm cellAtIndex:3] setDoubleValue: 0.01]; // c
    [[spsaCoefficientsForm cellAtIndex:4] setDoubleValue: 100.0]; // A
    [[spsaCoefficientsForm cellAtIndex:5] setIntValue: 4]; // L
    
    // Set initial time span
    [simTimeSpanBegin setDoubleValue:SYSTEM_DEFAULT_TIME_BEGIN];
    [simTimeSpanEnd setDoubleValue:SYSTEM_DEFAULT_TIME_END];
    [simTimeSpanStep setDoubleValue:SYSTEM_DEFAULT_TIME_STEP];
    
    // set initial variables to drawer's content view & initial value of x
    [[testSystemVariableForm cellAtIndex:0] setDoubleValue:
     [(SimpleSystem *)currentSystem sigma]];
    [[testSystemVariableForm cellAtIndex:1] setDoubleValue:
     [(SimpleSystem *)currentSystem phi1]];
    
    initialState = [[MathMatrix alloc] initWithType:@"double"
                                              width:1UL
                                             height:[currentSystem dimX]];
    
    // Get initial value of x of the current system.
    [currentSystem getInitialX: initialState];
    
    // Set the initial value to the GUI element.
    [[initialTestSystem cellAtIndex:0] setDoubleValue:
     [initialState doubleValueAtRow:1UL column:1UL]];
    
    [initialState release];
}

//  ============================================================================
//  Accessor methods
//  ============================================================================
#pragma mark -
#pragma mark Accessor Methods

- (NSDrawer *) simVariableDrawer {
    return simVariableDrawer;
}

- (NSView *) simVariableView {
    return simVariableView;
}

- (void) setSimVariableView: (NSView *)theView {
    // not implemented yet
}

- (NSMatrix *) estimationCheckButtonMatrix {
    return estimationCheckButtonMatrix;
}

- (NSButton *) drawerToggleButton {
    return drawerToggleButton;
}

- (MathMatrix *)domain {
    return domain;
}

- (void)setDomain: (MathMatrix *)theDomain {
    [theDomain retain];
    [domain release];
    domain = theDomain;
}

- (MathMatrix *)span {
    return span;
}

- (void)setSpan: (MathMatrix *)theSpan {
    [theSpan retain];
    [span release];
    span = theSpan;
}

- (RandomNumberGenerator *)RNGenerator {
    return RNGenerator;
}

- (void)setRandomNumberGenerator: (RandomNumberGenerator *)theGenerator {
    [theGenerator retain];
    [RNGenerator release];
    RNGenerator = theGenerator;
}

- (GenericSystem *)currentSystem {
    return currentSystem;
}

- (void)setCurrentSystem: (GenericSystem *)theSystem {
    // *****
    // I think this method should be re-coded.
    // *****
    [theSystem retain];
    [currentSystem release];
    currentSystem = theSystem;
}

- (GenericParticleFilter *)pf {
    return pf;
}

- (void)setGenericParticleFilter: (GenericParticleFilter *)thePf {
    [thePf retain];
    [pf release];
    pf = thePf;
}

- (NSMutableDictionary *)systems {
    return systems;
}

- (void)setSystems: (NSMutableDictionary *)theSystems {
    [theSystems retain];
    [systems release];
    
    systems = theSystems;
}




//  ============================================================================
//  Action methods
//  ============================================================================
#pragma mark -
#pragma mark Action Methods

- (IBAction) beginSimulation: (id)sender {
    MathMatrix* xinit;
    unsigned i;
    
    // Start animation
    [spinningIndicator startAnimation:self];
    
    // Read simulation variables from the content view of the drawer to
    // the model system
    [self readSimulationVariablesToSystem];
    
    xinit = [[MathMatrix alloc] initWithType:@"double"
                                       width:1UL
                                      height:[[currentSystem X] height]];
    [self readInitialValues: xinit];
    
    // Run simulation of the model system
    NSLog(@"Simulation of the system begins.");
    [currentSystem simulateWithInitialState:xinit control:nil];
    NSLog(@"Simulation of the system ends.");
    
    // Write the simulated states and measurements to files
    [currentSystem writeAllStatesToFile];
    [currentSystem writeOutputComponent:1UL toFile:@"measurements.1.txt"];
    
    [pf setSystem: currentSystem];
    
    // State estimation
    if ( [[estimationCheckButtonMatrix cellAtRow:0 column:0] state] == NSOnState ) {
        NSLog(@"Particle filtering for state estimation begins.");
        [pf initializeParticleFilter];
        [pf estimateStates];
        NSLog(@"Particle filtering for state estimation ends.");
        
        // write states to file
        [pf writeStateToFile:@"states.txt"];
        
        // write estimate of the state to file
        [pf writeEstimateToFile:@"estimates.txt"];
        
        // write estimation error to file
        [pf writeEstimationErrorToFile:@"estimation_error.txt"];
    }
    
    // Parameter estimation
    if ( [[estimationCheckButtonMatrix cellAtRow:1 column:0] state] == NSOnState ) {
        NSLog( @"Particle filtering for parameter estimation begins." );
        switch ( [parameterEstimationMethodPopUpButton indexOfSelectedItem] ) {
        case CONST_PARAM_EST_METHOD_VIA_FILTERING:
            // [self estimateParametersUsingEstimationViaFiltering];
            break;
            
        case CONST_PARAM_EST_METHOD_AUX_PARTICLE_FILTER:
            [self estimateParametersUsingAuxParticleFilter];
            break;
            
        case CONST_PARAM_EST_METHOD_SPSA:
            [self estimateParametersUsingSPSA];
            break;
            
        }
        NSLog( @"Particle filtering for parameter estimation ends." );
    }
    
    [xinit release];
    
    // Stop animation
    [spinningIndicator stopAnimation:self];
}

- (IBAction) modelChanged: (id)sender {
    
    // Things to do in this method
    // 1. change modelSystem
    // 2. allocate an instance of system if necessary
    // 3. change the content view of the drawer
    
    GenericSystem* theSystem;
    
    switch ( [sender indexOfSelectedItem] ) {
    case CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM:
        // 1. Is the selected item the same as currentSystem?
        theSystem = [systems objectForKey:CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM];
        if ( theSystem == currentSystem ) {
            // If yes, there's nothing to do.
            return;
        } else {
            if ( !theSystem ) {
                // The selected item of the PopUp button has not been allocated yet.
                currentSystem = [[SimpleSystem alloc] init];
                [(SimpleSystem *)currentSystem setRNGenerator:RNGenerator];
                [(SimpleSystem *)currentSystem setXNoiseGenID:CONST_RNG_ID_SIMPLE_TEST_X];
                [(SimpleSystem *)currentSystem setYNoiseGenID:CONST_RNG_ID_SIMPLE_TEST_Y];
                
                [systems setObject:currentSystem
                            forKey:CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM];
                [currentSystem release];
            } else {
                // The selected item has been allocated already.
                // Just set currentSystem
                currentSystem = theSystem;
            }
            [self reopenDrawerWithView:testSystemDrawerContent];
            [[testSystemVariableForm cellAtIndex:0] setDoubleValue:
             [(SimpleSystem *)currentSystem sigma]];
            [[testSystemVariableForm cellAtIndex:1] setDoubleValue:
             [(SimpleSystem *)currentSystem phi1]];
        }
        break;
        
    case CONST_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL:
        // 1. Is the selected item the same as currentSystem?
        theSystem =
        [systems objectForKey:CONST_STRING_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL];
        if ( theSystem == currentSystem ) {
            // If yes, there's nothing to do.
            return;
        } else {
            if ( !theSystem ) {
                // The selected item of the PopUp button has not been allocated yet.
                currentSystem = [[HullWhiteOne alloc] init];
                [(HullWhiteOne *)currentSystem setRNGenerator:RNGenerator];
                [(HullWhiteOne *)currentSystem setXNoiseGenID:CONST_RNG_ID_HULL_WHITE_1_X];
                [(HullWhiteOne *)currentSystem setYNoiseGenID:CONST_RNG_ID_HULL_WHITE_1_Y];
                
                [systems setObject:currentSystem
                            forKey:CONST_STRING_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL];
                [currentSystem release];
            } else {
                // The selected item has been allocated already.
                // Just set currentSystem
                currentSystem = theSystem;
            }
            [self reopenDrawerWithView:hullWhiteOneDrawerContent];
            [[hullWhiteOneVariableForm cellAtIndex:0]
             setDoubleValue:[(HullWhiteOne *)currentSystem mrs]];
            [[hullWhiteOneVariableForm cellAtIndex:1]
             setDoubleValue:[(HullWhiteOne *)currentSystem vol]];
            [[hullWhiteOneVariableForm cellAtIndex:2]
             setDoubleValue:[(HullWhiteOne *)currentSystem volBSRM]];
        }
        break;
        
    case CONST_MODEL_IDENTIFIER_HULL_WHITE_2_FACTOR_MODEL:
        break;
        
    case CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2:
        // 1. Is the selected item the same as currentSystem?
        theSystem = [systems objectForKey:CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2];
        if ( theSystem == currentSystem ) {
            // If yes, there's nothing to do.
            return;
        } else {
            if ( !theSystem ) {
                // The selected item of the PopUp button has not been allocated yet.
                currentSystem = [[SimpleSystem2 alloc] init];
                [(SimpleSystem2 *)currentSystem setRNGenerator:RNGenerator];
                [(SimpleSystem2 *)currentSystem setXNoiseGenID:CONST_RNG_ID_SIMPLE_TEST_2_X];
                [(SimpleSystem2 *)currentSystem setYNoiseGenID:CONST_RNG_ID_SIMPLE_TEST_2_Y];
                [systems setObject:currentSystem
                            forKey:CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2];
                [currentSystem release];
            } else {
                // The selected item has been allocated already.
                // Just set currentSystem
                currentSystem = theSystem;
            }
            [self reopenDrawerWithView:testSystem2DrawerContent];
            [[testSystem2VariableForm cellAtIndex:0] setDoubleValue:
             [(SimpleSystem2 *)currentSystem sigma]];
        }
        break;
        
    case CONST_MODEL_IDENTIFIER_RANDOM_WALK:
        // 1. Is the selected item the same as currentSystem?
        theSystem = [systems objectForKey:CONST_STRING_MODEL_IDENTIFIER_RANDOM_WALK];
        if ( theSystem == currentSystem ) {
            // If yes, there's nothing to do.
            return;
        } else {
            if ( !theSystem ) {
                // The selected item of the PopUp button has not been allocated yet.
                currentSystem = [[RandomWalk alloc] init];
                [(RandomWalk *)currentSystem setRNGenerator:RNGenerator];
                [(RandomWalk *)currentSystem setXNoiseGenID:CONST_RNG_ID_RANDOM_WALK_X];
                [(RandomWalk *)currentSystem setYNoiseGenID:CONST_RNG_ID_RANDOM_WALK_Y];
                [systems setObject:currentSystem
                            forKey:CONST_STRING_MODEL_IDENTIFIER_RANDOM_WALK];
                [currentSystem release];
            } else {
                // The selected item has been allocated already.
                // Just set currentSystem
                currentSystem = theSystem;
            }
            /*
             [self reopenDrawerWithView:testSystem2DrawerContent];
             [[testSystem2VariableForm cellAtIndex:0] setDoubleValue:
             [(SimpleSystem2 *)currentSystem sigma]];
             */
        }
        break;
        
    default:
        NSLog(@"modelChanged:(id)sender encountered an error.");
        return;
    }
    
    //	NSRunAlertPanel(@"Simulation", @"Model changed!", @"OK", nil, nil);
}

- (IBAction) estimationCheckButtonMatrixClicked: (id)sender {
    
    switch ( [[sender cellWithTag:1] state] ) {
    case NSOnState:
        [parameterEstimationMethodPopUpButton setEnabled:YES];
        if ( [parameterEstimationMethodPopUpButton indexOfSelectedItem]
            == CONST_PARAM_EST_METHOD_SPSA ) {
            [spsaCoefficientsForm setEnabled:YES];
        }
        break;
        
    case NSOffState:
        [parameterEstimationMethodPopUpButton setEnabled:NO];
        [spsaCoefficientsForm setEnabled:NO];
        break;
    }
}

- (IBAction) modifyTimeSpan: (id) sender {
    double begin, end, step, val;
    
    // Obtain the begin, end, and step of time span.
    begin =	[span doubleValueAtRow:1UL column:1UL];
    end =	[span doubleValueAtRow:1UL column:[span width]];
    step =	[span doubleValueAtRow:1UL column:2UL] - begin;
    
    // Set val to the double value of the sender (NSTextField).
    val = [sender doubleValue];
    
    // Build new time span.
    switch ( [sender tag] ) {
    case CONST_TEXT_FIELD_ID_TIME_SPAN_BEGIN:
        [self buildTimeSpanBeginsAt:val endsAt:end withStepSize:step];
        break;
        
    case CONST_TEXT_FIELD_ID_TIME_SPAN_END:
        [self buildTimeSpanBeginsAt:begin endsAt:val withStepSize:step];
        break;
        
    case CONST_TEXT_FIELD_ID_TIME_SPAN_STEP:
        [self buildTimeSpanBeginsAt:begin endsAt:end withStepSize:val];
        break;
        
    default:
        NSLog( @"Invalid sender id in modifyTimeSpan:" );
        return;
    }
    
    // Set the time span of the current system.
    [currentSystem setTimeSpan:span];
}

- (IBAction) changeParameterEstimationMethod: (id) sender {
    switch ( [sender indexOfSelectedItem] ) {
    case CONST_PARAM_EST_METHOD_VIA_FILTERING:
        [spsaCoefficientsForm setEnabled:NO];
        break;
        
    case CONST_PARAM_EST_METHOD_AUX_PARTICLE_FILTER:
        [spsaCoefficientsForm setEnabled:NO];
        break;
        
    case CONST_PARAM_EST_METHOD_SPSA:
        [spsaCoefficientsForm setEnabled:YES];
        break;
    }
}


//  ============================================================================
//  Private Methods
//  ============================================================================
#pragma mark -
#pragma mark Private Methods

- (void) readInitialValues: (MathMatrix *)xi {
    switch ( [modelSelectionPopUpButton indexOfSelectedItem] ) {
        // simple test model
    case CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM:
        [xi setDoubleValue: [[initialTestSystem cellAtIndex:0] doubleValue]
                     atRow: 1UL
                    column: 1UL];
        break;
        
        // Hull White 1-factor model
    case CONST_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL:
        [xi setDoubleValue: [[initialHullWhiteOne cellAtIndex:0] doubleValue]
                     atRow: 1UL
                    column: 1UL];
        break;
        
        // Hull White 2-factor model
    case CONST_MODEL_IDENTIFIER_HULL_WHITE_2_FACTOR_MODEL:
        
        break;
        
        // test model 2
    case CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2:
        [xi setDoubleValue: [[initialTestSystem2 cellAtIndex:0] doubleValue]
                     atRow: 1UL
                    column: 1UL];
        
        [xi setDoubleValue: [[initialTestSystem2 cellAtIndex:1] doubleValue]
                     atRow: 2UL
                    column: 1UL];
        break;
        
    case CONST_MODEL_IDENTIFIER_RANDOM_WALK:
        for (unsigned i = 0; i != 4; ++i) {
            [xi setDoubleValue: 0.0
                         atRow: i+1UL
                        column: 1UL];
        }
        break;
        
    default:
        NSLog(@"readInitialValues: encountered an error.");
        return;
    }
}

- (void) readSimulationVariablesToSystem {
    switch ( [modelSelectionPopUpButton indexOfSelectedItem] ) {
        // simple test model
    case CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM:
        [(SimpleSystem *)currentSystem setSigma:
         [[testSystemVariableForm cellAtIndex:0] doubleValue]];
        
        [(SimpleSystem *)currentSystem setPhi1:
         [[testSystemVariableForm cellAtIndex:1] doubleValue]];
        break;
        
        // Hull White 1-factor model
    case CONST_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL:
        [(HullWhiteOne *)currentSystem setMrs:
         [[hullWhiteOneVariableForm cellAtIndex:0] doubleValue]];
        
        [(HullWhiteOne *)currentSystem setVol:
         [[hullWhiteOneVariableForm cellAtIndex:1] doubleValue]];
        
        [(HullWhiteOne *)currentSystem setVolBSRM:
         [[hullWhiteOneVariableForm cellAtIndex:2] doubleValue]];
        break;
        
        // Hull White 2-factor model
    case CONST_MODEL_IDENTIFIER_HULL_WHITE_2_FACTOR_MODEL:
        
        break;
        
        // test model 2
    case CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2:
        [(SimpleSystem2 *)currentSystem setSigma:
         [[testSystem2VariableForm cellAtIndex:0] doubleValue]];
        break;
        
    case CONST_MODEL_IDENTIFIER_RANDOM_WALK:
        [(RandomWalk *)currentSystem setProcessNoise:0.5];
        [(RandomWalk *)currentSystem setMeasurementNoise:0.2];
        break;
        
    default:
        NSLog(@"readSimulationVariablesToSystem encountered an error.");
        return;
    }
}

- (void)reopenDrawerWithView:(NSView *)theView {
    [simVariableDrawer close];
    [drawerToggleButton setState:NSOffState];
    [simVariableDrawer setContentView:theView];
    [simVariableDrawer open];
    [drawerToggleButton setState:NSOnState];
}

// Build time span that begins at "begin", ends at "end".
// The step size is given in "step."
- (void)buildTimeSpanBeginsAt: (double) begin
                       endsAt: (double) end
                 withStepSize: (double) step {
    
    int i;
    int numberOfSteps = (int)((end - begin)/step);
    
    [span release];
    span = [[MathMatrix alloc] initWithType:@"double"
                                      width:(numberOfSteps + 1)
                                     height:1UL];
    
    for ( i = 0; i <= numberOfSteps; i++ ) {
        [span setDoubleValue:(begin + (double)i*step)
                       atRow:1UL
                      column:(unsigned)(i + 1)];
    }
}

// Parameter estimation methods.
// 1. Estimation by measurement comparison.
- (void) estimateParametersUsingMeasurementComparison {
    
}

// 2. Auxiliary particle filter.
- (void) estimateParametersUsingAuxParticleFilter {
    
}

// 3. SPSA
- (void) estimateParametersUsingSPSA {
    double alpha, gamma, a, c, A;
    unsigned L;
    
    alpha = [[spsaCoefficientsForm cellAtIndex:0] doubleValue];
    gamma = [[spsaCoefficientsForm cellAtIndex:1] doubleValue];
    a = [[spsaCoefficientsForm cellAtIndex:2] doubleValue];
    c = [[spsaCoefficientsForm cellAtIndex:3] doubleValue];
    A = [[spsaCoefficientsForm cellAtIndex:4] doubleValue];
    L = [[spsaCoefficientsForm cellAtIndex:5] intValue];
    
    [pf setWindowSize: L];
    [pf estimateParametersUsingSPSAWithAlpha: alpha
                                       gamma: gamma
                                           a: a
                                           c: c
                                           A: A];
    
}

@end
