//
//  AppStateManager.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppStateManager.h"
#import "AppState.h"
#import "JSON.h"

#import <CoreFoundation/CFUUID.h>

@implementation AppStateManager

@synthesize appState;


- (id)init {
    self = [super init];
	
    if (self) {
		NSString* jsonString = nil;
		
		// 1. load from prefs if available
		jsonString = [[NSUserDefaults standardUserDefaults] stringForKey:@"appState.json"];
		
		// 2. if not, load from filesystem
		if(jsonString == nil || [jsonString length] == 0) {
			
			NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:@"appStateDefault" ofType:@"json"];
			NSStringEncoding encodingUsed;
			NSError* error = nil;
			jsonString = [[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:jsonFilePath] usedEncoding:&encodingUsed error:&error] retain];  
			
		}
		
		SBJSON* sbJson = [[SBJSON alloc] init];
		NSDictionary* appStateDict = [sbJson objectWithString:jsonString error:nil];
		[sbJson release];
		
		appState = [AppState fromDictionary:appStateDict];
		
    }
    return self;
}


-(void) saveToPreferences {
	
	if(appState.uuid == nil || [appState.uuid isEqualToString:@""]) {
		CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
		if (theUUID) {
			appState.uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
			CFRelease(theUUID);
		} else {
			appState.uuid = @"UNABLE_TO_GEN";
		}
	}								
	
	
	SBJSON* sbJson = [[SBJSON alloc] init];
	NSString* strAppState = [sbJson stringWithObject:[appState toDictionary]];
	[sbJson release];

	[[NSUserDefaults standardUserDefaults] setObject:strAppState forKey:@"appState.json"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

-(void) dealloc {
	[appState release];
	[super dealloc];
}

@end
