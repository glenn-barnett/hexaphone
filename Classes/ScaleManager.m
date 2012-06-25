//
//  ScaleManager.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScaleManager.h"
#import "SBJSON.h"
#import "Scale.h"
#import "Instrument.h"

@implementation ScaleManager

@synthesize instrument;
@synthesize scalesMap;
@synthesize sortedScales;

- (id)init {
    self = [super init];
	
    if (self) {
		//class-specific init
		NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:@"scales" ofType:@"json"];
		
		NSURL* fileURL = [NSURL fileURLWithPath:jsonFilePath]; 
		NSStringEncoding encodingUsed;
		NSError* error = nil;
		NSString *fileContentsAsString = [[NSString stringWithContentsOfURL:fileURL usedEncoding:&encodingUsed error:&error] retain];  
		
		SBJSON* sbJson = [[SBJSON alloc] init];
		NSArray* arrScaleDicts = [sbJson objectWithString:fileContentsAsString error:&error];
		[sbJson release];
		
		scalesMap = [[NSMutableDictionary alloc] init];
		sortedScales = [[NSMutableArray alloc] init];
		
		for(NSDictionary* scaleDict in arrScaleDicts) {
			Scale* s = [Scale scaleFromDictionary:scaleDict];
			[scalesMap setObject:s forKey:s.scaleId];
			[sortedScales addObject:s];
		}
		
//		NSArray* sortedScaleIds = [[scalesMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//		for(NSString* scaleId in sortedScaleIds) {
//			[sortedScales addObject:[scalesMap objectForKey:scaleId]];
//		}
		
    }
    return self;
}

-(void) setActiveScaleId:(NSString*) scaleId {
	for(Scale* s in sortedScales) {
		if([scaleId isEqualToString:s.scaleId]) {
			s.isActive = YES;
		} else {
			s.isActive = NO;
		}
	}
}



-(void) dealloc {
	[scalesMap release];
	[sortedScales release];
	[super dealloc];
}

@end
