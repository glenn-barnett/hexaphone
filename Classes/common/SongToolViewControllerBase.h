//
//  SongToolViewControllerBase.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongToolPanelBase.h"
#import "PageSwipeControl.h"
#import "PanelCountControl.h"
#import "SongToolProgressPanel.h"

@class SongToolsMainController;

@protocol SongToolViewControllerDelegate
- (void)showExtendedToolPanel:(UIView*)main:(UIView*)extended;
- (void)hideExtendedToolPanel;
@end


@interface SongToolViewControllerBase : UIViewController <SongToolViewControllerDelegate> {
	id						mToolDelegate;
	UIImage 				*mToolIcon;
	NSString 				*mToolName;
	NSMutableArray 			*mToolPanels;				// Stores all the songtool's panels
	PageSwipeControl		*mPageSwipeControl;			// Manages swiping between panels
	UIView					*mSwipeModeView;			// Container for the various "panel swipe" controls
	UIView 					*mPanelView;				// Container for the active panel
	PanelCountControl		*mPanelCountControl;		// Displays the # of panels and toggles the "panel swipe mode"	
	SongToolPanelBase		*mActivePanel;				// Maintains the active panel
	UIView					*mActiveExtendedPanel;		// Maintains the active extended panel
    SongToolsMainController *mSongToolsMainController;
    SongToolProgressPanel 	*mProgressPanel;
    BOOL                	mShowProgressPanel;
    UIButton            	*mShowPanels;
	BOOL					mIsHidden;
}

@property(nonatomic, retain) UIImage* toolIcon;
@property(nonatomic, retain) NSString* toolName;
@property(readonly) BOOL showProgressPanel;
@property(readonly) SongToolProgressPanel *progressPanel;
@property(readonly) UIView *activePanel;
@property(readonly) UIView *panelView;

- (id)initTool:(SongToolsMainController *)stmc delegate:(id)toolDelegate;
- (void)closeTool;

- (void)addPanel:(SongToolPanelBase*)toolView;
- (void)removePanel:(SongToolPanelBase*)toolView;
- (void)showPanel:(NSInteger)index;
- (void)panelPressed:(id)sender:(UIEvent*)fromEvent;
- (void)toggleExtendedPanel:(UIView*) main:(UIView*)extended;
- (void)enterPanelSwipeMode:(id)sender:(UIEvent*)fromEvent;
- (void)setModal:(BOOL)modal;
- (void)setShowProgressPanel:(BOOL)show withTitle:(NSString *)title withImage:(UIImage *)image;
- (BOOL)isHidden;

// Navigation item handlers
- (void)closeNavItemPressed:(id)sender;
- (void)songToolsNavItemPressed:(id)sender;

- (void)show:(BOOL)animated touchPoint:(CGPoint)point;
- (void)hide:(BOOL)animated touchPoint:(CGPoint)point;
- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context;

@end
