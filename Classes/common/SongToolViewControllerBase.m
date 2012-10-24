//
//  SongToolViewControllerBase.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "SongToolViewControllerBase.h"
#import "SongToolsMainController.h"
#import "SongToolsNavigationBar.h"
#import <QuartzCore/QuartzCore.h>

#define TOOL_PANEL_WIDTH				300
#define SWIPE_MODE_TOOL_PANEL_WIDTH		200
#define SWIPE_MODE_TOOL_PANEL_MARGIN 	((TOOL_PANEL_WIDTH - SWIPE_MODE_TOOL_PANEL_WIDTH) / 2)

@implementation SongToolViewControllerBase
@synthesize toolIcon = mToolIcon;
@synthesize toolName = mToolName;
@synthesize progressPanel = mProgressPanel;
@synthesize activePanel = mActivePanel;
@synthesize panelView = mPanelView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		// Allocate the array for storing tool panels
		mToolPanels = [[NSMutableArray alloc] initWithCapacity:1];
		
		// Setup the swipe mode view
		mSwipeModeView = [[UIView alloc] init];
		mSwipeModeView.backgroundColor = [UIColor clearColor];

		// Make some adjustments for landscape mode
		if([SongToolsMainController isLandscapeMode])
		{
			mSwipeModeView.frame = CGRectMake(0, 
											  44, 
											  self.view.frame.size.height, 
											  self.view.frame.size.width-44);	
			mPageSwipeControl = [[PageSwipeControl alloc] initWithFrame:mSwipeModeView.bounds];
		}
		else
		{
			mSwipeModeView.frame = CGRectMake(0, 
											  0, 
											  self.view.frame.size.width, 
											  self.view.frame.size.height-57);
			CGRect f = CGRectMake(0, 
								 0, 
								 self.view.frame.size.width, 
								 self.view.frame.size.height-64-44);
			mPageSwipeControl = [[PageSwipeControl alloc] initWithFrame:f];
		}
		mSwipeModeView.hidden = YES;		
		
		// Add the custom page swiping control to the "swipe mode view"
		mPageSwipeControl.backgroundColor = [UIColor clearColor];
		mPageSwipeControl.pageSize = CGSizeMake(SWIPE_MODE_TOOL_PANEL_WIDTH, SWIPE_MODE_TOOL_PANEL_WIDTH);
		[mPageSwipeControl addTarget:self action:@selector(panelPressed::) forControlEvents:UIControlEventTouchUpInside];		
		[mSwipeModeView addSubview:mPageSwipeControl];
		[mPageSwipeControl release];
		
		// Setup the panel view
		mPanelView = [[UIView alloc] init];
		mPanelView.backgroundColor = [UIColor clearColor];
		mPanelView.frame = CGRectMake((self.view.frame.size.width - 320) / 2, 0, 320, 320);
		mPanelView.hidden = NO;
		
		// Add the Panel Count Control
		mPanelCountControl = [[PanelCountControl alloc] init];
		mPanelCountControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[mPanelCountControl addTarget:self action:@selector(enterPanelSwipeMode::) forControlEvents:UIControlEventTouchUpInside];
		CGRect frame = mPanelCountControl.frame;
		frame.origin.x = (int)((320 - frame.size.width) / 2);
		frame.origin.y = 325;
		mPanelCountControl.frame = frame;
		mPanelCountControl.backgroundColor = [UIColor clearColor];
		mPanelCountControl.hidden = YES;
		[self.view addSubview:mPanelCountControl];
		[mPanelCountControl release];
		
		// Make some adjustments for landscape mode
		if([SongToolsMainController isLandscapeMode])
		{
			mPanelView.frame = CGRectMake((self.view.frame.size.height - 320) / 2, 
										  0,
										  320, 
										  320);
										  
            mPanelCountControl.center = CGPointMake(290,120+44);
        }		
		
		// The "panel view" is displayed by default (the active panel is displayed)
		[self.view addSubview:mSwipeModeView];
		[mSwipeModeView release];
		[self.view addSubview:mPanelView];
		[mPanelView release];
		self.view.clipsToBounds = NO;
		
		mShowProgressPanel = NO;
		mProgressPanel = [[SongToolProgressPanel alloc] initWithNibName:@"SongToolProgressPanel" bundle:nil];		
		mIsHidden = YES;		
	}
    return self;
}

- (void)closeTool
{
	// Remove any delegate associations
	for(unsigned int i = 0; i < [mToolPanels count]; ++i)
	{
		SongToolPanelBase* stp = [mToolPanels objectAtIndex:i];
		stp.delegate = nil;
	}
}

- (id)initTool:(SongToolsMainController *)stmc delegate:(id)toolDelegate
{
    if(self = [super init])
	{
        mSongToolsMainController = stmc;
		mToolDelegate = toolDelegate;
    }
    return self;
}

