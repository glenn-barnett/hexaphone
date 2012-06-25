//
//  Song.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/5/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//


@interface Loop : NSObject {

	NSString* loopId;
	NSString* loopName;
	NSString* loopCategory;
	NSDecimalNumber* bpm;
	NSDecimalNumber* beats;
	NSString* file;
	
	NSString* scaleId;
	NSString* tuningId;
	
	BOOL isActive;

}

@property (nonatomic,retain) NSString* loopId;
@property (nonatomic,retain) NSString* loopName;
@property (nonatomic,retain) NSString* loopCategory;
@property (nonatomic,retain) NSDecimalNumber* bpm;
@property (nonatomic,retain) NSDecimalNumber* beats;
@property (nonatomic,retain) NSString* file;
@property (nonatomic,retain) NSString* scaleId;
@property (nonatomic,retain) NSString* tuningId;
@property (nonatomic) BOOL isActive;

-(NSString*) key;
-(NSString*) label;


+(id) loopFromDictionary:(NSDictionary*) dict;

@end
