//
//  SongToolExtendedPanelBase.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SongToolViewControllerDelegate;

@interface SongToolExtendedPanelBase : UIView {
	id<SongToolViewControllerDelegate> delegate;
	UIButton	*mDoneButton;
	UIImageView	*mLogo;
}

@property(nonatomic, retain) id<SongToolViewControllerDelegate> delegate;
@property(nonatomic, retain) IBOutlet UIButton *doneButton;
@property(nonatomic, retain) IBOutlet UIImageView *logo;

- (void)donePressed:(id)sender:(UIEvent*)fromEvent;
@end
