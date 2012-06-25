//
//  RecordingPlayer.h
//  Hexatone
//
//  Created by Glenn Barnett on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Recording;

@class HexaphoneAppDelegate;
@class Instrument;
@class LoopPlayer;

@interface RecordingPlayer : NSObject {

	Recording* loadedRecording;

	uint64_t recPlaybackIterationStartTime;
	double ticksToMilliseconds;
	
	double cpuPlaySliceIntervalSec;
	SInt64 cpuPlaySliceLatencyCompensationMs;
	
	BOOL isRecordingPlaying;
	BOOL repeatPlayback;
	BOOL willPlaybackRepeat;
	NSTimer* playbackTimer;
	NSThread* playSliceThread;
	NSTimeInterval playbackStartTime;


	SInt64 nextEventMsCached;
	BOOL cursorHasMoved;
	BOOL delayedStartRequestIsPending;
	float loopPlaybackDurationBeforeStart;
	
	HexaphoneAppDelegate* appDelegate;
	Instrument* instrument;
	LoopPlayer* loopPlayer;
	
}
@property (nonatomic) BOOL repeatPlayback;
@property (nonatomic, retain) Recording* loadedRecording;
@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;
@property (nonatomic, retain) Instrument* instrument;
@property (nonatomic, retain) LoopPlayer* loopPlayer;

-(BOOL) isRecordingPlaying;
-(void) loadRecording:(Recording*) recording;
-(void) loadRecordingFromURL:(NSURL*) recordingFileURL reloadInstrument:(BOOL) reloadInstrument indicateModified:(BOOL)indicateModified;
-(void) togglePlayback;
-(void) toggleRepeatPlayback;
-(void) resetProgressMeter;
-(void) repeat;
-(void) loopIterated;
-(void) stop;
-(void) startFromToggle;
-(void) killPlaySliceThread;
-(void) startPlaySliceThread;


@end
