//
//  AudioCopyBackView.h
//	MAPI-AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongToolExtendedPanelBase.h"
#import "AppsTableView.h"

@interface AudioCopyBackView : SongToolExtendedPanelBase {
	AppsTableView *mTableView;
}

@property(nonatomic, retain) IBOutlet AppsTableView *tableView;

@end
