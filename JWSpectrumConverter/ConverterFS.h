//
//  ConverterFS.h
//  Mac2Spec
//
//  Created by James on 10/5/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterBase.h"


// init does not expect anything in the parameter dictionary.
// You can modify the palette by updating the parameter dictionary with:
//  key: @"addColour", value: (NSNumber*)index
//  key: @"removeColour", value: (NSNumber*)index

@interface ConverterFS : ConverterBase
{	
	int* ditherLookup;
    // Fast lookup table to find nearest colour matches.
	
	CGImageRef ditheredBitmap;
}

- (bool)paletteChange:(int)index add:(bool)add;
- (void)createDitherLookup;

@end
