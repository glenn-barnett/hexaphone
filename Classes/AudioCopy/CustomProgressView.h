//
//  CustomProgressView.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomProgressView : UIProgressView {
}

- (void)setBackgroundImage:(UIImage*)image;
- (void)setBarImage:(UIImage*)image withLeftCap:(NSInteger)leftcap 
		  andTopCap:(NSInteger)topcap andOffset:(CGPoint)point;
@end
