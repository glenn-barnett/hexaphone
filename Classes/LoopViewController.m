//
//  LoopViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoopViewController.h"
#import "LoopManager.h"
#import "LoopPlayer.h"
#import "Loop.h"
#import "Instrument.h"
#import "HexaphoneAppDelegate.h"
#import "LoopPickerViewController.h"
#import "RecordingManager.h"

@implementation LoopViewController

@synthesize appDelegate;
@synthesize loopPlayer;

@synthesize loopDropdownButton;
@synthesize loopToggleButton;
@synthesize recToggleButton;
@synthesize autoTuneButton;

-(IBAction) changeLoop:(id) sender {
	//[appDelegate.loopManager openActionSheetInView:appDelegate.emptyLandscapeView];

	if(appDelegate.loopPickerViewController.view.hidden) {
		[appDelegate.loopPickerViewController show];
		[appDelegate.loopPickerViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];

	} else {
		[appDelegate.loopPickerViewController hide];
	}
}
-(IBAction) stop:(id) sender {
	[appDelegate.loopPlayer stop];
}
-(IBAction) toggleLoop:(id) sender {
	if([appDelegate.loopPlayer isLooping]) {
		[appDelegate.loopPlayer stop];
	} else {
		[appDelegate.loopPlayer play];
	}
}
-(IBAction) toggleRec:(id) sender {
	if(appDelegate.recordingManager.isRecording) {
		[appDelegate.recordingManager stopRecording];
	} else {
		[appDelegate.recordingManager startRecording];
	}
}
-(IBAction) loadRecommendation {
	[appDelegate.instrument loadPatchIdRIO:appDelegate.instrument.patchId 
								   scaleId:[appDelegate.loopPlayer activeLoop].scaleId 
								  tuningId:[appDelegate.loopPlayer activeLoop].tuningId];
	 
	
}
-(IBAction) slideInView {
	isShown = YES;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	CGRect frame = self.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y + frame.size.height;
	self.view.frame = frame;
	
	[UIView commitAnimations];
}

-(IBAction) slideOutView {
	isShown = NO;
	[appDelegate.loopPickerViewController hide];
	
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

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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


- (void)dealloc {
    [super dealloc];
}


@end
