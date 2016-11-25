//
//  WaveRecViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LoopPlayer.h"

@class HexaphoneAppDelegate;

@interface WaveRecViewController : UIViewController <AVAudioPlayerDelegate> {

	HexaphoneAppDelegate* appDelegate;
	AVAudioPlayer* previewPlayer;
	
	IBOutlet UIImageView* backgroundImage;
	
	IBOutlet UIButton* waveRecSourceRecButton;
	IBOutlet UIButton* waveRecSourceLiveButton;

	IBOutlet UIButton* waveRecRecIterMinusButton;
	IBOutlet UIButton* waveRecRecIterPlusButton;
	int recIterCount;
	int recItersElapsed;
	float oldLoopVolume;
	
	IBOutlet UILabel* waveRecIterCountLabel;

	IBOutlet UIButton* waveRecCaptureButton;

	IBOutlet UIButton* waveRecPreviewButton;

	IBOutlet UIButton* waveRecExportButton;

	IBOutlet UIButton* closeButton;

}

@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;

@property (retain, nonatomic) IBOutlet UIImageView* backgroundImage;

@property (retain, nonatomic) IBOutlet UIButton* waveRecSourceRecButton;
@property (retain, nonatomic) IBOutlet UIButton* waveRecSourceLiveButton;

@property (retain, nonatomic) IBOutlet UIButton* waveRecRecIterMinusButton;
@property (retain, nonatomic) IBOutlet UIButton* waveRecRecIterPlusButton;
@property (retain, nonatomic) IBOutlet UILabel* waveRecIterCountLabel;

@property (retain, nonatomic) IBOutlet UIButton* waveRecCaptureButton;

@property (retain, nonatomic) IBOutlet UIButton* waveRecPreviewButton;

@property (retain, nonatomic) IBOutlet UIButton* waveRecExportButton;

@property (retain, nonatomic) IBOutlet UIButton* closeButton;

-(void) resetState;
-(IBAction) chooseSourceRec;
-(IBAction) chooseSourceLive;
-(IBAction) decreaseRecIter;
-(IBAction) increaseRecIter;
-(IBAction) captureWaveToggle;
-(IBAction) previewWaveToggle;
-(IBAction) exportWave;

-(void) prepareView;
-(IBAction) closeView;

-(IBAction) testButtonPress:(id)sender;

-(void) updateRecIterCountLabel;
-(void) recIterated;

- (void)startPreview;
- (void)stopPreview;

@end
