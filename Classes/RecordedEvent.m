//
//  RecordedEvent.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RecordedEvent.h"


@implementation RecordedEvent

@synthesize keysPlaying;
@synthesize millisecond;
@synthesize patchId;
@synthesize scaleId;
@synthesize tuningId;
@synthesize loopId;
@synthesize keyboardOffset;

-(void) dealloc {
	NSLog(@"RecordedEvent: -delloc");
	[patchId release];
	[scaleId release];
	[tuningId release];
	[loopId release];
	[super dealloc];
}

-(id) initWithDictionary:(NSDictionary*) otherDictionary {
	self = [super init];
	if(self) {
		if([otherDictionary objectForKey:@"k"] != nil) {
			keysPlaying = [[otherDictionary objectForKey:@"k"] unsignedLongValue];
		} else {
			keysPlaying = 0l;
		}
		millisecond = [[otherDictionary objectForKey:@"t"] unsignedLongLongValue];
		patchId = [otherDictionary objectForKey:@"patchId"];
		scaleId = [otherDictionary objectForKey:@"scaleId"];
		tuningId = [otherDictionary objectForKey:@"tuningId"];
		loopId = [otherDictionary objectForKey:@"loopId"];
		
		if(loopId != nil) {
//			NSLog(@"RE.init: got loopId:%@", loopId);
		}
	}
	return self;
}

+(id) fromDictionary:(NSDictionary*) otherDictionary {
	// GSB: use class name
	RecordedEvent* instance = [[RecordedEvent alloc] init];
	
	// GSB: autogen string fields
	instance.keysPlaying = [[otherDictionary objectForKey:@"k"] unsignedLongValue];
	instance.millisecond = [[otherDictionary objectForKey:@"t"] unsignedLongLongValue];
	instance.patchId = [[otherDictionary objectForKey:@"patchId"] retain];
	instance.scaleId = [[otherDictionary objectForKey:@"scaleId"] retain];
	instance.tuningId = [[otherDictionary objectForKey:@"tuningId"] retain];
	instance.loopId = [[otherDictionary objectForKey:@"loopId"] retain];
	
	return [instance autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat:@"[%.2f] k:%10d p:%@ s:%@ t:%@ l:%@", 
			millisecond / 1000.0,
			keysPlaying,
			patchId,
			scaleId,
			tuningId,
			loopId];
}

-(NSDictionary*) toDictionary {
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSNumber numberWithUnsignedLong:keysPlaying] forKey:@"k"];
	[dict setObject:[NSNumber numberWithUnsignedLongLong:millisecond] forKey:@"t"];
	if(patchId != nil)
		[dict setObject:patchId forKey:@"patchId"];
	if(scaleId != nil)
		[dict setObject:scaleId forKey:@"scaleId"];
	if(tuningId != nil)
		[dict setObject:tuningId forKey:@"tuningId"];
	if(loopId != nil)
		[dict setObject:loopId forKey:@"loopId"];
	return [dict autorelease];
}

-(id)initAtMillisecond:(SInt64) millisecondArg
		   keysPlaying:(UInt32) keysPlayingArg {
    
	self = [super init];
	
    if (self) {
		millisecond = millisecondArg;
		keysPlaying = keysPlayingArg;
    }
    return self;
}

-(id)initAtMillisecond:(SInt64) millisecondArg
			   patchId:(NSString*) patchIdArg
			   scaleId:(NSString*) scaleIdArg
			  tuningId:(NSString*) tuningIdArg {

	self = [super init];
	
    if (self) {
		millisecond = millisecondArg;
		patchId = patchIdArg;
		scaleId = scaleIdArg;
		tuningId = tuningIdArg;
    }
    return self;
	
}


-(id)initAtMillisecond:(SInt64) millisecondArg
				loopId:(NSString*) loopIdArg {
	
	self = [super init];
	
    if (self) {
		millisecond = millisecondArg;
		loopId = loopIdArg;		
    }
    return self;
	
}

@end
