//
//  FlipsideViewController.m
//  zxcam
//
//  Created by James Weatherley on 30/06/2009.
//  Copyright James Weatherley 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import "../JWSpectrumConverter/ConverterBase.h"
#import "../JWSpectrumConverter/JWConverterManager.h"

#import <SystemConfiguration/SystemConfiguration.h>


@implementation FlipsideViewController

@synthesize picker;
@synthesize tableView;
@synthesize posteriseCell;
@synthesize monochromeCell;
@synthesize posteriseSwitch;
@synthesize monochromeSwitch;


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	ConverterBase* ditherer = [converterManager currentDitherer];
	NSString* description = [ditherer description];
	NSInteger row = -1;
	if([description compare:@"COD Matrix (2x2)"] == NSOrderedSame) {
		row = 0;
	} else if([description compare:@"COD Matrix (4x4)"] == NSOrderedSame) {
		row = 1;
	} else if([description compare:@"COD Matrix (8x8)"] == NSOrderedSame) {
		row = 2;
    } else if([description compare:@"COD Magic"] == NSOrderedSame) {
		row = 3;
    } else if([description compare:@"COD Magic (Nasik)"] == NSOrderedSame) {
		row = 4;
	} else if([description compare:@"Floyd-Steinberg"] == NSOrderedSame) {
		row = 5;
	} else {
		assert(0);
	}
	[picker selectRow:row inComponent:0 animated:NO];
	
	NSDictionary* parameters = [[converterManager converter:@"preprocess"] parameters];
	BOOL posteriseOn = [parameters[@"posterise"] boolValue];
	[posteriseSwitch setOn:posteriseOn animated:NO];
	
	BOOL monochromeOn = [parameters[@"monochrome"] boolValue];
	[monochromeSwitch setOn:monochromeOn animated:NO];
	
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
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Picker delegates
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
	return 1; // Posterise; Dither mode; Mono/Colour
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger rows = 0;
	if(component == 0) {
		rows = 6;
	} else {
		assert(0);
	}
	return rows;
}

-(NSString *)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString* title = @"?";

	if(component == 0) {
		switch(row) {
			case 0:
				title = @"Colour Ordered 2x2";
				break;
			case 1:
				title = @"Colour Ordered 4x4";
				break;
			case 2:
				title = @"Colour Ordered 8x8";
				break;
            case 3:
				title = @"Colour Ordered Magic";
				break;
            case 4:
				title = @"Colour Ordered Magic (Nasik)";
				break;
			case 5:
				title = @"Floyd-Steinberg";
				break;
			default:
				assert(0);
		};
	} else {
		assert(0);
	}
	return title;
}

-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	assert(component == 0);
	switch(row) {
		case 0:
			[converterManager setCurrentDitherer:[converterManager converter:@"cod2"]];
			break;
		case 1:
			[converterManager setCurrentDitherer:[converterManager converter:@"cod4"]];
			break;
		case 2:
			[converterManager setCurrentDitherer:[converterManager converter:@"cod8"]];
			break;
        case 3:
			[converterManager setCurrentDitherer:[converterManager converter:@"magic"]];
			break;
        case 4:
			[converterManager setCurrentDitherer:[converterManager converter:@"nasik"]];
			break;
		case 5:
			[converterManager setCurrentDitherer:[converterManager converter:@"fs"]];
			break;
		default:
			assert(0);
	};
}

#pragma mark Switch actions
-(IBAction)posteriseAction:(UISwitch*)sender
{
	ConverterBase* preprocess = [converterManager converter:@"preprocess"];
	NSDictionary* oldParameters = [preprocess parameters];
	NSMutableDictionary* newParameters = [NSMutableDictionary dictionaryWithDictionary:oldParameters];
	newParameters[@"posterise"] = @([sender isOn]);
	[preprocess setParameters:newParameters];
}

-(IBAction)monochromeAction:(UISwitch*)sender
{
	ConverterBase* preprocess = [converterManager converter:@"preprocess"];
	NSDictionary* oldParameters = [preprocess parameters];
	NSMutableDictionary* newParameters = [NSMutableDictionary dictionaryWithDictionary:oldParameters];
	newParameters[@"monochrome"] = @([sender isOn]);
	[preprocess setParameters:newParameters];
}

-(IBAction)colourAction:(UIButton*)sender
{
    NSLog(@"Colour button!");
}

-(IBAction)joinZxCam:(UIButton*)sender
{
	NSURL* url = [NSURL URLWithString:@"http://www.flickr.com/groups_join.gne?id=1198815@N25"];
	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark Table delegates
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = 0;
	if(section == 0) {
		rows = 4;
    } else if(section == 1) {
        rows = 8;
	} else {
		assert(0);
	}
	return rows;
}


// Customize the appearance of table view cells.
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	NSUInteger row = indexPath.row;
	UITableViewCell* cell = nil;
	cell.editing = NO;
	
    if(indexPath.section == 0) {
        switch(row) {
            case 0:
                cell = posteriseCell;
                break;
            case 1:
                cell = monochromeCell;
                break;
            case 2:
                cell = [[UITableViewCell alloc] init];
                cell.textLabel.text = @"Paper";
                break;
            case 3:
                cell = [[UITableViewCell alloc] init];
                cell.textLabel.text = @"Ink";
                break;
            default:
                assert(0);
        }
    } else if(indexPath.section == 1) {
        cell = [colourCell copy];
        // !!!! Leak
    }
    else {
        assert(0);
    }
    
	return cell;
}

-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	NSLog(@"Tapped");
}

@end
