//
//  JWConverterManager.h
//  JWSpectrumConverter
//
//  Created by James Weatherley on 22/06/2008.
//  Copyright 2008 James Weatherley. All rights reserved.
//

@class ConverterBase;


@interface JWConverterManager : NSObject {

	NSDictionary* converters;
	ConverterBase* currentDitherer;
}

-(ConverterBase*)converter:(NSString*)type;

-(NSArray*)ditherModes;
-(NSArray*)ditherModeNames;
-(NSArray*)attributeModes;
-(NSArray*)attributeModeNames;

-(ConverterBase*)currentDitherer;
-(void)setCurrentDitherer:(ConverterBase*)ditherer;

+(JWConverterManager*)sharedManager;

@end
