//
//  HexatoneAppDelegate.m
//  Hexatone
//
//  Created by Glenn Barnett on 1/3/09.
//  Copyright Impresario Digital Impresario Digital 2009. All rights reserved.
//


#include <stdlib.h>
#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "LoopPlayer.h"

#import "UIConstants.h"

#import "SurfaceViewController.h"
#import "KeysView.h"
#import "UpperViewController.h"
#import "PatchViewController.h"
#import "SetupViewController.h"
#import "RecViewController.h"
#import "LoopViewController.h"
#import "MiniMapView.h"
#import "RecordingPlayer.h"

#import "GLVectorOverlayView.h"
#import "Reachability.h"
#import "JSON.h"

#import <QuartzCore/QuartzCore.h>

#import "ScaleManager.h"
#import "PatchManager.h"
#import "AppStateManager.h"
#import "AppState.h"
#import "LoopManager.h"
#import "Loop.h"
#import "RecordingManager.h"
#import "Recording.h"
#import "NotesManager.h"
#import "Note.h"

#import "PatchPickerViewController.h"
#import "ScalePickerViewController.h"
#import "LoopPickerViewController.h"
#import "RecPickerViewController.h"

#import "EmptyLandscapeViewController.h"
#import "Appirater.h"

@implementation HexaphoneAppDelegate

@synthesize currentKeyboardOffset;

@synthesize window;
@synthesize masterView;
@synthesize splashView1;
@synthesize emptyLandscapeView;

@synthesize instrument;
@synthesize loopPlayer;
@synthesize recordingPlayer;

@synthesize scaleManager;
@synthesize patchManager;
@synthesize appStateManager;
@synthesize loopManager;
@synthesize recordingManager;
@synthesize notesManager;

@synthesize surfaceViewController;
@synthesize glVectorOverlayView;

@synthesize upperViewController;

@synthesize patchViewController;
@synthesize setupViewController;
@synthesize recViewController;
@synthesize loopViewController;

@synthesize patchPickerViewController;
@synthesize scalePickerViewController;
@synthesize loopPickerViewController;
@synthesize recPickerViewController;

@synthesize lastAveragePitch;
@synthesize numRecordingsMade;
@synthesize numRecordingsSaved;

@synthesize emptyLandscapeViewController;

-(void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"AppDelegate: -applicationDidReceiveMemoryWarning");
}


-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {

	if(url != nil && ([url isFileURL] || [[url scheme] isEqualToString:@"hexaphone"])) {
		NSLog(@"AppDelegate: handleOpenURL: %@", [url absoluteString]);
		
		NSURL* urlToOpen;
		
		if([[url scheme] isEqualToString:@"hexaphone"]) {
			// transform to http
			urlToOpen = [[NSURL alloc] initWithScheme:@"http" host:[url host] path:[url path]];
		} else {
			urlToOpen = url;
		}
		
		if(recordingPlayer != nil) {
			[recordingPlayer stop];
			[recordingPlayer loadRecordingFromURL:urlToOpen reloadInstrument:YES indicateModified:YES];
			[patchViewController hideView];
			[setupViewController hideView];
			[loopViewController hideView];
			[recViewController hideView];
			[recViewController slideInView];
			
			[recordingPlayer performSelector:@selector(togglePlayback) 
					   withObject:nil 
					   afterDelay:1.0];
		} else {
			openedRecordingURL = [urlToOpen retain];
		}
		return YES;
	}
	return NO;
}

//-(void)applicationDidBecomeActive:(UIApplication *)application  {
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//-(void) applicationDidFinishLaunching:(UIApplication *)application {
	appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];

//	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedRotateNotification:) name: UIDeviceOrientationDidChangeNotification object: nil];

//	[UIDevice currentDevice].proximityMonitoringEnabled = YES;
//	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedProximityNotification:) name: UIDeviceProximityStateDidChangeNotification object: nil];
	
	//GSB 20100723 launch options
//	NSURL *launchUrl = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
//	if(launchUrl != nil && [launchUrl isFileURL]) {
//		NSLog(@"AppDelegate: didFinishLaunchingWithOptions: got fileURL: %@", [launchUrl absoluteString]);
//		UIAlertView *alert;
//		alert = [[UIAlertView alloc]	initWithTitle:		@"Launched with URL"
//														  message:			[launchUrl absoluteString]
//														 delegate:			nil
//												cancelButtonTitle:	@"Cancel"
//												otherButtonTitles:	@"OK", nil];
//		[alert show];
//		
//	}
	
	
	// new above
	for(int i=0; i<kAccelerometerAverageSampleSize; i++) {
		lastTilts[i] = -120.0f;
		lastPitches[i] = -90.0f;
		lastPitch2s[i] = 180.0f;
//		lastXs[i] = 0.0f;
//		lastYs[i] = 0.0f;
//		lastZs[i] = 0.0f;
//		deltaXs[i] = 0.0f;
//		deltaYs[i] = 0.0f;
//		deltaZs[i] = 0.0f;
	}
	curAccelArrayIndex = 0;
	lastBumpTime = [NSDate timeIntervalSinceReferenceDate] + 8.0; // 8 seconds of bump immunity
	lastAccelerationLoggingTime = [NSDate timeIntervalSinceReferenceDate];

	[self initializeAnalytics];
	
	//GSB20100310: trying to flip
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	// non-deprecated (3.2+): [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

//	[UIApplication sharedApplication].isIdleTimerDisabled = YES; //TBD 3.0

	[self positionElements];
	
	[NSThread detachNewThreadSelector: @selector(showSplashScreen1) toTarget: self withObject: nil ];

	return YES;
	
}


