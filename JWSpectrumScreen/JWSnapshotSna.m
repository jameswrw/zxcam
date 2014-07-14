//
//  JSSnapshotSna.m
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshotSna.h"


@implementation JWSnapshotSna

- (JWSnapshotType)type
{
	return SnapshotSna;
}


- (NSData*)screenData
{
	if(!screenData) {
		const char* snapshotBytes = [snapshot bytes];
		screenData = [NSData dataWithBytes:(void*)(snapshotBytes + 27) length:SCREEN_STANDARD_BYTES];
	}
	return screenData;
}

@end
