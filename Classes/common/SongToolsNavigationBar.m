//
//  SongToolsNavigationBar.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "SongToolsNavigationBar.h"


@implementation SongToolsNavigationBar
@synthesize opacity;

- (id)init
{
	if(self = [super init])
	{
		self.opacity = 0.80f;
	}
	return self;
}

- (void)setOpacity:(float)val;
{
	opacity = val;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	// Draw the background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0);
	CGContextSetAlpha(context, opacity);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGRect rrect = self.bounds;	
	CGContextFillRect(context, rrect);
}

@end
