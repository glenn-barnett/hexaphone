//
//  CustomProgressView.m
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "CustomProgressView.h"

#define BKG_VIEW_TAG 10
#define BAR_VIEW_TAG 11

@implementation CustomProgressView

- (id)init
{
	if(self = [super init])
	{
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setBackgroundImage:(UIImage*)image
{
	if([self viewWithTag:BKG_VIEW_TAG])
		[[self viewWithTag:BKG_VIEW_TAG] removeFromSuperview];
	
	UIImageView *iv = [[UIImageView alloc] initWithImage:image];
	iv.tag = BKG_VIEW_TAG;
	[self insertSubview:iv atIndex:0];
	[iv release];
}

- (void)setBarImage:(UIImage*)image withLeftCap:(NSInteger)leftcap 
		  andTopCap:(NSInteger)topcap andOffset:(CGPoint)point
{
	if([self viewWithTag:BAR_VIEW_TAG])
		[[self viewWithTag:BAR_VIEW_TAG] removeFromSuperview];
	
	UIImageView *iv = [[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:leftcap topCapHeight:topcap]];
	iv.tag = BAR_VIEW_TAG;
	[self addSubview:iv];
	CGRect frame = iv.frame;
	frame.origin.x += point.x;
	frame.origin.y += point.y;
	iv.frame = frame;
	[iv release];
}

- (void)setProgress:(float)value
{
	[super setProgress:value];
	
	UIImageView *bar = (UIImageView*)[self viewWithTag:BAR_VIEW_TAG];
	UIImageView *bkgrnd = (UIImageView*)[self viewWithTag:BKG_VIEW_TAG];
	
	
	CGRect frame = bar.frame;
	if(value >= 1.0f)
		frame.size.width = self.bounds.size.width - frame.origin.x * 2;
	else
		frame.size.width = floor((self.bounds.size.width)* value);
	
	// Set minimum bar size
//	if(frame.size.width < 18)
//		frame.size.width = 0;
	
	bar.frame = frame;
}

- (void)drawRect:(CGRect)rect
{
}


@end
