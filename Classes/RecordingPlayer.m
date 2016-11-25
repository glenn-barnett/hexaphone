//
//  RecordingPlayer.m
//  Hexatone
//
//  Created by Glenn Barnett on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RecordingPlayer.h"
#import "Recording.h"
#import "RecordedEvent.h"
#import "RecViewController.h"
#import "WaveRecViewController.h"

#import "HexaphoneAppDelegate.h"
#import "Instrument.h"
#import "LoopPlayer.h"
#import "Loop.h"
#import "SBJSON.h"
#import "GLVectorOverlayView.h"

#import "UIDevice+machine.h"

@implementation RecordingPlayer

@synthesize loadedRecording;
@synthesize appDelegate;
@synthesize instrument;
@synthesize loopPlayer;
@synthesize repeatPlayback;


// 3G cannot handle 0.01f interval
// 3G can handle 0.02f for playback, but doesnt leave enough left for accompaniment
// 3G sounds reasonable w/ 0.05 - but STILL not enough juice left for accomp

//#define SLOW_PLAYSLICE_INTERVAL_SEC 0.05f
//#define SLOW_PLAYSLICE_LATENCYCOMP_MS 15.0f
#define SLOW_PLAYSLICE_INTERVAL_SEC 0.05f 
#define SLOW_PLAYSLICE_LATENCYCOMP_MS 0ll // testing lower lookahead


#define MED_PLAYSLICE_INTERVAL_SEC 0.02f
#define MED_PLAYSLICE_LATENCYCOMP_MS 0ll

//#define FAST_PLAYSLICE_INTERVAL_SEC 0.005f	// -5ms latency peak
//#define FAST_PLAYSLICE_INTERVAL_SEC 0.01f		//  7ms latency peak
#define FAST_PLAYSLICE_INTERVAL_SEC 0.02f		// 25ms latency peak (still sounds good)
//#define FAST_PLAYSLICE_INTERVAL_SEC 0.03f		// 45ms latency peak (starting to sound bad)
#define FAST_PLAYSLICE_LATENCYCOMP_MS 0ll

//TODO disable latency comp?

- (id)init {
    self = [super init];
	
    if (self) {
		isRecordingPlaying = NO;
		repeatPlayback = YES;
		willPlaybackRepeat = NO;
		nextEventMsCached = 0ll;
		cursorHasMoved = YES;
		delayedStartRequestIsPending = NO;
		loopPlaybackDurationBeforeStart = 0.0f;

		
		NSString* machine = [[UIDevice currentDevice] machine];
		
		// The first time we get here, ask the system
		// how to convert mach time units to nanoseconds
		mach_timebase_info_data_t timebase;
		// to be completely pedantic, check the return code of this next call.
		mach_timebase_info(&timebase);
		double ticksToNanoseconds = (double)timebase.numer / timebase.denom;
		ticksToMilliseconds = ticksToNanoseconds / 1000000.0;
		
		
		if(machine != nil) {
			if([machine isEqualToString:@"iPod1,1"] || 
			   [machine isEqualToString:@"iPod1,2"] ||
			   [machine isEqualToString:@"iPhone1,1"] ||
			   [machine isEqualToString:@"iPhone1,2"]) {
				// gen 1 cpu - slow
				NSLog(@"gen 1 cpu detected.  using slow playslice");
				cpuPlaySliceIntervalSec = SLOW_PLAYSLICE_INTERVAL_SEC;
				cpuPlaySliceLatencyCompensationMs = SLOW_PLAYSLICE_LATENCYCOMP_MS;
				
			} else if([machine isEqualToString:@"iPhone2,1"] ||
					  [machine isEqualToString:@"i386"]) {
				NSLog(@"3gs cpu or simu detected.  using fast playslice");
				// 3gs or simu - fast
				cpuPlaySliceIntervalSec = FAST_PLAYSLICE_INTERVAL_SEC;
				cpuPlaySliceLatencyCompensationMs = FAST_PLAYSLICE_LATENCYCOMP_MS;
			} else {
				// unrecognized - assume fast
				NSLog(@"unrecognized cpu detected.  using fast playslice");
				cpuPlaySliceIntervalSec = FAST_PLAYSLICE_INTERVAL_SEC;
				cpuPlaySliceLatencyCompensationMs = FAST_PLAYSLICE_LATENCYCOMP_MS;
			}
		} else {
			// not found - assume fast
			NSLog(@"no cpu detected.  using fast playslice");
			cpuPlaySliceIntervalSec = FAST_PLAYSLICE_INTERVAL_SEC;
			cpuPlaySliceLatencyCompensationMs = FAST_PLAYSLICE_LATENCYCOMP_MS;
		}
				
				
		
		// 3g: OLD
		//#define kLatencyCompensationMs 50.0f
		//#define kPlaySliceFrequency 0.015f
		
		// 3g: OK
//		cpuPlaySliceIntervalSec = 0.05f;
//		cpuPlaySliceLatencyCompensationMs = 30.0f;

    }
    return self;
}

