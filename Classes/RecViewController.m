//
//  MainMenuViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RecViewController.h"
#import "RecPickerViewController.h"
#import "HexaphoneAppDelegate.h"
#import "RecordingManager.h"
#import "RecordingPlayer.h"
#import "WaveRecViewController.h"

@implementation RecViewController

@synthesize appDelegate;
@synthesize waveRecViewController;
@synthesize recordingChooserButton;
@synthesize recordingChooserLabel;
@synthesize recordingPlaybackToggleButton;
@synthesize recordingFileOperationButton;
@synthesize recordingPlaybackRepeatToggleButton;
@synthesize recordingWavExportButton;
@synthesize recordingProgressView;
@synthesize recordingProgressImage;
@synthesize recordingPlayIcon;

@synthesize lessonChooserButton;
@synthesize lessonVideoButton;
@synthesize lessonPlaybackToggleButton;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	waveRecViewController = [[WaveRecViewController alloc] initWithNibName:@"WaveRecViewController" bundle:[NSBundle mainBundle]];
	waveRecViewController.appDelegate = appDelegate;
	[self.view addSubview:waveRecViewController.view];
	waveRecViewController.view.frame = CGRectMake(0,
											  0 - waveRecViewController.view.frame.size.height,
											  waveRecViewController.view.frame.size.width,
											  waveRecViewController.view.frame.size.height);
	
	
}

-(IBAction) showWavExportView {
	NSLog(@"RVC: showWavExportView");

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	CGRect frame = waveRecViewController.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y + frame.size.height;
	waveRecViewController.view.frame = frame;
	
	[waveRecViewController resetState];
	[waveRecViewController prepareView];
	
	[UIView commitAnimations];
}

-(IBAction) hideWavExportView {
	NSLog(@"RVC: showWavExportView");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	CGRect frame = waveRecViewController.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y - frame.size.height;
	waveRecViewController.view.frame = frame;
	
	[UIView commitAnimations];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction) chooseRecording {
//	NSLog(@"RecVC -chooseRecording: BEGIN");

	//OLD: UIAlertView approach
	//	[appDelegate.recordingManager openActionSheetInView:appDelegate.emptyLandscapeView];

//	if([[appDelegate.recordingManager getSavedRecordingFilenames] count] > 0) {
		if(appDelegate.recPickerViewController.view.hidden) {
			[appDelegate.recPickerViewController show];
			[appDelegate.recPickerViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
			
		} else {
			[appDelegate.recPickerViewController hide];
		}
//	}
}
-(IBAction) performFileOperation {
	[appDelegate.recordingManager openActionSheetInView:appDelegate.emptyLandscapeView];
}
-(IBAction) toggleRecordingPlayback {
//	NSLog(@"RecVC: -toggleRecordingPlayback");
	[appDelegate.recordingPlayer togglePlayback];
}
-(IBAction) toggleRecordingRepeatPlayback {
//	NSLog(@"RecVC: -toggleRecordingRepeatPlayback");
	[appDelegate.recordingPlayer toggleRepeatPlayback];
}


-(IBAction)slideInView {
	isShown = YES;
//	NSLog(@"RecViewController: -slideInView");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	CGRect frame = self.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y + frame.size.height;
	self.view.frame = frame;
	
	[UIView commitAnimations];
}

-(IBAction) slideOutView {
	isShown = NO;
//	NSLog(@"RecViewController: -slideOutView");
	[appDelegate.recPickerViewController hide];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	
	CGRect frame = self.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y - frame.size.height;
	self.view.frame = frame;
	
	[UIView commitAnimations];
}

-(void) hideView {
	if(isShown) {
		CGRect frame = self.view.frame;
		frame.origin.y = (CGFloat) frame.origin.y - frame.size.height;
		self.view.frame = frame;
		isShown = NO;
	}
}


-(IBAction) toggleRecording {
	[appDelegate.recordingManager toggleRecording];
}
-(IBAction) toggleLoop {
	[appDelegate.recordingPlayer togglePlayback];
}

- (void)dealloc {
    [super dealloc];
}


@end
