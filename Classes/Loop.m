//
//  Song.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/5/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "Loop.h"


@implementation Loop

@synthesize loopId;
@synthesize loopName;
@synthesize loopCategory;
@synthesize bpm;
@synthesize beats;
@synthesize file;
@synthesize scaleId;
@synthesize tuningId;
@synthesize isActive;

-(NSString*) key { return loopId; }
-(NSString*) label { return [NSString stringWithFormat:@"%@ [%d bpm / %d]", loopName, [bpm intValue], [beats intValue]]; }
-(BOOL) isSelected { return isActive; }

- (id)init {
	self = [super init];
	
	if (self) {
		isActive = NO;
	}
	
	return self;
}


+(id) loopFromDictionary:(NSDictionary*) dict {
	
	Loop* l			= [[Loop alloc] init];
	l.loopId			= [dict valueForKey:@"loopId"];
	l.loopName			= [dict valueForKey:@"loopName"];
	l.loopCategory		= [dict valueForKey:@"loopCategory"];
	l.bpm				= [dict valueForKey:@"bpm"];
	l.beats				= [dict valueForKey:@"beats"];
	if(l.beats == nil) {
		l.beats = [NSDecimalNumber zero];
	}
	l.file  			= [dict valueForKey:@"file"];
	l.scaleId  			= [dict valueForKey:@"scaleId"];
	l.tuningId 			= [dict valueForKey:@"tuningId"];
	l.isActive = NO;
	
	return l;
	
}




-(void) dealloc {
	//TODO POSTLAUNCH domain class dealloc
	[super dealloc];
}


@end
