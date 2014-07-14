//
//  JWSnapshot.m
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshot.h"


@implementation JWSnapshot

- (id)initWithData:(NSData*)data
{
	if((self = [super init])) {
		snapshot = [NSData dataWithData:data];
	}
	return self;
}

- (JWSnapshotType)type
{
	return SnapshotError;
}

- (NSData*)screenData
{
	return screenData;
}

- (ScreenMode)screenMode
{
	return ScreenModeSinclair;
}

@end
