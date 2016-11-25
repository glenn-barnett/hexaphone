//
//  Patch.h
//  Hexatone
//
//  Created by Glenn Barnett on 1/15/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sample;

@interface Patch : NSObject {
	NSString* patchId;
	NSString* patchName;
	NSString* patchNameShort;
	NSString* patchScaleType;
	NSMutableDictionary* mapNoteIdToSample;
	BOOL loop;
	BOOL isActive;
}

+(id) patchFromDictionary:(NSDictionary*) dict;

@property (nonatomic,retain) NSString* patchId;
@property (nonatomic,retain) NSString* patchName;
@property (nonatomic,retain) NSString* patchNameShort;
@property (nonatomic,retain) NSString* patchScaleType;
@property BOOL loop;
@property BOOL isActive;

-(NSString*) key;
-(NSString*) label;

-(id) init;
-(void) addSample:(Sample*) sample;
-(Sample*) getSampleForNoteId:(NSString*) noteId;
		
@end
