//
//  PageSwipeControl.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "PageSwipeControl.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_PAGE_WIDTH	220
#define DEFAULT_PAGE_HEIGHT	220

@implementation PageSwipeDragInterceptor

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	mTapResponder.didMove = false;
	//mTapResponder.phaseLabel.text = @"Touch Phase: begin";
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//	mTapResponder.phaseLabel.text = @"Touch Phase: moving";
	
	UITouch *touch = [touches anyObject];
	CGPoint currentPos = [touch locationInView:self];
	CGPoint previousPos = [touch previousLocationInView:self];
	
	float x = currentPos.x - previousPos.x;
	CGPoint pos = mTapResponder.scrollView.contentOffset;
	pos.x -= x;
	
	mTapResponder.didMove = true;
	mTapResponder.doPageForward = currentPos.x < previousPos.x;
	[mTapResponder.scrollView setContentOffset:pos animated:FALSE];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//mTapResponder.phaseLabel.text = @"Touch Phase: ended";
	
	if(mTapResponder.didMove)
	{
		if(mTapResponder.doPageForward)
			mTapResponder.currentPage++;
		else
			mTapResponder.currentPage--;
		
		if(mTapResponder.currentPage < 0)
			mTapResponder.currentPage = 0;
		
		if(mTapResponder.currentPage > mTapResponder.pageCount - 1)
			mTapResponder.currentPage = mTapResponder.pageCount - 1;
	}
	else
	{
		CGPoint currentPos = [[touches anyObject] locationInView:self];
		float x = currentPos.x;
		float y = currentPos.y;
		if(x > 50 && x < 270 &&
		   y > 50 && y < 270)
		{
			[mTapResponder sendActionsForControlEvents:UIControlEventTouchUpInside];
		}
	}
	
	CGPoint pos = mTapResponder.scrollView.contentOffset;
	pos.x = mTapResponder.currentPage * mTapResponder.pageScrollAmount;
	[mTapResponder.scrollView setContentOffset:pos animated:TRUE];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	/*	
	 UITouch *touch = [touches anyObject];
	 CGPoint loc = [touch locationInView:mTapResponder];
	 UIView *v = [mTapResponder hitTest:loc withEvent:event];
	 [v touchesCancelled:touches withEvent:event];
	 */
}

-(void)setTapResponder:(UIView *)responder
{
	//[mTapResponder release];
	mTapResponder = (PageSwipeControl*)responder;
}

-(void)dealloc
{
	[super dealloc];
}
@end



@implementation PageSwipeControl
//@synthesize phaseLabel;
@synthesize scrollView = mScrollView;
@synthesize pageSize = mPageSize;;
@synthesize pageScrollAmount = mPageScrollAmount;
@synthesize pageCount;
@synthesize currentPage;
@synthesize didMove;
@synthesize doPageForward;
@synthesize	pageOrigin = mPageOrigin;

- (id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		mPageSize = CGSizeMake(DEFAULT_PAGE_WIDTH, DEFAULT_PAGE_HEIGHT);
		pageCount = 0;
		currentPage = 0;
		didMove = FALSE;
		doPageForward = FALSE;
		
		mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-20)];
		mScrollView.delegate = self;
		mScrollView.backgroundColor = [UIColor clearColor];
		[self addSubview:mScrollView];
		[mScrollView release];
				
		mPageControl = [[UIPageControl alloc] init];
		mPageControl.backgroundColor = [UIColor clearColor];
		mPageControl.center = CGPointMake(frame.size.width / 2, 
										  (frame.size.height - mScrollView.frame.size.height) / 2 + mScrollView.frame.size.height);
		//[mPageSwipeIndicator addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:mPageControl];
		[mPageControl release];
		
		/*
		phaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		phaseLabel.backgroundColor = [UIColor blueColor];
		phaseLabel.text = @"Touch Phase: ";
		phaseLabel.hidden = YES;
	 	[self addSubview:phaseLabel];
		[phaseLabel release];
		*/
 
		mDragInterceptor = [[PageSwipeDragInterceptor alloc] initWithFrame:self.bounds];
		[mDragInterceptor setTapResponder:self];
		
		// Add the view where it will block our touches.
		[self insertSubview:mDragInterceptor aboveSubview:mScrollView];
		[mDragInterceptor release];
	}
	return self;
}

- (void)addPage:(UIView*)page withTitle:(NSString*)title
{
	// Render the view into an image and add to the scroll view
	UIGraphicsBeginImageContext(page.bounds.size);
	[page.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIImageView *iv = [[UIImageView alloc] initWithImage:image];
	
	int width = self.frame.size.width;
	int height = self.frame.size.height;
	int pageWidth = mPageSize.width;
	int pageHeight = mPageSize.height;
	int pageOverlap = pageWidth / 4; // 1/4 page overlap
	int spacing = (width - 2*pageOverlap - pageWidth) / 2;
	CGSize contentSize = mScrollView.contentSize;

	float x = contentSize.width + spacing;
	if(pageCount == 0)
		x = pageOverlap + spacing;
	float y = (height - pageHeight) / 2;

	iv.frame = CGRectMake(x, y, pageWidth, pageHeight);
	
	[mScrollView addSubview:iv];
	[iv release];
	
	mPageScrollAmount = pageWidth + spacing;
	
	// Add the panel title
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y-25, pageWidth, 25)];
	label.text = title;
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	[mScrollView addSubview:label];
	[label release];
	
	mPageControl.numberOfPages = ++pageCount;
	mScrollView.contentSize = CGSizeMake(x+pageWidth, pageHeight);
	mScrollView.contentOffset = CGPointMake(currentPage * (pageWidth+spacing), 0);
	
	if(pageCount == 1)
		mPageOrigin = CGPointMake(x, y);
}

- (void)showPage:(NSInteger)page animated:(BOOL)animate
{
	[self setCurrentPage:page];
	[mScrollView setContentOffset:CGPointMake(page * mPageScrollAmount, 0) animated:animate];
}

- (void)reset
{
	NSArray *views = mScrollView.subviews;
	for(unsigned int i = 0; i < [views count]; ++i)
		[[views objectAtIndex:i] removeFromSuperview];
	mScrollView.contentSize = CGSizeMake(0,0);	
	pageCount = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[mPageControl setCurrentPage:currentPage];
}

-(void)dealloc
{
	[super dealloc];
}

@end