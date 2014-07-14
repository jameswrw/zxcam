/*
 *  JWCoreGraphics.h
 *  zxcam
 *
 *  Created by James Weatherley on 10/07/2009.
 *  Copyright 2009 James Weatherley. All rights reserved.
 *
 */
#import <CoreGraphics/CoreGraphics.h>

// Return an ARGB CGContextRef with the same dimensions as inImage, or with the specified dimensions.
// Caller must free the CGContextRef by calling CGContextRelease().
CGContextRef CreateARGBBitmapContext (CGImageRef image);
CGContextRef CreateARGBBitmapContextWithDimensions(size_t pixelsWide, size_t pixelsHigh);

// Draws image into the context, and returns a pointer to the start of the bitmap.
// Caller must free the returned pointer with free().
UInt8* rawBitmap(CGContextRef context, CGImageRef image);