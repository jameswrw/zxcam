//
//  AttributeBlock.h
//  Mac2Spec
//
//  Created by James on 20/8/2006.
//  Copyright 2006 James Weatherley. All rights reserved.
//

#import "PixelData.h"


@interface AttributeBlock : NSObject {
	
	int ink;
	int paper;
	int inkCount;
	int paperCount;
	
	NSUInteger index;
	NSUInteger height;
	NSUInteger width;
	
	int bitmapOffset;
	int attributeOffset;
	
	NSUInteger attributeCount;
	NSUInteger attributeRow;
	NSUInteger attributeCol;
	const unsigned char* attributeBase;
	
	unsigned char attributeByte;
	unsigned char* rowBitmaps;
	
	PixelData pixelData;
	
	//CGImageRef macBitmap;
}

+(void)setBitmapData:(CGImageRef)bitmap;
+(void)releaseBitmap;

-(id)initWithWidth:(NSUInteger)attrWidth height:(NSUInteger)attrHeight index:(NSUInteger)idx;
-(BOOL)setAttributeData;
-(void)setAttributeRowAndColumn;
-(void)setOffsets;
-(void)normalizePaperAndInk;
-(void)determineBitmap;
-(void)pixelData;

-(int)index;

-(void)writeScreenOne:(unsigned char*)screenBase;
-(void)writeScreenTwo:(unsigned char*)attrBase;

@end
