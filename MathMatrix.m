//
//  MathMatrix.m
//  GenericParticleFilter
//
//  Created by Changmook Chun on Wed Feb 25 2004.
//  Copyright (c) 2004 Seoul National University. All rights reserved.
//

#import "MathMatrix.h"

// type constants
enum {
	CONST_MATH_MATRIX_TYPE_CHAR = 0,
	CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR,
	CONST_MATH_MATRIX_TYPE_INT,
	CONST_MATH_MATRIX_TYPE_UNSIGNED,
	CONST_MATH_MATRIX_TYPE_FLOAT,
	CONST_MATH_MATRIX_TYPE_DOUBLE
};



@implementation MathMatrix

// *****************************************************************************
//
//  INITIALIZATIONS & DEALLOC
//
// *****************************************************************************
#pragma mark -
#pragma mark Initializations & Dealloc

- (id)init {
	return [self initWithType:@"char"
                      width:1UL
                     height:1UL];
}

// designated initializer
- (id)initWithType: (NSString *)type
             width: (unsigned)width
            height: (unsigned)height {
  
	if (self = [super init]) {
		unsigned size = width * height;
		
		_width = width;
		_height = height;
		
		// memory allocation
		if ( [type isEqualToString:@"char"] ) {
			_data = (char *)malloc(size * sizeof(char));
			_type = CONST_MATH_MATRIX_TYPE_CHAR;
		} else if ( [type isEqualToString:@"unsigned char"] ) {
			_data = (unsigned char *)malloc(size * sizeof(unsigned char));
			_type = CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR;
		} else if ( [type isEqualToString:@"int"] ) {
			_data = (int *)malloc(size * sizeof(int));
			_type = CONST_MATH_MATRIX_TYPE_INT;
		} else if ( [type isEqualToString:@"unsigned"] ) {
			_data = (unsigned *)malloc(size * sizeof(int));
			_type = CONST_MATH_MATRIX_TYPE_UNSIGNED;
		} else if ( [type isEqualToString:@"float"] ) {
			_data = (float *)malloc(size * sizeof(float));
			_type = CONST_MATH_MATRIX_TYPE_FLOAT;
		} else if ( [type isEqualToString:@"double"] ) {
			_data = (double *)malloc(size * sizeof(double));
			_type = CONST_MATH_MATRIX_TYPE_DOUBLE;
		}
	}
	return self;
}

// dealloc
- (void)dealloc {
	if ( _data ) { /// _data is not nil
		free(_data);
	}
	
	[super dealloc];
}


// *****************************************************************************
//
//  ACCESSORS
//
// *****************************************************************************
#pragma mark -
#pragma mark Accessors

- (NSString *)type {
	NSString* typeName;
	
	switch ( _type ) {
		case CONST_MATH_MATRIX_TYPE_CHAR:
			typeName = @"char";
			break;
		case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
			typeName = @"unsigned char";
			break;
		case CONST_MATH_MATRIX_TYPE_INT:
			typeName = @"int";
			break;
		case CONST_MATH_MATRIX_TYPE_UNSIGNED:
			typeName = @"unsigned";
			break;
		case CONST_MATH_MATRIX_TYPE_FLOAT:
			typeName = @"float";
			break;
		case CONST_MATH_MATRIX_TYPE_DOUBLE:
			typeName = @"double";
			break;
	}
	return typeName;
}

- (void)setType: (NSString *)type {
	
}

- (unsigned)width {
	return _width;
}

- (void)setWidth: (unsigned)width {
	
}

- (unsigned)height {
	return _height;
}

- (void)setHeight: (unsigned)height {
	
}

- (void *) elements {
	return _data;
}

- (void)setElements: (void *)dt {
	// NOT implemented yet.
}


// *****************************************************************************
//
//  CLASS SPECIFIC METHODS
//
// *****************************************************************************
#pragma mark -
#pragma mark Retrieve or Set Data

- (unsigned)count {
	return (_width * _height);
}

