//
//  ConverterCOD.m
//  Mac2Spec
//
//  Created by James on 10/5/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterCOD.h"
#import "../JWMac2SpecCLib/AttributeManager.h"
#import "../JWMac2SpecCLib/ColourMacros.h"
#import "../JWMac2SpecCLib/JWCoreGraphics.h"

#include <math.h>

#pragma mark NSOperation
@interface JWPCODOperation : NSOperation
{
	NSDictionary* context;
}

@end

@implementation JWPCODOperation

-(id)initWithContext:(NSDictionary*)a_context
{
	if(self = [super init]) {
        context = a_context;
    }
	
	return self;
}

-(void)main
{	
	NSUInteger id = [context[@"id"] intValue];
	NSArray* ditherMatrix = context[@"ditherMatrix"];
	CGImageRef bitmap = [context[@"bitmap"] pointerValue];
	PixelData pixelData = *(PixelData*)[context[@"pixelData"] pointerValue];
	int* fastMatrix = [context[@"fastMatrix"] pointerValue];
	UInt8* bitmapData = [context[@"rawBitmap"] pointerValue];

	NSUInteger matrixSize = sqrt([ditherMatrix count]);
	NSUInteger shiftBy = rint(log2(128 / [ditherMatrix count]));
	
	NSUInteger pixelCount = CGImageGetWidth(bitmap) * CGImageGetHeight(bitmap);
	//NSSize size = [bitmap size];
	NSUInteger width = CGImageGetWidth(bitmap);
	int* ditheredMatrix = malloc(matrixSize * matrixSize * sizeof(int));
	
	NSUInteger cpus = [[NSProcessInfo processInfo] activeProcessorCount];
	NSUInteger startLine = (id * (pixelCount / pixelData.attrCount) / cpus) / pixelData.attrPerRow;
	NSUInteger endLine = ((id + 1) * (pixelCount / pixelData.attrCount) / cpus) / pixelData.attrPerRow;
	
	int i;
    int pixel;
    int r,g,b;
    const unsigned char* block;
	unsigned char* mutableBlock;
	int fastMatrixVal;
	unsigned long blockX, blockY, pixelX, pixelY;
	
	for(blockY = startLine * pixelData.attrHeight; 
		blockY < endLine * pixelData.attrHeight; 
		blockY += pixelData.attrHeight) {
		for(blockX = 0; blockX < width; blockX += pixelData.attrWidth) {
			mutableBlock = mutableAttribute(bitmapData, &pixelData, blockX, blockY);
			block = mutableBlock;
			
			i = 0;
			for(pixelY = 0; pixelY < matrixSize; ++pixelY) {
				for(pixelX = 0; pixelX < matrixSize; ++pixelX) {
					
					pixel = pixelRGBFromBlock(block, &pixelData, pixelX, pixelY);
					
					r = RED(pixel);
					g = GREEN(pixel);
					b = BLUE(pixel);
					
					r >>= shiftBy;
					g >>= shiftBy;
					b >>= shiftBy;
					
					fastMatrixVal = fastMatrix[i];
					r = 0x7F * (r >= fastMatrixVal);
					g = 0x7F * (g >= fastMatrixVal);
					b = 0x7F * (b >= fastMatrixVal);
					
					ditheredMatrix[i++] = (r << 16) | (g << 8) | b;
				}
			}
			setPixelBlock(mutableBlock, &pixelData, ditheredMatrix);
		}
	}
	free(ditheredMatrix);
}

@end


#pragma mark -
#pragma mark ConverterCOD
@implementation ConverterCOD
- (id)initWithParameters:(NSDictionary*)a_parameters
{
	if(self = [super initWithParameters:a_parameters]) {
		
        NSUInteger matrixSize = [[parameters valueForKey:@"matrixSize"] intValue];
        ditherMatrix = [self createCodMatrixSize:matrixSize];
        
        // Create the POC version on the dither matrix.
        [self initFastMatrix];
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	}
	return self;
}

- (void)dealloc
{
	free(fastMatrix);
	CGImageRelease(ditheredBitmap);
}

