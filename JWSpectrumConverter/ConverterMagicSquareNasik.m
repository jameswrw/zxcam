//
//  ConverterMagicSquareNasik.m
//  zxcam
//
//  Created by James Weatherley on 21/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConverterMagicSquareNasik.h"


@implementation ConverterMagicSquareNasik

- (id)initWithParameters:(NSDictionary*)a_parameters
{
    assert([[a_parameters valueForKey:@"matrixSize"] intValue] == 4);
    
	if(self = [super initWithParameters:a_parameters]) {
        ditherMatrix = @[@4,
                         @14,
                         @15,
                         @1,
                         @9,
                         @7,
                         @6,
                         @12,
                         @5,
                         @11,
                         @10,
                         @8,
                         @16,
                         @2,
                         @3,
                         @13];
        
        // Create the POC version on the dither matrix.
        [self initFastMatrix];
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	return self;
}

@end
