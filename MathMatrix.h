//
//  MathMatrix.h
//  GenericParticleFilter
//
//  Created by Changmook Chun on Wed Feb 25 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MathMatrix : NSObject {
@private
	int _type;
	
	unsigned _width;
	unsigned _height;
	
	void* _data;
}

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOC
//
// *****************************************************************************
#pragma mark -
#pragma mark Initializations & Dealloc

- (id)init;

// designated initializer
- (id)initWithType: (NSString *)type
             width: (unsigned)width
            height: (unsigned)height;

// dealloc
- (void)dealloc;


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (NSString *)type;
- (void)setType: (NSString *)type;

- (unsigned)width;
- (void)setWidth: (unsigned)width;

- (unsigned)height;
- (void)setHeight: (unsigned)height;

- (void *)elements;
- (void)setElements: (void *)dt;


// *****************************************************************************
//
//  CLASS SPECIFIC METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Retrieve or Set Data

- (unsigned)count;

//
//  Note that all the indices here, i.e., r and c, begin from 1.
//  To access the first row, for example, set r to 1 instead of 0.
//
- (void)getValue: (void *)val
           atRow: (unsigned)r
          column: (unsigned)c;

- (void)getVector: (MathMatrix *)v
         atColumn: (unsigned)c;

- (void)getVector: (MathMatrix *)v
            atRow: (unsigned)r;

- (void)setVector: (MathMatrix *)v
         atColumn: (unsigned)c;

- (void)setVector: (MathMatrix *)v
            atRow: (unsigned)r;

- (void)setCharValue: (char)val
               atRow: (unsigned)r
              column: (unsigned)c;

- (void)setUnsignedCharValue: (unsigned char)val
                       atRow: (unsigned)r
                      column: (unsigned)c;

- (void)setIntValue: (int)val
              atRow: (unsigned)r
             column: (unsigned)c;

- (void)setUnsignedValue: (unsigned)val
                   atRow: (unsigned)r
                  column: (unsigned)c;

- (void)setFloatValue: (float)val
                atRow: (unsigned)r
               column: (unsigned)c;

- (void)setDoubleValue: (double)val
                 atRow: (unsigned)r
                column: (unsigned)c;


- (char)charValueAtRow: (unsigned)r
                column: (unsigned)c;

- (unsigned)unsignedCharValueAtRow: (unsigned)r
                            column: (unsigned)c;

- (int)intValueAtRow: (unsigned)r
              column: (unsigned)c;

- (unsigned)unsignedValueAtRow: (unsigned)r
                        column: (unsigned)c;

- (float)floatValueAtRow: (unsigned)r
                  column: (unsigned)c;

- (double)doubleValueAtRow: (unsigned)r
                    column: (unsigned)c;

- (MathMatrix *)rankOfElements;

// *****************************************************************************
//
//  MATHEMATICAL OPERATIONS
//
// *****************************************************************************
#pragma mark -
#pragma mark Mathematical Operations

- (void) multiplyScalar: (double)scalar;

- (void) addMatrix: (MathMatrix *)mat;

- (void) subtractMatrix: (MathMatrix *)mat;


// *****************************************************************************
//
//  FILE OUTPUT
//
// *****************************************************************************
#pragma mark -
#pragma mark File Output Methods

- (void) writeMatrixToFile: (NSString *)fileName;

- (void) writeRow: (unsigned)r
           toFile: (NSString *)fileName;

- (void) writeRowTransposed: (unsigned)r
                     toFile: (NSString *)fileName;

- (void) writeColumn: (unsigned)c
              toFile: (NSString *)fileName;

@end
