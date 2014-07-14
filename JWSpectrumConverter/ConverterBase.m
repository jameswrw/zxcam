//
//  ConvertBase.m
//  Mac2Spec 3
//
//  Created by James on 1/12/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import "ConverterBase.h"


@implementation ConverterBase

-(id)initWithParameters:(NSDictionary*)a_parameters
{
	if(self = [super init]) {
        parameters = [[NSMutableDictionary alloc] init];
        [parameters setDictionary:a_parameters];
	}
	return self;
}

- (CGImageRef)convert:(CGImageRef)source
{
	return 0; //CGImageCreateCopy(source);
}

-(bool)setParameters:(NSDictionary*)a_parameters
{
	[parameters addEntriesFromDictionary:a_parameters];
	return true;
}

-(NSDictionary*)parameters
{
	return parameters;
}

-(NSString*)description
{
	// Provide a proper description in your derived class.
	assert(0);
}

-(NSString*)mode
{
	return [self description];
}

@end
