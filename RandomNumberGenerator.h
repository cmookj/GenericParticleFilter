//
//  RandomNumberGenerator.h
//  GenericParticleFilter
//
//  Created by Changmook Chun on 9/10/04.
//  Copyright 2004 Seoul National University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RandomNumberGenerator : NSObject {
@private
	BOOL* slots;
	unsigned currentGenerator;
}

// *****************************************************************************
//
// Initializations & Deallocation
//
// *****************************************************************************
#pragma -
#pragma Initializations & Deallocation

- (id) init;
- (id) initWithTwoSeeds: (long)seed1 :(long)seed2;
- (void) dealloc;


// *****************************************************************************
//
// Access Methods
//
// *****************************************************************************
#pragma -
#pragma Access Methods

- (unsigned) currentGenerator;
- (BOOL) setCurrentGenerator: (unsigned)n;



// *****************************************************************************
//
// Random Number Generation & Generator Selection
//
// *****************************************************************************
#pragma -
#pragma Random Number Generation & Generator Selection

- (BOOL) isSlotFree: (unsigned)n;
- (BOOL) isSlotOccupied: (unsigned)n;
- (unsigned) suggestEmptySlot;

- (BOOL) occupySlot: (unsigned)n;
- (BOOL) freeSlot: (unsigned)n;


@end
