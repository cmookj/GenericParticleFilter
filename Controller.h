//
//  Controller.h
//  Cocoa GPF
//
//  Created by Changmook Chun on 11/10/04.
//  Copyright 2004 Seoul National University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GenericSystem.h"
#import "SimpleSystem.h"
#import "SimpleSystem2.h"
#import "HullWhiteOne.h"
#import "RandomWalk.h"
#import "MathUtil.h"
#import "GenericParticleFilter.h"
#import "random.h"
#import "RandomNumberGenerator.h"
#import "MathMatrix.h"


//  ============================================================================
//  Constants
//  ============================================================================
#pragma mark -
#pragma mark Constants

// Constants: Model ID strings
#define CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM	@"test system"
#define CONST_STRING_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL	@"hull white 1"
#define CONST_STRING_MODEL_IDENTIFIER_HULL_WHITE_2_FACTOR_MODEL	@"hull white 2"
#define CONST_STRING_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2	@"test system 2"
#define CONST_STRING_MODEL_IDENTIFIER_RANDOM_WALK @"random walk"


// Constants: Random number generator IDs
enum {
	CONST_RNG_ID_GPF_RESAMPLER = 1UL,
	CONST_RNG_ID_GPF_BERNOULLI = 2UL,
	CONST_RNG_ID_SIMPLE_TEST_X = 3UL,
	CONST_RNG_ID_SIMPLE_TEST_Y = 4UL,
	CONST_RNG_ID_HULL_WHITE_1_X = 5UL,
	CONST_RNG_ID_HULL_WHITE_1_Y = 6UL,
	CONST_RNG_ID_HULL_WHITE_2_X1 = 7UL,
	CONST_RNG_ID_HULL_WHITE_2_X2 = 8UL,
	CONST_RNG_ID_HULL_WHITE_2_Y = 9UL,
	CONST_RNG_ID_SIMPLE_TEST_2_X = 10UL,
	CONST_RNG_ID_SIMPLE_TEST_2_Y = 11UL,
  CONST_RNG_ID_RANDOM_WALK_X = 12UL,
  CONST_RNG_ID_RANDOM_WALK_Y = 13UL
};

// Constants: NSTextField IDs
enum {
	CONST_TEXT_FIELD_ID_TIME_SPAN_BEGIN = 0,
	CONST_TEXT_FIELD_ID_TIME_SPAN_END = 1,
	CONST_TEXT_FIELD_ID_TIME_SPAN_STEP = 2
};

// Constants: Model IDs
enum {
	CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM = 0,
	CONST_MODEL_IDENTIFIER_HULL_WHITE_1_FACTOR_MODEL = 1,
	CONST_MODEL_IDENTIFIER_HULL_WHITE_2_FACTOR_MODEL = 2,
	CONST_MODEL_IDENTIFIER_SIMPLE_TEST_SYSTEM_2 = 3,
  CONST_MODEL_IDENTIFIER_RANDOM_WALK = 4
};

// Constants: Parameter estimation methods IDs
enum {
	CONST_PARAM_EST_METHOD_VIA_FILTERING = 0,
	CONST_PARAM_EST_METHOD_AUX_PARTICLE_FILTER = 1,
	CONST_PARAM_EST_METHOD_SPSA = 2
};


const unsigned CONST_DEFAULT_NUMBER_OF_PARTICLES = 200;

const unsigned CONST_DOMAIN_NUM_STEP = 400;
const double CONST_DOMAIN_LOWER_BOUND = -10.0;
const double CONST_DOMAIN_UPPER_BOUND = 10.0;

const double SYSTEM_DEFAULT_TIME_BEGIN = 0.0;
const double SYSTEM_DEFAULT_TIME_END = 120.0;
const double SYSTEM_DEFAULT_TIME_STEP = 1.0;
const unsigned SYSTEM_DEFAULT_TIME_SPAN_SIZE = 121;


//  ============================================================================
//  Interface
//  ============================================================================
#pragma mark -
#pragma mark Interface

@interface Controller : NSObject {
	@private
	// GUI elements
	IBOutlet NSDrawer*		simVariableDrawer;
	IBOutlet NSMatrix*		estimationCheckButtonMatrix;
	IBOutlet NSButton*		drawerToggleButton;
	IBOutlet NSPopUpButton*	modelSelectionPopUpButton;
	IBOutlet NSPopUpButton*	parameterEstimationMethodPopUpButton;
	IBOutlet NSForm*		spsaCoefficientsForm;
	IBOutlet NSTextField*	simTimeSpanBegin;
	IBOutlet NSTextField*	simTimeSpanEnd;
	IBOutlet NSTextField*	simTimeSpanStep;
	IBOutlet NSProgressIndicator*	spinningIndicator;
	
	
	// Variable Drawer's content views
	IBOutlet NSView* testSystemDrawerContent;
	IBOutlet NSView* hullWhiteOneDrawerContent;
	IBOutlet NSView* hullWhiteTwoDrawerContent;
	IBOutlet NSView* testSystem2DrawerContent;
	
	// Variable Forms
	IBOutlet NSForm*	testSystemVariableForm;
	IBOutlet NSForm*	hullWhiteOneVariableForm;
	IBOutlet NSForm*	hullWhiteTwoVariableForm;
	IBOutlet NSForm*	testSystem2VariableForm;
	
	// Initial Value Forms
	IBOutlet NSForm* initialTestSystem;
	IBOutlet NSForm* initialHullWhiteOne;
	IBOutlet NSForm* initialHullWhiteTwo;
	IBOutlet NSForm* initialTestSystem2;
	
	
	NSView*	simVariableView;
	
	// Helper object
	// id delegate;
	
	// Particle Filter support objects
	MathMatrix* domain;
	MathMatrix* span;
	
	RandomNumberGenerator* RNGenerator;
	NSMutableDictionary* systems;
	GenericSystem* currentSystem;
	GenericParticleFilter* pf;
	
}

//  ============================================================================
//  Initialization & Deallocation
//  ============================================================================
#pragma mark -
#pragma mark Initialization & Deallocation

- (id) init;
- (void) dealloc;


//  ============================================================================
//  Accessor methods
//  ============================================================================
#pragma mark -
#pragma mark Accessor Methods

- (NSDrawer *) simVariableDrawer;
- (NSView *) simVariableView;
- (void) setSimVariableView: (NSView *)theView;
- (NSMatrix *) estimationCheckButtonMatrix;
- (NSButton *) drawerToggleButton;

- (MathMatrix *)domain;
- (void)setDomain: (MathMatrix *)theDomain;

- (MathMatrix *)span;
- (void)setSpan: (MathMatrix *)theSpan;

- (RandomNumberGenerator *)RNGenerator;
- (void)setRandomNumberGenerator: (RandomNumberGenerator *)theGenerator;

- (GenericSystem *)currentSystem;
- (void)setCurrentSystem: (GenericSystem *)theSystem;

- (GenericParticleFilter *)pf;
- (void)setGenericParticleFilter: (GenericParticleFilter *)thePf;

- (NSMutableDictionary *)systems;
- (void)setSystems: (NSMutableDictionary *)theSystems;

//  ============================================================================
//  Action methods
//  ============================================================================
#pragma mark -
#pragma mark Action Methods

- (IBAction) beginSimulation: (id) sender;
- (IBAction) modelChanged: (id) sender;
- (IBAction) estimationCheckButtonMatrixClicked: (id) sender;
- (IBAction) modifyTimeSpan: (id) sender;
- (IBAction) changeParameterEstimationMethod: (id) sender;

@end
