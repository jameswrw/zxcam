//
//  ConverterMagicSquare.m
//  zxcam
//
//  Created by James Weatherley on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConverterMagicSquare.h"

@implementation ConverterMagicSquare

- (id)initWithParameters:(NSDictionary*)a_parameters
{
    assert([[a_parameters valueForKey:@"matrixSize"] intValue] == 4);
    
	if(self = [super initWithParameters:a_parameters]) {
        ditherMatrix = @[@1,
                         @4,
                         @3,
                         @2,
                         @2,
                         @1,
                         @4,
                         @3,
                         @3,
                         @2,
                         @1,
                         @4,
                         @4,
                         @3,
                         @2,
                         @1];
        
        // Create the POC version on the dither matrix.
        [self initFastMatrix];
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	return self;
}

@end
