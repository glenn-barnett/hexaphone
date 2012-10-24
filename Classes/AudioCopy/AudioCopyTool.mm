//
//  AudioCopyTool.mm
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "AudioCopyTool.h"
#import "AudioCopyBackView.h";
#import "CompatibleApps.h"
#import "SongToolsMainController.h"

#pragma mark -

@interface AudioCopyTool()
	
-(void)instantiateSoundPlayer;

@end

@implementation AudioCopyTool
@synthesize toolPanel = mContainer;
@synthesize mainView = mMainView;
@synthesize copyDoneView = mCopyDoneView;
@synthesize progressView = mProgressView;
@synthesize copyAudioButton = mCopyAudioButton;
@synthesize previewButton = mPreviewButton;
@synthesize noAudioToCopyButton = mNoAudioToCopyButton;
@synthesize playing = mPlaying;
@synthesize interruptedOnPlayback = mInterruptedOnPlayback;
@synthesize appSoundPlayer = mAppSoundPlayer;
@synthesize copyNameField = mCopyNameField;

#pragma mark -

- (id)initTool:(SongToolsMainController *)stmc delegate:(id)toolDelegate 
{
	if(self = [super initTool:stmc delegate:toolDelegate]){
		// This code snipet will load the views from the nib file
		NSArray* topLevelObjs = nil; 
		topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"AudioCopyTool" owner:self options:nil]; 
		if (topLevelObjs == nil) 
		{ 
			NSLog(@"Error! Could not load my Nib file.\n"); 
		}
														
		self.toolPanel.name = @"AudioCopy Panel";	// Give names to the tool panels
		[super addPanel:self.toolPanel];			// Add the tool panels to the view controller
		[super showPanel:0];					// Show the first tool panel by default]
        
		mAudioCopyPath = nil;
		Protocol *prot = @protocol(AudioCopyDelegate);
		if ([toolDelegate conformsToProtocol:prot])
		{
			mAudioCopyDelegate = toolDelegate;
			//check to see if we need to render
			if ([toolDelegate shouldRenderForAudioCopy:self])
			{
				[self setShowProgressPanel:YES withTitle:@"Rendering Audio..." withImage:nil];
				[self setModal:YES];
				[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateProgress:) userInfo:self repeats:YES];
			}
			else
			{
				[mAudioCopyPath release];
				mAudioCopyPath = [[toolDelegate pathForAudioCopy:self] retain];
				//nothing to copy
				if([mAudioCopyPath length] != 0)
				{
					self.noAudioToCopyButton.hidden = YES;
					self.previewButton.hidden = NO;
					self.copyAudioButton.hidden = NO;
				}
				else
				{
					self.noAudioToCopyButton.hidden = NO;
					self.previewButton.hidden = YES;
					self.copyAudioButton.hidden = YES;
				}
			}
		}
		
		if([mToolDelegate isPlayingForAudioCopy:self])
		{
			[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewpausebtn.png"] forState:UIControlStateNormal];
			if (mTimer)
			{
				[mTimer invalidate];
				mTimer = nil;
			}
			mTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(previewTimer:) userInfo:nil repeats:YES];
		}
		else
			[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewplaybtn.png"] forState:UIControlStateNormal];
		
					
		// Adjust the extended panel button position
		CGRect frame = mContainer.extendedPanelImage.frame;
		frame.origin.y += 8;
		mContainer.extendedPanelImage.frame = frame;
		frame = mContainer.extendedPanelButton.frame;
		frame.origin.y += 8;
		mContainer.extendedPanelButton.frame = frame;
		if (mAudioCopyDelegate)
			mCopyName = [mAudioCopyDelegate getSenderForAudioCopy:self];
		else
			mCopyName = @"AudioCopy";
		[mCopyName retain];
		// Setup the progress panel
		UIImageView *iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audiocopypaste_panel_bg.png"]] autorelease];
		iv.frame = CGRectMake(0, -4, iv.frame.size.width, iv.frame.size.height);
		self.progressPanel.backgroundView = iv;
		self.progressPanel.progressBarImage = [UIImage imageNamed:@"audiocopypaste_progress_bar.png"];
	}
	return self;
}

- (void)closeTool
{
	mCopyDoneView.tableView.delegate = nil;
	[(AudioCopyBackView*)mContainer.extendedPanel tableView].delegate = nil;
	[super closeTool];
}

