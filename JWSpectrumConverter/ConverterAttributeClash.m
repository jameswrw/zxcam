//
//  ConverterAttributeClash.m
//  Mac2Spec 3
//
//  Created by James on 16/7/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterAttributeClash.h"
#include "../JWMac2SpecCLib/AttributeManager.h"
#include "../JWMac2SpecCLib/ColourMacros.h"
#import "../JWMac2SpecCLib/JWCoreGraphics.h"


#pragma mark NSOperation
@interface JWPAttributeClashOperation : NSOperation
{
	NSDictionary* context;
}

@end

@implementation JWPAttributeClashOperation

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
    CGImageRef bitmap = [context[@"bitmap"] pointerValue];
	PixelData pixelData = *(PixelData*)[context[@"pixelData"] pointerValue];
	UInt8* bitmapData = [context[@"rawBitmap"] pointerValue];
	
	//NSSize size = [bitmap size];
	NSUInteger width = CGImageGetWidth(bitmap);
	NSUInteger height = CGImageGetHeight(bitmap);
	NSUInteger spectrumPixels = width * height;
	NSUInteger startLine =
		(id * (spectrumPixels / pixelData.attrCount) / [[NSProcessInfo processInfo] activeProcessorCount]) / pixelData.attrPerRow;
	NSUInteger endLine = 
		((id + 1) * (spectrumPixels / pixelData.attrCount) / [[NSProcessInfo processInfo] activeProcessorCount]) / pixelData.attrPerRow;
	
	// Could co this dynamically but the biggest size is 64 so what's the point?
    int pixels[64];
    int pixelCount = 0;	
	pixelCount = pixelData.attrCount;
	assert(pixelCount <= 64);
	
	int paperInk[2] = {-1, -1};
	
	NSUInteger blockX, blockY;
	for(blockY = startLine * pixelData.attrHeight; 
		blockY < endLine * pixelData.attrHeight;
		blockY += pixelData.attrHeight) {
		for(blockX = 0; blockX < width; blockX += pixelData.attrWidth) {
			analyzeBlock(bitmapData, &pixelData, blockX, blockY, paperInk, pixels, pixelCount);
		}
	}
}
@end


#pragma mark -
#pragma mark ConverterAttributeClash
@implementation ConverterAttributeClash

-(id)initWithParameters:(NSDictionary*)a_parameters
{
	self = [super initWithParameters:a_parameters];	
	initColourTable();
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	
	return self;
}

- (void)dealloc
{
	CGImageRelease(spectrumBitmap);
}

- (CGImageRef)convert:(CGImageRef)source
{
	CGContextRef context = CreateARGBBitmapContext(source);
	UInt8* sourceBaseAddress = rawBitmap(context, source);
	
	PixelData pixelData;
	setPixelData(
				 &pixelData, 
				 [[parameters valueForKey:@"width"] intValue],
				 [[parameters valueForKey:@"height"] intValue],
				 CGImageGetWidth(source)
				 );

    // Cache bitmap data so we can access it quick in the loops.
    pixelData.bytesPerRow = CGImageGetBytesPerRow(source);
    pixelData.samplesPerPixel = 4; // context is ARGB.
	
	NSUInteger cpus = [[NSProcessInfo processInfo] activeProcessorCount];
	for(NSUInteger i = 0; i < cpus; ++i) {
		NSDictionary* context = @{@"id": [NSNumber numberWithInt:i],
								 @"bitmap": [NSValue valueWithPointer:source],
								 @"rawBitmap": [NSValue valueWithPointer:sourceBaseAddress],
								 @"pixelData": [NSValue valueWithPointer:&pixelData]};
		[operationQueue addOperation:[[JWPAttributeClashOperation alloc] initWithContext:context]];
	}
	[operationQueue waitUntilAllOperationsAreFinished];
	
	CGImageRelease(spectrumBitmap);
	spectrumBitmap = CGBitmapContextCreateImage(context);
	
	// When finished, release the context
	CGContextRelease(context);
	
	// Free image data memory for the context
	if(sourceBaseAddress) {
		free(sourceBaseAddress);
	}
	
    return spectrumBitmap;
}

-(NSString*)description
{
	return parameters[@"buttonLabel"];
}

@end