-(void) loadData {
	
	loopPlayer = [[LoopPlayer alloc] init];
	loopPlayer.appDelegate = self;
	
	recordingPlayer = [[RecordingPlayer alloc] init];
	recordingPlayer.appDelegate = self; // for callbacks to update slider position
	recordingPlayer.instrument = instrument;
	recordingPlayer.loopPlayer = loopPlayer;
	
	recViewController.recordingPlaybackRepeatToggleButton.selected = recordingPlayer.repeatPlayback;

	
	patchManager = [[PatchManager alloc] init];
	patchManager.instrument = instrument;

	scaleManager = [[ScaleManager alloc] init];
	scaleManager.instrument = instrument;
	loopManager = [[LoopManager alloc] init]; 
	loopManager.loopPlayer = loopPlayer;
	recordingManager = [[RecordingManager alloc] init];
	recordingManager.appDelegate = self; // for callbacks to update slider position
	recordingManager.instrument = instrument;
	recordingManager.loopPlayer = loopPlayer;
	recordingManager.recordingPlayer = recordingPlayer;
	
	notesManager = [[NotesManager alloc] initFromJsonFile:@"notes.json"]; 
	
	AppState* appState = appStateManager.appState;
	
	if(![[patchManager.patchesMap allKeys] containsObject:appState.patchId]) {
		Patch* firstPatch = [patchManager.sortedPatches objectAtIndex:0];
		appState.patchId = firstPatch.patchId;
	}
	if(![[scaleManager.scalesMap allKeys] containsObject:appState.scaleId]) {
		Scale* firstScale = [scaleManager.sortedScales objectAtIndex:0];
		appState.scaleId = firstScale.scaleId;
	}
	if(![[loopManager.loopsMap allKeys] containsObject:appState.loopId]) {
		Loop* firstLoop = [loopManager.sortedLoops objectAtIndex:0];
		appState.loopId = firstLoop.loopId;
	}
	
	[instrument loadPatchIdRIO:appState.patchId scaleId:appState.scaleId tuningId:appState.tuningId];
	
	[loopPlayer loadLoop:[loopManager.loopsMap objectForKey:appState.loopId]];
	[miniMapView positionSelection:[appState.kbOffset intValue]];
	
	[patchViewController setInitialTuningId:appState.tuningId];
	
	[surfaceViewController updateLabels];
	
	loopLastChanged = [NSDate timeIntervalSinceReferenceDate];

	[patchPickerViewController.tableView reloadData];
	[scalePickerViewController.tableView reloadData];	
	
	numRecordingsMade = 0;
	numRecordingsSaved = 0;
	
	// if we were passed a URL at app start, open that
	if(openedRecordingURL != nil) {
		[recordingPlayer loadRecordingFromURL:openedRecordingURL reloadInstrument:YES indicateModified:YES];
		[openedRecordingURL release];
		openedRecordingURL = nil;
		[recViewController slideInView];
		[recordingPlayer performSelector:@selector(togglePlayback) 
							  withObject:nil 
							  afterDelay:1.0];
		
	} else {
		// open the default
		
		NSString* defaultRecordingFilename = @" Latest Recording.hexrec";

		NSArray* systemDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString* documentsDirectory = [systemDirectories objectAtIndex:0];  
		NSString* defaultRecordingFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, defaultRecordingFilename];

		
		BOOL isDirectory = NO;
		if ( [[NSFileManager defaultManager] fileExistsAtPath:defaultRecordingFilePath isDirectory: &isDirectory] ) {
			//[recordingPlayer loadRecordingFromFilename:defaultRecordingFilename];
			[recordingPlayer loadRecordingFromURL:[NSURL fileURLWithPath:defaultRecordingFilePath] reloadInstrument:NO indicateModified:NO];

			recordingPlayer.loadedRecording.isLatest = YES;
		}
	}
	
	[self hideSplashScreens];


	
}

-(void) changeViewRotation {
	if(appStateManager.appState.rotateView) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
		masterView.transform = CGAffineTransformMakeRotation(M_PI / -2);
		emptyLandscapeViewController.view.transform = CGAffineTransformMakeRotation(M_PI / -2);
	} else {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
		masterView.transform = CGAffineTransformMakeRotation(M_PI / 2);
		emptyLandscapeViewController.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
	}
}


