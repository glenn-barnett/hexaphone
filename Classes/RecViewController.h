//
//  MainMenuViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HexaphoneAppDelegate;
@class WaveRecViewController;

@interface RecViewController : UIViewController<UIActionSheetDelegate> {

	HexaphoneAppDelegate* appDelegate;
	WaveRecViewController* waveRecViewController;

	IBOutlet UIButton* recordingChooserButton;
	IBOutlet UILabel* recordingChooserLabel;
	IBOutlet UIButton* recordingFileOperationButton; // rename or delete
	IBOutlet UIButton* recordingPlaybackToggleButton; // play or stop
	IBOutlet UIButton* recordingPlaybackRepeatToggleButton; // play or stop
	IBOutlet UIButton* recordingWavExportButton;
	IBOutlet UIProgressView* recordingProgressView;
	IBOutlet UIImageView* recordingProgressImage;
	IBOutlet UIImageView* recordingPlayIcon;

	IBOutlet UIButton* lessonChooserButton;
	IBOutlet UIButton* lessonVideoButton; // rename or delete
	IBOutlet UIButton* lessonPlaybackToggleButton; // play or stop
	BOOL isShown;
	
	// checkbox: replace 'help' with 'record'

}

@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;
@property (nonatomic, retain) WaveRecViewController* waveRecViewController;
@property (nonatomic, retain) IBOutlet UIButton* recordingChooserButton;
@property (nonatomic, retain) IBOutlet UILabel* recordingChooserLabel;
@property (nonatomic, retain) IBOutlet UIButton* recordingFileOperationButton;
@property (nonatomic, retain) IBOutlet UIButton* recordingPlaybackToggleButton;
@property (nonatomic, retain) IBOutlet UIButton* recordingPlaybackRepeatToggleButton;
@property (nonatomic, retain) IBOutlet UIButton* recordingWavExportButton;
@property (nonatomic, retain) IBOutlet UIProgressView* recordingProgressView;
@property (nonatomic, retain) IBOutlet UIImageView* recordingProgressImage;
@property (nonatomic, retain) IBOutlet UIImageView* recordingPlayIcon;
@property (nonatomic, retain) IBOutlet UIButton* lessonChooserButton;
@property (nonatomic, retain) IBOutlet UIButton* lessonVideoButton;
@property (nonatomic, retain) IBOutlet UIButton* lessonPlaybackToggleButton;

-(IBAction) chooseRecording;
-(IBAction) performFileOperation;
-(IBAction) toggleRecordingPlayback;
-(IBAction) toggleRecordingRepeatPlayback;

-(IBAction) toggleRecording;
-(IBAction) toggleLoop;

-(IBAction) slideInView;
-(IBAction) slideOutView;
-(void) hideView;

-(IBAction) showWavExportView;
-(void) hideWavExportView;

@end
