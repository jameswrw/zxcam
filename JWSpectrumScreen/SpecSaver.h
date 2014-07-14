//
//  SpecSaver.h
//  Mac2Spec
//
//  Created by James on 18/12/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "../JWMac2SpecCLib/ColourMacros.h"
#import "JWSpectrumScreen.h"


typedef struct SpectrumScreenData {
	int screenSize;			// Size of contiguous data. There will be one block for sinclair and two for Timex.
	int bitmapOffset;		// Where does the bitmap data start wrt the base address of the data blob?
    int attribOffset;		// Where does the attribute data start wrt the base address of the data blob?
    int dataSize;			// The total size of all the data.
} SpectrumScreenData;

// Describes a particular pixel.
typedef struct AttributeData {
	int offset;		// Offset of pixel in the memory bitmap.
	int x;			// X coordinate of the pixel's attribute.
	int y;			// Y coordinate of the pixel's attribute.
} AttributeData;

typedef enum SaveFormat {
	SaveFormatTap,
	SaveFormatScr,
	SaveFormatPng,
	SaveFormatMp4
} SaveFormat;


@interface SpecSaver : NSObject {
	
	NSString* filetype;
    // If saving do we want .tap or .scr?
	
	int screenMode;
	// What's the screen mode?
	
	TimexHiResMode hiResMode;
}

// Write out a speccy file to memory - returned data is autoreleased.
- (NSData*)writeSpeccyScreen:(CGImageRef)bitmap;

// Write the header of a speccy file.
- (NSData*)writeHeaderWithName:(const char*)name
						size:(NSInteger)size
						loadAddress:(NSInteger)load_address;

// Return the checksum for a given data block.
// XOR 0xFF followed by all the data bytes.
- (unsigned char)checksumForData:(NSData*)data;

// Get the file type.
- (NSString*)filetype;

// Set the file type - valid values are SPEC_SAVE_TAP and SPEC_SAVE_SCR.            
- (void)setFiletype:(NSString*)type;

// Set the screen mode - normal speccy or the extra timex modes.
- (void)setScreenMode:(int)mode;

// Set the colour mode for Timex hi res.
- (void)setHiResMode:(TimexHiResMode)mode;
- (TimexHiResMode)hiResMode;

@end
