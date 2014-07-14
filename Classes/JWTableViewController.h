//
//  JWTableViewController.h
//  zxcam
//
//  Created by James Weatherley on 21/07/2009.
//  Copyright 2009 James Weatherley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JWConverterManager;


@interface JWTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

	UITableViewCell* posteriseCell;
    UITableViewCell* monochromeCell;
	
	IBOutlet JWConverterManager* converterManager;
}

@property (nonatomic, retain) IBOutlet UITableViewCell* posteriseCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* monochromeCell;

-(IBAction)posteriseAction:(UISwitch*)sender;
-(IBAction)monochromeAction:(UISwitch*)sender;

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section;
-(void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath;

@end
