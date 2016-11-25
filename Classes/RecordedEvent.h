//
//  RecordedEvent.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordedEvent : NSObject {
	UInt32 keysPlaying;
	SInt64 millisecond;
	NSString* patchId;
	NSString* scaleId;
	NSString* tuningId;
	NSString* loopId;
	UInt32 keyboardOffset;
}

@property(nonatomic) UInt32 keysPlaying;
@property(nonatomic) SInt64 millisecond;
@property(nonatomic,retain) NSString* patchId;
@property(nonatomic,retain) NSString* scaleId;
@property(nonatomic,retain) NSString* tuningId;
@property(nonatomic,retain) NSString* loopId;
@property(nonatomic) UInt32 keyboardOffset;

-(NSDictionary*) toDictionary;
-(id)initWithDictionary:(NSDictionary *)otherDictionary;
+(id) fromDictionary:(NSDictionary*) otherDictionary;

-(id)initAtMillisecond:(SInt64) millisecondArg
		   keysPlaying:(UInt32) keysPlayingArg;

-(id)initAtMillisecond:(SInt64) millisecondArg
			   patchId:(NSString*) patchId
			   scaleId:(NSString*) scaleId
			  tuningId:(NSString*) tuningId;

-(id)initAtMillisecond:(SInt64) millisecondArg
				loopId:(NSString*) loopId;

-(NSString*) description;


@end
