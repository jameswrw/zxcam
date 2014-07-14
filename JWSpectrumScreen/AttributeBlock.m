//
//  AttributeBlock.m
//  Mac2Spec
//
//  Created by James on 20/8/2006.
//  Copyright 2006 James Weatherley. All rights reserved.
//

#import "AttributeBlock.h"
#import "../JWMac2SpecCLib/AttributeManager.h"
#import "../JWMac2SpecCLib/JWCoreGraphics.h"

@implementation AttributeBlock

static CGImageRef sMacImage = 0;
static UInt8* sBaseAddress = 0;
static NSUInteger sBitmapWidth = 0;
static NSUInteger sBitmapHeight = 0;

+(void)setBitmapData:(CGImageRef)bitmap
{
	sMacImage = bitmap;
	sBitmapWidth = CGImageGetWidth(bitmap);
	sBitmapHeight = CGImageGetHeight(bitmap);
	
	if(sBaseAddress) {
		free(sBaseAddress);
		sBaseAddress = 0;
	}
	
	CGContextRef context = CreateARGBBitmapContext(bitmap);
	sBaseAddress = rawBitmap(context, bitmap);
	CGContextRelease(context);
}

+(void)releaseBitmap
{
	if(sBaseAddress) {
		free(sBaseAddress);
		sBaseAddress = 0;
	}
}

-(id)initWithWidth:(NSUInteger)w height:(NSUInteger)h index:(NSUInteger)idx
{
	if((self = [super init])) {
		assert(sBaseAddress);

		index = idx;
		height = h;
		width = w;
		
		// Allocate width * height bytes of strorage - divide width by eight as width is in bits.
		rowBitmaps = malloc((width / 8) * height * sizeof(unsigned char));
		if(![self setAttributeData]) {
			self = 0;
		}
	}
	return self;
}

-(void)dealloc
{
	free(rowBitmaps);
}

-(BOOL)setAttributeData
{
	assert(index >=0);
	
	BOOL success = FALSE;
	[self setAttributeRowAndColumn];
	
	if(index < attributeCount) {
		
		[self pixelData];
		
		attributeBase = attribute(sBaseAddress, &pixelData, attributeCol * width, attributeRow * height);		
		[self determineBitmap];
		
		// Use the commonest colour to determine if bright should be used.
		int bright = 0;
		if(paperCount > inkCount) {
			bright = !!(paper & 0x00808080);
		} else {
			bright = !!(ink & 0x00808080);
		}
	
		// Convert paper and ink to three bit values. 
		paper = ((paper & 0x00400000) >> 21) | 
				  ((paper & 0x00004000) >> 12) | 
				  ((paper & 0x00000040) >> 6);
		
		ink = ((ink & 0x00400000) >> 21) | 
				((ink & 0x00004000) >> 12) | 
				((ink & 0x00000040) >> 6);
		
		assert(ink < 8);
		assert(paper < 8);
		
		[self normalizePaperAndInk];
		
		// Build and write the attribute byte.
        attributeByte = 0;
        attributeByte |= paper << 3;
        attributeByte |= ink;
        attributeByte |= bright << 6;

		[self setOffsets];
		success = TRUE;
	}
	
	return success;
}

-(void)pixelData
{
	assert(sMacImage);
	pixelData.bytesPerRow = CGImageGetBytesPerRow(sMacImage);
	pixelData.samplesPerPixel = 4; // We're using ARGB throughout.
	pixelData.attrCount = attributeCount;
	pixelData.attrWidth = width;
}

-(void)setAttributeRowAndColumn
{
	unsigned int rows = sBitmapHeight / height;
	unsigned int cols = sBitmapWidth / width;
	attributeCount = rows * cols;
	attributeRow = index / cols;
	attributeCol = index % cols;
}

-(void)determineBitmap
{
	paper = pixelRGBFromBlock(attributeBase, &pixelData, 0, 0);
	
	// Scan the attribute block - create a bitmap for the row and determine paper and ink.
	// It is assumed that the attribute block only contains two colours.
	int x, y;
	inkCount = 0;
	paperCount = 0;
	unsigned char* rowBitmap = malloc(width / 8 * sizeof(unsigned char));
	
	for(y = 0; y < height; ++y) {
        size_t size = sizeof(rowBitmap);
		memset(rowBitmap, 0, size);
		for(x = 0; x < width; ++x) {
			int colour = pixelRGBFromBlock(attributeBase, &pixelData, x, y);
			if(colour != paper) {
				ink = colour;
				++inkCount;
				// Set ink bit in data
				*rowBitmap |= 1 << (width - 1 - x);
			} else {
				++paperCount;
			}
		}          
		// Store the attribute block row bitmap.
		rowBitmaps[y] = *rowBitmap;
	}
	assert(inkCount + paperCount == width * height);
	free(rowBitmap);
}

-(void)normalizePaperAndInk
{
	if(paper < ink) {
		int temp = paper;
		paper = ink;
		ink = temp;
		
		int i;
		for(i = 0; i < height * width / 8; ++i) {
			rowBitmaps[i] = ~rowBitmaps[i];
		}
	}
}

-(void)setOffsets
{
	int attributeRows = attributeCount / 0x20;
	int screenThird = 3 * attributeRow / attributeRows;
	int blockRow = attributeRow * height / 8 % 8;
	int blockLine = attributeRow * height % 8; 
	
	bitmapOffset = 0x800 * screenThird;
	bitmapOffset += 0x20 * blockRow;
	bitmapOffset += 0x100 * blockLine;
	bitmapOffset += attributeCol;
	
	attributeOffset = index;
}

-(void)writeScreenOne:(unsigned char*)screenBase
{
	int i;
	for(i = 0; i < height; ++i) {
		assert(*(screenBase + bitmapOffset + (i * 0x100)) == 0);
		*(screenBase + bitmapOffset + (i * 0x100)) = rowBitmaps[i];
	}
}

-(void)writeScreenTwo:(unsigned char*)attrBase
{
	assert(*(attrBase + attributeOffset) == 0);
	*(attrBase + attributeOffset) = attributeByte;
}

-(int)index
{
	return index;
}

-(NSString*)description
{
	NSString* string = @"----------------\n";
	NSString* numbers = [NSString stringWithFormat:@"ink:%d  paper:%d  attr:%x\n", ink, paper, attributeByte];
	string = [string stringByAppendingString:numbers];
	
	int i, j;
	for(i = 0; i < height; ++i) {
		NSString* line = @"";
		unsigned char mask = 0x80;
		for(j = 0; j < width; ++j) {
			if(rowBitmaps[i] & mask) {
				line = [line stringByAppendingString:@"*"];
			} else {
				line = [line stringByAppendingString:@"."];
			}
			mask >>= 1;
		}
		line = [NSString stringWithFormat:@"%@ : %x\n", line, rowBitmaps[i]];
		string = [string stringByAppendingString:line];
	}
	return string;
}

@end
