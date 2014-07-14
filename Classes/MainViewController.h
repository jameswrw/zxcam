//
//  MainViewController.h
//  zxcam
//
//  Created by James Weatherley on 30/06/2009.
//  Copyright James Weatherley 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ObjectiveFlickr.h"
#import "../TapePlayerViewControllerDelegate.h"

@class JWConverterManager;
@class RootViewController;
@class TapePlayerViewController;
@class Reachability;


@interface MainViewController : UIViewController 
<UINavigationControllerDelegate, 
UIImagePickerControllerDelegate, 
MFMailComposeViewControllerDelegate, 
OFFlickrAPIRequestDelegate,
UIActionSheetDelegate,
TapePlayerViewControllerDelegate>
{
	
	
	RootViewController* rootViewController;
	UIToolbar* toolbar;
		
	UIBarButtonItem* cameraButton;
	UIBarButtonItem* pictureButton;
	UIBarButtonItem* tapeButton;
	UIBarButtonItem* mailButton;
	
	UIImageView* macView;
	UIImageView* spectrumView;
	UIImageView* backgroundView;
	
	UISlider* brightness;
	UIImageView* minBrightness;
	UIImageView* maxBrightness;
	
	OFFlickrAPIContext* flickr;
	
	IBOutlet JWConverterManager* converterManager;
	IBOutlet UIButton* flickrButton;
	IBOutlet UIButton* debugFlickrResetButton;
	IBOutlet UIActivityIndicatorView* flickrSpinner;
	
	CGRect rect;
	
	Reachability* internetReachable;
    Reachability* hostReachable;
	BOOL internetActive;
	BOOL hostActive;
}

-(IBAction)brightnessChanged:(id)sender;
-(IBAction)twitter:(id)sender;
-(IBAction)flickr:(id)sender;
-(IBAction)flickrReset:(id)sender;

-(void)updateSpectrumView;
-(void)savePreferences;
-(void)flickrAuthenticate:(NSURL*)url;

@property (nonatomic, retain) RootViewController* rootViewController;
@property (nonatomic, retain) IBOutlet UIToolbar* toolbar;

@property (nonatomic, retain) IBOutlet UIBarButtonItem* cameraButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* pictureButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* tapeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* mailButton;

@property (nonatomic, retain)  IBOutlet UIImageView* macView;
@property (nonatomic, retain)  IBOutlet UIImageView* spectrumView;
@property (nonatomic, retain)  IBOutlet UIImageView* backgroundView;

@property (nonatomic, retain)  IBOutlet UISlider* brightness;
@property (nonatomic, retain)  IBOutlet UIImageView* minBrightness;
@property (nonatomic, retain)  IBOutlet UIImageView* maxBrightness;

@end
