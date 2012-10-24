//
//  SongToolIcon.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "SongToolIcon.h"

#define ICON_VIEW_TAG 10

@implementation SongToolIcon
@synthesize songTool = mSongTool;
@synthesize highlightView = mPressHighlight;

- (id)initWithSongTool:(SongToolFactory*)tool andFrame:(CGRect)frame{
	if(self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)])
	{
		self.songTool = tool;
	
		// Add the song tool image
		UIImageView* iv = [[UIImageView alloc] initWithImage:tool.icon];
		iv.contentMode = UIViewContentModeScaleAspectFit;
		iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		iv.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
		iv.tag = ICON_VIEW_TAG;
		[self addSubview:iv];

		// Add the song tool name
		UILabel* toolName = [[UILabel alloc] initWithFrame:CGRectMake(-5, frame.size.width + 3, 
			frame.size.width+10, frame.size.height - frame.size.width - 3)];
		toolName.text = tool.name;
		toolName.textAlignment = UITextAlignmentCenter;
		toolName.textColor = [UIColor whiteColor];
		toolName.font = [UIFont systemFontOfSize:11];
		toolName.contentMode = UIViewContentModeCenter;
		toolName.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;		
		toolName.backgroundColor = [UIColor clearColor];
		[self addSubview:toolName];
		
		UIImage *image = [UIImage imageNamed:@"songtool_icon_pressbg.png"];
		mPressHighlight = [[UIImageView alloc] initWithImage:image];
		mPressHighlight.alpha = 0.7f;
		mPressHighlight.hidden = YES;
		[self addSubview:mPressHighlight];
		
		[mPressHighlight release];
		[iv release];
		[toolName release];		
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	mPressHighlight.hidden = NO;
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self];
	BOOL inside = [self pointInside:loc withEvent:event];
	if(inside)
		[self performSelector:@selector(handlePress) withObject:nil afterDelay:0.05f];
	else
		mPressHighlight.hidden = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self];
	BOOL inside = [self pointInside:loc withEvent:event];
	mPressHighlight.hidden = !inside;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	mPressHighlight.hidden = YES;
}

- (void)handlePress
{
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	mPressHighlight.hidden = YES;
}

- (void)dealloc {
	self.songTool = nil;
	self.highlightView = nil;
    [super dealloc];
}

@end
