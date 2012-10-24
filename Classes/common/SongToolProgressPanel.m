//
//  SongToolProgressPanel.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "SongToolProgressPanel.h"

#define BACKGROUND_IMAGE_VIEW	10

@implementation SongToolProgressPanel
@synthesize label = mLabel;
@synthesize backgroundView = mBackgroundView;
@synthesize progressBarImage = mProgressBarImage;
@synthesize spinner = mSpinner;

-(void)setIcon:(UIImage *)image
{
	mIcon.image = image;
	mIcon.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	
	// Adjust location of icon keeping center at same place.
	mIcon.center = CGPointMake(150, 93.0/2.0);

	// Adjust the location of the image so that it is on pixel boundary.
	CGRect f = mIcon.frame;
	mIcon.frame = CGRectMake(round(f.origin.x), round(f.origin.y), f.size.width, f.size.height);
}


-(UIImage *)icon
{
	return mIcon.image;
}

- (void)setBackgroundView:(UIImageView *)view
{
	[mBackgroundView removeFromSuperview];
	
	[view retain];
	[mBackgroundView release];
	mBackgroundView = view;
	
	[self.view insertSubview:mBackgroundView atIndex:0];
}

- (void)setProgressBarImage:(UIImage *)image
{
	[image retain];
	[mProgressBarImage release];
	mProgressBarImage = image;
	
    UIImage *stretch_bar = [mProgressBarImage stretchableImageWithLeftCapWidth:3 topCapHeight:0];
    mCustomProgressBar.image = stretch_bar;	
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.progressBarImage = [UIImage imageNamed:@"progress_bar.png"];
		self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bounce_panel.png"]] autorelease];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
    UIImage *stretch_bar = [self.progressBarImage stretchableImageWithLeftCapWidth:3 topCapHeight:0];
    mCustomProgressBar.image = stretch_bar;
    mProgress = 0;
    CGRect rect = mCustomProgressBar.bounds;
    rect.size.width = 0;
    [mCustomProgressBar setBounds:rect];
	[mSpinner stopAnimating];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)setProgress:(float)p
{
    mProgress = p;
    CGRect rect = mCustomProgressBar.frame;
    rect.size.width = floor(260 * p);
    rect.origin.x = 18;
    [mCustomProgressBar setFrame:rect];
}

- (void)useSpinner
{
	[mCustomProgressBar setHidden:YES];
	[mSpinner startAnimating];
}

- (void)useProgressBar
{
	[mCustomProgressBar setHidden:NO];
	[mSpinner stopAnimating];
}

- (float)progress
{
    return mProgress;
}

- (void)setView:(UIView *)aView {
    if (!aView) { // view is being set to nil
        // set outlets to nil, e.g.
        self.label = nil;
		mCustomProgressBar = nil;
		mIcon = nil;
		self.spinner = nil;
    }
    // Invoke super's implementation last
    [super setView:aView];
}

- (void)dealloc {
	self.label = nil;
	self.spinner = nil;
	[mProgressBarImage release];
	[mBackgroundView release];
	[mCustomProgressBar release];
	mCustomProgressBar = nil;
	[mIcon release];
	mIcon = nil;
	[super dealloc];

}


@end
