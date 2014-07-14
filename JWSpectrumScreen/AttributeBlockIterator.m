//
//  AttributeBlockIterator.m
//  Mac2Spec
//
//  Created by James on 20/8/2006.
//  Copyright 2006 JamesWeatherley. All rights reserved.
//
#import "../JWMac2SpecCLib/AttributeManager.h"
#import "AttributeBlockIterator.h"
#import "AttributeBlock.h"
#import "AttributeBlockTimex.h"
#import "AttributeBlockTimexHiRes.h"


@implementation AttributeBlockIterator

-(id)initWithBitmap:(CGImageRef)image mode:(int)theMode
{
	if((self = [super init])) {
		bitmap = CGImageCreateCopy(image);
		
		[AttributeBlock setBitmapData:bitmap];
		mode = theMode;
		if(mode == ATTRIBUTE_ZX) {
			attributeHeight = ATTRIBUTE_HEIGHT_SINCLAIR;
			attributeWidth = ATTRIBUTE_WIDTH;
		} else if(mode == ATTRIBUTE_TIMEX_HI_COL) {
			attributeHeight = ATTRIBUTE_HEIGHT_TIMEX_HI_COL;
			attributeWidth = ATTRIBUTE_WIDTH;
		} else if(mode == ATTRIBUTE_TIMEX_HI_RES) {
			attributeHeight = ATTRIBUTE_HEIGHT_TIMEX_HI_RES;
			attributeWidth = ATTRIBUTE_WIDTH_TIMEX_HI_RES;
		} else {
			assert(0);
		}
		
		[self reset];
	}
	return self;
}

-(void)dealloc
{
	CGImageRelease(bitmap);
	[AttributeBlock releaseBitmap];
}

-(void)reset
{
	index = 0;
}

-(void)setHiResMode:(TimexHiResMode)hiMode
{
	hiResMode = hiMode;
}

-(AttributeBlock*)nextBlock
{
	AttributeBlock* block = nil;
	
	if(mode == ATTRIBUTE_ZX) {
		block = [[AttributeBlock alloc] initWithWidth:attributeWidth height:attributeHeight index:index];
	} else if(mode == ATTRIBUTE_TIMEX_HI_COL) {
		block = [[AttributeBlock alloc] initWithWidth:attributeWidth height:attributeHeight index:index];
	} else if(mode == ATTRIBUTE_TIMEX_HI_RES) {
		block = [[AttributeBlockTimexHiRes alloc] initWithWidth:attributeWidth height:attributeHeight index:index mode:hiResMode];
	}

	if(!block) {
		index = 0;
	} else {
		++index;
	}
	
	return block;
}


@end