- (void)getValue: (void *)val
           atRow: (unsigned)r
          column: (unsigned)c {
	
	unsigned offset;
	
	// check the range of r and c first
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to getValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
  
	switch ( _type ) {
		case CONST_MATH_MATRIX_TYPE_CHAR:
			*((char*)val) = ((char*)_data)[offset];
			break;
		case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
			*((unsigned char*)val) = ((unsigned char*)_data)[offset];
			break;
		case CONST_MATH_MATRIX_TYPE_INT:
			*((int*)val) = ((int*)_data)[offset];
			break;
		case CONST_MATH_MATRIX_TYPE_UNSIGNED:
			*((unsigned*)val) = ((unsigned*)_data)[offset];
			break;
		case CONST_MATH_MATRIX_TYPE_FLOAT:
			*((float*)val) = ((float*)_data)[offset];
			break;
		case CONST_MATH_MATRIX_TYPE_DOUBLE:
			*((double*)val) = ((double*)_data)[offset];
			break;
	}
}

- (void)getVector: (MathMatrix *)v
         atColumn: (unsigned)c {
	
	unsigned i, offset;
	
	// check the type of this object and v
	if ( ![[v type] isEqualToString:[self type]] ) { // type mismatch
		NSLog( @"Type mismatch error in getVector:atColumn:" );
		return;
	}
	
	// check dimensions
	if (([v height] != _height) || ([v width] != 1UL)) {	// dimension mismatch
		NSLog(@"Dimension mismatch error in getVector:atColumn:");
		return;
	}
	
	// check range
	if ((c < 1UL) || (_width < c)) {
		NSLog(@"The argument to getVector:atColumn: out of range");
		return;
	}
	
	for ( i = 1; i <= _height; i++ ) {
		offset = (i - 1)*_width + (c - 1);
    
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				[v setCharValue:((char*)_data)[offset]
                  atRow:i
                 column:1UL];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				[v setUnsignedCharValue:((unsigned char*)_data)[offset]
                          atRow:i
                         column:1UL];
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				[v setIntValue:((int*)_data)[offset]
                 atRow:i
                column:1UL];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				[v setUnsignedValue:((unsigned*)_data)[offset]
                      atRow:i
                     column:1UL];
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				[v setFloatValue:((float*)_data)[offset]
                   atRow:i
                  column:1UL];
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				[v setDoubleValue:((double*)_data)[offset]
                    atRow:i
                   column:1UL];
				break;
		}
	}
}

- (void)getVector: (MathMatrix *)v
            atRow: (unsigned)r {
	
	unsigned i, offset;
	
	// check the type of this object and v
	if ( ![[v type] isEqualToString:[self type]] ) { // type mismatch
		NSLog( @"Type mismatch error in getVector:atRow:" );
		return;
	}
	
	// check dimensions
	if (([v width] != _width) || ([v height] != 1UL)) {	// dimension mismatch
		NSLog(@"Dimension mismatch error in getVector:atRow:");
		return;
	}
	
	// check range
	if ((r < 1UL) || (_height < r)) {
		NSLog(@"The argument to getVector:atRow: out of range");
		return;
	}
	
	for ( i = 1; i <= _width; i++ ) {
		offset = (r - 1)*_width + (i - 1);
		
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				[v setCharValue:((char*)_data)[offset]
                  atRow:1UL
                 column:i];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				[v setUnsignedCharValue:((unsigned char*)_data)[offset]
                          atRow:1UL
                         column:i];
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				[v setIntValue:((int*)_data)[offset]
                 atRow:1UL
                column:i];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				[v setUnsignedValue:((unsigned*)_data)[offset]
                      atRow:1UL
                     column:i];
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				[v setFloatValue:((float*)_data)[offset]
                   atRow:1UL
                  column:i];
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				[v setDoubleValue:((double*)_data)[offset]
                    atRow:1UL
                   column:i];
				break;
		}
	}
}

