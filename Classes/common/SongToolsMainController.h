//
//  SongToolsMainController.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SongToolsNavigationBar.h"
#import "SongToolFactory.h"
#if USE_SONGLIST_VIEW
#import "SongListViewController.h"
#endif


@protocol TransportDelegate
	- (BOOL)transportGetPlaying;
	- (void)transportPlay:(id)sender;
	- (void)transportPause:(id)sender;
	- (void)transportSeekEnd:(id)sender;
	- (void)transportSeekBeginning:(id)sender;
	- (void)transportSeekForward:(id)sender;
	- (void)transportSeekBackward:(id)sender;
	@optional
	- (void)closeSession;
	- (void)openSessionAtPath:(NSString *)path;
	- (BOOL)transportGetPreviewing;
@end

@protocol TransitionDelegate
	-(void)grayAndDisable;
	-(void)ungrayAndEnable;
@end

@protocol SongToolsDelegate <NSObject>
@optional
	- (void)songToolsWillAppear;
	- (void)songToolsWillDisappear;
	- (void)songToolsDidDisappear;
	- (void)songToolsWillShowTools;
@end

@protocol SongListViewDelegate
	- (void)songListHidden:(BOOL)animated;
@end


@interface SongToolsMainController : UIViewController 
	<UIScrollViewDelegate, UITextFieldDelegate, UINavigationBarDelegate
#if USE_SONGLIST_VIEW
	, SongListViewDelegate> 
#else
	>
#endif
{
	IBOutlet UIView				*mMainView;
	IBOutlet UIView				*mBackView;
    IBOutlet UIView 			*mModalScreen;
	IBOutlet UIScrollView 		*mToolsScrollView;
	IBOutlet UIPageControl 		*mToolPageControl;
	IBOutlet UIView 			*mSongToolsView;
	IBOutlet UIView				*mTransportView;
	IBOutlet UIView				*mModalTransportScreen;
	// Song info view
	IBOutlet UITextField 		*mSongNameField;
	IBOutlet UIView 			*mSongInfoView;
	IBOutlet UILabel 			*mSongInfoLabel;
	IBOutlet UILabel 			*mAlertLabel;
	IBOutlet UIButton 			*mClearSongNameBtn;
	IBOutlet UIImageView 		*mAlertImageView;
	IBOutlet UIButton			*mPlayPauseBtn;
	
	SongToolsNavigationBar		*mNavbar;
	UINavigationItem			*mSongListNavItem;
	UINavigationItem 			*mSongToolsNavItem;
	UINavigationItem 			*mActiveSongToolNavItem;
#if USE_SONGLIST_VIEW
    SongListViewController		*mSongListViewController;
#endif
	NSMutableArray				*mSongTools;
	CGPoint  					mActiveToolLocation;
	BOOL						mDoHide;
	BOOL						mDoShowSongList;
	BOOL						mDoShowWifiSync;
	BOOL						mIsClosingSongList;
	id <TransportDelegate>		_delegate;
	id <TransitionDelegate>		_transdelegate;
	id <SongToolsDelegate>		_songtoolsdelegate;
@public
	SongToolFactory				*mActiveTool;	
}

@property(nonatomic, assign) id<TransportDelegate> delegate;
@property(nonatomic, assign) id<TransitionDelegate> transdelegate;
@property(nonatomic, assign) id<SongToolsDelegate> songtoolsdelegate;
@property(nonatomic, readonly) SongToolsNavigationBar *navbar;
#if USE_SONGLIST_VIEW
@property(nonatomic, readonly) SongListViewController *songListViewController;
#endif

- (void)addSongTool:(SongToolFactory*)tool;
- (void)addSongTools:(NSArray*)tools;

//- (void)show:(BOOL)show animated:(BOOL)animated;
- (void)showWithAnimation;
- (void)hideWithAnimation;
- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void*)context;
- (void)hideTransportWithAnimation;
- (void)showTransportWithAnimation;
- (IBAction)clearSongName:(id)sender;
- (void)changePage:(id)sender;
- (void)songToolIconPressed:(id)sender:(UIEvent*)fromEvent;
- (void)setupSongTools;

- (void)closeNavItemPressed:(id)sender;
- (void)songToolsNavItemPressed:(id)sender;
- (void)songListNavItemPressed:(id)sender;
- (void)songListHidden:(BOOL)animated;

- (void)showWifiSync;
- (void)showSongListView;
- (void)showSongToolsView;
- (void)showSongToolsViewWithoutAnimation;

- (void)reloadSongInfo;
- (void)setModal:(BOOL)modal;
- (void)showAlert:(BOOL)show;
- (BOOL)isToolShowing;
- (NSString *)activeToolName;

- (BOOL)getTransportPlayToggle;
- (void)setTransportPlayToggle:(BOOL)on;
- (IBAction)transportPlay:(id)sender;
- (IBAction)transportPause:(id)sender;
- (IBAction)transportSeekEnd:(id)sender;
- (IBAction)transportSeekBeginning:(id)sender;
- (IBAction)transportSeekForward:(id)sender;
- (IBAction)transportSeekBackward:(id)sender;

+ (BOOL)isLandscapeMode;

@end
