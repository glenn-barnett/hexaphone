//
//  SongToolsMainController.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#if USE_SONGLIST_VIEW
#import "SessionManager.h"
#endif
#import "SongToolsMainController.h"
#import "SongToolViewControllerBase.h"
#import "SongToolIcon.h"

#define TOOL_WIDTH				57
#define TOOL_HEIGHT				57
#define TOOL_LABEL_HEIGHT		15
#define TOOL_VERTICAL_SPACING	21 //21 forportrait, 5 in landscape
#define TOOL_HORIZONTAL_SPACING	18

#if USE_SONGLIST_VIEW
#define USE_STATUS_BAR 
#endif

#ifdef USE_STATUS_BAR
#define STATUS_BAR_HEIGHT	20
#else
#define STATUS_BAR_HEIGHT	0
#endif

#define NAV_BAR_HEIGHT		44
#define HEADER_SIZE			(STATUS_BAR_HEIGHT + NAV_BAR_HEIGHT)	// StatusBar + Navigation Bar
#define FOOTER_SIZE			44		// Transport Bar

#define USE_EQUAL_SONGTOOL_SPACING 	1

@interface SongToolsMainController ()  // category for private method declarations
- (void)activateSongTool:(SongToolFactory*)tool animated:(BOOL)doAnimated;
- (void)deActivateSongTool:(BOOL)doAnimated;
@end


@implementation SongToolsMainController
@synthesize navbar = mNavbar;
@synthesize delegate = _delegate;
@synthesize transdelegate = _transdelegate;
@synthesize songtoolsdelegate = _songtoolsdelegate;
#if USE_SONGLIST_VIEW
@synthesize songListViewController = mSongListViewController;
#endif


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		mSongTools = [[NSMutableArray arrayWithCapacity:1] retain];
		mDoHide = NO;
		mIsClosingSongList = NO;
		mDoShowSongList = NO;
		mDoShowWifiSync = NO;
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
	[mSongTools release];
#if USE_SONGLIST_VIEW	
	if (mSongListViewController)
        [mSongListViewController release];
