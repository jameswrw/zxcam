//
//  MainViewController.m
//  zxcam
//
//  Created by James Weatherley on 30/06/2009.
//  Copyright James Weatherley 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "RootViewController.h"
#import "TapePlayerViewController.h"
#import "../JWSpectrumConverter/JWConverterManager.h"
#import "../JWSpectrumConverter/ConverterBase.h"
#import "../JWMac2SpecCLib/AttributeManager.h"
#import "../JWSpectrumScreen/SpecSaver.h"
#import "../objflickr/FlickrAPIKey.h"
#import "../UIImageExtras.h"
#import "../Reachability.h"

#import <Social/Social.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/SystemConfiguration.h>

NSString* kStoredAuthTokenKeyName = @"FlickrAuthToken";
NSString* kGetAuthTokenStep = @"authenticate";
NSString* kUploadImageStep = @"upload";
NSString* kSetGroupStep = @"group";
NSString* kGroupId = @"1198815@N25";

SystemSoundID soundID = 0;


@implementation MainViewController

@synthesize toolbar;
@synthesize cameraButton;
@synthesize pictureButton;
@synthesize tapeButton;
@synthesize mailButton;
@synthesize macView;
@synthesize spectrumView;
@synthesize backgroundView;
@synthesize brightness;
@synthesize minBrightness;
@synthesize maxBrightness;
@synthesize rootViewController;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		flickr = [[OFFlickrAPIContext alloc] initWithAPIKey:OBJECTIVE_FLICKR_SAMPLE_API_KEY sharedSecret:OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET];
		NSString* authToken;
        if((authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName])) {
            flickr.authToken = authToken;
        }
    }
    return self;
}

+(void)initialize
{
	if([self class] == [MainViewController class]) {
	
		NSDictionary* defaults = @{@"red": @0,
								  @"green": @0,
								  @"blue": @0,
								  @"posterise": @NO,
								  @"monochrome": @NO,
								  @"ditherMode": @"cod8"};
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// Set up the toolbar buttons.
	cameraButton.target = self;
	pictureButton.target = self;
	tapeButton.target = self;
	mailButton.target = self;
	
	cameraButton.action = @selector(camera);
	pictureButton.action = @selector(picture);
	tapeButton.action = @selector(tape);
	mailButton.action = @selector(send);
	
	// Hide the brightness slider until we have an image to play with.
	[brightness setHidden:YES];
	[minBrightness setHidden:YES];
	[maxBrightness setHidden:YES];
	
	// Load up the Spectrum-esque background.
	NSString* path = [[NSBundle mainBundle] pathForResource:@"zxBackground" ofType:@"png"];
	backgroundView.image = [UIImage imageWithContentsOfFile:path];
	
	// Disable stuff if it can't be used for some reason: camera, mail, flickr.
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		cameraButton.enabled = NO;
	}
	
	if(![MFMailComposeViewController canSendMail]) {
		mailButton.enabled = NO;
	}

#if 0
	BOOL enableFlickrButton = NO;
	SCNetworkReachabilityRef network = SCNetworkReachabilityCreateWithName(NULL, "flickr.com");

	SCNetworkReachabilityFlags flags;
	Boolean success = SCNetworkReachabilityGetFlags(network, &flags);
	if(success) {
		if(flags & kSCNetworkFlagsReachable && !(flags & kSCNetworkFlagsConnectionRequired)) {
			enableFlickrButton = YES;
		} 
	}
	flickrButton.enabled = enableFlickrButton;
	CFRelease(network);
#endif
	
	// check for internet connection
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
	
	internetReachable = [Reachability reachabilityForInternetConnection];
	[internetReachable startNotifier];
	
	// check if a pathway to a random host exists
	hostReachable = [Reachability reachabilityWithHostName: @"flickr.com"];
	[hostReachable startNotifier];
	
	
	
	
	// Hide the spinner.
	flickrSpinner.hidden = YES;
	
	// Initialise the doodip loading noise which plays when a photo is successfully uploaded to flickr.
	if(!soundID) {
		path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/doodip.wav"];
		NSURL* filePath = [NSURL fileURLWithPath:path isDirectory:NO];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
	}
	
#if TARGET_IPHONE_SIMULATOR
	debugFlickrResetButton.hidden = NO;
#else
	debugFlickrResetButton.hidden = YES;
#endif
	
	// And now we're ready.
	[self loadPreferences];
    [super viewDidLoad];
}

