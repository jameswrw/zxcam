//
//  TapePlayerViewController.m
//  zxcam
//
//  Created by James Weatherley on 01/08/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//

#import "TapePlayerViewController.h"
#import "../JWSpectrumScreen/SpecSaver.h"
#import "../JWTap2Wav/JWSpectrumTape.h"
#import "../JWTap2Wav/JWTap2Wav.h"
#import "../JWMac2SpecCLib/AttributeManager.h"

@implementation TapePlayerViewController
@synthesize delegate;

-(void)viewDidLoad
{	
	eject.enabled = YES;
	rewind.enabled = NO;
	play.enabled = NO;
	stop.enabled = NO;
	
	[eject setTitle: @"" forState:UIControlStateNormal];
	[rewind setTitle: @"" forState:UIControlStateNormal];
	[play setTitle: @"" forState:UIControlStateNormal];
	[stop setTitle: @"" forState:UIControlStateNormal];

	lookDisabledHack.hidden = NO;

	[NSThread detachNewThreadSelector:@selector(makeWav:) toTarget:self withObject:nil];
}

-(void)makeWav:(id)context
{
    @autoreleasepool {
        if(image) {
            
            createTapeMessage.hidden = NO;
            progress.progress = 0.0;
            progress.hidden = NO;
            
            SpecSaver* saver = [[SpecSaver alloc] init];
            [saver setScreenMode:ATTRIBUTE_ZX];
            [self performSelectorOnMainThread:@selector(updateProgress:) withObject:@0.1f waitUntilDone:NO];
            
            [saver setFiletype:@"tap"];
            NSData* tap = [saver writeSpeccyScreen:image];
            [self performSelectorOnMainThread:@selector(updateProgress:) withObject:@0.3f waitUntilDone:NO];
            
            JWSpectrumTape* tape = [[JWSpectrumTape alloc] initWithData:tap];
            JWTap2Wav* waveMaker = [[JWTap2Wav alloc] initWithTape:tape];
            
            wavData = [waveMaker wavData];
            [self performSelectorOnMainThread:@selector(updateProgress:) withObject:@0.7f waitUntilDone:NO];
            
            
            @try {
                NSError* err = [[NSError alloc] init];
                audioPlayer = [[AVAudioPlayer alloc] initWithData:wavData error:&err];
                audioPlayer.delegate = self;
            }
            @catch(NSException* e)
            {
                NSLog(@"%@", e);
            }
            [self performSelectorOnMainThread:@selector(updateProgress:) withObject:@1.0f waitUntilDone:NO];
            eject.enabled = YES;
            rewind.enabled = YES;
            play.enabled = YES;
            stop.enabled = YES;
            lookDisabledHack.hidden = YES;
            
            progress.hidden = YES;
            createTapeMessage.hidden = YES;
        }
    }
}

-(void)updateProgress:(NSNumber*)value
{
	progress.progress = [value floatValue];
}

-(void)setImage:(CGImageRef)cgImage
{
	image = cgImage;
}

-(IBAction)eject:(id)sender;
{
    [self dismissViewControllerAnimated:YES completion:nil];
	[delegate tapePlayerDismissed:self];
}

-(IBAction)play:(id)sender;
{
	[audioPlayer play];
}

-(IBAction)stop:(id)sender;
{
	[audioPlayer pause];
}

-(IBAction)rewind:(id)sender;
{
	if(audioPlayer) {
		audioPlayer.currentTime = 0;
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Audio Player Delegate Methods
-(void)audioPlayerBeginInterruption:(AVAudioPlayer*)player
{
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer*)player
{
	[player play];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError*)error
{
	[player stop];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
	//[player release];
}
@end
