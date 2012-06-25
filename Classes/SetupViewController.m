//
//  SetupViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"
#import <math.h>
#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "LoopPlayer.h"
#import "AppStateManager.h"
#import "AppState.h"

#import "SurfaceViewController.h"
#import "KeysView.h"
#import "UIConstants.h"

#import "CustomUISwitch.h"
#import "GLVectorOverlayView.h"
#import "TiltIndicatorView.h"

@implementation SetupViewController

@synthesize appDelegate;
@synthesize pedalBehaviorButton;
@synthesize rotationBehaviorButton;
@synthesize versionLabel;
@synthesize accelDisplayLabel;

#define kLabelFontSize 11

-(void) valueChangedInView: (id) sender {
//	NSLog(@"SVC: valueChangedInView ENTER");
	if(keyLabelsSwitch == sender) {
		appDelegate.appStateManager.appState.showKeyLabels = [keyLabelsSwitch isOn];
		appDelegate.surfaceViewController.keysView.showKeyLabels = [keyLabelsSwitch isOn];
		[appDelegate.surfaceViewController.keysView updateLabels];
	} else if(keyIllumSwitch == sender) {
		appDelegate.appStateManager.appState.showKeyIllum = [keyIllumSwitch isOn];
		if([keyIllumSwitch isOn]) {
			[appDelegate.glVectorOverlayView startAnimation];
		} else {
			[appDelegate.glVectorOverlayView stopAnimation];
		}
	} else if(rotateViewSwitch == sender) {
//		appDelegate.masterView.transform = CGAffineTransformConcat(appDelegate.masterView.transform, CGAffineTransformMakeRotation(M_PI / -2));
		appDelegate.appStateManager.appState.rotateView = [rotateViewSwitch isOn];
		[appDelegate changeViewRotation];
	}
}


-(BOOL) isKeyIllumEnabled {
	return [keyIllumSwitch isOn];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 480, 152)];
	scrollView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"setupmenu-bg-stripesonly.png"]];
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[self.view insertSubview:scrollView atIndex:1];
	
	versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
//	CGAffineTransform rotate = CGAffineTransformMakeRotation(degreesToRadians(90));

// v1.1:
//	float SLIDER_INITIAL_X = 50.0f;
//	float SLIDER_DISTANCE_BETWEEN = 69.0f;
	float SLIDER_INITIAL_X = 35.0f; //30.0f min
	float SLIDER_DISTANCE_BETWEEN = 60.0f; //55.0f min
	
	float currentXOffset = SLIDER_INITIAL_X;

	
