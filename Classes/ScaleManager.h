//
//  PatchManager.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Instrument;

@interface ScaleManager : NSObject {

	Instrument* instrument;
	NSMutableDictionary* scalesMap;
	NSMutableArray* sortedScales;
	
}

@property (nonatomic, retain) Instrument* instrument;
@property (nonatomic,retain) NSMutableDictionary* scalesMap;
@property (nonatomic,retain) NSMutableArray* sortedScales;

-(void) setActiveScaleId:(NSString*) scaleId;

@end
