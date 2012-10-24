//
//  SongToolProgressPanel.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SongToolProgressPanel : UIViewController {
    IBOutlet UILabel *mLabel;
    IBOutlet UIImageView *mCustomProgressBar;
	IBOutlet UIImageView *mIcon;
	IBOutlet UIActivityIndicatorView *mSpinner;

	UIImageView *mBackgroundView;
	UIImage *mProgressBarImage;

    float mProgress;
}
@property (readwrite) float progress;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) UIImage *progressBarImage;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

- (void)useSpinner;
- (void)useProgressBar;

@end
