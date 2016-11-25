//
//  LoopManager.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoopPlayer;
@interface LoopManager : NSObject {

	LoopPlayer* loopPlayer;
	NSMutableDictionary* loopsMap;
	NSMutableArray* sortedLoops;
	
	NSMutableArray* loopCategories;
	
}

@property (nonatomic,retain) LoopPlayer* loopPlayer;
@property (nonatomic,retain) NSMutableDictionary* loopsMap;
@property (nonatomic,retain) NSMutableArray* sortedLoops;
@property (nonatomic,retain) NSMutableArray* loopCategories;


-(void) setActiveLoopId:(NSString*) loopId;
-(NSArray*) getLoopsByCategory:(NSString*) category;

@end
