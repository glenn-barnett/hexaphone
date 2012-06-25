//
//  UpperViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HexaphoneAppDelegate;
@class Instrument;
@class SurfaceViewController;
@class PatchViewController;
@class Loop;

@interface UpperViewController : UIViewController {
	HexaphoneAppDelegate* appDelegate;

	Instrument* instrument;
	SurfaceViewController* surfaceViewController;

	UInt16 activePreset;
	

	IBOutlet UIButton* helpButton;
	IBOutlet UIButton* recordToggleButton;
	IBOutlet UIButton* loopToggleButton;
	IBOutlet UIButton* loopButton;
	IBOutlet UIButton* patchButton;
	IBOutlet UIButton* menuButton;

	IBOutlet UILabel* recDisplayLabel;
	IBOutlet UILabel* loopDisplayLabel;
	IBOutlet UILabel* messageLabel;

	IBOutlet UIImageView* iconRecRec;
	IBOutlet UIImageView* iconRecPending;
	IBOutlet UIImageView* iconLoopPlay;
	
	IBOutlet UIButton* recordWavOutButton;

}

@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;
@property (nonatomic, retain) Instrument *instrument;
@property (nonatomic, retain) SurfaceViewController *surfaceViewController;

@property (nonatomic, retain) IBOutlet UIButton *helpButton;
@property (nonatomic, retain) IBOutlet UIButton *recordToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *loopToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *loopButton;
@property (nonatomic, retain) IBOutlet UIButton *patchButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UILabel *recDisplayLabel;
@property (nonatomic, retain) IBOutlet UILabel *loopDisplayLabel;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UIImageView* iconRecRec;
@property (nonatomic, retain) IBOutlet UIImageView* iconRecPending;
@property (nonatomic, retain) IBOutlet UIImageView* iconLoopPlay;
@property (nonatomic, retain) IBOutlet UIButton* recordWavOutButton;


-(IBAction) toggleRecording;
-(IBAction) toggleLoop;
-(IBAction) togglePatchView;
-(IBAction) toggleEffectsView;
-(IBAction) toggleMenuView;
-(IBAction) toggleLoopView;

-(IBAction) toggleRecordWavOut;
-(IBAction) promptForAudioCopy;


@end
