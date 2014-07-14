//
//  JWSnapshotSzx.m
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshotSzx.h"
#import <zlib.h>

@implementation JWSnapshotSzx

- (id)initWithData:(NSData*)data
{
	if((self = [super initWithData:data])) {
		assert(snapshot);
		
		u_int32_t SZX_BLOCK_STATE = *((const u_int32_t*)"ZXST");
		u_int32_t SZX_BLOCK_RAMPAGE = *((u_int32_t*)"RAMP");
		u_int32_t SZX_BLOCK_TIMEX = *((u_int32_t*)"SCLD");

		BOOL isTimex = NO;
		char out255 = 0;
		NSData* ram16k = nil;
									
		const char* snapshotBytes = [snapshot bytes];
		LPZXSTHEADER zxStateHeader = (LPZXSTHEADER)snapshotBytes;
		
		if(zxStateHeader->dwMagic == SZX_BLOCK_STATE) {
			
			if(zxStateHeader->chMachineId == ZXSTMID_TC2048 || zxStateHeader->chMachineId == ZXSTMID_TC2068) {
				isTimex = YES;
			}
			snapshotBytes += sizeof(ZXSTHEADER);
			LPZXSTBLOCK block = NULL;
			const char* endOfSnapshot = [snapshot bytes];
			endOfSnapshot += [snapshot length];
			
			while(snapshotBytes < endOfSnapshot) {
				block = (LPZXSTBLOCK)snapshotBytes;
				if(block->dwId == SZX_BLOCK_RAMPAGE || block->dwId == SZX_BLOCK_TIMEX) {
					if(block->dwId == SZX_BLOCK_RAMPAGE) {
						LPZXSTRAMPAGE rampage = (LPZXSTRAMPAGE)snapshotBytes;
						// We only care about page 5 - it's the one with the screen data.
						if(rampage->chPageNo == 5) {
							if(rampage->wFlags & ZXSTRF_COMPRESSED) {
								NSUInteger length = block->dwSize - (sizeof(ZXSTRAMPAGE) - sizeof(ZXSTBLOCK) - 1);
								ram16k = [self inflateRampage:rampage->chData length:length];
							} else {
								ram16k = [NSData dataWithBytes:rampage->chData length:1024 * 16];
							}
						}
					} else {
						assert(isTimex);
						LPZXSTSCLDREGS timexInfo = (LPZXSTSCLDREGS)block;
						out255 = timexInfo->chFf;
					}
				}
				snapshotBytes += sizeof(ZXSTBLOCK);
				snapshotBytes += block->dwSize;
			}
		}
		if(ram16k) {
			if(isTimex && out255) {
				// Timex screen, copy first 12K from the ram page.
				NSData* bitmap = [NSData dataWithBytes:[ram16k bytes] length:1024 * 6];
				NSData* attributes = [NSData dataWithBytes:[ram16k bytes] + 0x2000 length:1024 * 6];
				NSMutableData* screen = [NSMutableData dataWithData:bitmap];
				[screen appendData:attributes];
				
				if(out255 == 2) {
					screenMode = ScreenModeTimexHiCol;
				} else {
					// Append the out255 byte to the screen data.
					screenMode = ScreenModeTimexHiRes;
					[screen	appendBytes:&out255 length:1];
				}
				screenData = [NSData dataWithData:screen];
			} else {
				// Normal screen, copy first 6,912 bytes from ram page.
				screenData = [NSData dataWithBytes:[ram16k bytes] length:6912];
				screenMode = ScreenModeSinclair;
			}
		} else {
			self = nil;
		}
	}
	return self;
}


- (NSData*)inflateRampage:(u_int8_t*)rampage length:(NSUInteger)length
{
	assert(rampage);
	assert(length);
	
	BOOL success = NO;
	
	// We know that the pages are 16K in length.
	NSMutableData* data = [NSMutableData dataWithLength:1024 * 16];
	char* dataBytes = [data mutableBytes];
	
	z_stream zstr;
	zstr.next_in = rampage;
	zstr.avail_in = length;
	zstr.next_out = (Bytef*)dataBytes;
	zstr.avail_out = [data length];
	zstr.zalloc = Z_NULL;
	zstr.zfree = Z_NULL;
	zstr.opaque = Z_NULL;
	
	int err = inflateInit(&zstr);
	if(err == Z_OK) {
		err = inflate(&zstr, Z_SYNC_FLUSH);
		if(err == Z_STREAM_END) {
			success = YES;
		}
	}
	
	if(!success) {
		data = nil;
	}
	
	return data;
}


- (ScreenMode)screenMode
{
	return screenMode;
}

@end
