//
//  Sample.m
//  Hexatone
//
//  Created by Glenn Barnett on 1/17/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//
//   afconvert -f caff -d LEI16@44100 -c 1 in.wav out.caf

#import "Sample.h"
#import "Tuning.h"

#define kCafFileType @"caf"

@implementation Sample

@synthesize noteId;
@dynamic cafName;
@synthesize cafFilePath;
@synthesize octaveAdjust;
@synthesize stepAdjust;

+(id) sampleFromDictionary:(NSDictionary*) dict {

	Sample *s = [[Sample alloc] init];
	s.noteId		= [dict valueForKey:@"noteId"];
	s.cafName		= [dict valueForKey:@"cafName"];
	s.octaveAdjust	= [dict valueForKey:@"octaveAdjust"];
	s.stepAdjust	= [dict valueForKey:@"stepAdjust"];
	return s;
	
}

-(NSString*) cafName {
	return cafName;
}

-(void) setCafName:(NSString*) cafNameArg {
	cafName = cafNameArg;
	self.cafFilePath = [[NSBundle mainBundle] pathForResource:self.cafName ofType:kCafFileType];
	if(self.cafFilePath == nil) {
		NSLog(@" *** ERROR: null cafFilePath for sample: %@", self);
	}
	
}

- (float) sampleRateMultiplierForTuning:(Tuning*) tuning {
	float sampleRateMultiplier = 1.0f;
	
	int octavesChange = [self.octaveAdjust intValue];
	
	double halfStepsChange = [self.stepAdjust floatValue];
	
	for(SInt32 d=0; d<octavesChange; d++) {
		sampleRateMultiplier *= 2	;
	}
	
	for(SInt32 d=0; d>octavesChange; d--) {
		sampleRateMultiplier /= 2	;
	}
	
	for(float d=0.0f; d<halfStepsChange; d+=0.5f) {
		sampleRateMultiplier *= 1.05946	;
	}
	
	for(float d=0.0f; d>halfStepsChange; d-=0.5f) {
		sampleRateMultiplier /= 1.05946	;
	}
	
	for(float d=0.0f; d<tuning.stepAdjustment; d+=0.5f) {
		sampleRateMultiplier *= 1.05946	;
	}
	
	for(float d=0.0f; d>tuning.stepAdjustment; d-=0.5f) {
		sampleRateMultiplier /= 1.05946	;
	}
	
	return sampleRateMultiplier;
	
}

- (NSString*) description {
	return [NSString stringWithFormat:@"[Sample noteId=%@ cafName=%@ octAdj=%f stepAdj=%f]", 
			self.noteId,
			self.cafName,
			self.octaveAdjust,
			self.stepAdjust
			];
}


-(void) dealloc {
	
	[noteId release];
	[cafName release];
	[cafFilePath release];
	[octaveAdjust release];
	[stepAdjust release];
	
	[super dealloc];
}

@end
