/*
 *  JWCoreGraphics.c
 *  zxcam
 *
 *  Created by James Weatherley on 10/07/2009.
 *  Copyright 2009 James Weatherley. All rights reserved.
 *
 */


#include "JWCoreGraphics.h"
#import <stdio.h>
#import <stdlib.h>
#import <assert.h>

// Mostly Apple sample code.
CGContextRef CreateARGBBitmapContext(CGImageRef inImage)
{
	// Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
	
	return CreateARGBBitmapContextWithDimensions(pixelsWide, pixelsHigh);
}

CGContextRef CreateARGBBitmapContextWithDimensions(size_t pixelsWide, size_t pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    size_t             bitmapByteCount;
    size_t             bitmapBytesPerRow;
	
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
	
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
	
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
	
    return context;
}


// Draws image into the context, and returns a pointer to the start of the bitmap.
// Caller must free the returned pointer with free().
UInt8* rawBitmap(CGContextRef context, CGImageRef image)
{
	if(context == NULL) { 
		// error creating context
		assert(0);
		return 0;
	}
	
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
	CGRect rect = {{0, 0}, {width, height}}; 
	
	// Draw the image to the bitmap context. Once we draw, the memory 
	// allocated for the context for rendering will then contain the 
	// raw image data in the specified color space.
	CGContextDrawImage(context, rect, image); 
	
	// Now we can get a pointer to the image data associated with the bitmap
	// context.
	UInt8* sourceBaseAddress = CGBitmapContextGetData (context);
	if(sourceBaseAddress == NULL) {
		assert(0);
	}
	return sourceBaseAddress;
}




