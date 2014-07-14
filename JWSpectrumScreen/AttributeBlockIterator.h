//
//  AttributeBlockIterator.h
//  Mac2Spec
//
//  Created by James on 20/8/2006.
//  Copyright 2006 James Weatherley. All rights reserved.
//

#import "JWSpectrumScreenConstants.h"

@class AttributeBlock;


@interface AttributeBlockIterator : NSObject {

	int index;
	int mode;
	int attributeHeight;
	int attributeWidth;
	
	TimexHiResMode hiResMode;
	
	CGImageRef bitmap;
}

- (id)initWithBitmap:(CGImageRef)image mode:(int)mode;

- (void)reset;
- (AttributeBlock*)nextBlock;

-(void)setHiResMode:(TimexHiResMode)mode;

@end