-(void)viewDidUnload
{
	[self savePreferences];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	if((self.interfaceOrientation == UIDeviceOrientationLandscapeLeft) || (self.interfaceOrientation == UIDeviceOrientationLandscapeRight)){
		NSLog(@"Landscape");
	} else	if((self.interfaceOrientation == UIDeviceOrientationPortrait) || (self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)){
		NSLog(@"Portrait");
	}
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Toolbar button methods
-(void)camera 
{
	[self pickImage:UIImagePickerControllerSourceTypeCamera];
}

-(void)picture 
{
	[self pickImage:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(void)tape 
{
	
	CGImageRef image = [spectrumView.image CGImage];
	if(image) {
		
		TapePlayerViewController* tapePlayerController = [[TapePlayerViewController alloc] initWithNibName:nil bundle:nil];
		[tapePlayerController setImage:image];
		[rootViewController.infoButton removeFromSuperview];
		tapePlayerController.delegate = self;
        
        [rootViewController presentViewController:tapePlayerController animated:YES completion:nil];
	}
}

-(void)send 
{
	UIActionSheet* sheet = nil;
	
	if(flickrButton.enabled) {
		sheet = [[UIActionSheet alloc] initWithTitle:@"Send to"
											 delegate:self 
									cancelButtonTitle:@"Cancel" 
							   destructiveButtonTitle:nil 
									otherButtonTitles:@"Photo Album", @"Mail", @"Twitter", @"Flickr", nil];
	} else {
		sheet = [[UIActionSheet alloc] initWithTitle:@"Send to"
											 delegate:self 
									cancelButtonTitle:@"Cancel" 
							   destructiveButtonTitle:nil 
									otherButtonTitles:@"Photo Album", @"Mail", @"Twitter", nil];
	}
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
	//[sheet showFromToolbar:toolbar];
}

-(void)photoLibrary 
{
	UIImageWriteToSavedPhotosAlbum(spectrumView.image, nil, nil, nil);
}

-(void)mail 
{
	CGImageRef image = [spectrumView.image CGImage];
	if(image) {
		SpecSaver* saver = [[SpecSaver alloc] init];
		[saver setScreenMode:ATTRIBUTE_ZX];
		
		[saver setFiletype:@"tap"];
		NSData* tap = [saver writeSpeccyScreen:image];
		
		[saver setFiletype:@"png"];
		NSData* png = [saver writeSpeccyScreen:image];
		
		MFMailComposeViewController* mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		
		[mailComposer setSubject:@"zxCam Images"];
		[mailComposer setMessageBody:@"Files converted by zxCam on iPhone." isHTML:NO];
		[mailComposer addAttachmentData:png mimeType:@"image/png" fileName:@"zxCam.png"];
		
		// The scr extension is also used for Windows screensavers. Mail servers think they're trojans.
		// [mailComposer addAttachmentData:scr mimeType:@"application/octet-stream" fileName:@"zxCam.scr"];
		[mailComposer addAttachmentData:tap mimeType:@"application/octet-stream" fileName:@"zxCam.tap"];
		
		[rootViewController.infoButton removeFromSuperview];
		[rootViewController presentViewController:mailComposer animated:YES completion: nil];
	}
}

-(void)pickImage:(UIImagePickerControllerSourceType)pickType
{
	if(pickType == UIImagePickerControllerSourceTypePhotoLibrary || pickType == UIImagePickerControllerSourceTypeCamera) {
		
		if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			cameraButton.enabled = NO;
		}
		UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        
		//imagePicker.allowsImageEditing = YES;
		imagePicker.delegate = self;
		imagePicker.sourceType = pickType;
		
		[rootViewController.infoButton removeFromSuperview];
        [rootViewController presentViewController:imagePicker animated:YES completion:nil];
	}
}

#pragma mark Image picker delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// Spectrum resolution.
	CGSize size;
	size.height = 192;
	size.width = 256;
	
    UIImage* img = info[@"UIImagePickerControllerEditedImage"];
	if(img == nil)
    {
        img = info[@"UIImagePickerControllerOriginalImage"];
    }
    macView.image = [img imageByScalingAndCroppingForSize:size];
    
	// Resize the image to Spectrum resolution.
	//UIGraphicsBeginImageContext(size);
	//[img drawInRect:CGRectMake(0, 0, size.width, size.height)];
	//macView.image = UIGraphicsGetImageFromCurrentImageContext();
	
	// Important to save prefernces. The OS might have unloaded the main view. 
	// When it is reloaded it will load the image from the preferences.
	// So make sure the preferences are up to date first.
	[self savePreferences];
	
	//UIGraphicsEndImageContext();
	//[[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];

	[rootViewController.view insertSubview:rootViewController.infoButton aboveSubview:self.view];
	[self updateSpectrumView];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[rootViewController.view insertSubview:rootViewController.infoButton aboveSubview:self.view];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];

	//[[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[rootViewController.view insertSubview:rootViewController.infoButton aboveSubview:self.view];
	[rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Tape player delegate
-(void)tapePlayerDismissed:(TapePlayerViewController*)tapePlayer
{
	[rootViewController.view insertSubview:rootViewController.infoButton aboveSubview:self.view];
}

#pragma mark Preferences
-(void)loadPreferences
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	ConverterBase* ditherer = [converterManager converter:[defaults objectForKey:@"ditherMode"]];	
	if(ditherer) {
		[converterManager setCurrentDitherer:ditherer];
	}
	
	NSData* imageData = [defaults objectForKey:@"image"];
	UIImage* image = [UIImage imageWithData:imageData];
	macView.image = image;
	
	NSNumber* red = [defaults objectForKey:@"red"];
	NSNumber* green = [defaults objectForKey:@"green"];
	NSNumber* blue = [defaults objectForKey:@"blue"];
	NSNumber* posterise = [defaults objectForKey:@"posterise"];
	NSNumber* monochrome = [defaults objectForKey:@"monochrome"];
	
	NSMutableDictionary* preprocessParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												 red, @"red",
												 green, @"green",
												 blue, @"blue",
												 posterise, @"posterise",
												 monochrome, @"monochrome",
												 nil];
	
	[[converterManager converter:@"preprocess"] setParameters: preprocessParameters];
	[brightness setValue:[red floatValue]];
	[self updateSpectrumView];
}

