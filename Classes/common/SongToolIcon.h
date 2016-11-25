//
//  SongToolIcon.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongToolFactory.h"

@interface SongToolIcon : UIControl {
	SongToolFactory *mSongTool;
	UIImageView		*mPressHighlight;
}

@property(retain) SongToolFactory* songTool;
@property(nonatomic, retain) UIView *highlightView;

- (id)initWithSongTool:(SongToolFactory*)tool andFrame:(CGRect)frame;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
