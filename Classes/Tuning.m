//
//  Key.m
//  Hexatone
//
//  Created by Glenn Barnett on 1/17/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "Tuning.h"

#define kStepAdjustmentC   0.0f
#define kStepAdjustmentDb  0.5f
#define kStepAdjustmentD   1.0f
#define kStepAdjustmentEb  1.5f
#define kStepAdjustmentE   2.0f
#define kStepAdjustmentF   2.5f
#define kStepAdjustmentGb  3.0f
#define kStepAdjustmentG   3.5f
#define kStepAdjustmentAb -2.0f
#define kStepAdjustmentA  -1.5f
#define kStepAdjustmentBb -1.0f
#define kStepAdjustmentB  -0.5f

#define kStepAdjustmentMax 3.5f
#define kStepAdjustmentMin -2.0f

@implementation Tuning

@dynamic stepAdjustment;
@synthesize tuningId;
@synthesize isActive;

+(id) C {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentC;
	return key;
}

+(id) Db {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentDb;
	return key;
}

+(id) D {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentD;
	return key;
}

+(id) Eb {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentEb;
	return key;
}

+(id) E {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentE;
	return key;
}

+(id) F {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentF;
	return key;
}

+(id) Gb {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentGb;
	return key;
}

+(id) G {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentG;
	return key;
}

+(id) Ab {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentAb;
	return key;
}

+(id) A {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentA;
	return key;
}

+(id) Bb {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentBb;
	return key;
}

+(id) B {
	Tuning* key = [[Tuning alloc] init];
	key.stepAdjustment = kStepAdjustmentB;
	return key;
}

+(id) tuningFromId:(NSString*) tuningIdArg {
	if([tuningIdArg isEqualToString:@"C"])
		return [Tuning C];
	if([tuningIdArg isEqualToString:@"Db"] || [tuningIdArg isEqualToString:@"C#"])
		return [Tuning Db];
	if([tuningIdArg isEqualToString:@"D"])
		return [Tuning D];
	if([tuningIdArg isEqualToString:@"Eb"] || [tuningIdArg isEqualToString:@"D#"])
		return [Tuning Eb];
	if([tuningIdArg isEqualToString:@"E"])
		return [Tuning E];
	if([tuningIdArg isEqualToString:@"F"])
		return [Tuning F];
	if([tuningIdArg isEqualToString:@"Gb"] || [tuningIdArg isEqualToString:@"F#"])
		return [Tuning Gb];
	if([tuningIdArg isEqualToString:@"G"])
		return [Tuning G];
	if([tuningIdArg isEqualToString:@"Ab"] || [tuningIdArg isEqualToString:@"G#"])
		return [Tuning Ab];
	if([tuningIdArg isEqualToString:@"A"])
		return [Tuning A];
	if([tuningIdArg isEqualToString:@"Bb"] || [tuningIdArg isEqualToString:@"A#"])
		return [Tuning Bb];
	if([tuningIdArg isEqualToString:@"B"])
		return [Tuning B];
	return nil; 
	
}



-(id) increment {
	if(self.stepAdjustment < kStepAdjustmentMax)
		self.stepAdjustment += 0.5;
	else
		self.stepAdjustment = kStepAdjustmentMin;
	
	return self;
}

-(id) decrement {
	if(self.stepAdjustment > kStepAdjustmentMin)
		self.stepAdjustment -= 0.5;
	else
		self.stepAdjustment = kStepAdjustmentMax;
	
	return self;
}

-(float) stepAdjustment {
	return stepAdjustment;
}

-(NSString*) label {
	return tuningId;
}

-(void) setStepAdjustment:(float)argStepAdjustment {
	stepAdjustment = argStepAdjustment;
	
	if     (stepAdjustment == kStepAdjustmentC)
		tuningId = @"C";
	else if(stepAdjustment == kStepAdjustmentDb)
		tuningId = @"Db";
	else if(stepAdjustment == kStepAdjustmentD)
		tuningId = @"D";
	else if(stepAdjustment == kStepAdjustmentEb)
		tuningId = @"Eb";
	else if(stepAdjustment == kStepAdjustmentE)
		tuningId = @"E";
	else if(stepAdjustment == kStepAdjustmentF)
		tuningId = @"F";
	else if(stepAdjustment == kStepAdjustmentGb)
		tuningId = @"Gb";
	else if(stepAdjustment == kStepAdjustmentG)
		tuningId = @"G";
	else if(stepAdjustment == kStepAdjustmentAb)
		tuningId = @"Ab";
	else if(stepAdjustment == kStepAdjustmentA)
		tuningId = @"A";
	else if(stepAdjustment == kStepAdjustmentBb)
		tuningId = @"Bb";
	else if(stepAdjustment == kStepAdjustmentB)
		tuningId = @"B";
	
}

-(void) dealloc {
	[tuningId release];
	[super dealloc];
}

@end
