//
//  AudioCopyProgress.m
//	MAPI-AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "AudioCopyProgress.h"


@implementation AudioCopyProgress
@synthesize spinner = mSpinner;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	self.spinner = nil;
    [super dealloc];
}


@end