//	UIImageView* moreImageLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setupmenu-bg-more-right.png"]];
//	[scrollView addSubview:moreImageLeft];
//	currentXOffset += 16;
	
	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"ROTATE\nSCREEN";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}
	
	rotateViewSwitch = [[CustomUISwitch alloc] initWithFrame:CGRectZero];
	rotateViewSwitch.delegate = self;
	[scrollView addSubview:rotateViewSwitch];
	rotateViewSwitch.transform = CGAffineTransformConcat(rotateViewSwitch.transform, CGAffineTransformMakeRotation(M_PI / -2));
	rotateViewSwitch.center = CGPointMake(currentXOffset, 93);
	[rotateViewSwitch setOn:appDelegate.appStateManager.appState.rotateView animated:NO];

	
	currentXOffset += SLIDER_DISTANCE_BETWEEN;

	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"KEY\nLABELS";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}

	keyLabelsSwitch = [[CustomUISwitch alloc] initWithFrame:CGRectZero];
	keyLabelsSwitch.delegate = self;
	[scrollView addSubview:keyLabelsSwitch];
	keyLabelsSwitch.transform = CGAffineTransformConcat(keyLabelsSwitch.transform, CGAffineTransformMakeRotation(M_PI / -2));
	keyLabelsSwitch.center = CGPointMake(currentXOffset, 93);
	[keyLabelsSwitch setOn:YES animated:NO];
	
	currentXOffset += SLIDER_DISTANCE_BETWEEN;
	
	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"KEY\nILLUM";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}
	
	keyIllumSwitch = [[CustomUISwitch alloc] initWithFrame:CGRectZero];
	keyIllumSwitch.delegate = self;
	[scrollView addSubview:keyIllumSwitch];
	keyIllumSwitch.transform = CGAffineTransformConcat(keyIllumSwitch.transform, CGAffineTransformMakeRotation(M_PI / -2));
	keyIllumSwitch.center = CGPointMake(currentXOffset, 93);
	[keyIllumSwitch setOn:YES animated:NO];
	
	
	currentXOffset += SLIDER_DISTANCE_BETWEEN;	
	
	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"FILTER\nREZ";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}
	
	sliderFilterRez = [[UISlider alloc] initWithFrame:CGRectMake(0,0,98,29)];
	sliderFilterRez.transform = CGAffineTransformConcat(sliderFilterRez.transform, CGAffineTransformMakeRotation(M_PI / -2));
	sliderFilterRez.center = CGPointMake(currentXOffset, 90);
	[sliderFilterRez setMinimumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-on.png"] forState: UIControlStateNormal];
	[sliderFilterRez setMaximumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-off.png"] forState: UIControlStateNormal];
	[sliderFilterRez setThumbImage:[UIImage imageNamed:@"setupmenu-sliderhandle.png"] forState: UIControlStateNormal];
	[sliderFilterRez addTarget:self action:@selector(sliderFilterRezChanged:) forControlEvents:UIControlEventValueChanged];
	//[sliderFilterRez addTarget:self action:@selector(sliderFilterRezChanged:) forEvents:7];
	[scrollView addSubview:sliderFilterRez];
	
	tiltIndicatorView = [[TiltIndicatorView alloc] initWithFrame:CGRectMake(0,0,38,129)];
	tiltIndicatorView.center = CGPointMake(currentXOffset, 90);
	[scrollView addSubview:tiltIndicatorView];
	
	currentXOffset += SLIDER_DISTANCE_BETWEEN;
	
	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"KEY\nVOL";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}

	sliderKeyVolume = [[UISlider alloc] initWithFrame:CGRectMake(0,0,98,29)];
	sliderKeyVolume.transform = CGAffineTransformConcat(sliderKeyVolume.transform, CGAffineTransformMakeRotation(M_PI / -2));
	sliderKeyVolume.center = CGPointMake(currentXOffset, 90);
	[sliderKeyVolume setMinimumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-on.png"] forState: UIControlStateNormal];
	[sliderKeyVolume setMaximumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-off.png"] forState: UIControlStateNormal];
	[sliderKeyVolume setThumbImage:[UIImage imageNamed:@"setupmenu-sliderhandle.png"] forState: UIControlStateNormal];
	[sliderKeyVolume addTarget:self action:@selector(sliderKeyVolumeChanged:) forControlEvents:UIControlEventValueChanged];
	//[sliderKeyVolume addTarget:self action:@selector(sliderKeyVolumeChanged:) forEvents:7];
	[scrollView addSubview:sliderKeyVolume];

	currentXOffset += SLIDER_DISTANCE_BETWEEN;

	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"LOOP\nVOL";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}
	
	sliderLoopVolume = [[UISlider alloc] initWithFrame:CGRectMake(0,0,98,29)];
	sliderLoopVolume.transform = CGAffineTransformConcat(sliderLoopVolume.transform, CGAffineTransformMakeRotation(M_PI / -2));
	sliderLoopVolume.center = CGPointMake(currentXOffset, 90);
	[sliderLoopVolume setMinimumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-on.png"] forState: UIControlStateNormal];
	[sliderLoopVolume setMaximumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-off.png"] forState: UIControlStateNormal];
	[sliderLoopVolume setThumbImage:[UIImage imageNamed:@"setupmenu-sliderhandle.png"] forState: UIControlStateNormal];
	[sliderLoopVolume addTarget:self action:@selector(sliderLoopVolumeChanged:) forControlEvents:UIControlEventValueChanged];
	//[sliderLoopVolume addTarget:self action:@selector(sliderLoopVolumeChanged:) forEvents:7];
	[scrollView addSubview:sliderLoopVolume];

	currentXOffset += SLIDER_DISTANCE_BETWEEN;

	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(currentXOffset - 30.0f, 0.0f, 60.0f, 40.0f)];
		l.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:kLabelFontSize];
		l.textAlignment = UITextAlignmentCenter;
		l.numberOfLines = 0;
		l.text = @"TOUCH\nSIZE";
		l.textColor = [UIColor whiteColor];
		l.backgroundColor = [UIColor clearColor];
		l.alpha = 0.75;
		[scrollView addSubview:l];
	}
	
	sliderTouchSize = [[UISlider alloc] initWithFrame:CGRectMake(0,0,98,29)];
	sliderTouchSize.transform = CGAffineTransformConcat(sliderTouchSize.transform, CGAffineTransformMakeRotation(M_PI / -2));
	sliderTouchSize.center = CGPointMake(currentXOffset, 90);
	[sliderTouchSize setMinimumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-on.png"] forState: UIControlStateNormal];
	[sliderTouchSize setMaximumTrackImage:[UIImage imageNamed:@"setupmenu-slidertrack-off.png"] forState: UIControlStateNormal];
	[sliderTouchSize setThumbImage:[UIImage imageNamed:@"setupmenu-sliderhandle.png"] forState: UIControlStateNormal];
	
	[sliderTouchSize addTarget:self action:@selector(sliderTouchSizeChanged:) forControlEvents:UIControlEventValueChanged];
	//[sliderTouchSize addTarget:self action:@selector(sliderTouchSizeChanged:) forEvents:7];
	[scrollView addSubview:sliderTouchSize];
	
	currentXOffset += SLIDER_DISTANCE_BETWEEN;
	
	
//	currentXOffset += 10;
//	UIImageView* moreImageRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setupmenu-bg-more-left.png"]];
//	CGRect moreImageRightFrame = moreImageRight.frame;
//	moreImageRightFrame.origin.x = currentXOffset;
//	moreImageRight.frame = moreImageRightFrame;
//	[scrollView addSubview:moreImageRight];
//	currentXOffset += 16;

	
//	scrollView.contentSize = CGSizeMake(currentXOffset, 152);
	scrollView.contentSize = CGSizeMake(480, 152);
	
	
	
	// inits
	
	sliderKeyVolume.value = [appDelegate.appStateManager.appState.sliderKeyVol floatValue];
	[self sliderKeyVolumeChanged:sliderKeyVolume];
	sliderLoopVolume.value = [appDelegate.appStateManager.appState.sliderLoopVol floatValue];
	[self sliderLoopVolumeChanged:sliderLoopVolume];
	sliderTouchSize.value = [appDelegate.appStateManager.appState.sliderTouchSize floatValue];
	[self sliderTouchSizeChanged:sliderTouchSize];
	sliderFilterRez.value = [appDelegate.appStateManager.appState.sliderFilterRez floatValue];
	[self sliderFilterRezChanged:sliderFilterRez];
	
}

-(void) sliderKeyVolumeChanged: (id) slider {
	//NSLog(@"sliderKeyVolumeChanged: to %.2f", sliderKeyVolume.value);
	[appDelegate.instrument setKeyVolume:0.1f + 0.9f * sliderKeyVolume.value];
	appDelegate.appStateManager.appState.sliderKeyVol = [NSNumber numberWithFloat:sliderKeyVolume.value];
}

-(void) sliderLoopVolumeChanged: (id) slider {
//	NSLog(@"sliderLoopVolumeChanged: to %.2f", sliderLoopVolume.value);
	[appDelegate.loopPlayer setLoopVolume:sliderLoopVolume.value];
	appDelegate.appStateManager.appState.sliderLoopVol = [NSNumber numberWithFloat:sliderLoopVolume.value];
}

-(void) sliderTouchSizeChanged: (id) slider {
//	NSLog(@"sliderTouchSizeChanged: to %.2f", sliderTouchSize.value);
	[appDelegate.instrument setTouchSize:sliderTouchSize.value];
	appDelegate.appStateManager.appState.sliderTouchSize = [NSNumber numberWithFloat:sliderTouchSize.value];
}

-(void) sliderVolumePedalEffectChanged: (id) slider {
//	NSLog(@"sliderVolumePedalEffectChanged: to %.2f", sliderVolumePedalEffect.value);
	[appDelegate.instrument setVolumePedalMinimum:1.0f - sliderVolumePedalEffect.value];
}


-(void) sliderFilterRezChanged: (id) slider {
	[appDelegate.instrument setFilterRez:sliderFilterRez.value];
	appDelegate.appStateManager.appState.sliderFilterRez = [NSNumber numberWithFloat:sliderFilterRez.value];

	// hide if slider is 'off'
	tiltIndicatorView.hidden = (sliderFilterRez.value == 0.0f);
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


-(IBAction)slideInView {
	isShown = YES;
//	NSLog(@"PatchViewController: -slideInView");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	CGRect frame = self.view.frame;
	frame.origin.y = (CGFloat) frame.origin.y + frame.size.height;
	self.view.frame = frame;
	
	[UIView commitAnimations];
}

-(IBAction) slideOutView {
	isShown = NO;
//	NSLog(@"PatchViewController: -slideOutView");
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

- (void)dealloc {
    [super dealloc];
}


@end
