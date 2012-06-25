//
//  NoteManager.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NotesManager.h"
#import "Note.h"
#import "SBJSON.h"

@implementation NotesManager

@synthesize notes;

- (id)initFromJsonFile:(NSString*) jsonFile {
    self = [super init];
	
    if (self) {
		//class-specific init
		//NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:@"loops" ofType:@"json"];
		NSString* jsonFilePath = [[NSBundle mainBundle] pathForResource:jsonFile ofType:nil];
		
		NSURL* fileURL = [NSURL fileURLWithPath:jsonFilePath]; 
		NSStringEncoding encodingUsed;
		NSError* error = nil;
		NSString *fileContentsAsString = [[NSString stringWithContentsOfURL:fileURL usedEncoding:&encodingUsed error:&error] retain];  
		
		// for array-type json files
		SBJSON* sbJson = [[SBJSON alloc] init];
		NSArray* arrInstanceDicts = [sbJson objectWithString:fileContentsAsString error:&error];
		[sbJson release];
		
		
		notes = [[NSMutableArray alloc] init];
		
		for(NSDictionary* instanceDict in arrInstanceDicts) {
			Note* instance = [Note fromDictionary:instanceDict];
			[notes addObject:instance];
		}
		
    }
    return self; // GSB: this the better way to manage leaks?
}

- (void)dealloc {
	[notes release];
	
    [super dealloc];
}


@end