-(void) loadRecording:(Recording*) recording {
	//[loadedRecording release]; //GSB: this crashes
	loadedRecording = recording;
	[loadedRecording retain];
}


-(void) loadRecordingFromURL:(NSURL*) recordingFileURL reloadInstrument:(BOOL) reloadInstrument indicateModified:(BOOL)indicateModified{
	
	// 0. if latest recording hasn't been saved, save it
	if(appDelegate.recordingManager.recordingRecording.isLatest && appDelegate.recordingManager.recordingRecording.isUnsaved) {
		//		NSLog(@"RP:loadRecording: saving unsaved latest recording...");
		[appDelegate.recordingManager saveLatestRecording];
	}
	
	// 1. load recording
	NSStringEncoding encodingUsed;
	NSError* error = nil;
	NSString* jsonString = [[NSString stringWithContentsOfURL:recordingFileURL usedEncoding:&encodingUsed error:&error] retain];
	
	SBJSON* sbJson = [[SBJSON alloc] init];
	NSDictionary* dictJson = [sbJson objectWithString:jsonString error:nil];
	[sbJson release];
	
	NSString* filenameOnly = [[recordingFileURL path] lastPathComponent];
	
	//loadedRecording = [[Recording alloc] initWithDictionary:dictJson];
	NSLog(@"RecordingPlayer: loadRecordingPatchAndLoopFromFilename: RELEASING old loadedRecording");
	[loadedRecording release]; 
	[self loadRecording:[[Recording alloc] initWithDictionary:dictJson]];
	if([filenameOnly isEqualToString:@" Latest Recording.hexrec"]) {
		loadedRecording.isLatest = YES;
	}
	loadedRecording.fileName = filenameOnly; // i'm a riot.
	loopPlaybackDurationBeforeStart = loadedRecording.loopPlaybackDurationBeforeStart;

	if(reloadInstrument) {

		// 2. load instrument(patch,scale,use current key)
		if(instrument.patchId == nil ||
		   ![instrument.patchId isEqualToString:loadedRecording.initialPatchId] ||
		   instrument.scaleId == nil || 
		   ![instrument.scaleId isEqualToString:loadedRecording.initialScaleId] ||
		   instrument.tuning == nil ||
		   instrument.tuning.tuningId == nil || 
		   ![instrument.tuning.tuningId isEqualToString:loadedRecording.initialTuningId]) {
			[instrument loadPatchIdRIO:loadedRecording.initialPatchId scaleId:loadedRecording.initialScaleId tuningId:loadedRecording.initialTuningId];
		} else {
			//		NSLog(@"loadRecording: no patch change necessary");
		}
		
		if(loadedRecording.initialLoopId != nil && 
		   (loopPlayer.activeLoop != nil ||
			![loadedRecording.initialLoopId isEqualToString:loopPlayer.activeLoop.loopId] )
		   ) {
			//		NSLog(@"loadRecording: loading initial loop %@, with startDelay=%.2f", loadedRecording.initialLoopId, loadedRecording.loopPlaybackDurationBeforeStart);
			
			[loopPlayer loadLoopId:loadedRecording.initialLoopId];
			
		}
		
	}
	
	// 4. wait for togglePlayback to be called
	NSString* filenameOnlyWithoutExtension = [filenameOnly substringWithRange:NSMakeRange(0, [filenameOnly length] - 7)];
	if(indicateModified) {
		loadedRecording.isUnsaved = YES;
		appDelegate.recViewController.recordingChooserLabel.text = [NSString stringWithFormat:@"*%@", filenameOnlyWithoutExtension];
	} else {
		appDelegate.recViewController.recordingChooserLabel.text = filenameOnlyWithoutExtension;
	}
	//[appDelegate.recViewController.recordingChooserButton setTitle:filename forState:UIControlStateNormal];
	
}