-(void)savePreferences
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	NSDictionary* preprocessParameters = [[converterManager converter:@"preprocess"] parameters];
	[defaults setObject:preprocessParameters[@"red"] forKey:@"red"];
	[defaults setObject:preprocessParameters[@"green"] forKey:@"green"];
	[defaults setObject:preprocessParameters[@"blue"] forKey:@"blue"];
	[defaults setObject:preprocessParameters[@"posterise"] forKey:@"posterise"];
	[defaults setObject:preprocessParameters[@"monochrome"] forKey:@"monochrome"];
	[defaults setObject:[[converterManager currentDitherer] mode] forKey:@"ditherMode"];
	
	if(macView.image) {
		NSData* png = UIImagePNGRepresentation(macView.image);
		[defaults setObject:png forKey:@"image"];
	}
	[defaults synchronize];
}

#pragma mark Spectrum view tweaking
-(void)updateSpectrumView
{
	if(macView.image) {
		
		[brightness setHidden:NO];
		[minBrightness setHidden:NO];
		[maxBrightness setHidden:NO];
		
		NSDictionary* preprocessParameters = @{@"red": [NSNumber numberWithInt:[brightness value]],
											  @"green": [NSNumber numberWithInt:[brightness value]],
											  @"blue": [NSNumber numberWithInt:[brightness value]]};
		[[converterManager converter:@"preprocess"] setParameters:preprocessParameters];
		
		// Set the image, and close the picker.
		CGImageRef preprocessed = [[converterManager converter:@"preprocess"] convert:[macView.image CGImage]];
		CGImageRef dithered = [[converterManager currentDitherer] convert:preprocessed];
		CGImageRef clashed = [[converterManager converter:@"zx"] convert:dithered];
		
		spectrumView.image = [UIImage imageWithCGImage:clashed];
		rect = [spectrumView frame];
	}
}

-(void)brightnessChanged:(id)sender
{
	[self updateSpectrumView];
}

#pragma mark Twitter
-(IBAction)twitter:(id)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterViewController setInitialText:@"#zxcam"];
        [twitterViewController addImage:spectrumView.image];
        
        [rootViewController presentViewController:twitterViewController animated:YES completion:nil];
    }
}


