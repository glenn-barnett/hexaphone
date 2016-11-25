//
//  LoopCopy.m
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "loopCopy.h"
#import "AudioCopyPaste.h"

@implementation LoopCopy

@synthesize didSucceed;
@synthesize mixPath;
@synthesize meta;
@synthesize pasteboard;

-(id)init
{
	if(self = [super init])
	{
		self.pasteboard = SWW_AUDIOCOPY_PASTEBOARD_NAME;
	}
	return self;
}

-(void)dealloc
{
	self.mixPath = nil;
	self.pasteboard = nil;
	self.meta = nil;
	[super dealloc];
}

- (void)main
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	didSucceed = NO;
	//BOOL result = [AudioCopyPaste copyAudioFileAtPath:mixPath withMeta:meta toPasteboard:pasteboard];
	BOOL result = [AudioCopyPaste copyMappedAudioFileAtPath:mixPath withMeta:meta toPasteboard:pasteboard];
   	assert(result);
	result = [AudioCopyPaste copyAudioFileAtPathToGeneralPasteboard:mixPath];
	assert(result);
	didSucceed = YES;
	[pool release];
}

@end