-(void) stopNotes {

	
	instrument.recordedKeysPlaying = 0;
	instrument.keysArePlaying = 0;
	UInt32 keysToStart = instrument.interfaceKeysPlaying & ~instrument.keysArePlaying & ~instrument.recordedKeysPlaying;
	UInt32 keysToStop = instrument.interfaceKeysPlaying & instrument.keysArePlaying & instrument.recordedKeysPlaying;
	[instrument startKeys:keysToStart stopKeys:keysToStop];
	
	
	// update overlay
	[appDelegate.glVectorOverlayView viewNeedsUpdate];
	
}

-(void) stop {
	
//	NSLog(@"RP:stop");
//	isRecordingPlaying = NO;
	willPlaybackRepeat = NO;

//	NSLog(@"RP: invalidating playbackTimer");
	[self killPlaySliceThread];
	[self stopNotes];
	[self resetProgressMeter];
	
	appDelegate.recViewController.recordingPlayIcon.hidden = NO;

}

-(void) startFromToggle {
	
	// make sure repeat playback is ON
	if(!repeatPlayback) { 
		[self toggleRepeatPlayback];
	}
	
//	NSLog(@"RP: -startFromToggle: starting up recording playback w/ loop");
	[self stop];
	appDelegate.recViewController.recordingPlayIcon.hidden = YES;
	
	if(loopPlayer.beatTickNumber <= 1) {
		// amnesty - go!
//		NSLog(@"RP: startFromToggle:  AMNESTY AMNESTY AMNESTY ***startPlaySliceThread*** now!");
		[self stopNotes];
		[self resetProgressMeter];
		[loadedRecording resetCursor];
		nextEventMsCached = [loadedRecording getNextEventMillisecond];
		cursorHasMoved = YES;
		[self startPlaySliceThread];
		
		recPlaybackIterationStartTime = mach_absolute_time() - (([loopPlayer durElapsed] * 1000.0) / ticksToMilliseconds);
		//playbackStartTime = [NSDate timeIntervalSinceReferenceDate] - [loopPlayer durElapsed];
		willPlaybackRepeat = NO;
	} else {
		//		// wait for next iteration
		//GSB : NO - playSlice isn't started yet.  we have to start it - after a delay
		//		willPlaybackRepeat = YES;
		
//		NSLog(@"RP: startFromToggle: ***startPlaySliceThread*** in %0.2f sec", [loopPlayer durUntilEnd]);

		[self resetProgressMeter];
		[loadedRecording resetCursor];
		cursorHasMoved = NO;
		nextEventMsCached = -1ll;
		recPlaybackIterationStartTime = mach_absolute_time() - (([loopPlayer durElapsed] * 1000.0) / ticksToMilliseconds);
		[self startPlaySliceThread]; // hopefully it will wait for the loop
				
	}
//	NSLog(@"RP: -startFromToggle: recPlaybackIterationStartTime = %qims");
}

-(void) togglePlayback {
//	NSLog(@"RP:togglePlayback");
	
	// 4. start playing!  time counts up
	if(!isRecordingPlaying) {
		
//		NSLog(@"RP:togglePlayback    [%@]: starting notes in %.2f ", [[NSDate date] description], loopPlaybackDurationBeforeStart);
		appDelegate.recViewController.recordingPlayIcon.hidden = YES;
		if(loadedRecording.initialLoopId != nil && [loopPlayer isLooping]) {
			[loopPlayer stop];
		}
		recPlaybackIterationStartTime = mach_absolute_time() + ((loopPlaybackDurationBeforeStart * 1000.0) / ticksToMilliseconds);
		if(loadedRecording.initialLoopId != nil) {
//			NSLog(@"RP:togglePlayback: starting initial loop");
			[loopPlayer play];
		}
		
		[self performSelector:@selector(startPlaySliceThreadWithLoop) 
				   withObject:nil 
				   afterDelay:loopPlaybackDurationBeforeStart];

	} else {
		[self stop];
		appDelegate.recViewController.recordingPlayIcon.hidden = NO;
		if([loopPlayer isLooping]) {
//			NSLog(@"RP:togglePlayback: Stopping loop");
			[loopPlayer stop];
		}
		
	}
	
	
}

-(void) startPlaySliceThreadWithLoop {
//	NSLog(@"RP:startPlaySliceThreadWithLoop ENTER");
	recPlaybackIterationStartTime = mach_absolute_time();
	[loadedRecording resetCursor];
	nextEventMsCached = [loadedRecording getNextEventMillisecond];
	cursorHasMoved = YES;
	[self startPlaySliceThread];
}

