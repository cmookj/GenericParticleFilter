//
//  RandomNumberGenerator.m
//  GenericParticleFilter
//
//  Created by Changmook Chun on 9/10/04.
//  Copyright 2004 Seoul National University. All rights reserved.
//

#import "RandomNumberGenerator.h"
#import "time.h"
#import "random.h"


// *****************************************************************************
//
// Private Methods
//
// *****************************************************************************
@interface RandomNumberGenerator (PrivateMethods)

- (BOOL) checkRange: (unsigned)n;

@end



@implementation RandomNumberGenerator
// *****************************************************************************
//
// Initializations & Deallocation
//
// *****************************************************************************
#pragma -
#pragma Initializations & Deallocation

- (id) init {
	long now = time(NULL);
	return [self initWithTwoSeeds: now :(now-1000)];
}

// designated initializer
- (id) initWithTwoSeeds: (long)seed1 :(long)seed2 {
	unsigned i;
	setall(seed1, seed2);
  
	slots = (BOOL*)malloc(32 * sizeof(BOOL));
	for ( i = 0; i < 32; i++ ) {
		slots[i] = NO;
	}
	
	currentGenerator = 0UL;
	return self;
}

- (void) dealloc {
	free(slots);
  [super dealloc];
}


// *****************************************************************************
//
// Access Methods
//
// *****************************************************************************
#pragma -
#pragma Access Methods

- (unsigned) currentGenerator {
	return currentGenerator;
}


- (BOOL) setCurrentGenerator: (unsigned)n {
	if ([self checkRange:n]) {
		if ( [self isSlotOccupied:n] ) {
			return NO;
		}
		currentGenerator = n;
		gscgn(1L, (long *)&currentGenerator);
		return YES;
	} else {
		return NO;
	}
}


// *****************************************************************************
//
// Random Number Generation & Generator Selection
//
// *****************************************************************************
#pragma -
#pragma Random Number Generation & Generator Selection

- (BOOL) isSlotFree: (unsigned)n { // this function checks whether
  // the n'th slot is free or not.
  // if free, it returns YES.
  // otherwise, NO.
	
	if ( [self checkRange:n] ) { // range of n is ok
		if ( slots[n - 1] == NO ) { // the slot is empty
			return YES;
		} else {
			return NO;
		}
	} else {
		NSLog( @"The argument is out of range in isSlotFree:" );
		return NO;
	}
}

- (BOOL) isSlotOccupied: (unsigned)n { // This function is the opposite of
  // the function isSlotFree:
	
	if ([self isSlotFree:n]) {	// The slot is free.
		return NO;
	} else {
		return YES;
	}
}

- (unsigned) suggestEmptySlot {
	//
	// NOT implemented yet !!!!!
	//
	return 0UL;
}

- (BOOL) occupySlot: (unsigned)n { // this function checks whether
  // the n'th slot is empty or not.
  // If free, it occupies the slot
  // and returns YES.
  // Otherwise, NO.
	
	if ([self checkRange:n] && [self isSlotFree:n]) { // range of n is good
    // and n'th slot is empty
		slots[n - 1] = YES;
		return YES;
	} else {
		return NO;
	}
}

- (BOOL) freeSlot: (unsigned)n {
	if ([self checkRange:n] && [self isSlotOccupied:n]) { // The range of n is
    // good and occupied.
		slots[n - 1] = NO;
		return YES;
	} else {
		return NO;
	}
}



// *****************************************************************************
//
// Private Methods
//
// *****************************************************************************
#pragma -
#pragma Private Methods

- (BOOL) checkRange: (unsigned)n {
	if (( 1UL <= n ) && ( n <= 32UL )) {
		return YES;
	} else {
		return NO;
	}
}



@end
