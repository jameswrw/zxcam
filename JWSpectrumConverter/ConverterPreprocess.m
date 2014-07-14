//
//  ConverterPreprocess.m
//  Mac2Spec 3
//
//  Created by James on 16/7/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterPreprocess.h"
#import "../JWMac2SpecCLib/JWCoreGraphics.h"

#pragma mark NSOperation
@interface JWPreprocessOperation : NSOperation
{
	NSDictionary* context;
}

@end

@implementation JWPreprocessOperation

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
	NSDictionary* parameters = context[@"parameters"];
	int rLevel = [parameters[@"red"] intValue];
	int gLevel = [parameters[@"green"] intValue];
	int bLevel = [parameters[@"blue"] intValue];
	BOOL monochrome = [parameters[@"monochrome"] intValue];
	CGImageRef bitmap = [context[@"bitmap"] pointerValue];
	UInt8* sourceBaseAddress = [context[@"rawdata"] pointerValue];
		
	NSUInteger sourceBytesPerRow = CGImageGetBytesPerRow(bitmap);
	NSUInteger width = CGImageGetWidth(bitmap);
	NSUInteger height = CGImageGetHeight(bitmap);
	uint8_t mask = (unsigned char)[context[@"mask"] intValue];
	
	// Offset is 4 for RGBA or 3 for plain RGB.
	// It's always 4 now because we created the context as ARGB.
    NSUInteger offset = 4;
	
	UInt8* ip = 0;
    NSInteger rColourValue, gColourValue, bColourValue;
	NSUInteger cpus = [[NSProcessInfo processInfo] activeProcessorCount];
	
	for(NSUInteger j = id; j < height; j+= cpus) {
		ip = sourceBaseAddress + (j * sourceBytesPerRow);
		for(NSUInteger i = 0; i < width; i++) {
			// Alpha in ip[0], but we don't care.
			rColourValue = ip[1];
			gColourValue = ip[2];
			bColourValue = ip[3];
			
			if(monochrome) {
				NSUInteger sum = rColourValue + gColourValue + bColourValue;
				sum /= 3;
				rColourValue = sum & 0xff;
				gColourValue = sum & 0xff;
				bColourValue = sum & 0xff;
			}
			
			rColourValue += rLevel;
			if(rColourValue < 0) {
				rColourValue = 0;
			} else if(rColourValue > 0xFF) {
				rColourValue = 0xFF;
			}
			ip[1] = rColourValue & mask;
			
			gColourValue += gLevel;
			if(gColourValue < 0) {
				gColourValue = 0;
			} else if(gColourValue > 0xFF) {
				gColourValue = 0xFF;
			}
			ip[2] = gColourValue & mask;
			
			bColourValue += bLevel;
			if(bColourValue < 0) {
				bColourValue = 0;
			} else if(bColourValue > 0xFF) {
				bColourValue = 0xFF;
			}
			ip[3] = bColourValue & mask;
			ip += offset;
		}
	}
}

@end


#pragma mark -
#pragma mark ConverterPreprocess
@implementation ConverterPreprocess

-(id)initWithParameters:(NSDictionary*)a_parameters
{
    self = [super initWithParameters:a_parameters];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
	
	return self;
}

-(void)dealloc
{
	CGImageRelease(preprocessedBitmap);
}

-(bool)setParameters:(NSDictionary*)a_parameters
{
	NSNumber* colour = a_parameters[@"red"];
	if(colour) {
		[self setColour:@"red" value:colour];
	}
	colour = a_parameters[@"green"];
	if(colour) {
		[self setColour:@"green" value:colour];
	}
	colour = a_parameters[@"blue"];
	if(colour) {
		[self setColour:@"blue" value:colour];
	}
	
	NSNumber* posterise = a_parameters[@"posterise"];
	if(posterise) {
		parameters[@"posterise"] = posterise;
	}
	
	NSNumber* monochrome = a_parameters[@"monochrome"];
	if(monochrome) {
		parameters[@"monochrome"] = monochrome;
	}
	
	return true;
}

-(CGImageRef)convert:(CGImageRef)source
{
	// Create the bitmap context
	CGContextRef cgctx = CreateARGBBitmapContext(source);
	UInt8* sourceBaseAddress = rawBitmap(cgctx, source);
	
    // Only do stuff if we have to.
	if([parameters[@"posterise"] intValue] ||
	   [parameters[@"monochrome"] intValue] ||
	   [parameters[@"red"] intValue] ||
	   [parameters[@"green"] intValue] ||
	   [parameters[@"blue"] intValue]) {
		
		uint8_t posteriseMask = 0;		
		if([parameters[@"posterise"] intValue]) {
			posteriseMask = 0x80;
		} else {
			posteriseMask = 0xFF;
		}
		
		// Run an operation for each line in the image.
		NSInteger cpus = [[NSProcessInfo processInfo] activeProcessorCount];
		for(NSInteger i = 0; i < cpus; ++i) {
			NSDictionary* context = @{@"id": [NSNumber numberWithInteger:i],
									 @"parameters": parameters,
									 @"bitmap": [NSValue valueWithPointer:source],
									 @"rawdata": [NSValue valueWithPointer:sourceBaseAddress],
									 @"mask": [NSNumber numberWithInt:posteriseMask]};
			[operationQueue addOperation:[[JWPreprocessOperation alloc] initWithContext:context]];
		}
		[operationQueue waitUntilAllOperationsAreFinished];
    }
	
	CGImageRelease(preprocessedBitmap);
	preprocessedBitmap = CGBitmapContextCreateImage(cgctx);
	
	// When finished, release the context
    CGContextRelease(cgctx);
	
    // Free image data memory for the context
    if(sourceBaseAddress) {
        free(sourceBaseAddress);
    }
	
    return preprocessedBitmap;
}

-(void)setColour:(NSString*)colour value:(NSNumber*)value
{
	if([value intValue] < -255) {
		value = @-255;
	} else if([value intValue] > 255) {
		value = @255;
	}
	parameters[colour] = value;
}

-(NSString*)description
{
	return @"Preprocess";
}

@end
