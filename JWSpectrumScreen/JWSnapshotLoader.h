//
//  JWSnapshotLoader.h
//  Mac2SpecQLPlugin
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshot.h"


@interface JWSnapshotLoader : NSObject {
	JWSnapshot* snapshot;
}

- (id)initWithContentsOfURL:(NSURL*)url;
- (JWSnapshotType)type;
- (NSData*)screenData;
- (ScreenMode)screenMode;

@end
