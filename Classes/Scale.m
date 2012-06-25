//
//  Scale.m
//  Hexatone
//
//  Created by Glenn Barnett on 2/15/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "Scale.h"


@implementation Scale

@synthesize scaleId;
@synthesize scaleName;
@synthesize scaleType;
@synthesize arrNoteIds;
@synthesize isActive;

-(NSString*) key { return scaleId; }
-(NSString*) label { return scaleName; }
-(BOOL) isSelected { return isActive; }

+(id) scaleFromDictionary:(NSDictionary*) dict {

	Scale* s = [[Scale alloc] init];
	s.scaleId = [dict valueForKey:@"scaleId"];
	s.scaleName = [dict valueForKey:@"scaleName"];
	s.scaleType = [dict valueForKey:@"scaleType"];
	s.isActive = NO;
	
	NSArray* arrNotes = [dict valueForKey:@"notes"];
	for(NSString* noteId in arrNotes) {
		[s addNoteId:noteId];
	}
	
	return s;
}

-(id) init {
	arrNoteIds = [[NSMutableArray alloc] init];
	
	return self;
}

-(void) addNoteId:(NSString*) noteId {
	[arrNoteIds addObject:noteId];
}

-(void) dealloc {
	[scaleId release];
	[scaleName release];
	[scaleType release];
	[arrNoteIds release];
	[super dealloc];
}

@end
