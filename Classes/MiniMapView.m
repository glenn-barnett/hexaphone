//
//  MiniMapView.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MiniMapView.h"
#import "MiniMapSelectionView.h"
#import "HexaphoneAppDelegate.h"
#import "AppStateManager.h"
#import "AppState.h"
#import "UIConstants.h"

@implementation MiniMapView

#define kRectangleWidth 192
#define kRectangleHalfWidth kRectangleWidth / 2
#define kTouchableHeight 45
#define kBaffleOffset -288

-(id) init {
	if(self = [super init]) {
		// 480 x 44
		
		UIImageView* minimapBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"minimap-bg-ringstyle.png"]];
		minimapBg.frame = CGRectMake(0, 10, 480, 44);
		[self addSubview:minimapBg];
		
		appDelegate = (HexaphoneAppDelegate*) [[UIApplication sharedApplication] delegate];
		
		self.multipleTouchEnabled = NO;
		
		rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kRectangleWidth, UI_MINIMAP_HEIGHT)];
		rectangle.backgroundColor = [UIColor yellowColor];

		selectionView = [[MiniMapSelectionView alloc] init];
		
		appDelegate = (HexaphoneAppDelegate*) [[UIApplication sharedApplication] delegate];

		[self addSubview:selectionView];
		
	}
	return self;
}


//- (id)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        // Initialization code
//    }
//    return self;
//}


//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	
//	UITouch* t = [touches anyObject]; // multitouch is disabled, so will only be one
//	CGPoint pos = [t locationInView:self];
//
//	NSLog(@"MiniMapView: touchesBegan() BEGIN: (%.2f, %.2f)", pos.x, pos.y);
	
	[self touchesMoved:touches withEvent:event];
	
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{ 
	UITouch* t = [touches anyObject]; // multitouch is disabled, so will only be one
	CGPoint pos = [t locationInView:self];
	
//	NSLog(@"MiniMapView:touchesMoved: (%.0f,%.0f)", pos.x, pos.y);
	if(pos.y > kTouchableHeight) {
		return;
	}
	
	// 191 wide
	// 95 - minimum
	// 385 - maximum
	
	if(pos.x < kRectangleHalfWidth) {

		[self positionSelection:0];

//		CGRect rectFrame = rectangle.frame;
//		rectFrame.origin.x = 0;
//		rectangle.frame = rectFrame;
//		
//		CGRect selectionFrame = selectionView.frame;
//		selectionFrame.origin.x = kBaffleOffset;
//		selectionView.frame = selectionFrame;
		
	} else if(480 - kRectangleHalfWidth < pos.x) {

		[self positionSelection:(480 - kRectangleWidth)];

//		CGRect rectFrame = rectangle.frame;
//		rectFrame.origin.x = 480 - kRectangleWidth;
//		rectangle.frame = rectFrame;
//
//		CGRect selectionFrame = selectionView.frame;
//		selectionFrame.origin.x = 480 - kRectangleWidth + kBaffleOffset;
//		selectionView.frame = selectionFrame;

	} else {
		
		[self positionSelection:((SInt16) pos.x) - kRectangleHalfWidth];
		
//		CGRect rectFrame = rectangle.frame;
//		rectFrame.origin.x = pos.x - kRectangleHalfWidth;
//		rectangle.frame = rectFrame;
//		
//		CGRect selectionFrame = selectionView.frame;
//		selectionFrame.origin.x = pos.x - kRectangleHalfWidth + kBaffleOffset;
//		selectionView.frame = selectionFrame;

	}
	
//	SInt16 offset = -760 + (rectangle.frame.origin.x * 2.5);
//	[appDelegate setKeyboardOffset:offset];
	
}

-(void) positionSelection:(SInt16) miniMapSelectionOffset {
	
	CGRect rectFrame = rectangle.frame;
	rectFrame.origin.x = miniMapSelectionOffset;
	rectangle.frame = rectFrame;
	
	CGRect selectionFrame = selectionView.frame;
	selectionFrame.origin.x = miniMapSelectionOffset + kBaffleOffset + 1;
	selectionView.frame = selectionFrame;

	SInt16 offset = -40 + (rectangle.frame.origin.x * -2.5);
	[appDelegate setKeyboardOffset:offset];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
//	NSLog(@"MiniMapView: touchesEnded() BEGIN");
	
	SInt16 snapX;
	
	float originalPositionX = rectangle.frame.origin.x;
	
	
	//TODO POSTLAUNCH: configurable snap	
	if(YES) {
		// half octave snap:
		//   7 potential positions
		//   0 - 288
		snapX = roundf(originalPositionX / 48.0f) * 48;
	} else {	
		// full octave snap:
		//   4 potential positions
		//   0 - 288
		snapX = roundf(originalPositionX / 96.0f) * 96;
	}

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1];
	
	[self positionSelection:snapX];
	
//	CGRect rectFrame = rectangle.frame;
//	rectFrame.origin.x = snapX;
//	rectangle.frame = rectFrame;
//
//	CGRect selectionFrame = selectionView.frame;
//	selectionFrame.origin.x = snapX + kBaffleOffset;
//	selectionView.frame = selectionFrame;
	
	[UIView commitAnimations];

	appDelegate.appStateManager.appState.kbOffset = [NSNumber numberWithInt:snapX];
	
}



- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
}




-(void) positionKeyboard {

	// originalPositionX:	 0 - 288
	//	 keyboardOffestX: -761 - -41 (range: 720)
	// formula: -761 + (originalPositionX * 2.5)
	
	SInt16 offset = -761 + (rectangle.frame.origin.x * 2.5);
	[appDelegate setKeyboardOffset:offset];

}

- (void)dealloc {
    [super dealloc];
}


@end
