//
//  TrackManager.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoopManager.h"
#import "Loop.h"
#import "JSON.h"
#import "LoopPlayer.h";

@implementation LoopManager

@synthesize loopPlayer;
@synthesize loopsMap;
@synthesize sortedLoops;
@synthesize loopCategories;

- (id)init {
    self = [super init];
	
    if (self) {
		//class-specific init
		NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:@"loops" ofType:@"json"];
		
		NSURL* fileURL = [NSURL fileURLWithPath:jsonFilePath]; 
		NSStringEncoding encodingUsed;
		NSError* error = nil;
		NSString *fileContentsAsString = [[NSString stringWithContentsOfURL:fileURL usedEncoding:&encodingUsed error:&error] retain];  
		
		SBJSON* sbJson = [[SBJSON alloc] init];
		NSArray* arrLoopDicts = [sbJson objectWithString:fileContentsAsString error:&error];
		[sbJson release];
		
		loopsMap = [[NSMutableDictionary alloc] init];
		sortedLoops = [[NSMutableArray alloc] init];
		loopCategories = [[NSMutableArray alloc] init];
		
		for(NSDictionary* loopDict in arrLoopDicts) {
			Loop* l = [Loop loopFromDictionary:loopDict];
			[loopsMap setObject:l forKey:l.loopId];
			[sortedLoops addObject:l];
			if(![loopCategories containsObject:l.loopCategory]) {
				[loopCategories addObject:l.loopCategory];
			}
		}
		
//		NSArray* sortedLoopIds = [[loopsMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//		for(NSString* loopId in sortedLoopIds) {
//			[sortedLoops addObject:[loopsMap objectForKey:loopId]];
//		}		
    }
    return self;
}

-(NSArray*) getLoopsByCategory:(NSString*) category {
	NSPredicate* predicate = [NSPredicate predicateWithFormat:
							  [NSString stringWithFormat:@"loopCategory CONTAINS \"%@\"", category]];
	
	return [sortedLoops filteredArrayUsingPredicate:predicate]; 
	
}

-(void) setActiveLoopId:(NSString*) loopId {
	for(Loop* l in sortedLoops) {
		if([loopId isEqualToString:l.loopId]) {
			l.isActive = YES;
		} else {
			l.isActive = NO;
		}
	}
}


-(void) dealloc {
	[loopsMap release];
	[sortedLoops release];
	[super dealloc];
}

@end
