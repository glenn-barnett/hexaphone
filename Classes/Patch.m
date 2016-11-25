//
//  Patch.m
//  Hexatone
//
//  Created by Glenn Barnett on 1/15/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "Patch.h"

#import "Sample.h"

@implementation Patch

@synthesize patchId;
@synthesize patchName;
@synthesize patchNameShort;
@synthesize patchScaleType;
@synthesize loop;
@synthesize isActive;

-(NSString*) key { return patchId; }
-(NSString*) label { return patchName; }
-(BOOL) isSelected { return isActive; }

+(id) patchFromDictionary:(NSDictionary*) dict {
	
	Patch* p = [[Patch alloc] init];
	p.patchId			= [dict valueForKey:@"patchId"];
	p.patchName			= [dict valueForKey:@"patchName"];
	p.patchNameShort	= [dict valueForKey:@"patchNameShort"];
	p.patchScaleType	= [dict valueForKey:@"patchScaleType"];
	p.loop				= [[dict valueForKey:@"loop"] boolValue];
	p.isActive			= NO;

	NSArray* arrSamples = [dict valueForKey:@"samples"];
	for(NSDictionary* sampleDict in arrSamples) {
		Sample *s = [Sample sampleFromDictionary:sampleDict];
		[p addSample:s];
	}
	return p;
	
}

-(id) init {
	mapNoteIdToSample = [[NSMutableDictionary alloc] init];

	return self;
}

-(void) addSample:(Sample*) sample {
	[mapNoteIdToSample setObject:sample forKey:sample.noteId];
}

-(Sample*) getSampleForNoteId:(NSString*) noteId {
	Sample* sample = (Sample*) [mapNoteIdToSample objectForKey:noteId];
	if(sample == nil) {
//		NSLog(@"Patch[%@]:    WARNING", self.patchId);
//		NSLog(@"Patch[%@]:    WARNING   -getSampleForNoteId:%@ returned NIL", self.patchId, noteId);
//		NSLog(@"Patch[%@]:    WARNING", self.patchId);
	}
	
	return sample;
}

-(void) dealloc {

	[patchId release];
	[patchName release];
	[patchScaleType release];
	[mapNoteIdToSample release];
	
	[super dealloc];
}

@end
