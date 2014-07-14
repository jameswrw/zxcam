//
//  JWSnapshotZ80.h
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshot.h"


@interface JWSnapshotZ80 : JWSnapshot {

// What version of Z80 are we reading? 1, 2 or 3.
int version;

}


// Looks for the screen data contained in the Z80 file.
- (id)initWithData:(NSData*)data;


// Uncompress the z80 file.
//
// Returns the uncompressed data if successful, otherwise returns nil.
- (NSData*)inflateZ80:(NSData*)z80;


@end