-(void) loopIterated {
//	NSLog(@"RP:loopIterated: playing:%d, willRepeat:%d", isRecordingPlaying, willPlaybackRepeat);
	if(isRecordingPlaying) {
		if(willPlaybackRepeat) {
//			NSLog(@"RP:loopIterated[willPlaybackRepeat=YES]: calling -repeat");
			[self repeat];
		} else {
			SInt64 lastEventMs = loadedRecording.lastEventMilliseconds;
			SInt64 elapsedTimeMilliseconds = (mach_absolute_time() - recPlaybackIterationStartTime) * ticksToMilliseconds;
			
			if(elapsedTimeMilliseconds + 300 > lastEventMs) { // repeat if w/in 300ms of end
//				NSLog(@"RP:loopIterated: %qims / %qims (WAY LATE repeating)", elapsedTimeMilliseconds, lastEventMs);
				[self repeat];
			}
		}
	}
}


-(void) startPlaySliceThread {
//	NSLog(@"RP: startPlaySliceThread <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	isRecordingPlaying = YES;
	delayedStartRequestIsPending = NO;
	// intended to be called after a delay (loopPlaybackDurationBeforeStart)
	
//	if(playSliceThread != nil && [playSliceThread isExecuting]) {
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING    playSliceThread instantiated while already running, aborting");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		return;
//	}
	
	// this will be the first ms to play.  compared against now.

	
//GSB 20100708 - disabled this, bad?  NO, IT WORKS!
//	
//	nextEventMsCached = [loadedRecording getNextEventMillisecond];
//	cursorHasMoved = YES;

//	NSLog(@"RP: startPlaySliceThread set nextEventMsCached = %qi ***************", nextEventMsCached);	
	
	
//	
//	//
//	//TODO CLEANUP old NSThreadless code below
//	//
//	if(playbackTimer != nil && [playbackTimer isValid]) {
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING    playbackTimer instantiated while already running, aborting");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		NSLog(@"WARNING WARNING WARNING");
//		return;
//	}
//	
	playbackTimer = [NSTimer scheduledTimerWithTimeInterval:cpuPlaySliceIntervalSec target:self selector:@selector(playSlice) userInfo:nil repeats:YES];
//	NSThread* playSliceThread = 
//		[[NSThread alloc] initWithTarget:self 
//								selector:@selector(runPlaySliceTimer) 
//								  object:nil]; //Create a new thread
//	
//	[playSliceThread start]; //start the thread

}

-(void) runPlaySliceTimer {
//	NSLog(@"RP: runPlaySliceTimer <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	playbackTimer = [[NSTimer scheduledTimerWithTimeInterval: cpuPlaySliceIntervalSec
									  target: self
									selector: @selector(playSlice)
									userInfo: nil
									 repeats: YES] retain];
	
	[runLoop run];
	[pool release];
}


-(void) killPlaySliceThread {
	isRecordingPlaying = NO;
	
	NSLog(@"RP: killPlaySliceThread <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
//	if(playSliceThread != nil && [playSliceThread isExecuting]) {
//		NSLog(@"RP: killPlaySliceThread   cancelling thread");
//		[playSliceThread cancel];
//		playSliceThread = nil;
//	}
	if(playbackTimer != nil && [playbackTimer isValid]) {
		NSLog(@"RP: killPlaySliceThread   invalidating timer");
		[playbackTimer invalidate];
		playbackTimer = nil;
	}
	
	if(delayedStartRequestIsPending) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startPlaySliceThread) 
											   object:nil];
		delayedStartRequestIsPending = NO;
	}
	
	[self stopNotes];
}	




-(void) toggleRepeatPlayback {
	//NSLog(@"RP:toggleRepeatPlayback:%@", repeatPlayback?@"YES":@"NO");
	// toggle bool value
	if(repeatPlayback) {
		repeatPlayback = NO;
		// set button normal
	} else {
		repeatPlayback = YES;
		// set button selected
	}
	appDelegate.recViewController.recordingPlaybackRepeatToggleButton.selected = repeatPlayback;
}





