//
//  PatchViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PatchViewController.h"

#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "Patch.h"
#import "PatchManager.h"

#import "PatchPickerViewController.h"
#import "ScalePickerViewController.h"

#import "UIConstants.h"

@implementation PatchViewController

@synthesize instrument;
@synthesize appDelegate;

@synthesize patchButton;
@synthesize scaleButton;

@synthesize tuningButtonAb;
@synthesize tuningButtonA;
@synthesize tuningButtonBb;
@synthesize tuningButtonB;
@synthesize tuningButtonC;
@synthesize tuningButtonDb;
@synthesize tuningButtonD;
@synthesize tuningButtonEb;
@synthesize tuningButtonE;
@synthesize tuningButtonF;
@synthesize tuningButtonGb;
@synthesize tuningButtonG;

@synthesize closeButton;


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

-(IBAction) changePatch:(id) sender {
	
	if(appDelegate.patchPickerViewController.view.hidden) {
		[appDelegate.patchPickerViewController show];
		[appDelegate.patchPickerViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];

	} else {
		[appDelegate.patchPickerViewController hide];
	}
	//[appDelegate.patchManager openActionSheetInView:appDelegate.emptyLandscapeView];

}

-(IBAction) changeScale:(id) sender {
	if(appDelegate.scalePickerViewController.view.hidden) {
		[appDelegate.scalePickerViewController show];
		[appDelegate.scalePickerViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];

	} else {
		[appDelegate.scalePickerViewController hide];
	}
	//[appDelegate.scaleManager openActionSheetInView:appDelegate.emptyLandscapeView];
}


-(void) setInitialTuningId:(NSString*) tuningId {
	[self clearTuningSelection];
	if([tuningId isEqualToString:@"Ab"]) tuningButtonAb.selected = YES;
	else if([tuningId isEqualToString:@"A"]) tuningButtonA.selected = YES;
	else if([tuningId isEqualToString:@"Bb"]) tuningButtonBb.selected = YES;
	else if([tuningId isEqualToString:@"B"]) tuningButtonB.selected = YES;
	else if([tuningId isEqualToString:@"C"]) tuningButtonC.selected = YES;
	else if([tuningId isEqualToString:@"Db"]) tuningButtonDb.selected = YES;
	else if([tuningId isEqualToString:@"D"]) tuningButtonD.selected = YES;
	else if([tuningId isEqualToString:@"Eb"]) tuningButtonEb.selected = YES;
	else if([tuningId isEqualToString:@"E"]) tuningButtonE.selected = YES;
	else if([tuningId isEqualToString:@"F"]) tuningButtonF.selected = YES;
	else if([tuningId isEqualToString:@"Gb"]) tuningButtonGb.selected = YES;
	else if([tuningId isEqualToString:@"G"]) tuningButtonG.selected = YES;
	
}

-(void) clearTuningSelection {
	tuningButtonAb.selected = NO;
	tuningButtonA.selected = NO;
	tuningButtonBb.selected = NO;
	tuningButtonB.selected = NO;
	tuningButtonC.selected = NO;
	tuningButtonDb.selected = NO;
	tuningButtonD.selected = NO;
	tuningButtonEb.selected = NO;
	tuningButtonE.selected = NO;
	tuningButtonF.selected = NO;
	tuningButtonGb.selected = NO;
	tuningButtonG.selected = NO;
}	

-(void) activateTuningId:(NSString*) tuningId {
	[self clearTuningSelection];
	if([tuningId isEqualToString:@"Ab"]) {
		tuningButtonAb.selected = YES;
	} else if([tuningId isEqualToString:@"A"]) {
		tuningButtonA.selected = YES;
	} else if([tuningId isEqualToString:@"Bb"]) {
		tuningButtonBb.selected = YES;
	} else if([tuningId isEqualToString:@"B"]) {
		tuningButtonB.selected = YES;
	} else if([tuningId isEqualToString:@"C"]) {
		tuningButtonC.selected = YES;
	} else if([tuningId isEqualToString:@"Db"]) {
		tuningButtonDb.selected = YES;
	} else if([tuningId isEqualToString:@"D"]) {
		tuningButtonD.selected = YES;
	} else if([tuningId isEqualToString:@"Eb"]) {
		tuningButtonEb.selected = YES;
	} else if([tuningId isEqualToString:@"E"]) {
		tuningButtonE.selected = YES;
	} else if([tuningId isEqualToString:@"F"]) {
		tuningButtonF.selected = YES;
	} else if([tuningId isEqualToString:@"Gb"]) {
		tuningButtonGb.selected = YES;
	} else if([tuningId isEqualToString:@"G"]) {
		tuningButtonG.selected = YES;
	}
}

