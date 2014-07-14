//
//  JWSnapshotSzx.h
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshot.h"
#import "JWSzx.h"



@interface JWSnapshotSzx : JWSnapshot {

	ScreenMode screenMode;
}

// Looks for the blocks containing the screen bitmap and any Timex info.
- (id)initWithData:(NSData*)data;


// Called if the ram pages are compressed. 
// Pass in the compressed page in as 'rampage', and its length as 'length'.
//
// Preconditions.
//   'rampage' os not NULL.
//   'length is not zero.
//
// Returns the uncompressed data if successful, otherwise returns nil.
- (NSData*)inflateRampage:(u_int8_t*)rampage length:(NSUInteger)length;


@end
