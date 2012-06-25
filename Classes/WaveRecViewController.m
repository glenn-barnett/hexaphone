//
//  WaveRecViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WaveRecViewController.h"
#import "UIConstants.h"
#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "EmptyLandscapeViewController.h"
#import "RecViewController.h"
#import "RecordingPlayer.h"
#import "Loop.h"


@implementation WaveRecViewController

@synthesize appDelegate;

@synthesize backgroundImage;

@synthesize waveRecSourceRecButton;
@synthesize waveRecSourceLiveButton;

@synthesize waveRecRecIterMinusButton;
@synthesize waveRecRecIterPlusButton;
@synthesize waveRecIterCountLabel;

@synthesize waveRecCaptureButton;

@synthesize waveRecPreviewButton;

@synthesize waveRecExportButton;

@synthesize closeButton;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	recIterCount = 1;
	[self updateRecIterCountLabel];

	// can't set selected+highlighted state in IB
	[waveRecSourceRecButton		setImage:[UIImage imageNamed:@"waverec-b-1rec-on.png"]	forState:UIControlStateSelected|UIControlStateHighlighted];
	[waveRecSourceLiveButton	setImage:[UIImage imageNamed:@"waverec-b-1live-on.png"]	forState:UIControlStateSelected|UIControlStateHighlighted];
	[waveRecCaptureButton		setImage:[UIImage imageNamed:@"waverec-b-2-on.png"]		forState:UIControlStateSelected|UIControlStateHighlighted];
	[waveRecPreviewButton		setImage:[UIImage imageNamed:@"waverec-b-3-on.png"]		forState:UIControlStateSelected|UIControlStateHighlighted];
	[waveRecExportButton		setImage:[UIImage imageNamed:@"waverec-b-4-on.png"]		forState:UIControlStateSelected|UIControlStateHighlighted];
	
}


typedef enum {
	k0Initial, // 1a 1b !2 !3 !4
	k1aSourceRec, // 2 !3 !4
	k1bSourceLive, // 2 !3 !4
	k2a1Capturing, // 2* 3 4
	k2b1Capturing, // 2* 3 4
	k2a2Captured,  // 2 3 4
	k2b2Captured,  // 2 3 4
	k3aPreviewing, // 2 3* 4
	k3bPreviewing  // 2 3* 4
} WaveRecState;

-(BOOL) isSourceRec {
	return waveRecSourceRecButton.selected;
}
-(BOOL) isSourceLive {
	return waveRecSourceLiveButton.selected;
}

-(BOOL) isCapturing {
	return waveRecCaptureButton.selected;
}

-(BOOL) isPreviewing {
	return waveRecPreviewButton.selected;
}

