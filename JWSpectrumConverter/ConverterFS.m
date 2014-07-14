//
//  ConverterFS.m
//  Mac2Spec
//
//  Created by James on 10/5/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterFS.h"
#import "../JWMac2SpecCLib/ColourMacros.h"
#import "../JWMac2SpecCLib/JWCoreGraphics.h"

#include <stdlib.h>

int cNearestColour(int* palette, int palette_size, int r, int g, int b);

@implementation ConverterFS

-(id)initWithParameters:(NSDictionary*)a_parameters
{
	self = [super initWithParameters:a_parameters];
	
	// This palette changes as the user adds and subtracts colours from it.
	NSMutableArray* userPalette = [[NSMutableArray alloc]initWithCapacity:15];
	

	// Set up the user palette and lookup dictionary.
	NSNumber* colour;
	int i;
	for(i = 0; i < 15; ++i) {
		colour = @(spectrumColourFromIndex(i));
		[userPalette addObject:colour];
	}
	
	[parameters setValue:userPalette forKey:@"palette"];
	
	// Fill up the f/s dither lookup table.
	ditherLookup = malloc((1 << 15) * sizeof(int));
	[self createDitherLookup];

	return self;
}

-(void)dealloc
{
	free(ditherLookup);	
	CGImageRelease(ditheredBitmap);
}

-(bool)setParameters:(NSDictionary*)a_parameters
{
	bool success = true;

	NSNumber* colour = a_parameters[@"addColour"];
	if(colour) {
		success = [self paletteChange:[colour intValue] add:YES];
	}
	
	colour = a_parameters[@"removeColour"];
	if(colour) {
		success &= [self paletteChange:[colour intValue] add:NO];
	}

	// We want to add any parameters that aren't @"addColour", or @"removeColour".
	[parameters addEntriesFromDictionary:a_parameters];
	[parameters removeObjectForKey:@"addColour"];
	[parameters removeObjectForKey:@"deleteColour"];
	
	return success;
}

-(CGImageRef)convert:(CGImageRef)source
{
    CGContextRef context = CreateARGBBitmapContext(source);
	UInt8* sourceBaseAddress = rawBitmap(context, source);
	const size_t sourceBytesPerRow  = CGImageGetBytesPerRow(source);
	int offset = 4; // context is ARGB format.

	int colour;
	size_t height;
	size_t width;

	height = CGImageGetHeight(source);
	width = CGImageGetWidth(source);
	
	int rerr1[width * 2];
	int gerr1[width * 2];
	int berr1[width * 2];

	memset(rerr1, 0, sizeof(int) * width * 2);
	memset(gerr1, 0, sizeof(int) * width * 2);
	memset(berr1, 0, sizeof(int) * width * 2);

	int* rerr2 = rerr1 + width;
	int* gerr2 = gerr1 + width;
	int* berr2 = berr1 + width;

	int rerr;
	int gerr;
	int berr;

	int i;
	int j;
	const UInt8* ip;
	UInt8* dp;

	// Create a temporary palette of ints for speed.
	int palette[SPEC_PALETTE_SIZE];
	NSArray* userPalette = [parameters valueForKey:@"palette"];
	int paletteSize = [userPalette count];
	for(i = 0; i < paletteSize; ++i) {
		palette[i] = [userPalette[i] intValue];
	}

	for(j = 0; j < height; j++ ) {
		dp = sourceBaseAddress + (j * sourceBytesPerRow);
		ip = dp;
		
		for(i = 0; i < width; i++) {
			rerr1[i] = rerr2[i] + ip[1];
			rerr2[i] = 0;
			gerr1[i] = gerr2[i] + ip[2];
			gerr2[i] = 0;
			berr1[i] = berr2[i] + ip[3];
			berr2[i] = 0;
			ip += offset;
		}
		
		colour = cNearestColour(palette,
								paletteSize,
								rerr1[0],
								gerr1[0],
								berr1[0]);
		
		dp[0] = 0xFF;
		dp[1] = RED(colour);
		dp[2] = GREEN(colour);
		dp[3] = BLUE(colour);
		dp += offset;
		
		for(i = 1; i < width - 1; i++) {
			
			colour = cNearestColour(palette,
									paletteSize,
									rerr1[i],
									gerr1[i],
									berr1[i]);
			dp[0] = 0xFF;
			dp[1] = RED(colour);
			dp[2] = GREEN(colour);
			dp[3] = BLUE(colour);
			dp += offset;
			
			rerr = rerr1[i];
			rerr -= RED(colour);
			gerr = gerr1[i];
			gerr -= GREEN(colour);
			berr = berr1[i];
			berr -= BLUE(colour);
			
			// diffuse red error
			rerr1[i+1] += (rerr * 7) >> 4;
			rerr2[i-1] += (rerr * 3) >> 4;
			rerr2[i]   += (rerr * 5) >> 4;
			rerr2[i+1] += (rerr) >> 4;
			
			// diffuse green error
			gerr1[i+1] += (gerr * 7) >> 4;
			gerr2[i-1] += (gerr * 3) >> 4;
			gerr2[i]   += (gerr * 5) >> 4;
			gerr2[i+1] += (gerr) >> 4;
			
			// diffuse red error
			berr1[i+1] += (berr * 7) >> 4;
			berr2[i-1] += (berr * 3) >> 4;
			berr2[i]   += (berr * 5) >> 4;
			berr2[i+1] += (berr) >> 4;
		}
             
		colour = cNearestColour(palette,
								paletteSize,
								rerr1[i],
								gerr1[i],
								berr1[i]);                                                    
		dp[0] = 0xFF;
		dp[1] = RED(colour);
		dp[2] = GREEN(colour);
		dp[3] = BLUE(colour);
	}
	
	CGImageRelease(ditheredBitmap);
	ditheredBitmap = CGBitmapContextCreateImage(context);
	
	// When finished, release the context
	CGContextRelease(context);
	
	// Free image data memory for the context
	if(sourceBaseAddress) {
		free(sourceBaseAddress);
	}
	
	return ditheredBitmap;
}