- (void)initFastMatrix
{
	// Create fast matrix and the result buffer.
	// Memory is freed in dealloc.
	NSUInteger size = [ditherMatrix count];
	fastMatrix = malloc(size * sizeof(int));
	
	unsigned int i;
	for(i = 0; i < size; ++i) {
		fastMatrix[i] = [ditherMatrix[i] intValue];
	}
}

// Pass in an n x n matrix and return 2n x 2x matrix.
// Assumed that [matrix count] is a power of two.
- (NSArray*)nextCODMatrix:(NSArray*)matrix
{
    unsigned int i;
    int row, col;
    int oldSide = sqrt([matrix count]);
    int newSide = 2 * oldSide;
    
    NSMutableArray* newMatrix = [[NSMutableArray alloc] initWithCapacity:(4 * [matrix count])];
    for(i = 0; i < 4 * [matrix count]; ++i) {
        [newMatrix addObject:@0];
    }
    
    int newVal;
    for(row = 0; row < oldSide; ++row) {
        for(col = 0; col < oldSide; ++col) {
            newVal = 4 * [matrix[(row * oldSide + col)] intValue];
            
            newMatrix[(row * newSide + col)] = @(newVal - 3);
            
            newMatrix[(row * newSide + (2 * [matrix count]) + (col + oldSide))] = @(newVal - 2);
			
            newMatrix[(row * newSide + col + oldSide)] = @(newVal - 1);
            
            newMatrix[(row * newSide + (2 * [matrix count]) + col)] = @(newVal);
        }
    }
    return newMatrix;
}


- (NSArray*)createCodMatrixSize:(NSUInteger)size
{	
	int logBase2 = lrint(log2(size));
	assert(lrint(exp2(logBase2)) == size);
	
	NSArray* matrix = [[NSMutableArray alloc] initWithObjects:
		@1,
		@3,
		@4,
		@2,
		nil];
	
	NSArray* newMatrix;
	
	int i;
	for(i = 1; i < logBase2; ++i) {
		newMatrix = [self nextCODMatrix:matrix];
		matrix = newMatrix;
	}
	return matrix;
}


- (CGImageRef)convert:(CGImageRef)source
{
    CGContextRef context = CreateARGBBitmapContext(source);
	UInt8* sourceBaseAddress = rawBitmap(context, source);
	
    // Cache bitmap data so we can access it quick in the loops.
    pixelData.bytesPerRow = CGImageGetBytesPerRow(source);
    pixelData.samplesPerPixel = 4; // We know it's in ARGB format.

    setPixelData(&pixelData, sqrt([ditherMatrix count]), sqrt([ditherMatrix count]), CGImageGetWidth(source));

	NSUInteger cpus = [[NSProcessInfo processInfo] activeProcessorCount];
	for(NSUInteger i = 0; i < cpus; ++i) {
		NSDictionary* context = @{@"id": [NSNumber numberWithInt:i],
								 @"ditherMatrix": ditherMatrix,
								 @"bitmap": [NSValue valueWithPointer:source],
								 @"rawBitmap": [NSValue valueWithPointer:sourceBaseAddress],
								 @"pixelData": [NSValue valueWithPointer:&pixelData],
								 @"fastMatrix": [NSValue valueWithPointer:fastMatrix]};
		
		[operationQueue addOperation:[[JWPCODOperation alloc] initWithContext:context]];
	}
	[operationQueue waitUntilAllOperationsAreFinished];
								 
	CGImageRelease(ditheredBitmap);
	ditheredBitmap = CGBitmapContextCreateImage(context);
								 
	// When finished, release the context
	CGContextRelease(context);
								 
	// Free image data memory for the context
	if(sourceBaseAddress) {
		free(sourceBaseAddress);
	}
								 
	return ditheredBitmap;
}

- (NSString*)description
{
	return parameters[@"buttonLabel"];
}

- (NSString*)mode
{
	NSUInteger order = sqrt([ditherMatrix count]);
	NSString* modeString = [NSString stringWithFormat:@"cod%zu", order];
	return modeString;
}

@end
