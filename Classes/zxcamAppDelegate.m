//
//  zxcamAppDelegate.m
//  zxcam
//
//  Created by James Weatherley on 30/06/2009.
//  Copyright James Weatherley 2009. All rights reserved.
//

#import "zxcamAppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"

@implementation zxcamAppDelegate


@synthesize window;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    window.rootViewController = rootViewController;
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
	[[rootViewController mainViewController] savePreferences];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL*)url
{
	[[rootViewController mainViewController] flickrAuthenticate:url];
	return YES;
}

@end