-(void) positionElements {
	appStateManager = [[AppStateManager alloc] init]; // need this guy early - for startupCount

	window.userInteractionEnabled = YES;
	window.multipleTouchEnabled = NO; // if this isn't set, subviews can't do multitouch
	
	
	UIScreen *screen = [UIScreen mainScreen];
	//GSB 20091024: this was the problem.  why was i declaring my own window?
	//	window = [[UIWindow alloc] initWithFrame:[screen bounds]];
	
    [window makeKeyAndVisible];
	masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
	masterView.userInteractionEnabled = YES;
	[window addSubview:masterView];
	[self positionLandscapeElement:masterView window:window screen:screen 
								 x:0 
								 y:0 
							 width:480 
							height:320];
	
	emptyLandscapeViewController = [[EmptyLandscapeViewController alloc] init];
	//	emptyLandscapeViewController.view.backgroundColor = [UIColor redColor];
	//	emptyLandscapeViewController.view.alpha = 0.5f;
	//	emptyLandscapeViewController.view.frame = CGRectMake(0,
	//													  0,
	//													  UI_SCREEN_WIDTH,
	//													  UI_SCREEN_HEIGHT);
	//	[masterView addSubview:emptyLandscapeViewController.view];
	[window addSubview:emptyLandscapeViewController.view];
	[self positionLandscapeElement:emptyLandscapeViewController.view window:window screen:screen 
								 x:0 
								 y:0 
							 width:480 
							height:320];
	//	[self positionLandscapeElement:emptyLandscapeViewController.view window:window screen:screen 
	//								 x:0 
	//								 y:0 
	//							 width:UI_SCREEN_WIDTH 
	//							height:UI_SCREEN_HEIGHT];
	//	[window addSubview:emptyLandscapeViewController.view];
	[self changeViewRotation];
	
	
	//GSB: splash screen - to do this, we'll have to
	// a.) wait for this method to finish, setting everything hidden or alpha 0.0
	// b.) kick off a thread to run the flash and do the rest 
	
	splashView1 = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"logo-impdigit.png"]];
	splashView1.alpha = 0.0;
	
	[masterView addSubview:splashView1];
	
	splashView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-hexaphone.png"]];
	splashView2.alpha = 0.0;
	
	{
		UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(10,280,460,20)];
		l.backgroundColor = [UIColor clearColor];
		l.textColor = UIColorFromRGB(0x404F5F);
		l.textAlignment = UITextAlignmentCenter;
		l.adjustsFontSizeToFitWidth = YES;
		l.font = [UIFont fontWithName:UI_KEYS_TIPLABELBIG_FONT_NAME size:UI_KEYS_TIPLABELBIG_FONT_SIZE];
		
		
		int offset = [appStateManager.appState.startupCount intValue];

		int NUM_FORTUNES = 9;
		
		switch (offset % NUM_FORTUNES) {
			case 0:
				l.text = @"SOME SAMPLES BY ADVENTURE KID - http://adventurekid.se";
				break;
			case 1:
				l.text = @"THE IPHONE'S SPEAKER IS IN THE BOTTOM CORNER; TRY NOT TO COVER IT UP";
				break;
			case 2:
				l.text = @"USE THE HEADPHONE JACK, IT SOUNDS MUCH BETTER";
				break;
			case 3:
				l.text = @"FIND VIDEOS, LESSONS, AND MORE AT HEXAPHONE.COM";
				break;
			case 4:
				l.text = @"SOME SOUNDS CAN ONLY BE HEARD THROUGH AN EXTERNAL SPEAKER";
				break;
			case 5:
				l.text = @"TURN OFF KEY ILLUM TO IMPROVE CLASSIC/3G PERFORMANCE";
				break;
			case 6:
				l.text = @"PRESS RECORD ONCE TO START RECORDING, A SECOND TIME TO PLAY IT BACK";
				break;
			case 7:
				l.text = @"WANT TO CONTRIBUTE A BEAT TO HEXAPHONE?  BEATS@HEXAPHONE.COM";
				break;
			case 8:
				l.text = @"twitter.com/hexaphonejam";
				break;
			default:
				break;
		}
		appStateManager.appState.startupCount = [NSNumber numberWithInt:++offset];
		
		[splashView2 addSubview:l];
	}
		
		
	
	[masterView addSubview: splashView2];
}

- (void) showSplashScreen1 {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	NSLog(@"AppDelegate: -showSplashScreen1");
	//[NSThread sleepForTimeInterval: (NSTimeInterval) 0.5];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(loadInterface)];
	
	splashView1.alpha = 1.0;
	[UIView commitAnimations];
	
//	NSLog(@"AppDelegate: -showSplashScreen1 END");
	
	[pool release];
	
}

- (void) showSplashScreen2 {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
//	NSLog(@"AppDelegate: -showSplashScreen2");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(loadData)];
	
	splashView2.alpha = 1.0;
	[UIView commitAnimations];
	
//	NSLog(@"AppDelegate: -showSplashScreen2 END");
	
	[pool release];
	
}

- (void) hideSplashScreens {
//	NSLog(@"AppDelegate: -hideSplashScreen");

	splashView1.hidden = YES;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	splashView2.alpha = 0.0;
	[UIView commitAnimations];

	//[splashView removeFromSuperview];
}


//-(void) receivedProximityNotification: (NSNotification*) notification
//{
//	BOOL proximity = [[UIDevice currentDevice] proximityState]; 
//	if(proximity) {
//		NSLog(@"received proximity notification, and it's true!!!!!!!!!!!!!!!!!!!!!!!!!!");
//	}
//	
//}



- (void) loadInterface {
//	NSLog(@"AppDelegate: -loadInterface");

	// Configure the accelerometer, but don't start it.
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	//[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	UIScreen* screen = [UIScreen mainScreen];
	
	
	instrument = [[Instrument alloc] init];

	
	
	surfaceViewController = [[SurfaceViewController alloc] init];
	surfaceViewController.instrument = instrument;
	//surfaceViewController.view.hidden = YES;
	
	[masterView insertSubview:surfaceViewController.view belowSubview:splashView1];
	surfaceViewController.view.frame = CGRectMake(UI_KEYS_OFFSET, UI_MAINCONTROLS_HEIGHT, UI_KEYS_WIDTH, UI_KEYS_HEIGHT);
//	[self positionLandscapeElement:surfaceViewController.view window:window screen:screen 
//								 x:UI_KEYS_OFFSET 
//								 y:UI_MAINCONTROLS_HEIGHT 
//							 width:UI_KEYS_WIDTH 
//							height:UI_KEYS_HEIGHT];

	patchViewController = [[PatchViewController alloc] initWithNibName:@"PatchViewController" bundle:[NSBundle mainBundle]];
	patchViewController.instrument = instrument;
	patchViewController.appDelegate = self;
	patchViewController.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[patchViewController.closeButton setImage:[UIImage imageNamed:@"soundmenu-b-close.png"] forState:UIControlStateNormal];
	[patchViewController.closeButton setImage:[UIImage imageNamed:@"soundmenu-b-close.png"] forState:UIControlStateHighlighted];
	[patchViewController.closeButton addTarget:patchViewController action:@selector(slideOutView) forControlEvents:UIControlEventTouchUpInside];

	patchViewController.closeButton.frame = CGRectMake(410, -60, 60, 50);
//	[self positionLandscapeElement:patchViewController.closeButton window:window screen:screen 
//								 x:14
//								 y:-60
//							 width:50 
//							height:60];

	patchViewController.view.frame = CGRectMake(0,
												0 - patchViewController.view.frame.size.height,
												patchViewController.view.frame.size.width,
												patchViewController.view.frame.size.height);
	//	[self positionLandscapeElement:[patchViewController view] window:window screen:screen 
//								 x:0 
//								 y:0 - [patchViewController view].frame.size.height
//							 width:[patchViewController view].frame.size.width 
//							height:[patchViewController view].frame.size.height];
	[masterView insertSubview:patchViewController.view belowSubview:splashView1];
	[masterView insertSubview:patchViewController.closeButton belowSubview:patchViewController.view];
	

	
	setupViewController = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:[NSBundle mainBundle]];
	setupViewController.appDelegate = self;
	[masterView insertSubview:setupViewController.view belowSubview:splashView1];
	setupViewController.view.frame = CGRectMake(0,
												0 - setupViewController.view.frame.size.height,
												setupViewController.view.frame.size.width,
												setupViewController.view.frame.size.height);
	//	[self positionLandscapeElement:[setupViewController view] window:window screen:screen 
