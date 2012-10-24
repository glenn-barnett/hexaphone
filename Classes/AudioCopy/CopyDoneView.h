//
//  CopyDoneView.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppsTableView.h"

@interface CopyDoneView : UIView {
	AppsTableView *mTableView;
}

@property(nonatomic, retain) IBOutlet AppsTableView* tableView;

@end