-(void) repeat {
	
	[appDelegate.recViewController.waveRecViewController recIterated];

	
	willPlaybackRepeat = NO;
	
	recPlaybackIterationStartTime = mach_absolute_time();
	[loadedRecording resetCursor];
	nextEventMsCached = [loadedRecording getNextEventMillisecond];
	cursorHasMoved = YES;

	//NSLog(@"RP:repeat: <<<<<<<<<<<<<<<<<<<<<<<<<< resetting timer time to %qi", recPlaybackIterationStartTime);

//	if(loopPlaybackDurationBeforeStart > 0.05f) {
//		[self killPlaySliceThread];
//		NSLog(@"RP:repeat <<<<<<<<<<<<<<<< adding delay before repeat: %.2f", loopPlaybackDurationBeforeStart);
//		recPlaybackIterationStartTime = mach_absolute_time() + ((loopPlaybackDurationBeforeStart * 1000.0) / ticksToMilliseconds);
//		//playbackStartTime = [NSDate timeIntervalSinceReferenceDate] + loopPlaybackDurationBeforeStart;
//		delayedStartRequestIsPending = YES;
//		[self performSelector:@selector(startPlaySliceThread) withObject:nil afterDelay:loopPlaybackDurationBeforeStart];
//	} else {
//		
//		nextEventMsCached = [loadedRecording getNextEventMillisecond];
//		cursorHasMoved = YES;
//		//playbackStartTime = [NSDate timeIntervalSinceReferenceDate];
////		[self startPlaySliceThread];
//	}
//	[self resetProgressMeter];
	
}

-(BOOL) isRecordingPlaying {
	return isRecordingPlaying;
}

-(void) resetProgressMeter {
	appDelegate.recViewController.recordingProgressView.progress = 0.0;
	CGRect rect = appDelegate.recViewController.recordingProgressImage.bounds;
	rect.size.width = 0.0;
	appDelegate.recViewController.recordingProgressImage.bounds = rect;

}