// Add or remove SPEC_PALETTE[index] from m_user_palette.
// Return false if disallowed - removing colour would leave < 2 palette entries.
-(bool)parameters:(NSDictionary*)a_parameters
{
	bool retval = true;
	NSNumber* add = [a_parameters valueForKey:@"addColour"];
	if(add) {
		retval = [self paletteChange:[add intValue] add:true];
	}
	
	NSNumber* remove = [a_parameters valueForKey:@"removeColour"];
	if(remove) {
		retval = [self paletteChange:[add intValue] add:false];
	}
	return retval;
}


-(bool)paletteChange:(int)idx add:(bool)add
{
    bool retval = true;
	NSMutableArray* userPalette = [parameters valueForKey:@"palette"];
	
    if(!add && [userPalette count] == 2) {
        retval = false;
    } else {
        NSNumber* colour = [[NSNumber alloc] initWithInt:spectrumColourFromIndex(idx)];
        if(!add) {

            NSNumber* paletteEntry;
			NSNumber* removee = nil;
			for(paletteEntry in userPalette) {
                if([paletteEntry isEqualToNumber:colour]) {
                    removee = paletteEntry;
					break;
                }
            }
			if(removee) {
				[userPalette removeObjectIdenticalTo:removee];
			}
        } else {
            if(![userPalette containsObject:colour]) {
                [userPalette addObject:colour];
            }
        }
        
        // Update the lookup table.
        [self createDitherLookup];
    }
    return retval;
}

-(void) createDitherLookup
{
    int i;
    int r,g,b;
    
    // Create a temporary palette of ints for speed.
    int palette[16];
	NSArray* userPalette = [parameters valueForKey:@"palette"];
    int palette_size = [userPalette count];
	
    for(i=0; i < palette_size; ++i) {
        palette[i] = [userPalette[i] intValue];
    }
    
    for(i = 0; i < (1 << 15); ++i) {
        r = (i & 0x7C00) >> 7;
        g = (i & 0x3E0) >> 2;
        b = (i & 0x1F) << 3;
        
        ditherLookup[i] = cNearestColour(palette, palette_size, r, g, b);
    }
}

-(NSString*)description
{
	return @"Floyd-Steinberg";
}

-(NSString*)mode
{
	return @"fs";
}

@end

#pragma mark -
#pragma mark C Methods

// Given r,g,b and a palette return the palette colour that is closest to r,g,b.
// C call for maximum speed.
int cNearestColour(int* palette, int palette_size, int r, int g, int b)
{
    int colour;
    int dr, dg, db;
    int dist;
    
    int minDist = INT_MAX;
    int nearest_match = 0;
    
    int i;
    for(i = 0; i < palette_size; ++i) {
        colour = palette [i];
        dr = (RED(colour)) - r;
        dg = (GREEN(colour)) - g;
        db = (BLUE(colour)) - b;
		
        dist = dr*dr + dg*dg + db*db;
        if(dist < minDist) {
            minDist = dist;
            nearest_match = colour;
        }
    }
    return nearest_match;
}
