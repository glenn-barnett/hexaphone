//
//  Note.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Note.h"


@implementation Note

// GSB: autogen string fields
@synthesize noteLetter;
@synthesize noteTitle;
@synthesize noteSubTitle;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		// GSB: would be needed if we were to do obj-obj relationships / arrays / maps
    }
    return self;
}


+(id) fromDictionary:(NSDictionary*) otherDictionary {
	// GSB: use class name
	Note* instance = [[Note alloc] init];

	// GSB: autogen string fields
	instance.noteLetter = [otherDictionary objectForKey:@"noteLetter"];
	instance.noteTitle = [otherDictionary objectForKey:@"noteTitle"];
	instance.noteSubTitle = [otherDictionary objectForKey:@"noteSubTitle"];
		
	return instance;
}


-(NSDictionary*) toDictionary {
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

	// GSB: autogen string output
	if(noteLetter != nil)
		[dict setObject:noteLetter forKey:@"noteLetter"];
	if(noteTitle != nil)
		[dict setObject:noteLetter forKey:@"noteTitle"];
	if(noteSubTitle != nil)
		[dict setObject:noteLetter forKey:@"noteSubTitle"];

	return [dict autorelease]; //GSB: confirm this is the right way to prevent leaks
}


- (void)dealloc {
    [super dealloc];
}


@end
