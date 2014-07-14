//
//  ConvertBase.h
//  Mac2Spec 3
//
//  Created by James on 1/12/2005.
//  Copyright 2005 James Weatherley. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONVERTER_IDLE -1


@interface ConverterBase : NSObject
{
	NSMutableDictionary* parameters;
}

// a_parameters can be nil if parameters are not required.
-(id)initWithParameters:(NSDictionary*)a_parameters;


-(CGImageRef)convert:(CGImageRef)source;
// Returns a new (autoreleased) version of source.
// Override in derived classes to do some actual work.

-(bool)setParameters:(NSDictionary*)parameters;
-(NSDictionary*)parameters;
-(NSString*)mode;

@end