- (void)loadView
{
	[super loadView];
	self.view.frame = CGRectMake(0, 0, 320, 480);
	self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)awakeFromNib
{
	int i;
	i = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[mToolPanels removeAllObjects];
	[mToolPanels release];
	[mProgressPanel release];
	self.toolIcon = nil;
	self.toolName = nil;
    [super dealloc];
}

- (void)showPanel:(NSInteger)index
{
	if(index >= 0 && index < [mToolPanels count])
	{
		NSArray* views = mPanelView.subviews;
		if([views count] > 0)
			[[views objectAtIndex:0] removeFromSuperview];
	
		SongToolPanelBase *panel = [mToolPanels objectAtIndex:index];
		[mPanelView insertSubview:panel atIndex:0];

		// Center the panel in it's parent view
		CGRect f = CGRectMake((mPanelView.frame.size.width - TOOL_PANEL_WIDTH) / 2,
							  (mPanelView.frame.size.height - TOOL_PANEL_WIDTH) / 2,
							  TOOL_PANEL_WIDTH,
							  TOOL_PANEL_WIDTH);
		panel.frame = f;
		if(panel.extendedPanel)
			[panel.extendedPanel setFrame:f];
		
        mActivePanel = panel;
		[self.view bringSubviewToFront:mPanelCountControl];
    }
}

- (void)addPanel:(SongToolPanelBase*)panel
{
	if(panel == nil)
		return;
	
	// Only allow the toolview to be added once
	for(unsigned int i = 0; i < [mToolPanels count]; ++i)
	{
		if(panel == [mToolPanels objectAtIndex:i])
			return;
	}
	// Add the tool panel
	[mToolPanels addObject:panel];
	panel.delegate = self;
	
	// Set the number of panels for the count control and display it if there is more than 1
	[mPanelCountControl setPanelCount:[mToolPanels count]];
	if ([mToolPanels count] <= 1)
		mPanelCountControl.hidden = YES;
	else
	{
		mPanelCountControl.hidden = NO;
		[self.view bringSubviewToFront:mPanelCountControl];
	}
}

- (void)removePanel:(SongToolPanelBase*)panel;
{
	for(unsigned int i = 0; i < [mToolPanels count]; ++i)
	{
		if(panel == [mToolPanels objectAtIndex:i])
		{
			[mToolPanels removeObjectAtIndex:i];
			break;
		}
	}

	// Set the number of panels for the count control and display it if there is more than 1
	[mPanelCountControl setPanelCount:[mToolPanels count]];
	mPanelCountControl.hidden = [mToolPanels count] <= 1;
}

