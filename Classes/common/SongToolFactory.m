//
//  SongToolFactory.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//
 
#import "SongToolFactory.h"
#import "SongToolsMainController.h"
#import "SongToolViewControllerBase.h"

@implementation SongToolFactory

@synthesize name = mToolName;
@synthesize icon = mToolIcon;
@synthesize controller = mToolController;

- (id)initWithClass:(Class)toolClass name:(NSString*)toolName andIcon:(UIImage*)toolIcon delegate:(id)toolDelegate;
{
	NSAssert([toolClass isSubclassOfClass:[SongToolViewControllerBase class]] == YES, @"song tool is not of the right type");
	
	if (self = [super init])
	{
		self.name = toolName;
		self.icon = toolIcon;
		mToolClass = toolClass;
		mToolDelegate = toolDelegate;
	}
	return self;
}

- (SongToolViewControllerBase*)openTool:(SongToolsMainController*)stmc{
	
	mToolController = [[mToolClass alloc] initTool:stmc delegate:mToolDelegate];
	return mToolController;
}

- (void)closeTool{
	[mToolController closeTool];
	[mToolController release];
	mToolController = nil;
}

@end