//								 x:0 
//								 y:0 - [setupViewController view].frame.size.height
//							 width:[setupViewController view].frame.size.width 
//							height:[setupViewController view].frame.size.height];

	recViewController = [[RecViewController alloc] initWithNibName:@"RecViewController" bundle:[NSBundle mainBundle]];
	recViewController.appDelegate = self;
	[masterView insertSubview:recViewController.view belowSubview:splashView1];
	recViewController.view.frame = CGRectMake(0,
											  0 - recViewController.view.frame.size.height,
											  recViewController.view.frame.size.width,
											  recViewController.view.frame.size.height);
	//	[self positionLandscapeElement:[recViewController view] window:window screen:screen 
//								 x:0 
//								 y:0 - [recViewController view].frame.size.height
//							 width:[recViewController view].frame.size.width 
//							height:[recViewController view].frame.size.height];
	
	
	loopViewController = [[LoopViewController alloc] initWithNibName:@"LoopViewController" bundle:[NSBundle mainBundle]];
	loopViewController.loopPlayer = loopPlayer;
	loopViewController.appDelegate = self;
	loopViewController.view.frame = CGRectMake(0,
											   0 - loopViewController.view.frame.size.height,
											   loopViewController.view.frame.size.width,
											   loopViewController.view.frame.size.height);
											   
	[masterView insertSubview:loopViewController.view belowSubview:splashView1];
//	[self positionLandscapeElement:[loopViewController view] window:window screen:screen 
//								 x:0
//								 y:0 - [loopViewController view].frame.size.height
//							 width:[loopViewController view].frame.size.width 
//							height:[loopViewController view].frame.size.height];

	miniMapView = [[MiniMapView alloc] init];
	miniMapView.opaque = YES;
	miniMapView.exclusiveTouch = YES;
	miniMapView.userInteractionEnabled =YES;
	[masterView insertSubview:miniMapView aboveSubview:surfaceViewController.view];
	miniMapView.frame = CGRectMake(0, 62, 480, 55);
//	[self positionLandscapeElement:miniMapView window:window screen:screen 
//								 x:0
//								 y:62
//							 width:480 
//							height:55];
	
	upperViewController = [[UpperViewController alloc] initWithNibName:@"UpperViewController" bundle:[NSBundle mainBundle]];
	upperViewController.appDelegate = self;
	upperViewController.instrument = instrument;
	upperViewController.surfaceViewController = surfaceViewController;

	[masterView insertSubview:upperViewController.view aboveSubview:surfaceViewController.view];
//	[self positionLandscapeElement:[upperViewController view] window:window screen:screen 
//								 x:0
//								 y:0 
//							 width:[upperViewController view].frame.size.width 
//							height:[upperViewController view].frame.size.height];


	
	glVectorOverlayView = [[GLVectorOverlayView alloc] initWithFrame:CGRectMake(0, 115, 480, 205) instrument:instrument];
	glVectorOverlayView.opaque = NO;
	glVectorOverlayView.exclusiveTouch = NO;
	glVectorOverlayView.userInteractionEnabled = NO;
	
	// cpu detection for ogl frame rate
	
	NSString* machine = [[UIDevice currentDevice] machine];
	if(machine != nil &&
	   ([machine isEqualToString:@"iPod1,1"] || 
		[machine isEqualToString:@"iPod1,2"] ||
		[machine isEqualToString:@"iPhone1,1"] ||
		[machine isEqualToString:@"iPhone1,2"])) {
	   // gen 1 cpu - slow
		NSLog(@"AppDelegate: gen 1 cpu detected.  running OGL @ 20fps");
		glVectorOverlayView.animationInterval = 1.0 / 20.0;
	} else {
		// assume fast
		NSLog(@"AppDelegate: fast cpu detected.  running OGL @ 60fps");
		glVectorOverlayView.animationInterval = 1.0 / 60.0;
	}
	
	//3GS+ 1/60
	//older: 1/30 looks great
	glVectorOverlayView.animationInterval = 1.0 / 20.0;
	//glVectorOverlayView.hidden = YES;

	[glVectorOverlayView startAnimation];


	[masterView insertSubview:glVectorOverlayView aboveSubview:surfaceViewController.view];
//	[self positionLandscapeElement:glVectorOverlayView window:window screen:screen 
//								 x:0 
//								 y:UI_MAINCONTROLS_HEIGHT 
//							 width:UI_SCREEN_WIDTH 
//							height:UI_KEYS_HEIGHT];
	
	patchPickerViewController = [[PatchPickerViewController alloc] init];
	patchPickerViewController.view.frame = CGRectMake(UI_PATCHPICKERVC_XOFFSET,
													  UI_PATCHPICKERVC_YOFFSET,
													  UI_PATCHPICKERVC_WIDTH,
													  UI_PATCHPICKERVC_HEIGHT);