- (void)setVector: (MathMatrix *)v
         atColumn: (unsigned)c {
	
	unsigned i;
	
	// check the type of this object and v
	if ( ![[v type] isEqualToString:[self type]] ) { // type mismatch
		NSLog( @"Type mismatch error in setVector:atColumn:" );
		return;
	}
	
	// check dimensions
	if (([v height] != _height) || ([v width] != 1UL)) {	// dimension mismatch
		NSLog(@"Dimension mismatch error in setVector:atColumn:");
		return;
	}
	
	// check range
	if ((c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setVector:atColumn: out of range");
		return;
	}
	
	for ( i = 1; i <= _height; i++ ) {
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				[self setCharValue: [v charValueAtRow:i column:1UL]
                     atRow: i
                    column: c];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				[self setUnsignedCharValue: [v unsignedCharValueAtRow: i
                                                       column: 1UL]
                             atRow: i
                            column: c];
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				[self setIntValue: [v intValueAtRow:i column:1UL]
                    atRow: i
                   column: c];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				[self setUnsignedValue: [v unsignedValueAtRow:i column:1UL]
                         atRow: i
                        column: c];
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				[self setFloatValue: [v floatValueAtRow:i column:1UL]
                      atRow: i
                     column: c];
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				[self setDoubleValue: [v doubleValueAtRow:i column:1UL]
                       atRow: i
                      column: 1UL];
				break;
		}
	}
}

- (void)setVector: (MathMatrix *)v
            atRow: (unsigned)r {
	
	unsigned i, offset;
	
	// check the type of this object and v
	if ( ![[v type] isEqualToString:[self type]] ) { // type mismatch
		NSLog( @"Type mismatch error in setVector:atRow:" );
		return;
	}
	
	// check dimensions
	if (([v width] != _width) || ([v height] != 1UL)) {	// dimension mismatch
		NSLog(@"Dimension mismatch error in setVector:atRow:");
		return;
	}
	
	// check range
	if ((r < 1UL) || (_height < r)) {
		NSLog(@"The argument to setVector:atRow: out of range");
		return;
	}
	
	for ( i = 1; i <= _width; i++ ) {
		offset = (r - 1)*_width + (i - 1);
		
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				[self setCharValue: [v charValueAtRow:1UL column:i]
                     atRow: r
                    column: i];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				[self setUnsignedCharValue: [v unsignedCharValueAtRow: 1UL
                                                       column: i]
                             atRow: r
                            column: i];
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				[self setIntValue: [v intValueAtRow:1UL column:i]
                    atRow: r
                   column: i];
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				[self setUnsignedValue: [v unsignedValueAtRow:1UL column:i]
                         atRow: r
                        column: i];
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				[self setFloatValue: [v floatValueAtRow:1UL column:i]
                      atRow: r
                     column: i];
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				[self setDoubleValue: [v doubleValueAtRow:1UL column:i]
                       atRow: r
                      column: i];
				break;
		}
	}
}

- (void)setCharValue: (char)val
               atRow: (unsigned)r
              column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_CHAR ) {
		NSLog(@"Type mismatch error in setCharValue:atRow:column:");
		return;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setCharValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
	((char*)_data)[offset] = val;
}

- (void)setUnsignedCharValue: (unsigned char)val
                       atRow: (unsigned)r
                      column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR ) {
		NSLog(@"Type mismatch error in setUnsignedCharValue:atRow:column:");
		return;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setUnsignedCharValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
	((unsigned char*)_data)[offset] = val;
}

- (void)setIntValue: (int)val
              atRow: (unsigned)r
             column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_INT ) {
		NSLog(@"Type mismatch error in setIntValue:atRow:column:");
		return;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setIntValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
	((int*)_data)[offset] = val;
}

- (void)setUnsignedValue: (unsigned)val
                   atRow: (unsigned)r
                  column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_UNSIGNED) {
		NSLog(@"Type mismatch error in setUnsignedValue:atRow:column:");
		return;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setUnsignedValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
	((unsigned*)_data)[offset] = val;
}

- (void)setFloatValue: (float)val
                atRow: (unsigned)r
               column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_FLOAT ) {
		NSLog(@"Type mismatch error in setFloatValue:atRow:column:");
		return;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setFloatValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
	((float*)_data)[offset] = val;
}

- (void)setDoubleValue: (double)val
                 atRow: (unsigned)r
                column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_DOUBLE ) {
		NSLog(@"Type mismatch error in setDoubleValue:atRow:column:");
		return;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to setDoubleValue:atRow:column: out of range");
		return;
	}
	
	offset = (r - 1)*_width + (c - 1);
	((double*)_data)[offset] = val;
}