#pragma mark Flickr
-(IBAction)flickr:(id)sender
{
	flickrButton.hidden = YES;
	flickrSpinner.hidden = NO;
	[flickrSpinner startAnimating];
	
	if(![[[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName] length]) {
		NSURL* url = [flickr loginURLFromFrobDictionary:nil requestedPermission:OFFlickrWritePermission];
		NSLog(@"%@", [url description]);
		[[UIApplication sharedApplication] openURL:url];
	} else {
		[self upload:spectrumView.image];
	}
}

-(IBAction)flickrReset:(id)sender
{
	[self setAndStoreFlickrAuthToken:nil];
}

-(void)flickrAuthenticate:(NSURL*)url
{
	NSString* query = [url query];
	NSRange range = [query rangeOfString:@"="];
	NSString* frob = [query substringFromIndex:range.location + 1];
	
	OFFlickrAPIRequest* request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr];
	[request setDelegate:self];
	request.sessionInfo = kGetAuthTokenStep;
	[request callAPIMethodWithGET:@"flickr.auth.getToken" arguments:@{@"frob": frob}];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest*)inRequest didCompleteWithResponse:(NSDictionary*)inResponseDictionary
{	
	if(inRequest.sessionInfo == kGetAuthTokenStep) {
		flickrButton.hidden = NO;
		flickrSpinner.hidden = YES;
		[flickrSpinner stopAnimating];
		[self setAndStoreFlickrAuthToken:[[inResponseDictionary valueForKeyPath:@"auth.token"] textContent]];
		[self flickr:nil];
		//self.flickrUserName = [inResponseDictionary valueForKeyPath:@"auth.user.username"];
	} else if(inRequest.sessionInfo == kUploadImageStep) {
		OFFlickrAPIRequest* request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr];
		[request setDelegate:self];
		request.sessionInfo = kSetGroupStep;
		NSDictionary* photoIdNode = inResponseDictionary[@"photoid"];
		NSString* photoId = (NSString*)photoIdNode[OFXMLTextContentKey];
		[request callAPIMethodWithPOST:@"flickr.groups.pools.add" arguments:@{@"photo_id": photoId,
																			@"group_id": kGroupId}];
		
		// Play the upload sound here. We've still got to try and add to the ZxCam group, but that might fail if
		// we're not members. The picture is uploaded and that's what matters!
		AudioServicesPlaySystemSound(soundID);
	} else if(inRequest.sessionInfo == kSetGroupStep) {
		flickrButton.hidden = NO;
		flickrSpinner.hidden = YES;
		[flickrSpinner stopAnimating];
	}
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest*)inRequest didFailWithError:(NSError*)inError
{
	flickrButton.hidden = NO;
	flickrSpinner.hidden = YES;
	[flickrSpinner stopAnimating];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest*)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
	//NSLog(@"Flickr API request sent bytes");
}

-(void)setAndStoreFlickrAuthToken:(NSString*)inAuthToken
{
	if (![inAuthToken length]) {
		flickr.authToken = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenKeyName];
	}
	else {
		flickr.authToken = inAuthToken;
		[[NSUserDefaults standardUserDefaults] setObject:inAuthToken forKey:kStoredAuthTokenKeyName];
	}
	[self savePreferences];
}

-(void)upload:(UIImage*)image
{
    NSData* data = UIImagePNGRepresentation(image);
	
	OFFlickrAPIRequest* request = [[OFFlickrAPIRequest alloc] initWithAPIContext:flickr];
	[request setDelegate:self];
    request.sessionInfo = kUploadImageStep;
    [request uploadImageStream:[NSInputStream inputStreamWithData:data] 
			 suggestedFilename:@"Taken with ZxCam" 
			 MIMEType:@"image/png" 
			 arguments:@{@"is_public": @"1",
						@"tags": @"zxcam", 
						@"description": @"<A HREF=\"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=326164647\">Taken with ZxCam</A>"}];
}

#pragma mark Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex != actionSheet.cancelButtonIndex) {
		if(buttonIndex == 0) {
			[self photoLibrary];
		} else if(buttonIndex == 1) {
			[self mail];
		} else if(buttonIndex == 2) {
			[self twitter:nil];
        } else if(buttonIndex == 3) {
			[self flickr:nil];
		} else {
			assert(0);
		}
	}
}

#pragma mark Reachability
-(void)checkNetworkStatus:(NSNotification*)notice
{
	NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
	switch (internetStatus)
	
	{
		case NotReachable:
		{
			NSLog(@"The internet is down.");
			internetActive = NO;
			
			break;
			
		}
		case ReachableViaWiFi:
		{
			NSLog(@"The internet is working via WIFI.");
			internetActive = YES;
			
			break;
			
		}
		case ReachableViaWWAN:
		{
			NSLog(@"The internet is working via WWAN.");
			internetActive = YES;
			
			break;
			
		}
	}
	
	NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
	switch (hostStatus)
	
	{
		case NotReachable:
		{
			NSLog(@"A gateway to the host server is down.");
			hostActive = NO;
			
			break;
			
		}
		case ReachableViaWiFi:
		{
			NSLog(@"A gateway to the host server is working via WIFI.");
			hostActive = YES;
			
			break;
			
		}
		case ReachableViaWWAN:
		{
			NSLog(@"A gateway to the host server is working via WWAN.");
			hostActive = YES;
			
			break;
			
		}
	}
	flickrButton.enabled = hostActive;
}

#pragma mark dealloc
- (void)dealloc
{
	AudioServicesDisposeSystemSoundID(soundID);
	soundID = 0;
}

@end
