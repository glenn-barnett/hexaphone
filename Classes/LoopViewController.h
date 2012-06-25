//
//  LoopViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HexaphoneAppDelegate;
@class LoopPlayer;

@interface LoopViewController : UIViewController {
	HexaphoneAppDelegate* appDelegate;
	BOOL isShown;
	LoopPlayer* loopPlayer;
	IBOutlet UIButton* loopDropdownButton;
	IBOutlet UIButton* autoTuneButton;
	IBOutlet UIButton* loopToggleButton;
	IBOutlet UIButton* recToggleButton;
}

@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;
@property (nonatomic, retain) LoopPlayer* loopPlayer;
@property (nonatomic, retain) IBOutlet UIButton* loopDropdownButton;
@property (nonatomic, retain) IBOutlet UIButton* autoTuneButton;
@property (nonatomic, retain) IBOutlet UIButton* loopToggleButton;
@property (nonatomic, retain) IBOutlet UIButton* recToggleButton;

-(IBAction) changeLoop:(id) sender;
-(IBAction) stop:(id) sender;
-(IBAction) toggleLoop:(id) sender;
-(IBAction) toggleRec:(id) sender;
-(IBAction) loadRecommendation;

-(IBAction) slideInView;
-(IBAction) slideOutView;
-(void) hideView;

@end
