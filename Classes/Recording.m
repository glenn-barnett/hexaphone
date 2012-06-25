//
//  Recording.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Recording.h"
#import "RecordedEvent.h"
#import "Instrument.h"

@implementation Recording

@synthesize fileName;
@synthesize events;

@synthesize initialPatchId;
@synthesize initialScaleId;
@synthesize initialTuningId;

@synthesize initialLoopId;
@synthesize loopPlaybackDurationBeforeStart;


@synthesize lastEventMilliseconds;
@synthesize haveKeysBeenPlayed;
@synthesize hasEarlyEvent;

@synthesize isUnsaved;
@synthesize isLatest;
@synthesize isSoloStart;


- (id)init {
    self = [super init];
	
    if (self) {
		//class-specific init
		haveKeysBeenPlayed = NO;
		hasEarlyEvent = NO;
		events = [[NSMutableArray alloc] init];
		numEvents = 0;
		playbackCursor = 0;
		isUnsaved = NO;
		isLatest = YES;
		isSoloStart = NO;
    }
    return self;
}

-(UInt64) getPlaybackCursor {
	return playbackCursor;
}

-(UInt64) getNumEventsRemaining {
	return numEvents - playbackCursor;
}

-(RecordedEvent*) getRecordedEventAtCursor {
	if(playbackCursor < [events count]) { 
		//NSLog(@"cursor: %d", playbackCursor);
		return [events objectAtIndex:playbackCursor];
	} else {
//		NSLog(@"Recording:getRecordedEventAtCursor: cursor at end - returning NIL");
		return nil;
	}
}

-(SInt64) getNextEventMillisecond {
//	if(playbackCursor < [events count]) { 
//		RecordedEvent* re = [events objectAtIndex:playbackCursor];
//		return re.millisecond;
//	} else {
//		return -1ll; 
//	}
	return nextEventMillisecond;
}

-(void) advanceCursor {
	playbackCursor++;
	
	if(playbackCursor < [events count]) { 
		RecordedEvent* re = [events objectAtIndex:playbackCursor];
		nextEventMillisecond = re.millisecond;
	} else {
		nextEventMillisecond = -1ll; 
	}
	
}
-(void) resetCursor {
	playbackCursor = 0;
	RecordedEvent* re = [events objectAtIndex:playbackCursor];
	nextEventMillisecond = re.millisecond;
	
//	NSLog(@"Recording:resetCursor:%qu", playbackCursor);
}
-(void) moveCursorToEnd {
	nextEventMillisecond = -1ll;
}


-(id) initWithDictionary:(NSDictionary*) otherDictionary {
	self = [self init];
	if(self) {
		events = [[NSMutableArray alloc] init];
		haveKeysBeenPlayed = YES;
		isLatest = NO;
		
		NSArray* eventsFromDict = [otherDictionary objectForKey:@"events"];
		for(NSDictionary* eventDict in eventsFromDict) {
			NSString* loopId = [[eventDict objectForKey:@"loopId"] retain];
			if(loopId != nil) {
//				NSLog(@"R-initWD: got non-null loopId: %@", loopId);
			}
			[events addObject:[RecordedEvent fromDictionary:eventDict]];
			//[events addObject:[[RecordedEvent alloc] initWithDictionary:eventDict]];
		}
		NSNumber* lastEventMillisecondsNumber = [otherDictionary objectForKey:@"lastEventMilliseconds"];
		if(lastEventMillisecondsNumber == nil) {
			lastEventMilliseconds = 0;
		} else {
			lastEventMilliseconds = [lastEventMillisecondsNumber longLongValue];
		}
		//[lastEventMillisecondsNumber release];
			
			
		initialPatchId = [[otherDictionary objectForKey:@"initialPatchId"] retain];
		initialScaleId = [[otherDictionary objectForKey:@"initialScaleId"] retain];
		initialTuningId = [[otherDictionary objectForKey:@"initialTuningId"] retain];
		initialLoopId = [[otherDictionary objectForKey:@"initialLoopId"] retain];
		
		NSNumber* loopPlaybackDurationBeforeStartNumber = [otherDictionary objectForKey:@"loopPlaybackDurationBeforeStart"];
		if(loopPlaybackDurationBeforeStartNumber == nil) {
			loopPlaybackDurationBeforeStart = 0;
		} else {
			loopPlaybackDurationBeforeStart = [loopPlaybackDurationBeforeStartNumber doubleValue];
		}
		
		numEvents = [events count];
		
	}
	return self;
}


