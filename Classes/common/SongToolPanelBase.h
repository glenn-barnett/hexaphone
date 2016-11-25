//
//  SongToolViewBase.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SongToolViewControllerDelegate;
@class SongToolExtendedPanelBase;

@interface SongToolPanelBase : UIView {
	NSString 							*mName;
	id<SongToolViewControllerDelegate>	delegate;
	IBOutlet SongToolExtendedPanelBase	*mExtendedPanel;
	IBOutlet UIImageView				*mExtendedPanelImage;
	UIButton							*mExtendedPanelButton;
}

@property(nonatomic, retain) id<SongToolViewControllerDelegate>	delegate;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) SongToolExtendedPanelBase *extendedPanel;
@property(nonatomic, retain) UIButton *extendedPanelButton;
@property(nonatomic, retain) UIImageView *extendedPanelImage;

- (void)showExtendedPanel:(id)sender:(UIEvent*)fromEvent;

@end

