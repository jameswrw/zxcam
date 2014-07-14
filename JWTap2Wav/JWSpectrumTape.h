//
//  JWSpectrumTape.h
//  zxcam
//
//  Created by James Weatherley on 15/07/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//
@interface JWSpectrumTape : NSObject <NSFastEnumeration>
{

	NSData* tapFile;
	NSUInteger blockIndex;
	NSUInteger blockCount;
}

// This will return zero if the tape fails to verify.
-(id)initWithData:(NSData*)tape;

// Verify tapFile. Checks that the block sizes in the tape file
// are consistent with the data.
-(BOOL)verify;

// Return the next block of raw data.
-(NSData*)nextBlock;

// Return the number of blocks on the tape.
-(NSUInteger)blockCount;
@end
