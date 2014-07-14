//
//  JWConverterManager.m
//  JWSpectrumConverter
//
//  Created by James Weatherley on 22/06/2008.
//  Copyright 2008 James Weatherley. All rights reserved.
//

#import "JWConverterManager.h"
#import "ConverterPreprocess.h"
#import "ConverterCOD.h"
#import "ConverterMagicSquare.h"
#import "ConverterMagicSquareNasik.h"
#import "ConverterFS.h"
#import "ConverterAttributeClash.h"
#import "../JWMac2SpecCLib/AttributeManager.h"

@implementation JWConverterManager

// This class is a singleton.
static JWConverterManager* sharedConverter = nil;

+(JWConverterManager*)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConverter = [[self alloc] init];
    });
    return sharedConverter;
}

+(id)allocWithZone:(NSZone*)zone
{
    @synchronized(self) {
        if (sharedConverter == nil) {
            return [super allocWithZone:zone];
        }
    }
    return sharedConverter;
}


-(id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if(sharedConverter == nil) {
            if (self = [super init]) {
				sharedConverter = self;
				
				NSDictionary* cod2Param = @{@"matrixSize": @2,
										   @"buttonLabel": @"COD Matrix (2x2)"};
				
				NSDictionary* cod4Param = @{@"matrixSize": @4,
										   @"buttonLabel": @"COD Matrix (4x4)"};
				
				NSDictionary* cod8Param = @{@"matrixSize": @8,
										   @"buttonLabel": @"COD Matrix (8x8)"};
				
                NSDictionary* codMagic = @{@"matrixSize": @4,
										   @"buttonLabel": @"COD Magic Square"};
                
                NSDictionary* codMagicNasik = @{@"matrixSize": @4,
                                          @"buttonLabel": @"COD Magic Square (Nasik)"};
                
				NSDictionary* zxParam = @{@"width": @ATTRIBUTE_WIDTH,
										 @"height": @ATTRIBUTE_HEIGHT_SINCLAIR,
										 @"buttonLabel": @"Standard Spectrum"};
				
				NSDictionary* timexHiColParam = @{@"width": @ATTRIBUTE_WIDTH,
												 @"height": @ATTRIBUTE_HEIGHT_TIMEX_HI_COL,
												 @"buttonLabel": @"Timex High Colour"};
				
				NSDictionary* timexHiResParam = @{@"width": @ATTRIBUTE_WIDTH,
												 @"height": @ATTRIBUTE_HEIGHT_TIMEX_HI_RES,
												 @"buttonLabel": @"Timex High Res"};
				
				NSDictionary* preprocessParam = @{@"posterise": @0,
												 @"monochrome": @0};
				
				converters = [[NSDictionary alloc] initWithObjectsAndKeys:
							  [[ConverterPreprocess alloc] initWithParameters:preprocessParam], @"preprocess",
							  [[ConverterCOD alloc] initWithParameters:cod2Param], @"cod2",
							  [[ConverterCOD alloc] initWithParameters:cod4Param], @"cod4",
							  [[ConverterCOD alloc] initWithParameters:cod8Param], @"cod8",
                              [[ConverterMagicSquare alloc] initWithParameters:codMagic], @"magic",
                              [[ConverterMagicSquareNasik alloc] initWithParameters:codMagicNasik], @"nasik",
							  [[ConverterFS alloc] initWithParameters:nil], @"fs",
							  [[ConverterAttributeClash alloc] initWithParameters:zxParam], @"zx",
							  [[ConverterAttributeClash alloc] initWithParameters:timexHiColParam], @"timexHiCol",
							  [[ConverterAttributeClash alloc] initWithParameters:timexHiResParam], @"timexHiRes",
							  nil];
				
				currentDitherer = [self converter:@"cod8"];
			}
		}
	}
	return self;				
}

-(id)copyWithZone:(NSZone*)zone 
{
	return self;
}

-(ConverterBase*)converter:(NSString*)type
{
	return converters[type];
}

-(NSArray*)ditherModes
{
	NSMutableArray* modes = [[NSMutableArray alloc] init];
	NSString* key = nil;
	ConverterBase* cb = nil;
	
	for(key in converters) {
		cb = converters[key];
		if(![cb isMemberOfClass:[ConverterPreprocess class]] && ![cb isMemberOfClass:[ConverterAttributeClash class]]) {
			[modes addObject:key];
		}
	}
	
	[modes sortUsingSelector:@selector(compare:)];
	return modes;
}

-(NSArray*)ditherModeNames
{
	NSMutableArray* names = [[NSMutableArray alloc] init];
	NSString* mode = nil;
	NSArray* modes = [self ditherModes];
	for(mode in modes) {
		[names addObject:[converters[mode] description]];
	}
	return names;
}

-(NSArray*)attributeModes
{
	NSMutableArray* modes = [[NSMutableArray alloc] init];
	NSString* key = nil;
	ConverterBase* cb = nil;
	
	for(key in converters) {
		cb = converters[key];
		if([cb isMemberOfClass:[ConverterAttributeClash class]]) {
			[modes addObject:key];
		}
	}
	
	return modes;
}

-(NSArray*)attributeModeNames
{
	NSMutableArray* names = [[NSMutableArray alloc] init];
	NSString* mode = nil;
	NSArray* modes = [self attributeModes];
	for(mode in modes) {
		[names addObject:[converters[mode] description]];
	}
	 return names;
}

-(ConverterBase*)currentDitherer
{
	return currentDitherer;
}

-(void)setCurrentDitherer:(ConverterBase*)ditherer
{
	currentDitherer = ditherer;
}

@end
