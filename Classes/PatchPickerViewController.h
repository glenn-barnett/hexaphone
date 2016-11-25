//
//  PatchTableViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HexaphoneAppDelegate;
@class Patch;

@interface PatchPickerViewController : UITableViewController {

	
	HexaphoneAppDelegate* appDelegate;
	
	UITableView *tableView;
	UIImageView *imageView;
}

@property (retain, nonatomic) HexaphoneAppDelegate* appDelegate;

//@property (nonatomic, retain) IBOutlet UITableView *tableView;
//@property (nonatomic, retain) IBOutlet UIImageView *imageView;

-(void) show;
-(void) hide;
-(Patch*) getRecentPatch:(int) index;

@end
