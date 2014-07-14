//
//  UIImageExtras.h
//  zxcam
//
//  Created by James Weatherley on 31/03/2010.
//  Copyright 2010 James Weatherley. All rights reserved.
//

#import <Foundation/Foundation.h>

// http://www.iphonedevbook.com/forum/viewtopic.php?f=25&t=661
@interface UIImage (Extras)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;


@end
