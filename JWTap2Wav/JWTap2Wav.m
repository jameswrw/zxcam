//
//  JWTap2Wav.m
//  zxcam
//
//  Created by James Weatherley on 15/07/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//

#import "JWTap2Wav.h"
#import "JWSpectrumTape.h"


@implementation JWTap2Wav

const int WAV_SAMPLE_RATE = 44100;
const float TSTATE = 1.0 / 3500000;

const int RIFF_LENGTH = 12;
const int FMT_LENGTH = 24;

@synthesize leadInOut;
@synthesize leader;
@synthesize sync;
@synthesize one;
@synthesize zero;


-(id)initWithTape:(JWSpectrumTape*)inTape
{
	if(self = [super init]) {
		tape = inTape;
		[self createPulses];
	}
	return self;
}

-(void)createPulses
{
	NSMutableData* data = [[NSMutableData alloc] initWithLength:WAV_SAMPLE_RATE * 0.45];
	memset([data mutableBytes], 0x80, [data length]);
	leadInOut = data;
	
	leader = [self newPulseWithOnTStates:2168 offTStates:2168];
	sync = [self newPulseWithOnTStates:667 offTStates:735];
	one = [self newPulseWithOnTStates:1710 offTStates:1710];
	zero = [self newPulseWithOnTStates:855 offTStates:855];
}

-(NSData*)newPulseWithOnTStates:(NSUInteger)onTStates offTStates:(NSUInteger)offTStates
{
	UInt8 hi = 0xff;
	UInt8 lo = 0x00;
	
	NSUInteger lengthOn = onTStates * WAV_SAMPLE_RATE * TSTATE;
	NSUInteger lengthOff = offTStates * WAV_SAMPLE_RATE * TSTATE;
	NSMutableData* pulse = [[NSMutableData alloc] initWithLength:lengthOn + lengthOff];
	
	SInt8* bytes = malloc(lengthOn);
	memset(bytes, lo, lengthOn);
	[pulse replaceBytesInRange:NSMakeRange(0, lengthOn) withBytes:bytes length:lengthOn];
	
	bytes = realloc(bytes, lengthOff);
	memset(bytes, hi, lengthOff);
	[pulse replaceBytesInRange:NSMakeRange(lengthOn, lengthOff) withBytes:bytes length:lengthOff];
	
	free(bytes);
	return pulse;
}

-(NSData*)wavData;
{
	NSMutableData* data = [NSMutableData dataWithLength:8];
	[data replaceBytesInRange:NSMakeRange(0, 4) withBytes:"data"];
	
	if([tape blockCount]) {
		NSData* tapeBlock = nil;
	
		for(tapeBlock in tape) {
			[data appendData:[self leadInOut]];
			for(int i = 0; i < 2048; ++i) {
				[data appendData:leader];
			}
			[data appendData:[self sync]];
			[data appendData:[self makePCM:tapeBlock]];
		}
		[data appendData:[self leadInOut]];
	}
	if([data length] & 1) {
		[data increaseLengthBy:1];
	}
	
	NSUInteger pcmLength = [data length] - 8;
	[data replaceBytesInRange:NSMakeRange(4, 4) withBytes:&pcmLength];
	
	NSUInteger fmtDataLength = FMT_LENGTH - 8;
	UInt16 compressionCode = 1;
	UInt16 channels = 1;
	UInt16 bitsPerSample = 8;
	UInt16 blockAlign = 1;
	NSUInteger bytesPerSecond = WAV_SAMPLE_RATE * blockAlign;
	
	NSMutableData* fmt = [NSMutableData dataWithLength:FMT_LENGTH];
	[fmt replaceBytesInRange:NSMakeRange(0, 4) withBytes:"fmt "];
	[fmt replaceBytesInRange:NSMakeRange(4, 4) withBytes:&fmtDataLength];
	[fmt replaceBytesInRange:NSMakeRange(8, 2) withBytes:&compressionCode];
	[fmt replaceBytesInRange:NSMakeRange(10, 2) withBytes:&channels];
	[fmt replaceBytesInRange:NSMakeRange(12, 4) withBytes:&WAV_SAMPLE_RATE];
	[fmt replaceBytesInRange:NSMakeRange(16, 4) withBytes:&bytesPerSecond];
	[fmt replaceBytesInRange:NSMakeRange(20, 2) withBytes:&blockAlign];
	[fmt replaceBytesInRange:NSMakeRange(22, 2) withBytes:&bitsPerSample];
	
	NSMutableData* riff = [NSMutableData dataWithLength:RIFF_LENGTH];
	NSUInteger wavLength = [fmt length] + [data length];
	[riff replaceBytesInRange:NSMakeRange(0, 4) withBytes:"RIFF"];
	[riff replaceBytesInRange:NSMakeRange(4, 4) withBytes:&wavLength];
	[riff replaceBytesInRange:NSMakeRange(8, 4) withBytes:"WAVE"];
	
	[riff appendData:fmt];
	[riff appendData:data];
	
	return riff;
}

-(NSData*)makePCM:(NSData*)tapeBlock
{
	NSMutableData* pcmBlock = [[NSMutableData alloc] init];
	const UInt8* bytes = [tapeBlock bytes];
	NSUInteger length = [tapeBlock length];
	
	
	UInt8 byte = 0;
	UInt8 mask = 0;
	bool bit = false;
	
	for(NSUInteger i = 0; i < length; ++i) {
		byte = bytes[i];
		for(NSUInteger bitIndex = 0 ; bitIndex < 8; ++bitIndex) {
			mask = 0x80 >> bitIndex;
			bit = byte & mask;
			if(bit) {
				[pcmBlock appendData:[self one]];
			} else {
				[pcmBlock appendData:[self zero]];
			}
		}
	}
	
	return pcmBlock;
}

@end