//	[self positionLandscapeElement:patchPickerViewController.view window:window screen:screen 
//								 x:UI_PATCHPICKERVC_XOFFSET
//								 y:UI_PATCHPICKERVC_YOFFSET
//							 width:UI_PATCHPICKERVC_WIDTH 
//							height:UI_PATCHPICKERVC_HEIGHT]; //GSB: bug when it's 0
	[masterView addSubview:patchPickerViewController.view];
	patchPickerViewController.appDelegate = self;
	patchPickerViewController.view.hidden = YES;
	
	scalePickerViewController = [[ScalePickerViewController alloc] init];
	scalePickerViewController.view.frame = CGRectMake(UI_SCALEPICKERVC_XOFFSET,
													  UI_SCALEPICKERVC_YOFFSET,
													  UI_SCALEPICKERVC_WIDTH,
													  UI_SCALEPICKERVC_HEIGHT);
//	[self positionLandscapeElement:scalePickerViewController.view window:window screen:screen 
//								 x:UI_SCALEPICKERVC_XOFFSET
//								 y:UI_SCALEPICKERVC_YOFFSET
//							 width:UI_SCALEPICKERVC_WIDTH 
//							height:UI_SCALEPICKERVC_HEIGHT]; //GSB: bug when it's 0
	[masterView addSubview:scalePickerViewController.view];
	scalePickerViewController.appDelegate = self;
	scalePickerViewController.view.hidden = YES;
	
	loopPickerViewController = [[LoopPickerViewController alloc] init];
	loopPickerViewController.view.frame = CGRectMake(UI_LOOPPICKERVC_XOFFSET,
													  UI_LOOPPICKERVC_YOFFSET,
													  UI_LOOPPICKERVC_WIDTH,
													  UI_LOOPPICKERVC_HEIGHT);
//	[self positionLandscapeElement:loopPickerViewController.view window:window screen:screen 
//								 x:UI_LOOPPICKERVC_XOFFSET
//								 y:UI_LOOPPICKERVC_YOFFSET
//							 width:UI_LOOPPICKERVC_WIDTH 
//							height:UI_LOOPPICKERVC_HEIGHT]; //GSB: bug when it's 0
	[masterView addSubview:loopPickerViewController.view];
	loopPickerViewController.appDelegate = self;
	loopPickerViewController.view.hidden = YES;

	recPickerViewController = [[RecPickerViewController alloc] init];
	recPickerViewController.view.frame = CGRectMake(UI_RECPICKERVC_XOFFSET,
													  UI_RECPICKERVC_YOFFSET,
													  UI_RECPICKERVC_WIDTH,
													  UI_RECPICKERVC_HEIGHT);
//	[self positionLandscapeElement:recPickerViewController.view window:window screen:screen 
//								 x:UI_RECPICKERVC_XOFFSET
//								 y:UI_RECPICKERVC_YOFFSET
//							 width:UI_RECPICKERVC_WIDTH 
//							height:UI_RECPICKERVC_HEIGHT]; //GSB: bug when it's 0
	[masterView addSubview:recPickerViewController.view];
	recPickerViewController.appDelegate = self;
	recPickerViewController.view.hidden = YES;
	
	emptyLandscapeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT)];
	emptyLandscapeView.userInteractionEnabled = NO;
	[masterView addSubview:emptyLandscapeView];
//	[self positionLandscapeElement:emptyLandscapeView window:window screen:screen 
//								 x:0 
//								 y:0 
//							 width:UI_SCREEN_WIDTH 
//							height:UI_SCREEN_HEIGHT];
	
	

	
	
	//GSB TODO POSTLAUNCH IN APP PURCHASE PERSISTENCE
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];  
	NSString* presetBehavior = [userDefaults stringForKey:@"presetBehavior"];
//	NSLog(@"AppDelegate: -loadInterface **** loaded presetBehavior '%@' from userDefaults", presetBehavior);
	if(presetBehavior == nil) {
		[userDefaults setObject:@"octave_only" forKey:@"presetBehavior"];  
		[userDefaults synchronize];
	}
	
	
	
	//[self loadData];
	[self showSplashScreen2];
	
	
	[glVectorOverlayView viewNeedsUpdate];
	[glVectorOverlayView drawView]; //initial draw
	
	[Appirater appLaunched];
	
}	

-(void) showPatchView {
	[patchViewController slideInView];
}
-(void) showEffectsView {
	[setupViewController slideInView];
}
-(void) showMainMenuView {
	[recViewController slideInView];
}
-(void) showLoopView {
	[loopViewController slideInView];
}

//-(void) showMainMenu {
//	// open a dialog with an OK and cancel button
//	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Hexaphone Release %@ - Main Menu", appVersion]
//															 delegate:self 
//													cancelButtonTitle:@"Close Menu"
//											   destructiveButtonTitle:@"Start Recording"
//													otherButtonTitles:
//								  @"Configure Accelerometer", 
//								  @"Configure Instrument", 
//								  nil
//								  ];
//	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque; 
//	[actionSheet showInView:emptyLandscapeView];
//	[actionSheet release];
//	
//}
//
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//	NSLog(@"AppDelegate: actionSheet buttonClickedAtIndex[%d]", buttonIndex);
//	
//}

-(void) setKeyboardOffsetByNumber:(NSNumber*) offset {
	[self setKeyboardOffset:[offset intValue]];
}

-(void) setKeyboardOffset:(SInt16) offset {
	
	CGRect keysFrame = surfaceViewController.keysView.frame;
	SInt16 currentOffset = keysFrame.origin.x;
	SInt16 delta = offset - currentOffset;
	keysFrame.origin.x = offset;
	surfaceViewController.keysView.frame = keysFrame;

	
	currentKeyboardOffset = offset;
	
	glVectorOverlayView.offsetX = -40 - surfaceViewController.keysView.frame.origin.x;
	if(instrument.keysArePlaying > 0) {
		[glVectorOverlayView viewNeedsUpdate];
		//[glVectorOverlayView drawView]; //offset changed, redraw
		[instrument slideTouchPoints:delta];
	}
	
}