#endif
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
	 return NO;  // we don't want this auto rotating ever.  we'll rotate it if we want it rotated.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	// No active tool by default
	mActiveTool = nil;
		
	NSString *toolsTitle = @"Song Tools";
	NSString *closeButtonImageName = @"songtools_vert_btn_close_idle.png";
	NSString *toolsButtonImageName = @"songtools_btn_songtools_idle.png";

	if([SongToolsMainController isLandscapeMode])
	{
		toolsTitle = @"Tools";
		closeButtonImageName = @"songtools_btn_close_idle.png";
		toolsButtonImageName = @"songtools_btn_tools_idle.png";
	}	
	
	// Create the Song Tool navigation item
	mSongToolsNavItem = [[UINavigationItem alloc] initWithTitle:toolsTitle];		
	// A custom close navigation button
	UIImage *btnImage = [UIImage imageNamed:closeButtonImageName];
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(closeNavItemPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[mSongToolsNavItem setRightBarButtonItem:item animated:YES];
	[btn release];
	[item release];		

#if USE_SONGLIST_VIEW	
	// A custom "song list" navigation button		
	btnImage = [UIImage imageNamed:@"songtools_btn_songlist_idle.png"];
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(songListNavItemPressed:) forControlEvents:UIControlEventTouchUpInside];
	item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[mSongToolsNavItem setLeftBarButtonItem:item animated:YES];
	[btn release];
	[item release];
	
	// Add the song list view subview.
	mSongListViewController = [[SongListViewController alloc] initWithNibName:@"SongListViewController" bundle:nil];
	[mSongListViewController setSongListViewDelegate:self];
	int w = mSongListViewController.view.bounds.size.width;
	int h =  mSongListViewController.view.bounds.size.height;
	[mSongListViewController.view setFrame:CGRectMake(-1*w-10, 0.0, w,h)];
	[self.view addSubview:mSongListViewController.view];
	// Create the song list navigation item
	mSongListNavItem = [[UINavigationItem alloc] initWithTitle:@"Song List"];

	// A custom close navigation button
	btnImage = [UIImage imageNamed:closeButtonImageName];
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[btn addTarget:mSongListViewController action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[mSongListNavItem setRightBarButtonItem:btnItem animated:YES];
	[btn release];
	[btnItem release];
	
	// A custom "song list" navigation button		
	btnImage = [UIImage imageNamed:@"songtools_btn_edit_idle.png"];
	UIImage *done_img = [UIImage imageNamed:@"songtools_btn_done_idle.png"];
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[btn setImage:done_img forState:UIControlStateSelected];
	[btn addTarget:mSongListViewController action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[mSongListNavItem setLeftBarButtonItem:btnItem animated:YES];
	[btn release];
	[btnItem release];
#endif
	
	// Create the Selected song tool navigation item
	mActiveSongToolNavItem = [[UINavigationItem alloc] initWithTitle:@""];

	// A custom close navigation button
	btnImage = [UIImage imageNamed:closeButtonImageName];
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(closeNavItemPressed:) forControlEvents:UIControlEventTouchUpInside];
	item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[mActiveSongToolNavItem setRightBarButtonItem:item animated:YES];
	[btn release];
	[item release];	
	// A custom "done" navigation button		
	btnImage = [UIImage imageNamed:toolsButtonImageName];
	btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
	[btn setImage:btnImage forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(songToolsNavItemPressed:) forControlEvents:UIControlEventTouchUpInside];
	item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[mActiveSongToolNavItem setLeftBarButtonItem:item animated:YES];
	[btn release];
	[item release];
	
	// Setup main view display settings		
	[self.view setBackgroundColor:[UIColor clearColor]];
	[mMainView setBackgroundColor:[UIColor clearColor]];
	[mSongToolsView setBackgroundColor:[UIColor clearColor]];
	[mToolsScrollView setBackgroundColor:[UIColor clearColor]];
	[mTransportView setBackgroundColor:[UIColor clearColor]];

	mSongNameField.delegate = self;
	mSongNameField.clearButtonMode = UITextFieldViewModeNever;
	mSongNameField.font = [UIFont systemFontOfSize:19.0];
	mAlertLabel.font = [UIFont systemFontOfSize:13.0];
	mSongInfoLabel.font = [UIFont systemFontOfSize:13.0];

	// Setup the navigation bar
	if([SongToolsMainController isLandscapeMode])
	{
		mNavbar = [[SongToolsNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NAV_BAR_HEIGHT)];
		mNavbar.opacity = 0.8f;
	}
	else 
	{
		mNavbar = [[SongToolsNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NAV_BAR_HEIGHT + STATUS_BAR_HEIGHT)];
		mNavbar.opacity = 0.70f;
	}
	[self.view insertSubview:mNavbar atIndex:0];
#if USE_SONGLIST_VIEW	
	[mNavbar pushNavigationItem:mSongListNavItem animated:NO];
#endif	
	[mNavbar pushNavigationItem:mSongToolsNavItem animated:NO];
	mNavbar.barStyle = UIBarStyleBlack;
	mNavbar.translucent = YES;
	[mNavbar release];
	
	int mainheight = self.view.frame.size.height - HEADER_SIZE;	
	mMainView.frame = CGRectMake(0, HEADER_SIZE, self.view.frame.size.width, mainheight);
    mModalScreen.hidden = YES;
	
#if !USE_SONGLIST_VIEW
	// Don't show the Song info view		
	mSongInfoView.hidden = YES;
	CGRect frame = mToolsScrollView.frame;
	frame.size.height += frame.origin.y - mSongInfoView.frame.origin.y - FOOTER_SIZE;
	frame.origin.y = mSongInfoView.frame.origin.y;
	mToolsScrollView.frame = frame;
	[mSongInfoView removeFromSuperview];
#endif
}

- (void)addSongTool:(SongToolFactory*)tool
{
	[mSongTools addObject:tool];
	[self setupSongTools];
}

- (void)addSongTools:(NSArray*)tools
{
	for(int i=0; i<[tools count]; ++i)
	{
		if([[tools objectAtIndex:i] isKindOfClass:[SongToolFactory class]])
			[mSongTools addObject:[tools objectAtIndex:i]];
	}
	[self setupSongTools];
}

