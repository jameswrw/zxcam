//
//  JWSnapshotZ80.m
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshotZ80.h"


@implementation JWSnapshotZ80

- (id)initWithData:(NSData*)data
{
	if((self = [super initWithData:data])) {
	
		NSData* ram = nil;
		const char* z80Bytes = [data bytes];
		u_int16_t programCounter = *((u_int16_t*)(z80Bytes + 6));
		u_int16_t extraBlockLength = 0;
		
		if(!programCounter) {
			extraBlockLength = *((u_int16_t*)(z80Bytes + 30));
			if(extraBlockLength == 23) {
				version = 2;
			} else if(extraBlockLength == 54 || extraBlockLength == 55) {
				version = 3;
			} else {
				// Unknown Z80 version!
				version = 0;
				assert(0);
			}
		} else {
			version = 1;
		}
		
		if(version) {
			if(version == 1) {
				if(z80Bytes[12] & (1 << 4)) {
					NSData* compressedRam = [NSData dataWithBytes:(z80Bytes + 30) length:([data length] - 30)];
					ram = [self inflateZ80:compressedRam];
				} else {
					ram = [NSData dataWithBytes:(z80Bytes + 30) length:(48 * 1024)];
				}
			} else if(version == 2 || version ==3) {
				z80Bytes += 30;
				z80Bytes += extraBlockLength;
				// I guess the extra header block length word doesn't count as part of the header :/
				z80Bytes += 2;
				
				u_int8_t page = 0;
				u_int16_t length = 0;
				BOOL foundPage8 = NO;
				while(!foundPage8) {
					length = *(u_int16_t*)z80Bytes;
					page = z80Bytes[2];
					if(page == 8) {
						foundPage8 = YES;
						if(length == 0xffff) {
							// Uncompressed page.
							ram = [NSData dataWithBytes:(z80Bytes + 3) length:(16 * 1024)];
						} else {
							NSData* compressedRam = [NSData dataWithBytes:(z80Bytes + 3) length:length];
							ram = [self inflateZ80:compressedRam];
						}
					}
					z80Bytes += 3;
					if(length == 0xffff) {
						z80Bytes += 16 * 1024;
					} else {
						z80Bytes += length;
					}
				}
			} 
		} 
		
		if(ram) {
			screenData = [NSData dataWithBytes:[ram bytes] length:6912];
		} else {
			self = nil;
		}
	}
	
	return self;
}


- (NSData*)inflateZ80:(NSData*)z80
{
	const unsigned char* compressedBytes = [z80 bytes];
	NSUInteger length = [z80 length];
	NSMutableData* ramContents = nil;
	
	if(version == 1) {
		// Version one data should have an end marker.
		assert(compressedBytes[length - 1] == 0x00);
		assert(compressedBytes[length - 2] == 0xed);
		assert(compressedBytes[length - 3] == 0xed);
		assert(compressedBytes[length - 4] == 0x00);
		
		// Don't want to decompress the end marker.
		// Compressed data represents 48K.
		length -= 4;
		ramContents = [NSMutableData dataWithLength:(1024 * 48)];
	} else if(version == 2 || version == 3) {
		// No end marker. Data represents 16K.
		ramContents = [NSMutableData dataWithLength:(1024 * 16)];
	}
	
	int ramIdx = 0;
	char* ramBytes = [ramContents mutableBytes];
	for(int idx = 0; idx < length; ++idx) {

		if(compressedBytes[idx] == 0xed && compressedBytes[idx + 1] == 0xed) {
			unsigned char repeat = compressedBytes[idx + 2];
			unsigned char value = compressedBytes[idx + 3];
			for(int i = 0; i < repeat; ++i) {
				ramBytes[ramIdx++] = value;
			}
			// The loop will increment idx by one as well.
			idx += 3;
		} else {
			ramBytes[ramIdx++] = compressedBytes[idx];
		}
	}
	
	if(version == 1) {
		assert(ramIdx == 48 * 1024);
	} else {
		assert(ramIdx == 16 * 1024);
	}
	
	return ramContents;
}

@end
