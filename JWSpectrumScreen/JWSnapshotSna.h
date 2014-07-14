//
//  JSSnapshotSna.h
//  JWSpectrumScreen
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshot.h"


@interface JWSnapshotSna : JWSnapshot {

}

- (JWSnapshotType)type;
- (NSData*)screenData;

@end
