//
//  PanelCountControl.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PanelCountControl : UIControl {
	UIImageView *mImage;
	UILabel		*mLabel;
}

- (void)setPanelCount:(NSInteger)count;

@end
