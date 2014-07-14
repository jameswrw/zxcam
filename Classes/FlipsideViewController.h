//
//  FlipsideViewController.h
//  zxcam
//
//  Created by James Weatherley on 30/06/2009.
//  Copyright James Weatherley 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JWConverterManager;


@interface FlipsideViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {

	UIPickerView* picker;
	UITableView* tableView;
	IBOutlet JWConverterManager* converterManager;
	
	UITableViewCell* posteriseCell;
    UITableViewCell* monochromeCell;
	UITableViewCell* colourCell;
    
	UISwitch* posteriseSwitch;
	UISwitch* monochromeSwitch;
	
	IBOutlet UIButton* flickrButton;
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView;
-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component;
-(NSString *)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;


-(IBAction)posteriseAction:(UISwitch*)sender;
-(IBAction)monochromeAction:(UISwitch*)sender;
-(IBAction)colourAction:(UIButton*)sender;
-(IBAction)joinZxCam:(UIButton*)sender;

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath;


@property (nonatomic, retain) IBOutlet UIPickerView* picker;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* posteriseCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* monochromeCell;
@property (nonatomic, retain) IBOutlet UISwitch* posteriseSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* monochromeSwitch;

@end