- (void)show:(BOOL)animated touchPoint:(CGPoint)point
{	
	[self viewWillAppear:animated];
	
	if(animated)
	{
		// Render the active song tool into an image and add the image
		// to the view we will be animating		
		UIGraphicsBeginImageContext(self.view.bounds.size);
		[mPanelView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImageView *iv = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];	
		UIGraphicsEndImageContext();	
		iv.clipsToBounds = NO;
		[self.view addSubview:iv];
		[iv release];
		
		mActivePanel.hidden = YES;
		
		// In landscape mode we need to add the navbar to this view.  This resolves eventing issues
		// when the tool panel overlaps with the navbar
		if([SongToolsMainController isLandscapeMode])
			[self.view insertSubview:mSongToolsMainController.navbar atIndex:0];
	
		mPanelCountControl.alpha = 0.0f;

		[UIView beginAnimations:@"ShowTool" context:nil];
		[UIView setAnimationDuration:0.30f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	
	
		mPanelCountControl.alpha = 1.0f;
	
		// Scale down the active song tool image
		int x = point.x;
		int y = point.y;
		x = x > (int)self.view.bounds.size.width ? x % (int)self.view.bounds.size.width : x;
		y = y > (int)self.view.bounds.size.height ? y % (int)self.view.bounds.size.height : y;
		iv.frame = CGRectMake(x, y, 0, 0);

	
		// Scale active song tool into fullsize
#if USE_SONGLIST_VIEW	
		iv.frame = CGRectMake((self.view.bounds.size.width - mPanelView.bounds.size.width) / 2,
							  0,
							  self.view.bounds.size.width,
							  self.view.bounds.size.height);			
#else		
		iv.frame = CGRectMake((self.view.bounds.size.width - mPanelView.bounds.size.width) / 2,
							  (self.view.bounds.size.height - mPanelView.bounds.size.height) / 2,
							  self.view.bounds.size.width,
							  self.view.bounds.size.height);	
#endif		
	
		[UIView commitAnimations];
	}
	else 
	{
		mActivePanel.hidden = NO;	
		mPanelCountControl.alpha = 1.0f;
	}

}

- (void)hide:(BOOL)animated touchPoint:(CGPoint)point
{	
	[self viewWillDisappear:animated];
	
	if(animated)
	{
		// Render the active song tool into an image and add the image
		// to the view we will be animating
		UIGraphicsBeginImageContext(self.view.bounds.size);
		[mPanelView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImageView *iv = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];	
		UIGraphicsEndImageContext();
	
		iv.clipsToBounds = NO;
		[self.view addSubview:iv];
		[iv release];
	
		// Scale active song tool into fullsize
#if USE_SONGLIST_VIEW	
		iv.frame = CGRectMake((self.view.bounds.size.width - mPanelView.bounds.size.width) / 2,
							  0,
							  self.view.bounds.size.width,
							  self.view.bounds.size.height);			
#else		
		iv.frame = CGRectMake((self.view.bounds.size.width - mPanelView.bounds.size.width) / 2,
							  (self.view.bounds.size.height - mPanelView.bounds.size.height) / 2,
							  self.view.bounds.size.width,
							  self.view.bounds.size.height);
#endif	
	
		mActivePanel.hidden = YES;
		mPanelCountControl.alpha = 1.0f;

		[UIView beginAnimations:@"HideTool" context:nil];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	
	
		mPanelCountControl.alpha = 0.0f;
	
		// Scale down the active song tool image
		int x = point.x;
		int y = point.y;
		x = x > (int)self.view.bounds.size.width ? x % (int)self.view.bounds.size.width : x;
		y = y > (int)self.view.bounds.size.height ? y % (int)self.view.bounds.size.height : y;
		iv.frame = CGRectMake(x, y, 0, 0);
	
		[UIView commitAnimations];	
	}
	else
	{
		[mActivePanel removeFromSuperview];
		mPanelCountControl.alpha = 0.0f;
	}
}


- (void)panelPressed:(id)sender:(UIEvent*)fromEvent
{	
	NSInteger page = mPageSwipeControl.currentPage;

	[self showPanel:page];
	mPanelView.hidden = NO;
	UIGraphicsBeginImageContext(mPanelView.bounds.size);
	[mPanelView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImageView *iv = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];	
	UIGraphicsEndImageContext();

	mPanelView.hidden = YES;
	mPanelCountControl.hidden = NO;
	mPanelCountControl.alpha = 0.0f;
	mSwipeModeView.alpha = 1.0f;
	
	float xOffset = mActivePanel.frame.origin.x;
	float yOffset = mActivePanel.frame.origin.y;
	float inc = 0;
	if([SongToolsMainController isLandscapeMode])
		inc += 44;
	iv.frame = CGRectMake(mPageSwipeControl.pageOrigin.x - xOffset,
						  mPageSwipeControl.pageOrigin.y - yOffset + inc,
						  SWIPE_MODE_TOOL_PANEL_WIDTH + (mPanelView.frame.size.width - TOOL_PANEL_WIDTH),
						  SWIPE_MODE_TOOL_PANEL_WIDTH + (mPanelView.frame.size.height - TOOL_PANEL_WIDTH));	
	
	[self.view addSubview:iv];
	[iv release];
	
	[UIView beginAnimations:@"showPanel" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	
	
	iv.frame = mPanelView.frame;
	mSwipeModeView.alpha = 0.0f;
	mPanelCountControl.alpha = 1.0f;
	
	[UIView commitAnimations];
}

- (void)enterPanelSwipeMode:(id)sender:(UIEvent*)fromEvent
{	
	// Build the "page swipe control" using the current states of all the tool panels
	[mPageSwipeControl reset];
	for(unsigned int i = 0; i < [mToolPanels count]; ++i)
	{	
		SongToolPanelBase *stp = [mToolPanels objectAtIndex:i];
		[mPageSwipeControl addPage:stp withTitle:stp.name];
	}
	[mPageSwipeControl showPage:[mToolPanels indexOfObject:mActivePanel] animated:NO];
	
	UIGraphicsBeginImageContext(mPanelView.bounds.size);
	[mPanelView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImageView *iv = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];	
	UIGraphicsEndImageContext();
	
	iv.frame = mPanelView.frame;
	[self.view addSubview:iv];
	[iv release];
	
	mSwipeModeView.hidden = NO;
	mSwipeModeView.alpha = 0.0f;
	mPanelView.hidden = YES;
	mPanelCountControl.alpha = 1.0f;
	
	[UIView beginAnimations:@"enterSwipe" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	
	
	float xOffset = mActivePanel.frame.origin.x;
	float yOffset = mActivePanel.frame.origin.y;
	float inc = 0;
	if([SongToolsMainController isLandscapeMode])
		inc += 44;
	
	iv.frame = CGRectMake(mPageSwipeControl.pageOrigin.x - xOffset,
						  mPageSwipeControl.pageOrigin.y - yOffset + inc,
						  SWIPE_MODE_TOOL_PANEL_WIDTH + (mPanelView.frame.size.width - TOOL_PANEL_WIDTH),
						  SWIPE_MODE_TOOL_PANEL_WIDTH + (mPanelView.frame.size.height - TOOL_PANEL_WIDTH));
		
	mSwipeModeView.alpha = 1.0f;
	mPanelCountControl.alpha = 0.0f;
	[UIView commitAnimations];
}


- (void)animationDidStop: (NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	if([animationID isEqualToString:@"enterSwipe"])
	{
		[[[self.view subviews] lastObject] removeFromSuperview];
		
		mSwipeModeView.hidden = NO;
		mPanelView.hidden = YES;
		mPanelCountControl.hidden = YES;		
	}
	else if([animationID isEqualToString:@"showPanel"])
	{
		[[[self.view subviews] lastObject] removeFromSuperview];
		
		mPanelView.hidden = NO;
		mPanelCountControl.hidden = NO;
		mSwipeModeView.hidden = YES;

		mPanelView.alpha = 1.0f;
		mPanelCountControl.alpha = 1.0f;
		mSwipeModeView.alpha = 1.0f;
	}
	else if([animationID isEqualToString:@"ShowTool"])
	{
		[[[self.view subviews] lastObject] removeFromSuperview];	
		mActivePanel.hidden = NO;
	}
	else if([animationID isEqualToString:@"HideTool"])
	{
		[[[self.view subviews] lastObject] removeFromSuperview];
		//NSArray *sviews = [self.view subviews];
		//for (int i=0; i<[sviews count]; i++)
		//{
		//	[[sviews objectAtIndex:i] removeFromSuperview];
		//}
		//[mActivePanel removeFromSuperview];
		[self.view removeFromSuperview];
	}
	
}

- (void)toggleExtendedPanel:(UIView*)main:(UIView*)extended
{		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6f];
	
	[UIView setAnimationTransition:([main superview] ? 
									UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft)
						   			forView:mPanelView cache:YES];

	// Center the panel in it's parent view
	CGRect f = CGRectMake((mPanelView.frame.size.width - TOOL_PANEL_WIDTH) / 2,
						  (mPanelView.frame.size.height - TOOL_PANEL_WIDTH) / 2,
						  TOOL_PANEL_WIDTH,
						  TOOL_PANEL_WIDTH);
	
	if ([extended superview])
	{
		[extended removeFromSuperview];
		[mPanelView addSubview:main];
		main.frame = f;
	}
	else
	{
		[main removeFromSuperview];
		[mPanelView addSubview:extended];
		extended.frame = f;
	}
	
	[UIView commitAnimations];
}

#pragma mark SongToolViewControllerDelegate

- (void)showExtendedToolPanel:(UIView*)main:(UIView*)extended
{
	mActivePanel = (SongToolPanelBase*)main;
	mActiveExtendedPanel = extended;
	[self toggleExtendedPanel:mActivePanel:mActiveExtendedPanel];
}

- (void)hideExtendedToolPanel
{
	[self toggleExtendedPanel:mActivePanel:mActiveExtendedPanel];
}

- (void)viewWillDisappear:(BOOL)animated
{		
//	NSInteger page = mPageSwipeControl.currentPage;
//	[self showPanel:page];
	if([mPanelView isHidden])
	{
		mPanelView.hidden = NO;
		mSwipeModeView.hidden = YES;
	}
 
	mIsHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	mIsHidden = NO;
}

- (void)setShowProgressPanel:(BOOL)show withTitle:(NSString *)title withImage:(UIImage *)image
{
    if (show)
    {
        [mActivePanel addSubview:mProgressPanel.view];
        [mProgressPanel.label setText:title];
		mProgressPanel.icon = image;
        [mProgressPanel setProgress:0];
    }
    else
    {
        [mProgressPanel.view removeFromSuperview];
    }
    mShowProgressPanel = show;
}

- (BOOL)showProgressPanel
{
    return mShowProgressPanel;
}

- (void)setModal:(BOOL)modal
{
    [mSongToolsMainController setModal:modal];
    if (modal)
        mShowPanels.hidden = YES;
    else
        mShowPanels.hidden = NO;
}

- (BOOL)isHidden{
	return mIsHidden;
}

#pragma mark -
#pragma mark UI Event Handlers

- (void)closeNavItemPressed:(id)sender{
	[mSongToolsMainController closeNavItemPressed:sender];
}

- (void)songToolsNavItemPressed:(id)sender{
	[mSongToolsMainController songToolsNavItemPressed:sender];
}

@end
