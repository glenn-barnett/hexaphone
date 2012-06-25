//
//  Recording.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RecordedEvent;

@interface Recording : NSObject {
	NSString* fileName;
	NSMutableArray* events;
	UInt64 numEvents;
	
	NSString* initialPatchId;
	NSString* initialScaleId;
	NSString* initialTuningId;
	
	NSString* initialLoopId;
	NSTimeInterval loopPlaybackDurationBeforeStart;
	
	SInt64 lastEventMilliseconds;
	SInt64 nextEventMillisecond;
	UInt64 playbackCursor;
	
	BOOL haveKeysBeenPlayed;
	BOOL hasEarlyEvent;
	BOOL isUnsaved;
	BOOL isLatest;
	
	BOOL isSoloStart; // no need to persist, just used during recording
}

#define RECORDING_ANTICIPATED_LATENCY 0ll

@property (nonatomic, retain) NSString* fileName;
@property (nonatomic, retain) NSArray* events;

@property (nonatomic, retain) NSString* initialPatchId;
@property (nonatomic, retain) NSString* initialScaleId;
@property (nonatomic, retain) NSString* initialTuningId;

@property (nonatomic, retain) NSString* initialLoopId;
@property (nonatomic) NSTimeInterval loopPlaybackDurationBeforeStart;

@property (nonatomic,readonly) SInt64 lastEventMilliseconds;
@property (nonatomic) BOOL haveKeysBeenPlayed;
@property (nonatomic) BOOL hasEarlyEvent;
@property (nonatomic) BOOL isUnsaved;
@property (nonatomic) BOOL isLatest;
@property (nonatomic) BOOL isSoloStart;

-(void) moveCursorToEnd;

-(NSDictionary*) toDictionary;

-(void) addEarlyEventKeysPlayingEvent:(UInt32)keysPlaying;

-(void) addEventAtMillisecond:(SInt64)millisecond
				  keysPlaying:(UInt32)keysPlaying;

-(void) addEventAtMillisecond:(SInt64)millisecond
					  patchId:(NSString*) patchId
					  scaleId:(NSString*) scaleId
					 tuningId:(NSString*) tuningId;

-(void) addEventAtMillisecond:(SInt64)millisecond
					   loopId:(NSString*) patchId;

-(RecordedEvent*) getRecordedEventAtCursor;
-(void) advanceCursor;
-(void) resetCursor;
-(UInt64) getPlaybackCursor;
-(UInt64) getNumEventsRemaining;
-(SInt64) getNextEventMillisecond;
@end