#define kAnimationSteps 6.0
#define kAnimationDuration 0.2
-(void) setKeyboardOffsetManuallyAnimated:(SInt16) offset {
	
	CGRect keysFrame = surfaceViewController.keysView.frame;
	SInt16 currentOffset = keysFrame.origin.y;
	SInt16 delta = offset - currentOffset;
	
	for(double percentage = 1.0/kAnimationSteps; percentage <= 1.0; percentage += 1.0/kAnimationSteps) {
		// 0.1, 0.2, 0.3 ... 1.0
		
		[self performSelector:@selector(setKeyboardOffsetByNumber:) 
				   withObject:[NSNumber numberWithInt:(int) currentOffset + (delta * percentage)] 
				   afterDelay:kAnimationDuration * percentage];
	}
	
}

- (void) positionLandscapeElement:(UIView*)element window:(UIWindow*)windowParam screen:(UIScreen*)screen x:(float)x y:(float)y width:(float)width height:(float)height {

//	NSLog(@"AppDelegate: -positionLandscapeElement x:%.0f y:%.0f width:%.0f height:%.0f", x, y, width, height);
	
	element.bounds = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
	element.transform = CGAffineTransformConcat(element.transform, CGAffineTransformMakeRotation(M_PI / -2));
	element.center = windowParam.center;
	
	CGRect landscapeFrame = element.frame;
	landscapeFrame.origin.x = (CGFloat) y;				// Y for X
	landscapeFrame.origin.y = (CGFloat) x;				// X for Y
	landscapeFrame.size.width = (CGFloat) height;		// Y for X
	landscapeFrame.size.height = (CGFloat) width;		// X for Y
	element.frame = landscapeFrame;

}

// called by instrument
-(void) changedPatchId:(NSString*) patchId scaleId:(NSString*) scaleId tuningId:(NSString*) tuningId {
//	NSLog(@"changedPatch:%@ scale:%@ key:%@", patchId, scaleId, tuningId);
	
	[patchManager setActivePatchId:patchId];
	[scaleManager setActiveScaleId:scaleId];

	[patchViewController.patchButton setTitle:instrument.patch.patchName forState:UIControlStateNormal];
	[patchViewController.scaleButton setTitle:instrument.scale.scaleName forState:UIControlStateNormal];
	
	[self commitLastPatchSession];
	
	lastPatchSession = [[NSMutableDictionary alloc] init];
	[lastPatchSession setObject:patchId forKey:@"p"];
	[lastPatchSession setObject:scaleId forKey:@"s"];
	[lastPatchSession setObject:tuningId forKey:@"k"];
	
	patchLastChanged = [NSDate timeIntervalSinceReferenceDate];

	
	[appStateManager.appState changePatchId:patchId];
	[appStateManager.appState changeScaleId:scaleId];
	appStateManager.appState.tuningId = tuningId;

	[surfaceViewController updateLabels];
	
	[patchPickerViewController.tableView reloadData];
	[scalePickerViewController.tableView reloadData];

}

#define kMinimumPatchDurationForLogging 30.0
-(void) commitLastPatchSession {
	if(patchLastChanged != 0.0 && lastPatchSession != nil) {
		NSTimeInterval lastPatchSessionDuration = [NSDate timeIntervalSinceReferenceDate] - patchLastChanged;
		if(lastPatchSessionDuration > kMinimumPatchDurationForLogging) {
			[lastPatchSession setObject:[NSNumber numberWithInt:(int)lastPatchSessionDuration] forKey:@"d"];
			[arrPatchSessions addObject:lastPatchSession];
		}
	}
}

-(void) changedLoop:(NSString*) loopId {

	[loopViewController.loopDropdownButton setTitle:[[loopPlayer activeLoop] label] forState:UIControlStateNormal];

//	Scale* scale = [scaleManager.scalesMap objectForKey:[loopPlayer activeLoop].scaleId];
//	NSString* tuningId = [loopPlayer activeLoop].tuningId;
//	
	[appStateManager.appState changeLoopId:loopId];
	[loopPickerViewController.tableView reloadData];
	[recPickerViewController.tableView reloadData];

//	[loopViewController.autoTuneButton 
//	 setTitle:[NSString stringWithFormat:@"%@ / %@", scale.scaleName, tuningId]
//	 forState:UIControlStateNormal];

	
	appStateManager.appState.loopId = loopId;
	
}

-(void) startedLoopPlayback {
	[self commitLastLoopSession];
	lastLoopSession = [[NSMutableDictionary alloc] init];
	[lastLoopSession setObject:appStateManager.appState.loopId forKey:@"t"];
	
	loopLastChanged = [NSDate timeIntervalSinceReferenceDate];
	[recordingManager startedLoopId:[loopPlayer activeLoop].loopId];
	//[upperViewController.loopToggleButton setTitle:@"STOP" forState:UIControlStateNormal];
}
-(void) stoppedLoopPlayback {
	[recordingManager stoppedLoop];
	//[upperViewController.loopToggleButton setTitle:@"PLAY" forState:UIControlStateNormal];
}
#define kMinimumTrackDurationForLogging 30.0
-(void) commitLastLoopSession {
	if(loopLastChanged != 0.0 && lastLoopSession != nil) {
		NSTimeInterval lastTrackSessionDuration = [NSDate timeIntervalSinceReferenceDate] - loopLastChanged;
		if(lastTrackSessionDuration > kMinimumTrackDurationForLogging) {
			[lastLoopSession setObject:[NSNumber numberWithInt:(int)lastTrackSessionDuration] forKey:@"d"];
			[arrLoopSessions addObject:lastLoopSession];

		}
	}
}

-(void) initializeAnalytics {
	patchLastChanged = 0.0;
	loopLastChanged = 0.0;
	
	if(arrPatchSessions != nil)
		[arrPatchSessions release];
	arrPatchSessions = [[NSMutableArray alloc] init];

	if(arrLoopSessions != nil)
		[arrLoopSessions release];
	arrLoopSessions = [[NSMutableArray alloc] init];
	
	if(lastPatchSession != nil)
		[lastPatchSession release];
	lastPatchSession = nil;
	
	if(lastLoopSession != nil)
		[lastLoopSession release];
	lastLoopSession = nil;
}

