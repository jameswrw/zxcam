//
//  ConverterAttributeClash.h
//  Mac2Spec 3
//
//  Created by James on 16/7/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterBase.h"
#include "PixelData.h"


// init expects a dictionary containing:
//  key: @"width", (NSNumber*)
//  key: @"height", (NSNumber*)

@interface ConverterAttributeClash : ConverterBase
{
	CGImageRef spectrumBitmap;
	NSOperationQueue* operationQueue;
}

@end
