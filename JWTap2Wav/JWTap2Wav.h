//
//  JWTap2Wav.h
//  zxcam
//
//  Created by James Weatherley on 15/07/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JWSpectrumTape;
@class JWTap2Wav;

//!!!! Make this a proper object !!!!
typedef struct ZxData {
	__unsafe_unretained NSData* data;
	NSInteger pos;
	__unsafe_unretained JWTap2Wav* tap2Wav;
} ZxData;


@interface JWTap2Wav : NSObject {
	JWSpectrumTape* tape;
	
	
	NSData* leadInOut;
	NSData* leader;
	NSData* sync;
	NSData* one;
	NSData* zero;
}

-(id)initWithTape:(JWSpectrumTape*)inTape;

-(void)createPulses;
-(NSData*)newPulseWithOnTStates:(NSUInteger)onTStates offTStates:(NSUInteger)offTStates;

-(NSData*)wavData;
-(NSData*)makePCM:(NSData*)tapeBlock;


@property (nonatomic, retain)  NSData* leadInOut;
@property (nonatomic, retain)  NSData* leader;
@property (nonatomic, retain)  NSData* sync;
@property (nonatomic, retain)  NSData* one;
@property (nonatomic, retain)  NSData* zero;

@end