-(void) commitAnalytics {
	
	// GSB 20101214 disabled
	
//	[self commitLastPatchSession];
//	[self commitLastLoopSession];
//	
//	if(([arrPatchSessions count] > 0 && [arrLoopSessions count] > 0)) {
//		
//		Reachability *r = [Reachability reachabilityWithHostName:@"impresariodigital.com"];
//		NetworkStatus internetStatus = [r currentReachabilityStatus];
//		if(internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
//			
//			//NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
//			
//			NSDateFormatter *dfTidy = [[NSDateFormatter alloc] init];
//			[dfTidy setDateFormat:@"yyyy-MM-dd-HHmm"];
//			
//			//NSString* dateStamp = [[NSDate date] description];
//			NSString* dateStamp = [dfTidy stringFromDate:[NSDate date]];
//			NSTimeInterval appRunDuration = [NSDate timeIntervalSinceReferenceDate] - appStarted;
//			
//			NSMutableDictionary* hsession = [[NSMutableDictionary alloc] init];
//			[hsession setObject:[NSString stringWithFormat:@"%@.%@", dateStamp, appStateManager.appState.uuid] forKey:@"_id"];
//			[hsession setObject:@"hsession" forKey:@"type"];
//			[hsession setObject:dateStamp forKey:@"date"];
//			[hsession setObject:appStateManager.appState.startupCount forKey:@"runs"];
//			[hsession setObject:[NSNumber numberWithInt:(int)appRunDuration] forKey:@"d"];
//			[hsession setObject:arrPatchSessions forKey:@"patches"];
//			[hsession setObject:arrLoopSessions forKey:@"loops"];
//			//			if(instrument.externalSpeakerWasUsed)
//			//				[hsession setObject:instrument.externalSpeakerWasUsed?@"Y":@"N" forKey:@"externalSpeakerWasUsed"];
//			if(numRecordingsMade > 0) 
//				[hsession setObject:[NSNumber numberWithInt:(int)numRecordingsMade] forKey:@"recMade"];
//			if(numRecordingsSaved > 0)
//				[hsession setObject:[NSNumber numberWithInt:(int)numRecordingsSaved] forKey:@"recSaved"];
//			
//			
//			SBJSON* sbJson = [[SBJSON alloc] init];
//			NSString *jsonString = [sbJson stringWithObject:hsession error:nil];
//			[sbJson release];
//			[hsession release]; //TODO validate release
//			
//			
//			NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
//			[request setURL:[NSURL URLWithString:@"http://impresariodigital.com/hexaphone-cloud/ws/hsession"]];
//			[request setHTTPMethod:@"POST"];
//			[request setTimeoutInterval:10.0];
//			[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//			[request setHTTPBody: [jsonString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
//			
//			NSURLResponse* response;
//			NSError* error;
//			[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//			
//			[request release];
//		}
//	}
}

-(void) applicationWillTerminate:(UIApplication *)application {
	[recordingManager stopRecording];
	[loopPlayer stop];
	[recordingPlayer stop];
	[appStateManager saveToPreferences];
	
	if(recordingManager.recordingRecording.isLatest && recordingManager.recordingRecording.isUnsaved) {
		[recordingManager saveLatestRecording];
	}

	[self commitAnalytics];
}

-(void) applicationDidEnterBackground:(UIApplication *)application {
	[recordingManager stopRecording];
	[loopPlayer stop];
	[recordingPlayer stop];
	[glVectorOverlayView stopAnimation];

	[appStateManager saveToPreferences];
	
	if(recordingManager.recordingRecording.isLatest && recordingManager.recordingRecording.isUnsaved) {
		[recordingManager saveLatestRecording];
	}

	[self commitAnalytics];
	
}

-(void) applicationWillEnterForeground:(UIApplication *)application {
	[self initializeAnalytics];
	
	if(setupViewController.isKeyIllumEnabled) {
		[glVectorOverlayView startAnimation];
	}
	
	[recPickerViewController initializeFeaturedRecordings];
	[recPickerViewController.tableView reloadData];
	
	//[Appirater appLaunched];
	
	[Appirater performSelector:@selector(appLaunched) 
			   withObject:nil 
			   afterDelay:1.0f];
	
	[instrument reloadPatchesRIO];
	
}


- (void)dealloc {
    [window release];
	
	//TODO POSTLAUNCH: release
	
	[upperViewController release];
	[super dealloc];
}



#define kMinimumSecondsBetweenEvents 1.00f

//-(void) receivedRotateNotification: (NSNotification*) notification
//{
//	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
//	if(now - lastBumpTime > kMinimumSecondsBetweenEvents) {
//		UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
//		switch (interfaceOrientation) {
//			case UIDeviceOrientationPortrait:
//				//			NSLog(@"UIDeviceOrientationPortrait");
//				[self bumpLeft];
//				lastBumpTime = now;
//				break;
//			case UIDeviceOrientationPortraitUpsideDown:
//				//			NSLog(@"UIDeviceOrientationPortraitUpsideDown");
//				[self bumpRight];
//				lastBumpTime = now;
//				break;
//				//		case UIDeviceOrientationLandscapeLeft:
//				//			NSLog(@"UIDeviceOrientationLandscapeLeft");
//				//			break;
//				//		case UIDeviceOrientationLandscapeRight:
//				//			NSLog(@"UIDeviceOrientationLandscapeRight");
//				//			break;
//				//		case UIDeviceOrientationFaceUp:
//				//			NSLog(@"UIDeviceOrientationFaceUp");
//				//			break;
//				//		case UIDeviceOrientationFaceDown:
//				//			NSLog(@"UIDeviceOrientationFaceDown");
//				//			break;
//				//		default:
//				//			break;
//		}
//	}
//}


