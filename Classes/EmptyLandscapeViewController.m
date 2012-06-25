//
//  EmptyLandscapeViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EmptyLandscapeViewController.h"

#import "CompatibleApps.h"
#import "AudioCopyPaste.h"

@implementation EmptyLandscapeViewController

@synthesize tempoForExport;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;
}

- (id)init {
    self = [super init];
	
    if (self) {
		self.view.userInteractionEnabled = NO;
		self.tempoForExport = 0;
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//TODO: Must call these functions for AudioCopyPaste
	[[CompatibleApps sharedInstance] refresh];
	[AudioCopyPaste initPasteBoard];  
}

-(IBAction)launchSongTools {
	NSLog(@"ELVC: launchSongTools BEGIN");

	if(!songToolsMainController)
	{
		/*
		 You may need to adjust this code to work with your view orientation and size.  If you have any problems, contact mapi@sonomawireworks.com
		 There are two SongTools.xib files in the MAPI SDK. One is for landscape mode and the other is for portrait. Only include one SongTools.xib in your
		 project, otherwise XCode will get confused. If your app must use both Portrait and Landscape orientation when displaying the Tools Overlay, contact us 
		 and we'll try and assist you with a solution. 
		 */
		// Make song tools view and add it to the holder.
		songToolsMainController = [[SongToolsMainController alloc] initWithNibName:@"SongTools" bundle:nil];
		songToolsMainController.view.center = CGPointMake(480/2, 320/2);
		[self.view addSubview:songToolsMainController.view];
		
		// Add all song tools
		NSMutableArray *tools = [NSMutableArray arrayWithObjects:
								 [[[SongToolFactory alloc] initWithClass:[AudioCopyTool class] name:@"AudioCopy" andIcon:[UIImage imageNamed:@"audiocopy_icon.png"] delegate:self] autorelease],
								 nil];
		
		[songToolsMainController addSongTools:tools];
		// Set the songtools delegate if you need callbacks for animation start and stop
		songToolsMainController.songtoolsdelegate = self;
	}
	

	[self.view bringSubviewToFront:songToolsMainController.view];
	songToolsMainController.view.hidden = YES;
	[songToolsMainController showWithAnimation];	
	
}
-(void)setupSongTools {
	NSLog(@"ELVC: setupSongTools BEGIN");
}

//TODO: Must implement these AudioCopyDelegate Functions to use AudioCopy	
#pragma mark AudioCopyDelegate

/*
 The file path for your wave file to be copied.
 The wave file must be an uncompressed 44.1kHz-16bit file in either mono or stereo.
 This file should NOT be altered during the AudioCopy process.
 */
- (NSString *)pathForAudioCopy:(id)sender{
	NSString *file_path = [NSString stringWithFormat:@"%@/hexaphone-export.wav", DOCUMENTS_FOLDER];
	return file_path;
}

// The Bundle Display Name of your app
- (NSString*)getSenderForAudioCopy:(id)sender{
	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];;
	NSString *displayname = [NSString stringWithFormat:@"CFBundleDisplayName"];
	NSString *senderval = [info objectForKey:displayname];
	return senderval;
}

/*
 The Tempo of your audio in integer (120).
 Return 0 if Tempo is not applicable.
 */
- (int)getTempoForAudioCopy:(id)sender{
	return tempoForExport;
}

// If your audio file should be rendered before it is copied, return YES;
- (BOOL)shouldRenderForAudioCopy:(id)sender{
	return NO;
}

// Return the render progress from 0.0f to 1.0f
- (float)getRenderProgressForAudioCopy:(id)sender{
	return 1.0f;
}

// When rendering has completed, this should return YES
- (BOOL)isRenderDoneForAudioCopy:(id)sender{
	return YES;
}

//TODO: Implement these AudioCopy Delegate Functions for previewing in the AudioCopy/Paste Tool
#pragma mark AudioCopyDelegate - Optional

//If your audio is currently playing, return YES
- (BOOL)isPlayingForAudioCopy:(id)sender{
	return mIsPlaying;
}

/*
 Start playback of your audio here for the AudioCopy Preview button.
 This app uses the AVAudioPlayer to play wave files, but your app might use RemoteIO or AudioQueueServices
 Change these functions accordingly.
 */
- (void)playForAudioCopy:(id)sender{
	if (mAudioPlayer)
	{
		[mAudioPlayer stop];
		[mAudioPlayer release];
		mAudioPlayer = nil;
	}
	CFStringRef fileString = (CFStringRef) [NSString stringWithFormat:@"%@/hexaphone-export.wav", DOCUMENTS_FOLDER];
	// create the file URL that identifies the file that the recording audio queue object records into
	CFURLRef fileURL =	CFURLCreateWithFileSystemPath (NULL,fileString,kCFURLPOSIXPathStyle,false);
	mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:(NSURL*)fileURL error:nil];
	mAudioPlayer.delegate = self; 
	[mAudioPlayer prepareToPlay];
	[mAudioPlayer play];
	mIsPlaying = YES;
	[self updateButtonStates];
	CFRelease(fileURL);
}

/*
 Stop playback of your audio here for the AudioCopy Preview button.
 This app uses the AVAudioPlayer to play wave files, but your app might use RemoteIO or AudioQueueServices
 Change these functions accordingly.
 */
- (void)stopForAudioCopy:(id)sender{
	if (mAudioPlayer)
	{
		[mAudioPlayer stop];
		[mAudioPlayer release];
		mAudioPlayer = nil;
		mIsPlaying = NO;
		[self updateButtonStates];
	}
}


//TODO: Implement the SongToolsDelegate functions if you need callbacks for Song Tools animation begin and end
/*
 If you have set the mSongTools.songtoolsdelegate = self, then you need to implement these functions
 */
#pragma mark SongToolsDelegate
- (void)songToolsWillAppear
{
	self.view.userInteractionEnabled = YES;
}

- (void)songToolsWillDisappear
{
	self.view.userInteractionEnabled = NO;
}

- (void)songToolsDidDisappear
{
}


-(void) updateButtonStates {
	// do nothing
}

@end