-(void) implementState:(WaveRecState) state {
	// initial / default
	waveRecSourceRecButton.selected = NO;
	waveRecSourceLiveButton.selected = NO;
	waveRecIterCountLabel.textColor = UIColorFromRGB(0xFF555555);
	waveRecCaptureButton.enabled = NO;
	waveRecCaptureButton.selected = NO;
	waveRecPreviewButton.enabled = NO;
	waveRecPreviewButton.selected = NO;
	waveRecExportButton.enabled = NO;
	waveRecExportButton.selected = NO;
	

	switch (state) {
		case k0Initial:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg.png"];
			break;
		case k1aSourceRec:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-1a.png"];
			waveRecSourceRecButton.selected = YES;
			waveRecIterCountLabel.textColor = UIColorFromRGB(0xFFD45E53);
			waveRecCaptureButton.enabled = YES;
			break;
		case k1bSourceLive:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-1b.png"];
			waveRecSourceLiveButton.selected = YES;
			waveRecCaptureButton.enabled = YES;
			break;
		case k2a1Capturing:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-1a.png"];
			waveRecSourceRecButton.selected = YES;
			waveRecIterCountLabel.textColor = UIColorFromRGB(0xFFD45E53);
			waveRecCaptureButton.enabled = YES;
			waveRecCaptureButton.selected = YES;
			break;
		case k2b1Capturing:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-1b.png"];
			waveRecSourceLiveButton.selected = YES;
			waveRecCaptureButton.enabled = YES;
			waveRecCaptureButton.selected = YES;
			break;
		case k2a2Captured:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-3a.png"];
			waveRecSourceRecButton.selected = YES;
			waveRecIterCountLabel.textColor = UIColorFromRGB(0xFFD45E53);
			waveRecCaptureButton.enabled = YES;
			waveRecPreviewButton.enabled = YES;
			waveRecExportButton.enabled = YES;
			break;
		case k2b2Captured:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-3b.png"];
			waveRecSourceLiveButton.selected = YES;
			waveRecCaptureButton.enabled = YES;
			waveRecPreviewButton.enabled = YES;
			waveRecExportButton.enabled = YES;
			break;
		case k3aPreviewing:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-3a.png"];
			waveRecSourceRecButton.selected = YES;
			waveRecIterCountLabel.textColor = UIColorFromRGB(0xFFD45E53);
			waveRecCaptureButton.enabled = YES;
			waveRecPreviewButton.enabled = YES;
			waveRecPreviewButton.selected = YES;
			waveRecExportButton.enabled = YES;
			break;
		case k3bPreviewing:
			backgroundImage.image = [UIImage imageNamed:@"waverec-bg-3b.png"];
			waveRecSourceLiveButton.selected = YES;
			waveRecCaptureButton.enabled = YES;
			waveRecPreviewButton.enabled = YES;
			waveRecPreviewButton.selected = YES;
			waveRecExportButton.enabled = YES;
			break;
		default:
			break;
	}
}

-(void) resetState {
	
	NSLog(@"WRVC: resetState");
	
	[self implementState:k0Initial];
	
	if([self isCapturing]) {
		[self captureWaveToggle];
	}
	if([self isPreviewing]) {
		[self stopPreview];
	}
	
	
}

-(IBAction) chooseSourceRec {
	if(![self isSourceRec]) {
		if(![self isCapturing]) {
			[self captureWaveToggle];
		}
		[self implementState:k1aSourceRec];
		if(appDelegate.loopPlayer.activeLoop != nil) {
			appDelegate.emptyLandscapeViewController.tempoForExport = [appDelegate.loopPlayer.activeLoop.bpm intValue];
		} else {
			appDelegate.emptyLandscapeViewController.tempoForExport = 0;
		}
	}
}
-(IBAction) chooseSourceLive {
	if(![self isSourceLive]) {
		if(![self isCapturing]) {
			[self captureWaveToggle];
		}
		[self implementState:k1bSourceLive];
		appDelegate.emptyLandscapeViewController.tempoForExport = 0;
	}
}
-(IBAction) decreaseRecIter {
	if(recIterCount > 1) {
		recIterCount /= 2;
	}
	[self updateRecIterCountLabel];
}
-(IBAction) increaseRecIter {
	if(recIterCount < 32) {
		recIterCount *= 2;
	}
	[self updateRecIterCountLabel];
}

-(void) recIterated {
	if([self isCapturing] && [self isSourceRec]) {
		recItersElapsed++;
		
		if(recItersElapsed >= recIterCount) {
			[appDelegate.instrument stopRecordWavOut];
			[appDelegate.recordingPlayer stop];
			[appDelegate.loopPlayer stop];
			[self implementState:k2a2Captured];
		}
	}
}