- (void)updateProgress:(NSTimer*)theTimer
{
   if (![mAudioCopyDelegate isRenderDoneForAudioCopy:self])
    {
        self.progressPanel.progress = [mAudioCopyDelegate getRenderProgressForAudioCopy:self];
    }
    else
    {
	    [self setModal:NO];	
        [self setShowProgressPanel:NO withTitle:@"" withImage:nil];
        [theTimer invalidate];
		theTimer=nil;
		mAudioCopyPath = [mAudioCopyDelegate pathForAudioCopy:self];
		if (mAudioCopyPath)
			[mAudioCopyPath retain];
			//nothing to copy
		if([mAudioCopyPath length] != 0)
		{
			self.noAudioToCopyButton.hidden = YES;
			self.previewButton.hidden = NO;
			self.copyAudioButton.hidden = NO;
		}
		else
		{
			self.noAudioToCopyButton.hidden = NO;
			self.previewButton.hidden = YES;
			self.copyAudioButton.hidden = YES;
		}
		[mContainer bringSubviewToFront:mMainView];
    }
}

#pragma mark -
void MyAudioServicesSystemSoundCompletionProc (SystemSoundID ssID, void *clientData)
{
	AudioServicesDisposeSystemSoundID(ssID);
}

- (IBAction)audioCopyPressed:(id)sender{
	//must stop preview plaback before copy
	[mToolDelegate stopForAudioCopy:self];
	[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewplaybtn.png"] forState:UIControlStateNormal];
	
	[self setModal:YES];
	[mContainer bringSubviewToFront:mProgressView];
	[mProgressView.spinner startAnimating];
	
	// Build the audio metadata
	NSNumber* tempo = [NSNumber numberWithInt:[mAudioCopyDelegate getTempoForAudioCopy:self]];
	NSString* senderName = [mAudioCopyDelegate getSenderForAudioCopy:self];	
	NSDictionary *meta = [[[NSDictionary alloc] initWithObjectsAndKeys:tempo, @"tempo", senderName, @"sender", mCopyName, @"copyname", nil] autorelease];

	[mLoopCopy release];
	mLoopCopy = [[LoopCopy alloc] init];
	mLoopCopy.mixPath = mAudioCopyPath;
	mLoopCopy.meta = meta;
	// Update the Current Paste index and get pasteboard name - This should be called exactly once before AudioCopy
	mLoopCopy.pasteboard = [AudioCopyPaste incrementPasteIndexAndGetPasteboardName]; 
	[mLoopCopy start];
	[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(handleTimer:) userInfo:self repeats:YES];
}

- (void)handleTimer:(NSTimer*)theTimer
{
    if([mLoopCopy didSucceed])
    {
        [self setModal:NO];
        mCopyDoneView.tableView.showCopyApps = NO;
        mCopyDoneView.tableView.showPasteApps = YES;
        [mCopyDoneView.tableView reloadData];
        [mContainer bringSubviewToFront:mCopyDoneView];
        
        [mProgressView.spinner stopAnimating];
        [theTimer invalidate];
        theTimer = nil;
    }
}

-(void)instantiateSoundPlayer{
	NSURL *newURL = [[NSURL alloc] initFileURLWithPath:mAudioCopyPath];
	
	AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: newURL error: nil];
	self.appSoundPlayer = newPlayer;
	[newPlayer release];
	
	[self.appSoundPlayer prepareToPlay];
	[self.appSoundPlayer setVolume: 1.0];
	[self.appSoundPlayer setDelegate: self];
}

#pragma mark -
#pragma mark Application playback control_________________