- (void)setupSongTools
{	
	// Remove all subview from the scroll view
	NSArray *views = mToolsScrollView.subviews;
	for(int i=0; i<[views count]; ++i)
		[[views objectAtIndex:i] removeFromSuperview];
	mToolsScrollView.contentSize = CGSizeMake(0.0f, 0.0f);
	
	if([mSongTools count] <= 0)
		return;

	int width = mToolsScrollView.bounds.size.width;
	int height = mToolsScrollView.bounds.size.height;
	
	int toolWidth = TOOL_WIDTH;
	int toolHeight = TOOL_HEIGHT + TOOL_LABEL_HEIGHT;
	int toolVertPadding = TOOL_VERTICAL_SPACING; 
	int toolHorizPadding = TOOL_HORIZONTAL_SPACING; 
	
	int maxRows = (height) / (toolHeight + toolVertPadding);
	int maxColumns = (width - toolHorizPadding) / (toolWidth + toolHorizPadding); 

	int toolsPerPage = maxRows * maxColumns;	
	int rowsPerPage = [mSongTools count] / maxColumns + ([mSongTools count] % maxColumns) > 0 ? 1 : 0;
	int pages = [mSongTools count] / toolsPerPage + 1;
	int pageHorizMargin = (width - (maxColumns * toolWidth + (maxColumns-1) * toolHorizPadding)) / 2;
#if USE_SONGLIST_VIEW	
	int pageVertMargin = (height - (maxRows * toolHeight + (maxRows-1) * toolVertPadding)) / 2;
#else
	int pageVertMargin = (height - (rowsPerPage * toolHeight + (rowsPerPage - 1) * toolVertPadding)) / 2;
#endif	
	// Center the icons on the page is there is not enought to fill up one row on the page
	if([mSongTools count] < maxColumns)
	{
		pageHorizMargin = (width - ([mSongTools count] * toolWidth + ([mSongTools count]-1) * toolHorizPadding)) / 2;
	}
	
	for(unsigned int i = 0; i < [mSongTools count]; ++i)
	{
		int page = i / toolsPerPage;
		int row = (i - (page * toolsPerPage)) / maxColumns;
		int col = (i - (page * toolsPerPage)) % maxColumns;
		
		/*
		// Calculate location of the song tool icons
		// x = page + horizontal page margin + tool column distance + spacing between columns
		// y = vertical page margin + tool row distance + spacing between rows
		*/
		
		float x = (width * page) + pageHorizMargin + (col * toolWidth) + (toolHorizPadding * col);
		float y = pageVertMargin + (toolHeight * row) + (toolVertPadding * row);
				
		SongToolFactory *st =  (SongToolFactory*)[mSongTools objectAtIndex:i];
		SongToolIcon    *sti = [[SongToolIcon alloc] initWithSongTool:st andFrame:CGRectMake(x, y, toolWidth, toolHeight)];
		[sti addTarget:self action:@selector(songToolIconPressed::) forControlEvents:UIControlEventTouchUpInside];
		[mToolsScrollView addSubview:sti];
		[sti release]; 
	}
	
	// Set the scroll view properties
	mToolsScrollView.bounds = CGRectMake(0, 0, mToolsScrollView.frame.size.width, mToolsScrollView.frame.size.height);
	mToolsScrollView.contentSize = CGSizeMake(mToolsScrollView.frame.size.width * pages, 
											  mToolsScrollView.frame.size.height);
	mToolsScrollView.pagingEnabled = YES;
	mToolsScrollView.directionalLockEnabled = YES;
	mToolsScrollView.showsVerticalScrollIndicator = NO;
	mToolsScrollView.showsHorizontalScrollIndicator = NO;
	[mToolsScrollView setDelegate:self];
	
	// Setup page control based on the number of song tools
	mToolPageControl.numberOfPages = pages;
	mToolPageControl.hidesForSinglePage = YES;	
}

-(void)reloadSongInfo
{
#if USE_SONGLIST_VIEW	
	// Make sure the thing has the right data before displaying it.
	SessionManager *session = [SessionManager sharedSessionManager];
	mSongNameField.text = [session currentSessionNameString];
	
	// Fill in the details.
	mSongInfoLabel.text = [NSString stringWithFormat:@"%@, %@, %@", 
		[session lastModifiedStringForSession:[session currentSessionNameString]],
		[session sizeStringForSession:[session currentSessionNameString]],
	    [session lengthStringForSession:[session currentSessionNameString]]];
#endif	
}

- (void)hideKeyboard
{
	[self showAlert:NO];
	[self reloadSongInfo];
	[mSongNameField resignFirstResponder];
}

