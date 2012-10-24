//
//  SongToolExtendedPanelBase.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "SongToolExtendedPanelBase.h"
#import "SongToolViewControllerBase.h"


@implementation SongToolExtendedPanelBase
@synthesize delegate;
@synthesize doneButton = mDoneButton;
@synthesize logo = mLogo;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {	
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code		
		self.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)awakeFromNib
{
	UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pback.png"]];
	[self insertSubview:iv atIndex:0];
	[iv release];
	
	if(!self.doneButton)
	{
		mDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(232, 260, 51, 31)];
		[mDoneButton setImage:[UIImage imageNamed:@"pback_done_idle.png"] forState:UIControlStateNormal];
		[mDoneButton setImage:[UIImage imageNamed:@"pback_done_pressed.png"] forState:UIControlStateSelected];
		mDoneButton.backgroundColor = [UIColor clearColor];
		[self addSubview:mDoneButton];
		[mDoneButton release];
		[self.doneButton retain];
	}
	[mDoneButton addTarget:self action:@selector(donePressed::) forControlEvents:UIControlEventTouchUpInside];
	
	if(!self.logo)
	{
		mLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pback_logos.png"]];
		mLogo.frame = CGRectMake(18, 260, mLogo.frame.size.width, mLogo.frame.size.height);
		[self addSubview:mLogo];
		[mLogo release];
		[self.logo retain];
	}
}	
		
- (void)dealloc 
{
	self.doneButton = nil;
	self.logo = nil;
	self.delegate = nil;
    [super dealloc];
}


- (void)donePressed:(id)sender:(UIEvent*)fromEvent
{
	[delegate hideExtendedToolPanel];
}


@end
