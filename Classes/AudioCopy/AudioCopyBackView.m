//
//  AudioCopyBackView.m
//	MAPI-AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "AudioCopyBackView.h"


@implementation AudioCopyBackView
@synthesize tableView = mTableView;

/*
- (void)layoutSubviews
{
}
*/
-(void)dealloc
{
	self.tableView = nil;
	[super dealloc];
}
@end
