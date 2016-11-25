//
//  CopyDoneView.m
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "CopyDoneView.h"

@implementation CopyDoneView
@synthesize tableView = mTableView;

-(void)dealloc
{
	self.tableView = nil;
	[super dealloc];
}

@end
