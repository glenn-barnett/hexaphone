//
//  AudioCopyProgress.h
//	MAPI-AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AudioCopyProgress : UIView {
	UIActivityIndicatorView *mSpinner;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@end
