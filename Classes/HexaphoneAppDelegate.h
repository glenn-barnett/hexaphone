//
//  HexatoneAppDelegate.h
//  Hexatone
//
//  Created by Glenn Barnett on 1/3/09.
//  Copyright Impresario Digital 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Texture2D.h"


@class Reachability;

@class Instrument;
@class LoopPlayer;
@class RecordingPlayer;

@class AppState;

@class ScaleManager;
@class PatchManager;
@class AppStateManager;
@class LoopManager;
@class RecordingManager;
@class NotesManager;

@class UpperViewController;
@class PatchViewController;
@class SetupViewController;
@class RecViewController;
@class LoopViewController;
@class SurfaceViewController;
@class GLVectorOverlayView;
@class MiniMapView;

@class PatchPickerViewController;
@class ScalePickerViewController;
@class LoopPickerViewController;
@class RecPickerViewController;

@class EmptyLandscapeViewController;

#define kAccelerometerFrequency 60.0f
#define kAccelerometerAverageSampleSize 6 
//#define kAccelerometerFrequency 120.0f
//#define kAccelerometerAverageSampleSize 20
#define kLoggingInterval 0.25f

@interface HexaphoneAppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate, UIActionSheetDelegate> {

	UIWindow *window;

	ScaleManager* scaleManager;
	PatchManager* patchManager;
	AppStateManager* appStateManager;
	LoopManager* loopManager;
	RecordingManager* recordingManager;
	NotesManager* notesManager;
	
	Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;

	double lastAveragePitch;
	double lastPitches[kAccelerometerAverageSampleSize];
	double lastPitch2s[kAccelerometerAverageSampleSize];
	double lastTilts[kAccelerometerAverageSampleSize];

//	double lastXs[kAccelerometerAverageSampleSize];
//	double lastYs[kAccelerometerAverageSampleSize];
//	double lastZs[kAccelerometerAverageSampleSize];
//	
//	double deltaXs[kAccelerometerAverageSampleSize];
//	double deltaYs[kAccelerometerAverageSampleSize];
//	double deltaZs[kAccelerometerAverageSampleSize];
	
	int curAccelArrayIndex;

	NSTimeInterval lastAccelerationLoggingTime;
	NSTimeInterval lastBumpTime;
	//	BOOL bumpEligible;
	
	
	SInt16 currentKeyboardOffset;
	
	UIView* masterView;
	UIView* splashView1;
	UIView* splashView2;
	UIView* emptyLandscapeView;
	EmptyLandscapeViewController* emptyLandscapeViewController;
	NSString* appVersion;

	Instrument* instrument;
	LoopPlayer* loopPlayer;
	RecordingPlayer* recordingPlayer;
	NSURL* openedRecordingURL;
	
	GLVectorOverlayView* glVectorOverlayView;
	MiniMapView* miniMapView;
	
	SurfaceViewController* surfaceViewController;
	UpperViewController* upperViewController;
	PatchViewController* patchViewController;
	SetupViewController* setupViewController;
	RecViewController* recViewController;
	LoopViewController* loopViewController;
	
	NSTimeInterval patchLastChanged;
	NSTimeInterval loopLastChanged;
	NSTimeInterval appStarted;
	
	NSMutableDictionary* lastPatchSession;
	NSMutableDictionary* lastLoopSession;
	int numRecordingsMade;
	int numRecordingsSaved;
	
	NSMutableArray* arrPatchSessions;
	NSMutableArray* arrLoopSessions;
	
	PatchPickerViewController* patchPickerViewController;
	ScalePickerViewController* scalePickerViewController;
	LoopPickerViewController* loopPickerViewController;
	RecPickerViewController* recPickerViewController;

}


@property SInt16 currentKeyboardOffset;

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) UIView* masterView;
@property (nonatomic, retain) UIView* splashView1;
@property (nonatomic, retain) UIView* emptyLandscapeView;

@property (nonatomic, retain) Instrument* instrument;
@property (nonatomic, retain) LoopPlayer* loopPlayer;
@property (nonatomic, retain) RecordingPlayer* recordingPlayer;

@property (nonatomic, retain) ScaleManager* scaleManager;
@property (nonatomic, retain) PatchManager* patchManager;
@property (nonatomic, retain) AppStateManager* appStateManager;
@property (nonatomic, retain) LoopManager* loopManager;
@property (nonatomic, retain) RecordingManager* recordingManager;
@property (nonatomic, retain) NotesManager* notesManager;

@property (nonatomic, retain) SurfaceViewController* surfaceViewController;
@property (nonatomic, retain) GLVectorOverlayView* glVectorOverlayView;
@property (nonatomic, retain) UpperViewController* upperViewController;

@property (nonatomic, retain) PatchViewController* patchViewController;
@property (nonatomic, retain) SetupViewController* setupViewController;
@property (nonatomic, retain) RecViewController* recViewController;
@property (nonatomic, retain) LoopViewController* loopViewController;

@property (nonatomic, retain) PatchPickerViewController* patchPickerViewController;
@property (nonatomic, retain) ScalePickerViewController* scalePickerViewController;
@property (nonatomic, retain) LoopPickerViewController* loopPickerViewController;
@property (nonatomic, retain) RecPickerViewController* recPickerViewController;

@property (nonatomic, retain) EmptyLandscapeViewController* emptyLandscapeViewController;

@property (nonatomic) int numRecordingsMade;
@property (nonatomic) int numRecordingsSaved;
@property (nonatomic) double lastAveragePitch;

-(void) setKeyboardOffsetByNumber:(NSNumber*) offset;
-(void) setKeyboardOffset:(SInt16) offset;
-(void) setKeyboardOffsetManuallyAnimated:(SInt16) offset;

-(void) showPatchView;
-(void) showEffectsView;
-(void) showMainMenuView;
-(void) showLoopView;

-(void) positionLandscapeElement:(UIView*)element window:(UIWindow*)window screen:(UIScreen*)screen x:(float)x y:(float)y width:(float)width height:(float)height;
-(void) loadInterface;
-(void) loadData;
-(void) positionElements;


-(void) changedPatchId:(NSString*) toneId scaleId:(NSString*) scaleId tuningId:(NSString*) tuningId;
-(void) commitLastPatchSession;
-(void) changedLoop:(NSString*) loopId;
-(void) startedLoopPlayback;
-(void) stoppedLoopPlayback;
-(void) commitLastLoopSession;

-(void) hideSplashScreens;

-(void) initializeAnalytics;
-(void) commitAnalytics;		

-(void) changeViewRotation;
	

@end