- (IBAction) playAppSound: (id) sender {
	if(!mAppSoundPlayer)
		[self instantiateSoundPlayer];
	[self.appSoundPlayer play];
	self.playing = YES;
	[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewpausebtn.png"] forState:UIControlStateNormal];
	//[appSoundButton setEnabled: NO];
}

#pragma mark -
#pragma mark AV Foundation delegate methods____________

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag {
	self.playing = NO;
	[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewplaybtn.png"] forState:UIControlStateNormal];
	//[appSoundButton setEnabled: YES];
}

- (void) audioPlayerBeginInterruption: player {
	NSLog (@"Interrupted. The system has stopped audio playback.");
	
	if (self.playing) {
		[self.appSoundPlayer pause];
		self.playing = NO;
		self.interruptedOnPlayback = YES;
		[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewplaybtn.png"] forState:UIControlStateNormal];
	}
}

- (void) audioPlayerEndInterruption: player {
	NSLog (@"Interruption ended. Resuming audio playback.");
	
	if (self.interruptedOnPlayback) {
		[self.appSoundPlayer prepareToPlay];
		[self.appSoundPlayer play];
		self.playing = YES;
		self.interruptedOnPlayback = NO;
		[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewpausebtn.png"] forState:UIControlStateNormal];
	}
}

#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:NO];
	//setup the progress panel
//	[mProgressPanel setBGImage:[UIImage imageNamed:@"audiocopypaste_panel_bg.png"]];
	[mSongToolsMainController hideTransportWithAnimation];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[mSongToolsMainController showTransportWithAnimation];
	[super viewWillDisappear:NO];
}

- (IBAction)donePressed{
	[mSongToolsMainController showSongToolsView];
}

- (IBAction)showCompatibleApps
{
	[mActivePanel.delegate showExtendedToolPanel:mActivePanel:mActivePanel.extendedPanel];
}

- (void)previewTimer:(NSTimer*)theTimer 
{
	if (![mToolDelegate isPlayingForAudioCopy:self])
	{
		[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewplaybtn.png"] forState:UIControlStateNormal];
		if (mTimer)
		{
			[mTimer invalidate];
			mTimer = nil;
		}
	}
}

- (IBAction)previewSoundPressed{
	if([mToolDelegate isPlayingForAudioCopy:self])
	{
		[mToolDelegate stopForAudioCopy:self];
		[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewplaybtn.png"] forState:UIControlStateNormal];
		if (mTimer)
		{
			[mTimer invalidate];
			mTimer = nil;
		}
	}
	else
	{
		[mToolDelegate playForAudioCopy:self];
		[self.previewButton setBackgroundImage:[UIImage imageNamed:@"previewpausebtn.png"] forState:UIControlStateNormal];
		if (mTimer)
		{
			[mTimer invalidate];
			mTimer = nil;
		}
		mTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(previewTimer:) userInfo:nil repeats:YES];
	} 
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
	theTextField.text = mCopyName;
	theTextField.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField
{
	theTextField.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField 
{
	mCopyName = theTextField.text;
	[mCopyName retain];
	theTextField.placeholder = mCopyName;
	[self hideKeyboard];
	return YES;
}

- (void)hideKeyboard
{
	[mCopyNameField resignFirstResponder];
}


#pragma mark AppsTableViewDelegate
- (void)appWasSelected:(int)index inSection:(int)section fromTable:(AppsTableView*)table
{
	NSDictionary *dict;
	if (!table.showPasteApps)
	{
		if(section == 0)
			dict = [[CompatibleApps sharedInstance].installedCopyApps objectAtIndex:index];	
		else
			dict = [[CompatibleApps sharedInstance].nonInstalledCopyApps objectAtIndex:index];	
	}
	else if (!table.showCopyApps)
	{
		if(section == 0)
			dict = [[CompatibleApps sharedInstance].installedPasteApps objectAtIndex:index];	
		else
			dict = [[CompatibleApps sharedInstance].nonInstalledPasteApps objectAtIndex:index];	
	}
	else
	{
		if(section == 0)
			dict = [[CompatibleApps sharedInstance].installedApps objectAtIndex:index];	
		else
			dict = [[CompatibleApps sharedInstance].nonInstalledApps objectAtIndex:index];	
	}
	
	NSNumber *isInstalled = (NSNumber*)[dict valueForKey:@"isInstalled"];
	NSString *urlscheme = (NSString*)[dict valueForKey:@"URLScheme"];
	NSString *appStoreURL = (NSString*)[dict valueForKey:@"appStoreURL"];
	
	// Determine the app's URL scheme
	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	NSArray *urlSchemes = (NSArray*)[[(NSArray*)[info objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
	NSString *currentURLScheme;
	if([urlSchemes count] > 0)
		currentURLScheme = [[urlSchemes objectAtIndex:0] retain];
	else
		currentURLScheme = @"";	
	
	BOOL isRunning = [urlscheme compare:currentURLScheme] == NSOrderedSame;
	BOOL doLaunch = true;
					  
	
	if(![isInstalled boolValue] || isRunning) 
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreURL]];
	}
	else if([isInstalled boolValue] && doLaunch)
	{
		NSURL *url = [NSURL URLWithString: [urlscheme stringByAppendingString:@"://"]];				
		[[UIApplication sharedApplication] openURL:url];
	}
	return;	
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[mLoopCopy release];
	[mAudioCopyPath release];
	
	if(self.playing)
		[self audioPlayerBeginInterruption:NULL];	
	
	self.mainView = nil;
	self.copyDoneView = nil;
	self.progressView = nil;
	self.noAudioToCopyButton = nil;
	self.copyAudioButton = nil;
	self.previewButton = nil;
	self.appSoundPlayer = nil;
	self.toolPanel = nil;
    [super dealloc];
}

@end
