//
//  TapePlayerViewController.h
//  zxcam
//
//  Created by James Weatherley on 01/08/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "../TapePlayerViewControllerDelegate.h"


@interface TapePlayerViewController : UIViewController <AVAudioPlayerDelegate> {
	CGImageRef image;
	NSData* wavData;
	AVAudioPlayer* audioPlayer;
	
	IBOutlet UIButton* eject;
	IBOutlet UIButton* play;
	IBOutlet UIButton* stop;
	IBOutlet UIButton* rewind;
	IBOutlet UIButton* lookDisabledHack;
	
	IBOutlet UILabel* createTapeMessage;
	IBOutlet UIProgressView* progress;
	
	__unsafe_unretained id<TapePlayerViewControllerDelegate> delegate;
}

-(void)makeWav:(id)context;
-(void)setImage:(CGImageRef)cgImage;
-(void)updateProgress:(NSNumber*)value;

-(IBAction)eject:(id)sender;
-(IBAction)play:(id)sender;
-(IBAction)stop:(id)sender;
-(IBAction)rewind:(id)sender;

-(void)audioPlayerBeginInterruption:(AVAudioPlayer*)player;
-(void)audioPlayerEndInterruption:(AVAudioPlayer*)player;
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError*)error;
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag;

@property (nonatomic, assign) id delegate;

@end