double rad_to_deg(double radians) {return (radians * 180.0) / M_PI;};





// GSB 201000810 - reviving for lowpass2
//
// UIAccelerometerDelegate method, called when the device accelerates.
//
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	
	// 3g: yes
	// 4: no
	
	// like a steering wheel (-90 left, 0 upright, +90 right)
	double tilt = rad_to_deg(atan2(acceleration.y, acceleration.x));
	
	// like a pedal (-90 flat, 0 upright (3g) / -180 upright (4), +90 upside-down)
	double pitch = rad_to_deg(atan2(acceleration.z, acceleration.x));
	if(!appStateManager.appState.rotateView) {
		if(pitch > 0) { 
			// turn positive numbers into 0
			pitch = 0.0; 
		} else {
			// turn -95 into -85
			// turn -135 into -45
			// turn -180 into 0
			pitch = -90.0 - (pitch + 90.0);
		}
	}
	// lateral pitch (-90 portrait, +90 upside-down portrait)
	double pitch2 = fabs(rad_to_deg(atan2(acceleration.y, acceleration.z)));
	
	lastTilts[curAccelArrayIndex] = tilt;
	lastPitches[curAccelArrayIndex] = pitch;
	lastPitch2s[curAccelArrayIndex] = pitch2;
	
	//int lastAccelArrayIndex = curAccelArrayIndex;
	curAccelArrayIndex = (curAccelArrayIndex + 1 ) % kAccelerometerAverageSampleSize;
	//	lastXs[curAccelArrayIndex] = acceleration.x;
	//	lastYs[curAccelArrayIndex] = acceleration.y;
	//	lastZs[curAccelArrayIndex] = acceleration.z;
	//	deltaXs[curAccelArrayIndex] = lastXs[lastAccelArrayIndex] - acceleration.x;
	//	deltaYs[curAccelArrayIndex] = lastYs[lastAccelArrayIndex] - acceleration.y;
	//	deltaZs[curAccelArrayIndex] = lastZs[lastAccelArrayIndex] - acceleration.z;
	
	//	double averageX, averageY, averageZ, averageDeltaX, averageDeltaY, averageDeltaZ = 0.0f;
//	double averageTilt, averagePitch, averagePitch2 = 0.0f;
	double averageTilt = 0.0f;
	double averagePitch = 0.0f;
	double averagePitch2 = 0.0f;
	for(int i=0; i<kAccelerometerAverageSampleSize; i++) {
		averageTilt += lastTilts[i] / (double) kAccelerometerAverageSampleSize;
		averagePitch += lastPitches[i] / (double) kAccelerometerAverageSampleSize;
		averagePitch2 += lastPitch2s[i] / (double) kAccelerometerAverageSampleSize;
		
		//		averageX += lastXs[i] / (double) kAccelerometerAverageSampleSize;
		//		averageY += lastYs[i] / (double) kAccelerometerAverageSampleSize;
		//		averageZ += lastZs[i] / (double) kAccelerometerAverageSampleSize;
		//		
		//		averageDeltaX += deltaXs[i] / (double) kAccelerometerAverageSampleSize;
		//		averageDeltaY += deltaYs[i] / (double) kAccelerometerAverageSampleSize;
		//		averageDeltaZ += deltaZs[i] / (double) kAccelerometerAverageSampleSize;
	}
	
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	if(now - lastAccelerationLoggingTime > kLoggingInterval) {
		lastAccelerationLoggingTime = now;
		
//		NSLog(@"pitch: %4.0f (%4.0f avg)", pitch, averagePitch);
//		NSLog(@"pitch2: %4.0f (%4.0f avg) / pitch: %4.0f (%4.0f avg) / tilt: %4.0f (%4.0f avg)", pitch2, averagePitch2, pitch, averagePitch, tilt, averageTilt);
		
	}
	
	// pitch2:
	//   0 - vertical
	// -90 - flat
	
	if(averagePitch < 0) {
		[instrument setPedalAngle:fabs(averagePitch)];
		
		if(averagePitch >= -90) {
			lastAveragePitch = fabs(averagePitch);
		} else {
			lastAveragePitch = 90.0f;
		}
	} else {
		[instrument setPedalAngle:0.0f];
		lastAveragePitch = 0.0f;
	}

	
	
	//
//	// if it's been awhile since the last event...
//	if(now - lastBumpTime > kMinimumSecondsBetweenEvents) {
//		// if the pedal pitch is close to upright...
//		if(((-30.0 < averagePitch && averagePitch < 30.0) && (-30.0 < pitch && pitch < 30.0)) ||
//		   ((80.0 < averagePitch2 && averagePitch2 < 100.0) && (80.0 < averagePitch2 && averagePitch2 < 100.0))) {
//			if(now - lastAccelerationLoggingTime > kLoggingInterval) {
//				NSLog(@"pitch: OK");
//			}
//			// if the tilt is close to full right
//			if(45.0 < averageTilt && averageTilt < 135.0 && 45.0 < tilt && tilt < 135.0) {
//				NSLog(@"pitch2: %4.0f (%4.0f avg) / pitch: %4.0f (%4.0f avg) / tilt: %4.0f (%4.0f avg)  TILTING RIGHT", pitch2, averagePitch2, pitch, averagePitch, tilt, averageTilt);
//				lastBumpTime = now;
//				[self bumpRight];
//			} else if(-135.0 < averageTilt && averageTilt < -45.0 && -135.0 < tilt && tilt < -45.0) {
//				NSLog(@"pitch2: %4.0f (%4.0f avg) / pitch: %4.0f (%4.0f avg) / tilt: %4.0f (%4.0f avg)  TILTING LEFT", pitch2, averagePitch2, pitch, averagePitch, tilt, averageTilt);
//				lastBumpTime = now;
//				[self bumpLeft];
//			}
//		}
//	}
	
	
	// -0.25 -> -1.0+
	
	
}

@end