-(IBAction) captureWaveToggle {
	if(![self isCapturing]) {
		// start

		if([self isSourceRec]) {
			recItersElapsed = 0;
			
			if(!appDelegate.recordingPlayer.repeatPlayback) {
				[appDelegate.recordingPlayer toggleRepeatPlayback];
			}
			[appDelegate.recordingPlayer togglePlayback];
			[appDelegate.instrument startRecordWavOut];
			[self implementState:k2a1Capturing];
		} else if([self isSourceLive]) {
			[appDelegate.instrument startRecordWavOut];
			[self implementState:k2b1Capturing];
		}
	} else {
		// stop

		[appDelegate.instrument stopRecordWavOut];
 		if([self isSourceRec]) {
			[self implementState:k2a2Captured];
		} else if([self isSourceLive]) {
			[self implementState:k2b2Captured];
		}
	}
}

-(IBAction) previewWaveToggle {
	if([self isCapturing]) {
		[appDelegate.instrument stopRecordWavOut];
	}
	
	if(![self isPreviewing]) {
		// start
		[self startPreview];
		if([self isSourceRec]) {
			[self implementState:k3aPreviewing];
		} else if([self isSourceLive]) {
			[self implementState:k3bPreviewing];
		}
	} else {
		// stop
		[self stopPreview];
		if([self isSourceRec]) {
			[self implementState:k2a2Captured];
		} else if([self isSourceLive]) {
			[self implementState:k2b2Captured];
		}
	}
}
-(IBAction) exportWave {
	if([self isCapturing]) {
		[self captureWaveToggle];
	}
	if([self isPreviewing]) {
		[self stopPreview];
	}

	if([self isSourceRec]) {
		[self implementState:k2a2Captured];
	} else if([self isSourceLive]) {
		[self implementState:k2b2Captured];
	}
	
	[appDelegate.emptyLandscapeViewController launchSongTools];
}

-(void) prepareView {
	
	oldLoopVolume = appDelegate.loopPlayer.loopVolume;
	[appDelegate.loopPlayer setLoopVolume:0.0f];
	[appDelegate.recordingPlayer stop];
	[appDelegate.loopPlayer stop];
}

-(IBAction) closeView {
	if([self isCapturing]) {
		[self captureWaveToggle];
	}
	if([self isPreviewing]) {
		[self stopPreview];
	}

	[appDelegate.recordingPlayer stop];
	[appDelegate.loopPlayer stop];
	[appDelegate.loopPlayer setLoopVolume:oldLoopVolume];
	[appDelegate.recViewController hideWavExportView];
}

-(void) updateRecIterCountLabel {
	waveRecIterCountLabel.text = [NSString stringWithFormat:@"x%d", recIterCount];
}


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


- (void)startPreview {
	NSLog(@"WaveRec: startPreview");
	if (previewPlayer)
	{
		[previewPlayer stop];
		[previewPlayer release];
		previewPlayer = nil;
	}
	CFStringRef fileString = (CFStringRef) [NSString stringWithFormat:@"%@/hexaphone-export.wav", DOCUMENTS_FOLDER];
	// create the file URL that identifies the file that the recording audio queue object records into
	CFURLRef fileURL =	CFURLCreateWithFileSystemPath (NULL,fileString,kCFURLPOSIXPathStyle,false);
	previewPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:(NSURL*)fileURL error:nil];
	previewPlayer.delegate = self; 
	[previewPlayer prepareToPlay];
	[previewPlayer play];
	CFRelease(fileURL);
}

/*
 Stop playback of your audio here for the AudioCopy Preview button.
 This app uses the AVAudioPlayer to play wave files, but your app might use RemoteIO or AudioQueueServices
 Change these functions accordingly.
 */
- (void)stopPreview {
	NSLog(@"WaveRec: stopPreview");
	[self audioPlayerDidFinishPlaying:previewPlayer successfully:YES];
	if (previewPlayer)
	{
		[previewPlayer stop];
		[previewPlayer release];
		previewPlayer = nil;
	}

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	NSLog(@"WaveRec: audioPlayerDidFinishPlaying");
	
	if([self isSourceRec]) {
		[self implementState:k2a2Captured];
	} else if([self isSourceLive]) {
		[self implementState:k2b2Captured];
	}
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
