#import <Foundation/Foundation.h>
#import <MathMatrix.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	MathMatrix* A = [[MathMatrix alloc] initWithType:@"double" width:3 height:3];
	MathMatrix* B = [[MathMatrix alloc] initWithType:@"double" width:3 height:3];
	unsigned i, j;
	
	for ( i = 1; i <= 3; i++ ) {
		for ( j = 1; j <= 3; j++ ) {
			[A setDoubleValue:((i-1)*3 + j) atRow:i column:j];
			[B setDoubleValue:((i-1)*3 + j) atRow:i column:j];
			printf("%f ", [A doubleValueAtRow:i column:j]);
		}
		printf("\n");
	}
	
	[A multiplyScalar:2.0];
	[A addMatrix:B];
	[A subtractMatrix:A];
	
	for ( i = 1; i <= 3; i++ ) {
		for ( j = 1; j <= 3; j++ ) {
			printf("%f ", [A doubleValueAtRow:i column:j]);
		}
		printf("\n");
	}
	
    // insert code here...
    NSLog(@"Hello, World!");
    [pool release];
    return 0;
}
