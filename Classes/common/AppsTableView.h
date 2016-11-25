//
//  AppsTableView.h
//	MAPI-AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CompatibleApps.h"

@class AppsTableView;

@protocol AppsTableViewDelegate
- (void)appWasSelected:(int)index inSection:(int)section fromTable:(AppsTableView*)table;
@end

@interface AppsTableView : UIView <UITableViewDelegate, UITableViewDataSource, CompatibleAppsDelegate> 
{
	UITableView *mTableView;
	UIView		*mAppStoreSectionHeader;
	NSArray		*mAppList;		// Array of dictionaries descripting individual app properties
	NSString*	mURLScheme;
	BOOL		mShowPasteApps;
	BOOL		mShowCopyApps;
	BOOL		mShowCopyPasteImages;
	id<AppsTableViewDelegate> delegate;
}

@property(nonatomic, retain) id<AppsTableViewDelegate> delegate;
@property(nonatomic, retain) NSArray *appList;
@property(nonatomic) BOOL showPasteApps;
@property(nonatomic) BOOL showCopyApps;
@property(nonatomic) BOOL showCopyPasteImages;

- (void)reloadData;


@end
