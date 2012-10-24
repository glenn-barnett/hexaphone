//
//  AudioCopyTool.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "AppsTableView.h"
#import "AudioCopyPaste.h"
#import "AudioCopyProgress.h"
#import "CompatibleApps.h"
#import	"CopyDoneView.h"
#import "loopCopy.h"
#import "SimpleSettingCell.h"
#import "SongToolFactory.h"
#import "SongToolViewControllerBase.h"

@protocol AudioCopyDelegate
- (NSString *)pathForAudioCopy:(id)sender;
- (NSString*)getSenderForAudioCopy:(id)sender;
- (int)getTempoForAudioCopy:(id)sender;
- (BOOL)shouldRenderForAudioCopy:(id)sender;
- (float)getRenderProgressForAudioCopy:(id)sender;
- (BOOL)isRenderDoneForAudioCopy:(id)sender;
@optional
- (BOOL)isPlayingForAudioCopy:(id)sender;
- (void)playForAudioCopy:(id)sender;
- (void)stopForAudioCopy:(id)sender;
@end

@interface AudioCopyTool : SongToolViewControllerBase <AVAudioPlayerDelegate, AppsTableViewDelegate>
{		
	SongToolPanelBase			*mContainer;
	UIView						*mMainView;
	CopyDoneView				*mCopyDoneView;
	AudioCopyProgress			*mProgressView;
	LoopCopy 					*mLoopCopy;
	UIButton 					*mCopyAudioButton;
	UIButton 					*mPreviewButton;
	UIButton 					*mNoAudioToCopyButton;
	BOOL 						mPlaying;
	BOOL 						mInterruptedOnPlayback;
	id<AudioCopyDelegate>		mAudioCopyDelegate;
	AVAudioPlayer 				*mAppSoundPlayer;
	NSString 					*mAudioCopyPath;
	NSTimer						*mTimer;
	UITextField					*mCopyNameField;
	NSString					*mCopyName;
}

@property (nonatomic, retain) IBOutlet SongToolPanelBase *toolPanel;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet CopyDoneView *copyDoneView;
@property (nonatomic, retain) IBOutlet AudioCopyProgress *progressView;
@property (nonatomic, retain) IBOutlet UIButton *noAudioToCopyButton;
@property (nonatomic, retain) IBOutlet UIButton *copyAudioButton;
@property (nonatomic, retain) IBOutlet UIButton *previewButton;
@property (nonatomic, retain) IBOutlet UITextField *copyNameField;
@property (readwrite) BOOL playing;
@property (readwrite) BOOL interruptedOnPlayback;
@property (nonatomic, retain) AVAudioPlayer *appSoundPlayer;

- (IBAction)donePressed;
- (IBAction)showCompatibleApps;
- (IBAction)previewSoundPressed;
- (IBAction)audioCopyPressed:(id)sender;
- (void)hideKeyboard;

@end
