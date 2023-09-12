/*
 *  MathUtil.h
 *  GenericParticleFilter
 *
 *  Created by Changmook Chun on Mon Dec 08 2003.
 *  Copyright (c) 2003 Seoul National University. All rights reserved.
 *
 */

void
CumulativeSum (double *inVector,
               double *outVector,
               unsigned size
               );

void
CumulativeProduct (double *inVector,
                   double *outVector,
                   unsigned size
                   );

void
FlipLR (double *inVector,
        double *outVector,
        unsigned size
        );

void
Fix (double *inVector,
     double *outVector,
     unsigned size
     );

void
Hist (double *inVector, unsigned iSize,
      double *domainVector, unsigned dSize,
      unsigned *outVector
      );