- (void)setModal:(BOOL)modal
{
    if (modal)
    {
        mModalScreen.hidden = NO;
		mModalScreen.frame = self.view.bounds;
		[self.view insertSubview:mModalScreen belowSubview:mMainView];
		mTransportView.userInteractionEnabled = NO;
		mModalTransportScreen.hidden = NO;
		[self transportPause:self];
		[self setTransportPlayToggle:NO];
		mNavbar.userInteractionEnabled = NO;
	}
    else
    {
		mTransportView.userInteractionEnabled = YES;
		mModalTransportScreen.hidden = YES;
        mModalScreen.hidden = YES;
		[mModalScreen removeFromSuperview];
		mNavbar.userInteractionEnabled = YES;
    }
}

- (void)showWithAnimation
{
	if(self.songtoolsdelegate)
		[self.songtoolsdelegate songToolsWillAppear];
	
	if ([self getTransportPlayToggle])
		[self setTransportPlayToggle:YES];
	[self reloadSongInfo];
	// Make sure we are starting with a clean navbar
	while([[mNavbar items] count] > 0)
		[mNavbar popNavigationItemAnimated:NO];
	//item 1 is songlist, item 2 is songtools
#if USE_SONGLIST_VIEW
	[mNavbar pushNavigationItem:mSongListNavItem animated:NO];
#endif
	[mNavbar pushNavigationItem:mSongToolsNavItem animated:NO];
	

	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if(orientation == UIInterfaceOrientationPortrait)
	{
		UIApplication *app = [UIApplication sharedApplication];
		if ([app respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
		{
			// This will be used in iOS 3.2 and higher
			[app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		}
		else
		{
			// This will cause a deprecated warning, but it's needed to run on iOS 3.0
			[app setStatusBarHidden:NO animated:YES];
		}
		[app setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
	}
	
	self.view.hidden = NO;
	
	mNavbar.transform = CGAffineTransformIdentity;
	mMainView.transform = CGAffineTransformIdentity;
		
	mNavbar.transform = CGAffineTransformMakeTranslation (0, -mNavbar.frame.size.height);
	mMainView.transform = CGAffineTransformMakeTranslation (0, mMainView.frame.size.height+STATUS_BAR_HEIGHT);
	
	[UIView beginAnimations:@"show" context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];

	mNavbar.transform = CGAffineTransformIdentity;
	mMainView.transform = CGAffineTransformIdentity;
	[self.transdelegate grayAndDisable];
	[UIView commitAnimations];		
}

-(void) hideWithAnimation
{	
	if(self.songtoolsdelegate)
		[self.songtoolsdelegate songToolsWillDisappear];
	
	[self hideKeyboard];

	mNavbar.transform = CGAffineTransformIdentity;
	mMainView.transform = CGAffineTransformIdentity;
	
	[UIView beginAnimations:@"hide" context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	
	[self.transdelegate ungrayAndEnable];
	mNavbar.transform = CGAffineTransformMakeTranslation (0, -mNavbar.frame.size.height);
	mMainView.transform = CGAffineTransformMakeTranslation (0, mMainView.frame.size.height);
	
	[UIView commitAnimations];	
	UIApplication *app = [UIApplication sharedApplication];
	if ([app respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
	{
		// This will be used in iOS 3.2 and higher
		[app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	}
	else
	{
		// This will cause a deprecated warning, but it's needed to run on iOS 3.0
		[app setStatusBarHidden:YES animated:YES];
	}
}

- (void)songToolIconPressed:(id)sender:(UIEvent*)fromEvent
{
	if([sender isKindOfClass:[SongToolIcon class]])
	{
		// Store the tool's icon location (for animation purposes)
		SongToolIcon* sti = (SongToolIcon*)sender;
		mActiveToolLocation.x = sti.frame.origin.x + TOOL_WIDTH / 2;
		mActiveToolLocation.y = sti.frame.origin.y + TOOL_HEIGHT / 2;
		
#ifdef USE_STATUS_BAR
		mActiveToolLocation = [mMainView convertPoint:mActiveToolLocation fromView:mToolsScrollView];	
#else
		mActiveToolLocation = [self.view convertPoint:mActiveToolLocation fromView:mToolsScrollView];	
#endif				
		// Activate the songtool
		[self activateSongTool:[(SongToolIcon*)sender songTool] animated:YES];
		
		// Push the "song tool" navigation item
		[mActiveSongToolNavItem setTitle:mActiveTool.name];
		[mNavbar pushNavigationItem:mActiveSongToolNavItem animated:NO];	
	}
}

- (void)activateSongTool:(SongToolFactory*)tool animated:(BOOL)doAnimated
{
	// Store the active tool, open the tool, and prepare the tool for display
	mActiveTool = tool;
	[mActiveTool openTool:self];
		
	if(doAnimated)			
	{	
		// Add the tool to the appropriate view
		if([SongToolsMainController isLandscapeMode])
		{
			[self.view addSubview:mActiveTool.controller.view];
			mActiveTool.controller.view.frame = self.view.bounds;
		}
		else
		{
			[mMainView addSubview:mActiveTool.controller.view];
			mActiveTool.controller.view.frame = mMainView.bounds;													
		}
		
		[mActiveTool.controller show:doAnimated touchPoint:mActiveToolLocation];		
	
		// Animation from the song tool icon to the full song tool view
		[UIView beginAnimations:@"activateTool" context:nil];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	

		// Translate the respective views off the screen vertically
		mToolsScrollView.transform = CGAffineTransformMakeTranslation (0, 300);
		mSongInfoView.transform = CGAffineTransformMakeTranslation (0, -300);
		// Remove alphas
		mToolsScrollView.alpha = 0.0f;
		mSongInfoView.alpha = 0.0f;

		[UIView commitAnimations]; 				
	}
	else
	{
		mSongToolsView.hidden = YES;
		[mSongToolsView removeFromSuperview];
		mActiveTool.controller.view.hidden = NO;		
		[mMainView addSubview:mActiveTool.controller.view];	
		mActiveTool.controller.view.frame = mMainView.bounds;
	}
	[mMainView bringSubviewToFront:mTransportView];
}

- (void)deActivateSongTool:(BOOL)doAnimated
{
	if(doAnimated)
	{	
		// For landscape mode, we must add the navbar back to the main view
		if([SongToolsMainController isLandscapeMode])
			[self.view insertSubview:mNavbar atIndex:0];

		[mActiveTool.controller hide:doAnimated touchPoint:mActiveToolLocation];		
		mSongToolsView.hidden = NO;
	
		// Translate the SongInfo and ToolsScroll views off the screen vertically up/down
		mToolsScrollView.transform = CGAffineTransformMakeTranslation (0, 300);
		mSongInfoView.transform = CGAffineTransformMakeTranslation (0, -300);		
				
		[UIView beginAnimations:@"deActivateTool" context:nil];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];	

		// Remove the translation transformations from the individual views
		mToolsScrollView.transform = CGAffineTransformIdentity;
		mSongInfoView.transform = CGAffineTransformIdentity;	
				
		[UIView commitAnimations];	
	}
	else
	{
		[mActiveTool.controller viewWillDisappear:NO];
		[mActiveTool.controller.view removeFromSuperview];
		[mActiveTool closeTool];	
		mSongToolsView.hidden = NO;		
		[mMainView addSubview:mSongToolsView];
	}
	[mMainView bringSubviewToFront:mTransportView];
}


- (void)animationDidStop: (NSString *)animationID finished:(BOOL)finished context:(void *)context
{
	if([animationID isEqualToString:@"activateTool"])
	{		
		mSongToolsView.hidden = YES;
		
		// Remove the transformation
		mToolsScrollView.transform = CGAffineTransformIdentity;
		mSongInfoView.transform = CGAffineTransformIdentity;		
		
		// Restore the alphas
		mToolsScrollView.alpha = 1.0f;
		mSongInfoView.alpha = 1.0f;		
	}
	else if([animationID isEqualToString:@"deActivateTool"])
	{	
		[mActiveTool.controller.view removeFromSuperview];
		[mActiveTool closeTool];
		
		if(mDoHide)
			[self hideWithAnimation];
		else if(mDoShowSongList)
			[self showSongListView];
		else if(mDoShowWifiSync)
			[self showWifiSync];
		mDoHide = NO;
		mDoShowSongList = NO;
		mDoShowWifiSync = NO;
 	}
	else if([animationID isEqualToString:@"hide"])
	{
		if(self.songtoolsdelegate)
			[self.songtoolsdelegate songToolsDidDisappear];
		self.view.hidden = YES;
		
		if(mIsClosingSongList)
		{
			[self songListHidden:NO];
			mIsClosingSongList = NO;
		}
	}
}

- (void)changePage:(id)sender
{
	int pageWidth = mToolsScrollView.bounds.size.width;
	[mToolsScrollView setContentOffset:CGPointMake(pageWidth * mToolPageControl.currentPage, 0) animated:YES];
}

- (void)showAlert:(BOOL)show
{
	mAlertLabel.hidden = !show;
	mAlertImageView.hidden = !show;
}

- (IBAction)clearSongName:(id)sender
{
	mSongNameField.text = @"";
}

- (BOOL)isToolShowing
{
	if (mActiveTool.controller)
	{
		if (![mActiveTool.controller isHidden])
			return YES;
	}
	return NO;
}

- (NSString *)activeToolName
{
	return mActiveTool.name;
}

- (void)hideTransportWithAnimation
{
	[self transportPause:self];
	[self setTransportPlayToggle:NO];	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	mTransportView.alpha = 0.0f;
	mTransportView.userInteractionEnabled = NO;
	[UIView commitAnimations];
}

- (void)showTransportWithAnimation
{
	[self transportPause:self];
	[self setTransportPlayToggle:NO];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	mTransportView.alpha = 1.0f;
	mTransportView.userInteractionEnabled = YES;
	[UIView commitAnimations];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	mToolPageControl.currentPage = page;
	[mToolPageControl updateCurrentPageDisplay];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)theTextField
{
	mClearSongNameBtn.hidden = NO;
	theTextField.textColor = [UIColor colorWithRed:202.0f/255.0f green:201.0f/255.0f blue:188.0f/255.0f alpha:1];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField
{
	mClearSongNameBtn.hidden = YES;
	theTextField.textColor = [UIColor whiteColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField 
{	
#if USE_SONGLIST_VIEW	
	SessionManager *manager = [SessionManager sharedSessionManager];
	NSString* currentName = [manager currentSessionNameString];

	if(![manager checkForUniqueSongName:mSongNameField.text] && ![currentName compare:mSongNameField.text] == NSOrderedSame)
	{
		// Not a valid name, so display an error
		[self showAlert:YES];
	}
	else
	{
		// Zero-length name not allowed, use the original name
		if([mSongNameField.text length] == 0)
		{
			mSongNameField.text = currentName;
		
		}
		else if([currentName compare:mSongNameField.text] != NSOrderedSame)
		{
			// Valid name, so rename the session
			// First close the session
			[self.delegate closeSession];
			//rename
			[manager renameSession:currentName ToName:mSongNameField.text];
			//re-open
			[self.delegate openSessionAtPath:[manager pathStringForSession:[manager currentSessionNameString]]];
		}
		[self hideKeyboard];
	}
	[self hideKeyboard];
#endif	
	return NO;
}

#pragma mark UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	[self hideKeyboard];
	[self reloadSongInfo];
	[self showAlert:NO];
	return YES;
}

#pragma mark Navigation Actions
- (void)closeNavItemPressed:(id)sender
{
	if([mSongToolsView isHidden])
	{
		mDoHide = YES;
		[self deActivateSongTool:YES];
	}
	else
		[self hideWithAnimation];		
}

- (void)songListNavItemPressed:(id)sender
{
	// Pop the current nav item and then show the view
	[mNavbar popNavigationItemAnimated:YES];
	[self hideKeyboard];
	[self showSongListView];
}

- (void)songToolsNavItemPressed:(id)sender
{	
	[self showSongToolsView];
}

- (void)showSongToolsView
{
	if(self.songtoolsdelegate && [self.songtoolsdelegate respondsToSelector:@selector(songToolsWillShowTools)])
		[self.songtoolsdelegate songToolsWillShowTools];

	if([mSongToolsView isHidden])
	{
		[self deActivateSongTool:YES];
		[mNavbar popNavigationItemAnimated:NO];
	}
}

- (void)showSongToolsViewWithoutAnimation
{
	if([mSongToolsView isHidden])
	{
		[self deActivateSongTool:NO];
		[mNavbar popNavigationItemAnimated:NO];
	}
}

- (void)showSongListView
{
#if USE_SONGLIST_VIEW
	if([self isToolShowing])
	{
		[self showSongToolsView];
		mDoShowSongList = YES;
		return;
	}

	if (self.delegate)
		[self.delegate transportPause:self];		
	[self setTransportPlayToggle:NO];
	
	// Animate the song tools off the screen to the right	
	mSongToolsView.transform = CGAffineTransformIdentity;
	mTransportView.transform = CGAffineTransformIdentity;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	mSongToolsView.transform = CGAffineTransformMakeTranslation (mSongToolsView.frame.size.width, 0);
	mTransportView.transform = CGAffineTransformMakeTranslation (mSongToolsView.frame.size.width, 0);
	[UIView commitAnimations];
	
	// Show the song list view
	[mSongListViewController revealWithAnimation:YES];
	[mNavbar popNavigationItemAnimated:YES];
#endif
}

- (void)showWifiSync
{
#if USE_SONGLIST_VIEW
	if([self isToolShowing])
	{
		[self showSongToolsView];
		mDoShowWifiSync = YES;
		return;
	}

	// Animate the song tools off the screen to the right	
	mSongToolsView.transform = CGAffineTransformIdentity;
	mTransportView.transform = CGAffineTransformIdentity;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	mSongToolsView.transform = CGAffineTransformMakeTranslation (mSongToolsView.frame.size.width, 0);
	mTransportView.transform = CGAffineTransformMakeTranslation (mSongToolsView.frame.size.width, 0);
	[UIView commitAnimations];
	
	// Show the song list view
	[mSongListViewController revealSyncWithAnimation:YES];	
	[mNavbar popNavigationItemAnimated:YES];
	
#endif
}

#pragma mark Transport actions
- (BOOL)getTransportPlayToggle
{
	if (self.delegate)
		return ([self.delegate transportGetPlaying]);
	else
		return NO;
}

- (void)setTransportPlayToggle:(BOOL)on
{
	if (on)
		[mPlayPauseBtn setImage:[UIImage imageNamed:@"songtools_button_pause_idle.png"] forState:UIControlStateNormal];
	else
		[mPlayPauseBtn setImage:[UIImage imageNamed:@"songtools_button_play_idle.png"] forState:UIControlStateNormal];
}

- (void)transportPause:(id)sender
{
	if (self.delegate)
		[self.delegate transportPause:sender];		
}

- (void)transportPlay:(id)sender
{
	if (self.delegate)
		[self.delegate transportPlay:sender];	
}

- (void)transportSeekEnd:(id)sender
{
	if (self.delegate)
		[self.delegate transportSeekEnd:sender];	
}

- (void)transportSeekBeginning:(id)sender
{
	if (self.delegate)
		[self.delegate transportSeekBeginning:sender];	
}

- (void)transportSeekForward:(id)sender
{
	if (self.delegate)
		[self.delegate transportSeekForward:sender];	
}

- (void)transportSeekBackward:(id)sender
{
	if (self.delegate)
		[self.delegate transportSeekBackward:sender];	
}

#pragma mark - SongListViewDelegate functions

-(void) enableCloseButton
{
	UINavigationItem *item = mNavbar.topItem;
	UIButton* button = (UIButton*)item.rightBarButtonItem.customView;
	button.hidden = NO;
}

-(void) disableCloseButton
{
#if USE_SONGLIST_VIEW	
	UINavigationItem *item = mNavbar.topItem;
	UIButton* button = (UIButton*)item.rightBarButtonItem.customView;
	button.hidden = YES;
	// Disable editing
	[mSongListViewController editButtonPressed:(UIButton*)item.leftBarButtonItem.customView];
#endif	
}

-(void) showSyncView
{	
}

-(void) closeSongList
{
	[self hideWithAnimation];
	mIsClosingSongList = YES;
}

- (void)songListHidden:(BOOL)animated
{
	if(animated)
	{
		mSongToolsView.transform = CGAffineTransformIdentity;
		mTransportView.transform = CGAffineTransformIdentity;
		mSongToolsView.transform = CGAffineTransformMakeTranslation (mSongToolsView.frame.size.width, 0);
		mTransportView.transform = CGAffineTransformMakeTranslation (mSongToolsView.frame.size.width, 0);
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25f];
		[UIView setAnimationDelegate:self];
		mSongToolsView.transform = CGAffineTransformIdentity;
		mTransportView.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
	}
	else 
	{
		mSongToolsView.transform = CGAffineTransformIdentity;
		mTransportView.transform = CGAffineTransformIdentity;
	}
	
	[mNavbar pushNavigationItem:mSongToolsNavItem animated:NO];
	[self reloadSongInfo];		
}

- (void)openSessionAtPath:(NSString *)path
{
	[self.delegate openSessionAtPath:path];	
}


+ (BOOL)isLandscapeMode
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if(orientation == UIInterfaceOrientationLandscapeLeft ||
	   orientation == UIInterfaceOrientationLandscapeRight)
		return YES;
	else 
		return NO;
}


@end
