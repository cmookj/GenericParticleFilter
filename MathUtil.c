/*
 *  MathUtil.c
 *  GenericParticleFilter
 *
 *  Created by Changmook Chun on Mon Dec 08 2003.
 *  Copyright (c) 2003 Seoul National University. All rights reserved.
 *
 */

#include "MathUtil.h"

void
CumulativeSum (double *inVector,
               double *outVector,
               unsigned size
               ) {
  
	int i;
	outVector[0] = inVector[0];
	for ( i = 1; i < size; i++ ) {
		outVector[i] = inVector[i] + outVector[i - 1];
	}
}

void
CumulativeProduct(double *inVector,
                  double *outVector,
                  unsigned size
                  ) {
	
	int i;
	outVector[0] = inVector[0];
	for ( i = 1; i < size; i++ ) {
		outVector[i] = inVector[i] * outVector[i - 1];
	}
}

void
FlipLR (double *inVector,
        double *outVector,
        unsigned size
        ) {
	
	int i, n;
	n = size - 1;
	for ( i = 0; i < size; i++ ) {
		outVector[n - i] = inVector[i];
	}
}

void
Fix (double *inVector,
     double *outVector,
     unsigned size
     ) {
	
	//
	//  NOT IMPLEMENTED YET !!!
	//
}

void
Hist (double *inVector, unsigned iSize,
      double *domainVector, unsigned dSize,
      unsigned *outVector
      ) {
	
	// This function assumes that domainVector has distinct numbers
	
	unsigned i, left, middle, right;
	for ( i = 0; i < dSize - 1; i++ ) {
		outVector[i] = 0;
	}
	
	for ( i = 0; i < iSize; i++ ) {
		// 1. Check for numbers greater than the last element of domainVector
		if ( inVector[i] > domainVector[dSize - 1] ) break;
		
		// 2. Otherwise, check where the number is located in the domainVector
		//    This algorithm resembles that of binary search
		left = 0;
		right = dSize - 1;
		while ( 1 ) {
			middle = left + (right - left) / 2;
			
			if ( inVector[i] >= domainVector[middle] ) {
				left = middle;
			} else {
				right = middle;
			}
			
			if ((right - left) == 1) break;
		}
		outVector[left]++;
	}
}
