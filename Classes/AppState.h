//
//  Preset.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AppState : NSObject {

	NSNumber* startupCount;
	
	NSString* patchId;
	NSString* scaleId;
	NSString* tuningId;
	NSNumber* kbOffset;
	NSString* loopId;
	
	NSString* uuid;
	
	NSString* recentPatchId1;
	NSString* recentPatchId2;
	NSString* recentPatchId3;
	
	NSString* recentScaleId1;
	NSString* recentScaleId2;
	NSString* recentScaleId3;

	NSString* recentLoopId1;
	NSString* recentLoopId2;
	NSString* recentLoopId3;

	BOOL rotateView;
	BOOL showKeyLabels;
	BOOL showKeyIllum;
	NSNumber* sliderFilterRez;
	NSNumber* sliderKeyVol;
	NSNumber* sliderLoopVol;
	NSNumber* sliderTouchSize;
}


+(id) fromDictionary:(NSDictionary*) dict;
-(NSDictionary*) toDictionary;

-(BOOL) hasAnyRecentPatches;
-(void) changePatchId:(NSString*) patchIdArg;

-(BOOL) hasAnyRecentScales;
-(void) changeScaleId:(NSString*) scaleIdArg;

-(BOOL) hasAnyRecentLoops;
-(void) changeLoopId:(NSString*) loopIdArg;


@property (nonatomic,retain) NSNumber* startupCount;
@property (nonatomic,retain) NSString* patchId;
@property (nonatomic,retain) NSString* scaleId;
@property (nonatomic,retain) NSString* tuningId;
@property (nonatomic,retain) NSNumber* kbOffset;
@property (nonatomic,retain) NSString* loopId;

@property (nonatomic,retain) NSString* uuid;

@property (nonatomic,retain) NSString* recentPatchId1;
@property (nonatomic,retain) NSString* recentPatchId2;
@property (nonatomic,retain) NSString* recentPatchId3;
@property (nonatomic,retain) NSString* recentScaleId1;
@property (nonatomic,retain) NSString* recentScaleId2;
@property (nonatomic,retain) NSString* recentScaleId3;
@property (nonatomic,retain) NSString* recentLoopId1;
@property (nonatomic,retain) NSString* recentLoopId2;
@property (nonatomic,retain) NSString* recentLoopId3;

@property (nonatomic) BOOL rotateView;
@property (nonatomic) BOOL showKeyLabels;
@property (nonatomic) BOOL showKeyIllum;
@property (nonatomic,retain) NSNumber* sliderFilterRez;
@property (nonatomic,retain) NSNumber* sliderKeyVol;
@property (nonatomic,retain) NSNumber* sliderLoopVol;
@property (nonatomic,retain) NSNumber* sliderTouchSize;


@end
