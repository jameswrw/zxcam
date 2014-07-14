//
//  SpecSaver.m
//  Mac2Spec
//
//  Created by James on 18/12/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "SpecSaver.h"
#import "AttributeBlock.h"
#import "AttributeBlockIterator.h"
#import "../JWMac2SpecCLib/AttributeManager.h"

const int SPECTRUM_SCREEN_BASE = 0x4000;
// Base address of the screen data.

const int TAP_HEADER_BYTES = 24;
// Length of a standard Spectrum tape header in bytes.

const int TAP_HEADER_CHECKSUM_BYTES = 1;
// The checksum for a Spectrum file is one byte.

const int SINCLAIR_SCREEN_BYTES = 0x1B00;
// Bytes in a standard Sinclair screen: pixels + attributes.

const int ATTRIB_OFFSET = 0x1800;
// Offset in datablob where the attributes start.

const int TIMEX_SCREEN_BYTES = 0x1800;
// Timex screen size: just pixels, the attributes are in a second identically sized file.

@implementation SpecSaver

-(id)init
{
	if((self = [super init])) {
		filetype = @"scr";
		[self setHiResMode:TimexHiResBlackWhite];
	}
	return self;
}

// Write out a speccy file to memory.
-(NSData*)writeSpeccyScreen:(CGImageRef)bitmap
{
	NSMutableData* fileContents = [NSMutableData dataWithCapacity:16 * 1024];
	
	if([filetype compare:@"png"] == NSOrderedSame) {
		UIImage* image = [UIImage imageWithCGImage:bitmap];
		fileContents = [NSMutableData dataWithData:UIImagePNGRepresentation(image)];
	} else if([filetype compare:@"scr"] == NSOrderedSame || [filetype compare:@"tap"] == NSOrderedSame) {
	
	JWSpectrumScreen* zxScreen = [[JWSpectrumScreen alloc] initWithRepresentation:bitmap mode:screenMode hiResMode:hiResMode];
	NSDictionary* screenSections = [zxScreen screenSections];
	NSMutableData* screen = [NSMutableData dataWithData:screenSections[@"Screen0"]];
	assert(screen);
	
	NSData* attributes = nil;
	if(screenMode == ATTRIBUTE_ZX || screenMode == ATTRIBUTE_TIMEX_HI_COL) {
		attributes = screenSections[@"Attributes"];
		assert(attributes);
		if(screenMode == ATTRIBUTE_ZX) {
			[screen appendData:attributes];
		}
	}
	
	if([filetype compare:@"tap"] == NSOrderedSame) {
		// Create the header for the first CODE block.
		NSData* header1 = [self writeHeaderWithName:"screen"
								size:[screen length]
								loadAddress:SPECTRUM_SCREEN_BASE];
		[fileContents appendData:header1]; 
	}
	[fileContents appendData:screen];
	if([filetype compare:@"tap"] == NSOrderedSame) {
		unsigned char checksum = [self checksumForData:screen];
		[fileContents appendBytes:&checksum	length:1];
	}
	
	// If we're saving a standard speccy screen we're done but for a Timex screen
	// we still need to write a header for the attribute code block.
	if(screenMode == ATTRIBUTE_TIMEX_HI_COL || screenMode == ATTRIBUTE_TIMEX_HI_RES) {
				
		NSData* block2;
		if(screenMode == ATTRIBUTE_TIMEX_HI_COL) {
			block2 = attributes;
		} else {
			block2 = screenSections[@"Screen1"];
		}
		
		if([filetype compare:@"tap"] == NSOrderedSame) {
			NSData* header2 = [self writeHeaderWithName:"attrib"
									size:[block2 length]
									loadAddress:0x6000];
									
			[fileContents appendData:header2];
		}
		[fileContents appendData:block2];
		
		if([filetype compare:@"tap"] == NSOrderedSame) {			
			unsigned char checksum = [self checksumForData:block2];
			[fileContents appendBytes:&checksum length:1];
		}
				
		if([filetype compare:@"scr"] == NSOrderedSame) {			
			if(screenMode == ATTRIBUTE_TIMEX_HI_RES) {
				NSData* out255 = screenSections[@"Out255"];
				[fileContents appendData:out255];
				}
			}
		}
	}
    return fileContents;
}

// Save image to a spectrum file format.
// Write the header of a speccy file.
- (NSData*)writeHeaderWithName:(const char*)name
						size:(NSInteger)size
						loadAddress:(NSInteger)load_address
{
	
	char* buffer = calloc(TAP_HEADER_BYTES, sizeof(char));
	
    int len;
    len = strlen(name);
    assert(len > 0 && len < 11);
    
    // Tap file header.
    buffer[0] = 0x13;  // 19 Bytes  
    buffer[1] = 0x00;  // ...
	
    // Actual speccy header.
    buffer[2] = 0x00;  // It's a header
    buffer[3] = 0x03;  // CODE
    
    // File name.
    int i;
    for(i = 0; i < 11; ++i) {
        if(i < len) {
            buffer[4+i] = name[i];
        } else {
            buffer[4+i] = 0x20;
        }
    }
	
    // Size.
    buffer[14] = size & 0xFF;
    buffer[15] = (size & 0xFF00) >> 8;
	
    // Load address.
    buffer[16] = load_address & 0xFF;
    buffer[17] = (load_address & 0xFF00) >> 8;
    
    // 0x8000 expected here.
    buffer[18] = 0x00;
    buffer[19] = 0x80;
    
    // Checksum.
    int checksum = 0;
    for(i = 2; i < 20; ++i) {
        checksum ^= buffer[i];
    }
    buffer[20] = checksum;
    
    // Tap file - second block header.
    size += 2;
    buffer[21] = size & 0xFF; 
    buffer[22] = (size & 0xFF00) >> 8;
    
    // Next block is CODE.
    buffer[23] = 0xFF;
	
	NSMutableData* data = [NSMutableData dataWithBytesNoCopy:buffer length:TAP_HEADER_BYTES];
	return data;
}

// XOR 0xDFF folowed by all the bytes.
- (unsigned char)checksumForData:(NSData*)data
{
	unsigned char checksum = 0xFF;
	
	const char* ptr = [data bytes];
	int length = [data length];
	int i = 0;
	for(i = 0; i < length; i++) {
		checksum ^= ptr[i];
	}
				
	return checksum;
}

// Get the file type.
- (NSString*)filetype
{
    return filetype;
}

// Set the file type.
- (void)setFiletype:(NSString*)type
{
    if([type caseInsensitiveCompare:@"scr"] == NSOrderedSame ||
       [type caseInsensitiveCompare:@"tap"] == NSOrderedSame ||
	   [type caseInsensitiveCompare:@"png"] == NSOrderedSame) {
        filetype = type;
    } else {
        assert(0);
    }
}

// Set the screen mode
- (void) setScreenMode:(int)mode
{
	screenMode = mode;
}

-(void)setHiResMode:(TimexHiResMode)mode
{
	hiResMode = mode;
}

-(TimexHiResMode)hiResMode
{
	return hiResMode;
}

@end





