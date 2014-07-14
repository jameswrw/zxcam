//
//  ConverterPreprocess.h
//  Mac2Spec 3
//
//  Created by James on 16/7/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterBase.h"


// setParameters expects any of the following:
//
// @"posterise", NSNumber*		: 1 Posterize on. 0, Posterize off.
// @"red", NSNumber*			: Set red value
// @"green", NSNumber*			: Set green value
// @"blue", NSNumber*			: Set blue value

@interface ConverterPreprocess : ConverterBase
{
	NSOperationQueue* operationQueue;
	CGImageRef preprocessedBitmap;	
}

- (void)setColour:(NSString*)colour value:(NSNumber*)value;

@end
