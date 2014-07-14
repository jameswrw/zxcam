//
//  JWSnapshotLoader.m
//  Mac2SpecQLPlugin
//
//  Created by James Weatherley on 23/11/2007.
//  Copyright 2007 James Weatherley. All rights reserved.
//

#import "JWSnapshotLoader.h"
#import "JWSnapshotSna.h"
#import "JWSnapshotSzx.h"
#import "JWSnapshotZ80.h"

@implementation JWSnapshotLoader

- (id)initWithContentsOfURL:(NSURL*)url
{
	if((self = [super init])) {

		NSString* path = [url path];
		NSString* extension = [path pathExtension];
		NSData* fileContents = [NSData dataWithContentsOfURL:url];
				
		if([extension caseInsensitiveCompare:@"sna"] == NSOrderedSame) {
			snapshot = [[JWSnapshotSna alloc] initWithData:fileContents];
		} else if([extension caseInsensitiveCompare:@"szx"] == NSOrderedSame) {
			snapshot = [[JWSnapshotSzx alloc] initWithData:fileContents];
		} else if([extension caseInsensitiveCompare:@"z80"] == NSOrderedSame) {
			snapshot = [[JWSnapshotZ80 alloc] initWithData:fileContents];
		}
		
		if(!snapshot) {
			self = nil;
		}
	}
	
	return self;
}

- (JWSnapshotType)type
{
	return [snapshot type];
}

- (NSData*)screenData
{
	return [snapshot screenData];
}

- (ScreenMode)screenMode
{
	return [snapshot screenMode];
}

@end