- (char)charValueAtRow: (unsigned)r
                column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_CHAR ) {
		NSLog(@"Type mismatch error in charValueAtRow:column:");
		NSLog(@"char 0 is returned.");
		return '\0';
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to charValueAtRow:column: out of range");
		NSLog(@"char 0 is returned.");
		return '\0';
	}
	
	offset = (r - 1)*_width + (c - 1);
	return ((char*)_data)[offset];
}

- (unsigned)unsignedCharValueAtRow: (unsigned)r
                            column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR ) {
		NSLog(@"Type mismatch error in unsignedCharValueAtRow:column:");
		NSLog(@"char 0 is returned.");
		return '\0';
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to unsignedCharValueAtRow:column: out of range");
		NSLog(@"char 0 is returned.");
		return '\0';
	}
	
	offset = (r - 1)*_width + (c - 1);
	return ((unsigned char*)_data)[offset];
}

- (int)intValueAtRow: (unsigned)r
              column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_INT ) {
		NSLog(@"Type mismatch error in intValueAtRow:column:");
		NSLog(@"int 0 is returned.");
		return 0L;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to intValueAtRow:column: out of range");
		NSLog(@"int 0 is returned.");
		return 0L;
	}
	
	offset = (r - 1)*_width + (c - 1);
	return ((int*)_data)[offset];
}

- (unsigned)unsignedValueAtRow: (unsigned)r
                        column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_UNSIGNED ) {
		NSLog(@"Type mismatch error in unsignedValueAtRow:column:");
		NSLog(@"unsigned int 0 is returned.");
		return 0UL;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to unsignedValueAtRow:column: out of range");
		NSLog(@"unsigned int 0 is returned.");
		return 0UL;
	}
	
	offset = (r - 1)*_width + (c - 1);
	return ((unsigned*)_data)[offset];
}

- (float)floatValueAtRow: (unsigned)r
                  column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_FLOAT ) {
		NSLog(@"Type mismatch error in floatValueAtRow:column:");
		NSLog(@"float 0.0 is returned.");
		return 0.0;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to floatValueAtRow:column: out of range");
		NSLog(@"float 0.0 is returned.");
		return 0.0;
	}
	
	offset = (r - 1)*_width + (c - 1);
	return ((float*)_data)[offset];
}

- (double)doubleValueAtRow: (unsigned)r
                    column: (unsigned)c {
	
	unsigned offset;
	
	// check type
	if ( _type != CONST_MATH_MATRIX_TYPE_DOUBLE) {
		NSLog(@"Type mismatch error in doubleValueAtRow:column:");
		NSLog(@"double 0.0 is returned.");
		return 0.0;
	}
	
	// check the range of r and c
	if ((r < 1UL) || (_height < r) || (c < 1UL) || (_width < c)) {
		NSLog(@"The argument to doubleValueAtRow:column: out of range");
		NSLog(@"double 0.0 is returned.");
		return 0.0;
	}
	
	offset = (r - 1)*_width + (c - 1);
	return ((double*)_data)[offset];
}

- (MathMatrix *)rankOfElements {
	// Calculates the rank of all elements.
	// This method returns (a pointer to) an autoreleased object of type MathMatrix.
	// The dimension of the MathMatrix is the same as that of the object called
	// this method. The type of the elements is unsigned.
	
	MathMatrix *result = [[MathMatrix alloc] initWithType:@"unsigned"
                                                  width:[self width]
                                                 height:[self height]];
	
	
	
	[result autorelease];
	return result;
}

// *****************************************************************************
//
//  MATHEMATICAL OPERATIONS
//
// *****************************************************************************
#pragma mark -
#pragma mark Mathematical Operations

