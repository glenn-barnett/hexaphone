//
//  Scale.h
//  Hexatone
//
//  Created by Glenn Barnett on 2/15/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scale : NSObject  {
	NSString* scaleId;
	NSString* scaleName;
	NSString* scaleType;
	NSMutableArray* arrNoteIds;
	BOOL isActive;

}

+(id) scaleFromDictionary:(NSDictionary*) dict;

@property (nonatomic,retain) NSString* scaleId;
@property (nonatomic,retain) NSString* scaleName;
@property (nonatomic,retain) NSString* scaleType;
@property (nonatomic,retain) NSMutableArray* arrNoteIds;
@property BOOL isActive;

-(NSString*) key;
-(NSString*) label;

-(void) addNoteId:(NSString*) noteId;

@end