-(NSDictionary*) toDictionary {
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	
	NSMutableArray* arrEventDicts = [[NSMutableArray alloc] init];
	for(RecordedEvent* e in events) {
		[arrEventDicts addObject: [e toDictionary]];
	}
	[dict setObject:[NSNumber numberWithLongLong:lastEventMilliseconds] forKey:@"lastEventMilliseconds"];
	[dict setObject:arrEventDicts forKey:@"events"];
	[dict setObject:initialPatchId forKey:@"initialPatchId"];
	[dict setObject:initialScaleId forKey:@"initialScaleId"];
	[dict setObject:initialTuningId forKey:@"initialTuningId"];
	if(initialLoopId != nil) {
		[dict setObject:initialLoopId forKey:@"initialLoopId"];
		[dict setObject:[NSNumber numberWithDouble:loopPlaybackDurationBeforeStart] forKey:@"loopPlaybackDurationBeforeStart"];
	}
	
	[arrEventDicts release];
	
	return [dict autorelease];
}

-(void) addEarlyEventKeysPlayingEvent:(UInt32)keysPlaying {
//	NSLog(@"addEarlyEventKeysPlayingEvent:%X", keysPlaying);
	hasEarlyEvent = YES;
	[events addObject:
	 [[[RecordedEvent alloc] initAtMillisecond:1l
								  keysPlaying:keysPlaying] autorelease]
	 ];
	
	
}

-(void) addEventAtMillisecond:(SInt64)millisecond
				  keysPlaying:(UInt32)keysPlaying {
//	NSLog(@"addEventAtMillisecond:%qims keysPlaying:%X", millisecond, keysPlaying);

	SInt64 adjustedMillisecond = millisecond - RECORDING_ANTICIPATED_LATENCY;
	if(adjustedMillisecond < 0) {
		adjustedMillisecond = millisecond;
	}
	
	[events addObject:
	 [[[RecordedEvent alloc] initAtMillisecond:adjustedMillisecond
								  keysPlaying:keysPlaying] autorelease]
	 ];
	
	lastEventMilliseconds = millisecond;
	
	if(keysPlaying != 0) {
		haveKeysBeenPlayed = YES;
	}
	
}

-(void) addEventAtMillisecond:(SInt64)millisecond
					  patchId:(NSString*) patchId
					  scaleId:(NSString*) scaleId
					 tuningId:(NSString*) tuningId {
//	NSLog(@"addEventAtMillisecond:%qims patch/scale/tune SHOULD BE UNUSED TODO POSTLAUNCH");
	[events addObject:
	 [[[RecordedEvent alloc] initAtMillisecond:millisecond
									  patchId:patchId
									  scaleId:scaleId
									 tuningId:tuningId] autorelease]
	 ];

	lastEventMilliseconds = millisecond;
}

-(void) addEventAtMillisecond:(SInt64)millisecond
					   loopId:(NSString*) loopId {
//	NSLog(@"addEventAtMillisecond:%qims loop SHOULD BE UNUSED TODO POSTLAUNCH");
	[events addObject:
	 [[[RecordedEvent alloc] initAtMillisecond:millisecond
									   loopId:loopId] autorelease]
	 ];

	lastEventMilliseconds = millisecond;

}

-(void) dealloc {
	NSLog(@"Recording: -delloc");
	[events release];
	[initialPatchId release];
	[initialScaleId release];
	[initialTuningId release];
	[initialLoopId release];
	[super dealloc];
}


@end
