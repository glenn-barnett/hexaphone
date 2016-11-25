//
//  Key.h
//  Hexatone
//
//  Created by Glenn Barnett on 1/17/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tuning : NSObject {
	float stepAdjustment;
	NSString* tuningId;
	BOOL isActive;
}

@property float stepAdjustment;
@property (nonatomic,retain) NSString* tuningId;
@property BOOL isActive;

-(id) increment;
-(id) decrement;
-(NSString*) label;
+(id) tuningFromId:(NSString*) tuningId;


+(id) Ab;
+(id) A;
+(id) Bb;
+(id) B;
+(id) C;
+(id) Db;
+(id) D;
+(id) Eb;
+(id) E;
+(id) F;
+(id) Gb;
+(id) G;


	
@end