-(void) playSlice {

	//NSTimeInterval playbackElapsedTime = [NSDate timeIntervalSinceReferenceDate] - playbackStartTime;
	//SInt64 elapsedTimeMilliseconds = playbackElapsedTime * 1000;
	SInt64 elapsedTimeMilliseconds = (mach_absolute_time() - recPlaybackIterationStartTime) * ticksToMilliseconds;
	SInt64 millisecondsUntilNextEvent = nextEventMsCached - elapsedTimeMilliseconds;
	
	//NSLog(@"RP: %7qims] next: %7qims | until: %4qims", elapsedTimeMilliseconds, nextEventMsCached, millisecondsUntilNextEvent);

	if(!cursorHasMoved && millisecondsUntilNextEvent > cpuPlaySliceLatencyCompensationMs) {
		return;
	} 
	
	SInt64 currentEventMs = nextEventMsCached;
	SInt64 millisecondsUntilCurrentEvent = elapsedTimeMilliseconds - currentEventMs;
	
	if(millisecondsUntilCurrentEvent < 0 - cpuPlaySliceLatencyCompensationMs) {
		//GSB: if we get into a solution where the cursor is far ahead, this fixes it.
		//NSLog(@"RP:playSlice: ahead, wait until catchup");
		cursorHasMoved = NO;
		return;
	}
	
	
	if(nextEventMsCached > 0ll && millisecondsUntilCurrentEvent > 500) { // no way we can catch up, abort and wait for loop
		//NSLog(@"RP:playSlice: behind, wait for next loop iter");
		[loadedRecording moveCursorToEnd];
		nextEventMsCached = -1ll;
//		NSLog(@"RP: playSlice: delta > 500ms.  simulate EOF, wait for loop");
	}
	
//	NSLog(@"RP:playSlice:                                          next: %10qims     until: %10qims ", nextEventMsCached, millisecondsUntilNextEvent );

	if(nextEventMsCached == -1ll) {
		if(repeatPlayback && [loopPlayer isLooping]) { 
			if(!willPlaybackRepeat) {
				willPlaybackRepeat = YES;
				//NSLog(@"RP: playSlice: EOF (will repeat) <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
				UInt32 instrumentRecordedKeysPlaying = instrument.recordedKeysPlaying;
				UInt32 instrumentInterfaceKeysPlaying = instrument.interfaceKeysPlaying;
				UInt32 keysToStart = 0 & ~instrumentRecordedKeysPlaying & ~instrumentInterfaceKeysPlaying;
				UInt32 keysToStop = ~0 & instrumentRecordedKeysPlaying & ~instrumentInterfaceKeysPlaying;
				//NSLog(@"RP                                      (1:%8X, 0:%8X)", keysToStart, keysToStop);
				[instrument startKeys:keysToStart stopKeys:keysToStop];
				//[self killPlaySliceThread];

//				float durUntilEnd = [loopPlayer durUntilEnd];
//				NSLog(@"RP: playSlice EOF <<<<[durUntilEnd = %.2fs]<<<< EARLY LOOPING DISABLED<<<<<<<<<<<<<<<<<<<<<<<<<<<", durUntilEnd);
//				
//				float latencySec = cpuPlaySliceLatencyCompensationMs / 1000.0f;
//				if(durUntilEnd < 0.03f) {
//					willPlaybackRepeat = NO; //hijacking
//					float durUntilStart = durUntilEnd - latencySec;
//					NSLog(@"RP: playSlice EOF <<<<[starting repeat loop early NOW]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<", durUntilStart);
//					NSLog(@"check against first event - it may be late, compared to latency");
//					
//					[self stopNotes];			
//					[self repeat];//go NOW
////					[self performSelector:@selector(repeat) 
////							   withObject:nil 
////							   afterDelay:durUntilStart];
//				}
			}
			return;
		} else if(repeatPlayback && ![loopPlayer isLooping]) {
			[self repeat];
		} else { // clean up.  this stuff should be in 'stop'
			[self stop];

			if([loopPlayer isLooping]) {
//				NSLog(@"RP: playSlice: EOF (done) <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
				[loopPlayer stop];
			}
			
		}
		return; 
	}
	
	// do it now - grab the (non-EOF) event
	RecordedEvent* e = [loadedRecording getRecordedEventAtCursor];
	// we just decided to "claim" this event.  advance the cursor in the recording, and cache the next event we'll need
	[loadedRecording advanceCursor];
	nextEventMsCached = [loadedRecording getNextEventMillisecond];
	cursorHasMoved = NO;
//	if(nextEventMsCached == 0ll) {
//		NSLog(@"PLAYSLICE set nextEventMsCached = 0 ***************");
//		NSLog(@"PLAYSLICE set nextEventMsCached = 0 ***************");
//		NSLog(@"PLAYSLICE set nextEventMsCached = 0 ***************");
//		NSLog(@"PLAYSLICE set nextEventMsCached = 0 ***************");
//		NSLog(@"PLAYSLICE set nextEventMsCached = 0 ***************");
//	}
	
	if(e == nil) {
//		NSLog(@"e is nil, killing playback");
		[self killPlaySliceThread];
		return;
	}
					
	// non-null, play it!
	UInt32 eventKeysPlaying = e.keysPlaying;
	UInt32 instrumentRecordedKeysPlaying = instrument.recordedKeysPlaying;
	UInt32 instrumentInterfaceKeysPlaying = instrument.interfaceKeysPlaying;
	
	// note handling
	UInt32 keysToStart = eventKeysPlaying & ~instrumentRecordedKeysPlaying & ~instrumentInterfaceKeysPlaying;
	UInt32 keysToStop = ~eventKeysPlaying & instrumentRecordedKeysPlaying & ~instrumentInterfaceKeysPlaying;
	instrument.recordedKeysPlaying = eventKeysPlaying;
	//NSLog(@"RP                                      (1:%8X, 0:%8X)", keysToStart, keysToStop);
	[instrument startKeys:keysToStart stopKeys:keysToStop];
	
//	NSLog(@"RP: %7qims]     (delta: %3qims)    PLAYING [%7qims:%X", elapsedTimeMilliseconds, millisecondsUntilCurrentEvent, currentEventMs, e.keysPlaying);

	// loop handling TODO POSTLAUNCH IMPROVE
	if(e.loopId != nil) {
		//TODO POSTLAUNCH: loop stops and starts in recording playback
		if([e.loopId isEqualToString:@"STOP"]) {
//			NSLog(@"RecordingPlayer:playSlice: stopping loop");
			[loopPlayer stop];
		} else if(loopPlayer.activeLoop == nil || [loopPlayer.activeLoop.loopId isEqualToString:e.loopId]) {
//			NSLog(@"RecordingPlayer:playSlice: loading loopId:%@", e.loopId);
			[loopPlayer loadLoopId:e.loopId];
			[loopPlayer play];
		}
	}
	
	// scale handling TODO POSTLAUNCH
	
	// patch handling TODO POSTLAUNCH
	
	
	
	// update percent complete
	float pctComplete = (float) elapsedTimeMilliseconds / (float) loadedRecording.lastEventMilliseconds;
	appDelegate.recViewController.recordingProgressView.progress = pctComplete;
	
}


@end
