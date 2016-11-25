//
//  PageSwipeControl.h
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageSwipeControl;

@interface PageSwipeDragInterceptor : UIView {
	PageSwipeControl *mTapResponder;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end


@interface PageSwipeControl : UIControl <UIScrollViewDelegate> {
	PageSwipeDragInterceptor 	*mDragInterceptor;
	UIScrollView 				*mScrollView;
	//UILabel 					*phaseLabel;
	NSInteger 					mPageScrollAmount;
	BOOL 						doPageForward;
	BOOL 						didMove;
	NSInteger 					pageCount;
	NSInteger 					currentPage;
	UIPageControl 				*mPageControl;
	CGSize 						mPageSize;
	CGPoint						mPageOrigin;
}

//@property(nonatomic, retain) UILabel *phaseLabel;
@property(nonatomic, retain) UIScrollView *scrollView;
@property(nonatomic, assign) NSInteger pageCount;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign) BOOL didMove;
@property(nonatomic, assign) BOOL doPageForward;
@property(nonatomic, assign) CGSize pageSize;
@property(nonatomic, readonly) CGPoint pageOrigin;
@property(nonatomic, readonly) NSInteger pageScrollAmount;

- (void)addPage:(UIView*)page withTitle:(NSString*)title;
- (void)reset;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)showPage:(NSInteger)page animated:(BOOL)animate;

@end
