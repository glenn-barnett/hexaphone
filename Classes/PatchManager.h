//
//  PatchManager.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Instrument;

@interface PatchManager : NSObject {
	
	Instrument* instrument;
	NSMutableDictionary* patchesMap;
	NSMutableArray* sortedPatches;
	UIActionSheet* patchSelectionActionSheet;
	
}

@property (nonatomic,retain) Instrument* instrument;
@property (nonatomic,retain) NSMutableDictionary* patchesMap;
@property (nonatomic,retain) NSMutableArray* sortedPatches;

-(void) setActivePatchId:(NSString*) patchId;

@end