-(IBAction) tuneAb:(id) sender {
	[instrument loadTuning:[Tuning Ab]];
	[self clearTuningSelection];
	tuningButtonAb.selected = YES;
}
-(IBAction) tuneA:(id) sender {
	[instrument loadTuning:[Tuning A]];
	[self clearTuningSelection];
	tuningButtonA.selected = YES;
}
-(IBAction) tuneBb:(id) sender {
	[self clearTuningSelection];
	tuningButtonBb.selected = YES;
	[instrument loadTuning:[Tuning Bb]];
}
-(IBAction) tuneB:(id) sender {
	[instrument loadTuning:[Tuning B]];
	[self clearTuningSelection];
	tuningButtonB.selected = YES;
}
-(IBAction) tuneC:(id) sender {
	[instrument loadTuning:[Tuning C]];
	[self clearTuningSelection];
	tuningButtonC.selected = YES;
}
-(IBAction) tuneDb:(id) sender {
	[instrument loadTuning:[Tuning Db]];
	[self clearTuningSelection];
	tuningButtonDb.selected = YES;
}
-(IBAction) tuneD:(id) sender {
	[instrument loadTuning:[Tuning D]];
	[self clearTuningSelection];
	tuningButtonD.selected = YES;
}
-(IBAction) tuneEb:(id) sender {
	[instrument loadTuning:[Tuning Eb]];
	[self clearTuningSelection];
	tuningButtonEb.selected = YES;
}
-(IBAction) tuneE:(id) sender {
	[instrument loadTuning:[Tuning E]];
	[self clearTuningSelection];
	tuningButtonE.selected = YES;
}
-(IBAction) tuneF:(id) sender {
	[instrument loadTuning:[Tuning F]];
	[self clearTuningSelection];
	tuningButtonF.selected = YES;
}
-(IBAction) tuneGb:(id) sender {
	[instrument loadTuning:[Tuning Gb]];
	[self clearTuningSelection];
	tuningButtonGb.selected = YES;
}
-(IBAction) tuneG:(id) sender {
	[instrument loadTuning:[Tuning G]];
	[self clearTuningSelection];
	tuningButtonG.selected = YES;
}


-(IBAction)slideInView {
	isShown = YES;
//	NSLog(@"PatchViewController: -slideInView");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	CGRect frame = self.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y + frame.size.height;
	self.view.frame = frame;

	CGRect closeButtonFrame = closeButton.frame;
	closeButtonFrame.origin.y = (CGFloat) closeButtonFrame.origin.y + frame.size.height + 40;
	closeButton.frame = closeButtonFrame;
	
	[UIView commitAnimations];
}

-(IBAction) slideOutView {
	isShown = NO;
//	NSLog(@"PatchViewController: -slideOutView");
	[appDelegate.patchPickerViewController hide];
	[appDelegate.scalePickerViewController hide];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	
	CGRect frame = self.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y - frame.size.height;
	self.view.frame = frame;

	CGRect closeButtonFrame = closeButton.frame;
	closeButtonFrame.origin.y = (CGFloat) closeButtonFrame.origin.y - frame.size.height - 40;
	closeButton.frame = closeButtonFrame;
	
	[UIView commitAnimations];
}
-(void) hideView {
	if(isShown) {
		CGRect frame = self.view.frame;
		frame.origin.y = (CGFloat) frame.origin.y - frame.size.height;
		self.view.frame = frame;

		CGRect closeButtonFrame = closeButton.frame;
		closeButtonFrame.origin.y = (CGFloat) closeButtonFrame.origin.y - frame.size.height - 40;
		closeButton.frame = closeButtonFrame;
		isShown = NO;
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
