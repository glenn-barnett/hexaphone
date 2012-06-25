//
//  Sample.h
//  Hexatone
//
//  Created by Glenn Barnett on 1/17/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//
//   afconvert -f caff -d LEI16@44100 -c 1 in.wav out.caf
// GSB: ensure that wav is mono - otherwise will be silent

#import <Foundation/Foundation.h>

@class Tuning;

@interface Sample : NSObject {
	NSString* noteId;
	NSString* cafName;
	NSString* cafFilePath;
	NSDecimalNumber* octaveAdjust;
	NSDecimalNumber* stepAdjust;
	
}

+(id) sampleFromDictionary:(NSDictionary*) dict;

@property (nonatomic,retain) NSString* noteId;
@property (nonatomic,retain) NSString* cafName;
@property (nonatomic,retain) NSString* cafFilePath;
@property (nonatomic,retain) NSDecimalNumber* octaveAdjust;
@property (nonatomic,retain) NSDecimalNumber* stepAdjust;

- (float) sampleRateMultiplierForTuning: (Tuning*)tuning;
- (NSString*) description;

@end
