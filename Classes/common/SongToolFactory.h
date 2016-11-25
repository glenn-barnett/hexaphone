//
//  SongToolFactory.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SongToolsMainController;
@class SongToolViewControllerBase;

@interface SongToolFactory : NSObject
{
	UIImage 					*mToolIcon;
	NSString 					*mToolName;
	SongToolViewControllerBase	*mToolController;
	Class						mToolClass;
	id							mToolDelegate;
}

@property(nonatomic, retain) UIImage *icon;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, readonly) SongToolViewControllerBase *controller;

- (id)initWithClass:(Class)toolClass name:(NSString*)toolName andIcon:(UIImage*)toolIcon delegate:(id)toolDelegate;
- (SongToolViewControllerBase*)openTool:(SongToolsMainController*)stmc;
- (void)closeTool;

@end