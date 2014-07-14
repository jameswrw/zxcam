//
//  JWSnapshot.h
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "../JWSpectrumScreen/JWSpectrumScreenConstants.h"

typedef enum JWSnapshotType	{
	SnapshotSzx,
	SnapshotSna,
	SnapshotZ80,
	SnapshotError
} JWSnapshotType;


@interface JWSnapshot : NSObject {

	NSData* snapshot;
	NSData* screenData;
}

- (id)initWithData:(NSData*)data;

- (JWSnapshotType)type;
- (NSData*)screenData;
- (ScreenMode)screenMode;

@end
