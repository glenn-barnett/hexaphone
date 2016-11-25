//
//  SongToolViewBase.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "SongToolPanelBase.h"
#import "SongToolExtendedPanelBase.h"
#import "SongToolViewControllerBase.h"

#define EXTENDED_PANEL_BUTTON	10

@implementation SongToolPanelBase
@synthesize name = mName;
@synthesize delegate;
@synthesize extendedPanel = mExtendedPanel;
@synthesize extendedPanelImage = mExtendedPanelImage;
@synthesize extendedPanelButton = mExtendedPanelButton;

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
		self.contentMode = UIViewContentModeCenter;
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

- (void)setDelegate:(id<SongToolViewControllerDelegate>)stvd
{
	delegate = stvd;
	if(mExtendedPanel)
		mExtendedPanel.delegate = stvd;
}

- (void)setHidden:(BOOL)hide
{
	[super setHidden:hide];
	[mExtendedPanel setHidden:hide];
}


- (void)awakeFromNib
{
	// Add the panel background image
//	UIImageView* iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"songtools_panel.png"]];
//	[self insertSubview:iv atIndex:0];
//	[iv release];
	
	if(mExtendedPanel)
	{	
		if(!self.extendedPanelImage)
		{
			// Add the extended panel button image
			UIImage* img = [UIImage imageNamed:@"infobtn.png"];		
			self.extendedPanelImage = [[UIImageView alloc] initWithImage:img];
		}
		CGRect rect = self.extendedPanelImage.frame;
		CGRect frame = CGRectMake(290 - rect.size.width, 
												290 - rect.size.height, 
												rect.size.width, 
												rect.size.height);

		self.extendedPanelImage.frame = frame;	
		[self addSubview:self.extendedPanelImage];
		[self.extendedPanelImage release];
					
		// Now add the button on top.
		frame = CGRectMake(frame.origin.x-10, frame.origin.y, frame.size.width+20, frame.size.height);
		mExtendedPanelButton = [[UIButton alloc] initWithFrame:frame];
		mExtendedPanelButton.showsTouchWhenHighlighted = YES;
		mExtendedPanelButton.backgroundColor = [UIColor clearColor];
		[mExtendedPanelButton addTarget:self action:@selector(showExtendedPanel::) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:mExtendedPanelButton];
		[mExtendedPanelButton release];
	}
}

- (void)addSubview:(UIView*)view
{
	[super addSubview:view];
}

- (void)bringSubviewToFront:(UIView*)view
{
	[super bringSubviewToFront:view];
	[super bringSubviewToFront:self.extendedPanelImage];
	[super bringSubviewToFront:mExtendedPanelButton];
}

- (void)dealloc 
{
	self.delegate = nil;
	self.name = nil;
	self.extendedPanel = nil;
	//self.extendedPanelButton = nil;
	//self.extendedPanelImage = nil;
    [super dealloc];
}


- (void)showExtendedPanel:(id)sender:(UIEvent*)fromEvent
{
	[delegate showExtendedToolPanel:self:mExtendedPanel];
}

@end