- (void) multiplyScalar: (double)scalar {
	unsigned i;
	unsigned numberOfAllElements = _width * _height;
	
	for ( i = 0UL; i < numberOfAllElements; i++ ) {
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				((char*)_data)[i] = ((char*)_data)[i] * scalar;
				break;
        
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				((unsigned char*)_data)[i] = ((unsigned char*)_data)[i] * scalar;
				break;
        
			case CONST_MATH_MATRIX_TYPE_INT:
				((int*)_data)[i] = ((int*)_data)[i] * scalar;
				break;
				
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				((unsigned*)_data)[i] = ((unsigned*)_data)[i] * scalar;
				break;
				
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				((float*)_data)[i] = ((float*)_data)[i] * scalar;
				break;
				
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				((double*)_data)[i] = ((double*)_data)[i] * scalar;
				break;
		}
	}
}

- (void) addMatrix: (MathMatrix *)mat {
	unsigned r, c;
	
	// check the type of this object and v
	if ( ![[mat type] isEqualToString:[self type]] ) { // type mismatch
		NSLog( @"Type mismatch error in addMatrix:" );
		return;
	}
	
	// check dimensions
	if (([mat height] != _height) || ([mat width] != _width)) {	// dimension mismatch
		NSLog(@"Dimension mismatch error in addMatrix:");
		return;
	}
	
	for ( r = 1UL; r <= _height; r++ ) {
		for ( c = 1UL; c <= _width; c++ ) {
			switch ( _type ) {
				case CONST_MATH_MATRIX_TYPE_CHAR:
					[self setCharValue: [self charValueAtRow:r column:c]
           + [mat charValueAtRow:r column:c]
                       atRow:r
                      column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
					[self setUnsignedCharValue:[self unsignedCharValueAtRow:r column:c]
           + [mat unsignedCharValueAtRow:r column:c]
                               atRow:r
                              column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_INT:
					[self setIntValue:[self intValueAtRow:r column:c]
           + [mat intValueAtRow:r column:c]
                      atRow:r
                     column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_UNSIGNED:
					[self setUnsignedValue:[self unsignedValueAtRow:r column:c]
           + [mat unsignedValueAtRow:r column:c]
                           atRow:r
                          column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_FLOAT:
					[self setFloatValue:[self floatValueAtRow:r column:c]
           + [mat floatValueAtRow:r column:c]
                        atRow:r
                       column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_DOUBLE:
					[self setDoubleValue:[self doubleValueAtRow:r column:c]
           + [mat doubleValueAtRow:r column:c]
                         atRow:r
                        column:c];
					break;
			}
		}
	}
}

- (void) subtractMatrix: (MathMatrix *)mat {
	unsigned r, c;
	
	// check the type of this object and v
	if ( ![[mat type] isEqualToString:[self type]] ) { // type mismatch
		NSLog( @"Type mismatch error in addMatrix:" );
		return;
	}
	
	// check dimensions
	if (([mat height] != _height) || ([mat width] != _width)) {	// dimension mismatch
		NSLog(@"Dimension mismatch error in addMatrix:");
		return;
	}
	
	for ( r = 1UL; r <= _height; r++ ) {
		for ( c = 1UL; c <= _width; c++ ) {
			switch ( _type ) {
				case CONST_MATH_MATRIX_TYPE_CHAR:
					[self setCharValue: [self charValueAtRow:r column:c]
           - [mat charValueAtRow:r column:c]
                       atRow:r
                      column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
					[self setUnsignedCharValue:[self unsignedCharValueAtRow:r column:c]
           - [mat unsignedCharValueAtRow:r column:c]
                               atRow:r
                              column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_INT:
					[self setIntValue:[self intValueAtRow:r column:c]
           - [mat intValueAtRow:r column:c]
                      atRow:r
                     column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_UNSIGNED:
					[self setUnsignedValue:[self unsignedValueAtRow:r column:c]
           - [mat unsignedValueAtRow:r column:c]
                           atRow:r
                          column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_FLOAT:
					[self setFloatValue:[self floatValueAtRow:r column:c]
           - [mat floatValueAtRow:r column:c]
                        atRow:r
                       column:c];
					break;
					
				case CONST_MATH_MATRIX_TYPE_DOUBLE:
					[self setDoubleValue:[self doubleValueAtRow:r column:c]
           - [mat doubleValueAtRow:r column:c]
                         atRow:r
                        column:c];
					break;
			}
		}
	}
}

// *****************************************************************************
//
//  FILE OUTPUT
//
// *****************************************************************************
#pragma mark -
#pragma mark File Output Methods

- (void) writeMatrixToFile: (NSString *)fileName {
	unsigned i, j;
	FILE *FP = fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "w");
	
	for ( i = 1; i <= _height; i++ ) {	// i'th row
		for ( j = 1; j <= _width; j++ ) { // j'th column
			switch ( _type ) {
				case CONST_MATH_MATRIX_TYPE_CHAR:
					fprintf( FP, "%c", [self charValueAtRow:i column:j] );
					break;
				case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
					fprintf( FP, "%c", [self unsignedCharValueAtRow:i column:j] );
					break;
				case CONST_MATH_MATRIX_TYPE_INT:
					fprintf( FP, "%d", [self intValueAtRow:i column:j] );
					break;
				case CONST_MATH_MATRIX_TYPE_UNSIGNED:
					fprintf( FP, "%u", [self unsignedValueAtRow:i column:j] );
					break;
				case CONST_MATH_MATRIX_TYPE_FLOAT:
					fprintf( FP, "  %9.4f", [self floatValueAtRow:i column:j] );
					break;
				case CONST_MATH_MATRIX_TYPE_DOUBLE:
					fprintf( FP, "  %9.4f", [self doubleValueAtRow:i column:j] );
					break;
			}
		}
		fprintf(FP, "\n");
	}
	fclose(FP);
}

- (void) writeRow: (unsigned)r
           toFile: (NSString *)fileName {
	
	unsigned j;
	FILE *FP = fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "w");
	
	for ( j = 1; j <= _width; j++ ) { // j'th column
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				fprintf( FP, "%c", [self charValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				fprintf( FP, "%c", [self unsignedCharValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				fprintf( FP, "%d", [self intValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				fprintf( FP, "%u", [self unsignedValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				fprintf( FP, "  %9.4f", [self floatValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				fprintf( FP, "  %9.4f", [self doubleValueAtRow:r column:j] );
				break;
		}
	}
	fprintf(FP, "\n");
	fclose(FP);
}

- (void) writeRowTransposed: (unsigned)r
                     toFile: (NSString *)fileName {
	
	unsigned j;
	FILE *FP = fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "w");
	
	for ( j = 1; j <= _width; j++ ) { // j'th column
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				fprintf( FP, "%c", [self charValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				fprintf( FP, "%c", [self unsignedCharValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				fprintf( FP, "%d", [self intValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				fprintf( FP, "%u", [self unsignedValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				fprintf( FP, "  %9.4f", [self floatValueAtRow:r column:j] );
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				fprintf( FP, "  %9.4f", [self doubleValueAtRow:r column:j] );
				break;
		}
		fprintf(FP, "\n");
	}
	fclose(FP);
}

- (void) writeColumn: (unsigned)c
              toFile: (NSString *)fileName {
	
	unsigned i;
	FILE *FP = fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "w");
	
	for ( i = 1; i <= _height; i++ ) {	// i'th row
		switch ( _type ) {
			case CONST_MATH_MATRIX_TYPE_CHAR:
				fprintf( FP, "%c", [self charValueAtRow:i column:c] );
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED_CHAR:
				fprintf( FP, "%c", [self unsignedCharValueAtRow:i column:c] );
				break;
			case CONST_MATH_MATRIX_TYPE_INT:
				fprintf( FP, "%d", [self intValueAtRow:i column:c] );
				break;
			case CONST_MATH_MATRIX_TYPE_UNSIGNED:
				fprintf( FP, "%u", [self unsignedValueAtRow:i column:c] );
				break;
			case CONST_MATH_MATRIX_TYPE_FLOAT:
				fprintf( FP, "  %9.4f", [self floatValueAtRow:i column:c] );
				break;
			case CONST_MATH_MATRIX_TYPE_DOUBLE:
				fprintf( FP, "  %9.4f", [self doubleValueAtRow:i column:c] );
				break;
		}
		fprintf(FP, "\n");
	}
	fclose(FP);
}

@end
