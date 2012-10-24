//
//  CompatibleApps.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@protocol CompatibleAppsDelegate<NSObject>
-(void)compatibleAppsRefreshed;
@end

@interface CompatibleApps : NSObject {
    ASINetworkQueue     *mQueue;
    int                 mImageLoadCount;
    BOOL                mReady;
    BOOL                mReadyFromNetwork;
    id<CompatibleAppsDelegate> 	mDelegate;
    NSString            *mCompatibleAppsCachePath;
	NSMutableArray		*mCompatibleApps;
	NSMutableArray		*mNonInstalledApps;
	NSMutableArray		*mInstalledApps;
	NSMutableArray		*mInstalledPasteApps;
	NSMutableArray		*mInstalledCopyApps;
	NSMutableArray		*mNonInstalledPasteApps;
	NSMutableArray		*mNonInstalledCopyApps;
}

@property(nonatomic, retain) IBOutlet NSArray *compatibleApps;
@property(nonatomic, retain) NSArray *installedApps;
@property(nonatomic, retain) NSArray *installedPasteApps;
@property(nonatomic, retain) NSArray *installedCopyApps;
@property(nonatomic, retain) NSArray *nonInstalledApps;
@property(nonatomic, retain) NSArray *nonInstalledPasteApps;
@property(nonatomic, retain) NSArray *nonInstalledCopyApps;
@property(nonatomic, retain) id<CompatibleAppsDelegate> delegate;
@property(readonly) BOOL ready;
@property(readonly) BOOL readyFromNetwork;

+ (CompatibleApps *)sharedInstance;
- (void)refresh;

@end
