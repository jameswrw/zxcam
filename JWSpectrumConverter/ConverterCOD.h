//
//  ConverterCOD.h
//  Mac2Spec
//
//  Created by James on 10/5/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConverterBase.h"
#import "PixelData.h"


// The base class init method expects an NSDictionary containing the key @"matrixSize"
// Expected values are powers of two.

@interface ConverterCOD : ConverterBase
{

	NSArray* ditherMatrix;
	int* fastMatrix;
    // Matrices used for the ordered dither.
	
	CGImageRef ditheredBitmap;
	NSOperationQueue* operationQueue;
	
	PixelData pixelData;
	unsigned char* bitmapData;
}

- (void)initFastMatrix;
// Fill fastMatrix with contents of ditherMatrix.

- (NSArray*)createCodMatrixSize:(NSUInteger)size;
// Create a COD dither matrix of side 'size'.
// size must be a power of two.

- (NSArray*)nextCODMatrix:(NSArray*)matrix;
// Pass in an n x n matrix and return 2n x 2x matrix.
// Assumed that [matrix count] is a power of two.

@end
