//
//  PatchManager.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PatchManager.h"
#import "SBJSON.h"
#import "Patch.h"
#import "Sample.h"
#import "Instrument.h"

@implementation PatchManager

@synthesize instrument;
@synthesize patchesMap;
@synthesize sortedPatches;

// REMEMBER> afconvert -f caff -d LEI16@44100 -c 1 in.wav out.caf

- (id)init {
    self = [super init];
	
    if (self) {
		//class-specific init
		NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:@"patches" ofType:@"json"];
		
		NSURL* fileURL = [NSURL fileURLWithPath:jsonFilePath]; 
		NSStringEncoding encodingUsed;
		NSError* error = nil;
		NSString *fileContentsAsString = [[NSString stringWithContentsOfURL:fileURL usedEncoding:&encodingUsed error:&error] retain];  
		
		SBJSON* sbJson = [[SBJSON alloc] init];
		NSArray* arrPatchDicts = [sbJson objectWithString:fileContentsAsString error:&error];
		[sbJson release];
		
		patchesMap = [[NSMutableDictionary alloc] init];
		sortedPatches = [[NSMutableArray alloc] init];
		
		for(NSDictionary* patchDict in arrPatchDicts) {
			Patch* p = [Patch patchFromDictionary:patchDict];
			[patchesMap setObject:p forKey:p.patchId];
			[sortedPatches addObject:p];
		}
		
//		NSArray* sortedPatchIds = [[patchesMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//		for(NSString* patchId in sortedPatchIds) {
//			[sortedPatches addObject:[patchesMap objectForKey:patchId]];
//		}		
    }
    return self;
}


-(void) setActivePatchId:(NSString*) patchId {
	for(Patch* p in sortedPatches) {
		if([patchId isEqualToString:p.patchId]) {
			p.isActive = YES;
		} else {
			p.isActive = NO;
		}
	}
}



-(void) dealloc {
	[patchesMap release];
	[sortedPatches release];
	[patchSelectionActionSheet release];	
	[super dealloc];
}

@end
