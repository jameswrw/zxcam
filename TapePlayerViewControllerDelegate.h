/*
 *  TapePlayerViewControllerDelegate.h
 *  zxcam
 *
 *  Created by James Weatherley on 21/11/2010.
 *  Copyright 2010 James Weatherley. All rights reserved.
 *
 */

@class TapePlayerViewController;

@protocol TapePlayerViewControllerDelegate <NSObject>
//Method declarations go here
-(void)tapePlayerDismissed:(TapePlayerViewController*)tapePlayer;

@end
