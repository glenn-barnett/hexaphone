//
//  UpperViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UpperViewController.h"
#import "HexaphoneAppDelegate.h"
#import "EmptyLandscapeViewController.h"
#import "AppStateManager.h"
#import "LoopManager.h"
#import "LoopPlayer.h"
#import "RecordingManager.h"
#import "UIConstants.h"
#import "Instrument.h"


@implementation UpperViewController

@synthesize appDelegate;
@synthesize instrument;
@synthesize surfaceViewController;

@synthesize helpButton;
@synthesize recordToggleButton;
@synthesize loopToggleButton;
@synthesize loopButton;
@synthesize patchButton;
@synthesize menuButton;

@synthesize recDisplayLabel;
@synthesize loopDisplayLabel;
@synthesize messageLabel;

@synthesize iconRecRec;
@synthesize iconRecPending;
@synthesize iconLoopPlay;

@synthesize recordWavOutButton;



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
/*
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


-(IBAction) toggleRecording {
	[appDelegate.recordingManager toggleRecording];
}
-(IBAction) toggleLoop {
	[appDelegate.loopPlayer toggleLoop];
}



-(IBAction) togglePatchView {
	[self.appDelegate showPatchView];
}
-(IBAction) toggleEffectsView {
	[self.appDelegate showEffectsView];
}
-(IBAction) toggleMenuView {
	[self.appDelegate showMainMenuView];
}
-(IBAction) toggleLoopView {
	[self.appDelegate showLoopView];
	//[appDelegate.loopManager openActionSheetInView:appDelegate.emptyLandscapeView];
}

-(IBAction) toggleRecordWavOut {
	if(recordWavOutButton.selected == NO) {
		NSLog(@"UVC: begin recording");
		recordWavOutButton.selected = YES;
		[instrument startRecordWavOut];
	} else {
		NSLog(@"UVC: end recording");
		recordWavOutButton.selected = NO;
		[instrument stopRecordWavOut];
	}
		
}

-(IBAction) promptForAudioCopy {
	[appDelegate.emptyLandscapeViewController launchSongTools];
}

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
