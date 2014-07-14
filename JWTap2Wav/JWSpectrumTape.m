//
//  JWSpectrumTape.m
//  zxcam
//
//  Created by James Weatherley on 15/07/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//

#import "JWSpectrumTape.h"


@implementation JWSpectrumTape


-(id)initWithData:(NSData*)tape
{
	if(self = [super init]) {
		tapFile = tape;
		blockIndex = 0;
		
		if(![self verify]) {
			self = 0;
		}
	}
	return self;
}

-(BOOL)verify
{
	BOOL valid = NO;
	
	if(tapFile) {
		NSUInteger length = [tapFile length];
		UInt16 blockSize = 0;
		NSUInteger index = 0;
		
		// Test against length - 1 as we need to extract two bytes to get the blockSize.
		while(index < length - 1) {
			[tapFile getBytes:&blockSize range:NSMakeRange(index, 2)];
			index += blockSize + 2; // The two is for the blockSize value.
			++blockCount;
		}
		
		// If we're just beyond the end of the tape, then we're valid.
		if(index == length) {
			valid = YES;
		}
	}
	return valid;
	
}

-(NSData*)nextBlock
{
	NSData* block = nil;
	NSUInteger length = [tapFile length];
	UInt16 blockSize = 0;
	
	if(blockIndex < length - 1) {
		[tapFile getBytes:&blockSize range:NSMakeRange(blockIndex, 2)];
		blockIndex += blockSize + 2; // The two is for the blockSize value.
		
		// If blockIndex is out of this range, then sonething has gone wrong.
		if(blockIndex <= length) {
			// According to the rules subdataWithRange returned object doesn't belong to us.
			// So we don't need to worry about releasing it.
			block = [tapFile subdataWithRange:NSMakeRange(blockIndex - blockSize, blockSize)];
		}
	}
	return block;
}

-(NSUInteger)blockCount
{
	return blockCount;
}

#pragma mark Fast enumeration
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len
{
	NSUInteger count = 0;
	
	if(state->state == 0) {
        // We are not tracking mutations, so we'll set state->mutationsPtr to point into one of our extra values,
        // since these values are not otherwise used by the protocol.
        // If your class was mutable, you may choose to use an internal variable that is updated when the class is mutated.
        // state->mutationsPtr MUST NOT be NULL.
        state->mutationsPtr = &state->extra[0];
    }
	
    // Now we provide items, which we track with state->state, and determine if we have finished iterating.
    if(state->state < blockCount) {
        // Set state->itemsPtr to the provided buffer.
        // Alternate implementations may set state->itemsPtr to an internal C array of objects.
        // state->itemsPtr MUST NOT be NULL.
        state->itemsPtr = stackbuf;
        // Fill in the stack array, either until we've provided all items from the list
        // or until we've provided as many items as the stack based buffer will hold.
        while((state->state < blockCount) && (count < len))
        {
            stackbuf[count] = [self nextBlock];
            state->state++;
            count++;
        }
    }
    else
    {
        // We've already provided all our items, so we signal we are done by returning 0.
        count = 0;
    }
    return count;
}

@end
