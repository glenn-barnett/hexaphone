//
//  MiniMapSelectionView.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MiniMapSelectionView.h"
#import "UIConstants.h"

@implementation MiniMapSelectionView

- (id)init {
	
	//CGRect frame = CGRectMake(5, -12, kBaffleWidth + kRectangleWidth + kBaffleWidth, UI_MINIMAP_HEIGHT);
	CGRect frame = CGRectMake(0, 0, 768, 57);
	
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		UIImageView* selector = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"minimap-selector-3dstyle.png"]];
		[self addSubview:selector];
		
//		UIView* leftBaffle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBaffleWidth, UI_MINIMAP_HEIGHT)];
//		leftBaffle.backgroundColor = [UIColor whiteColor];
//		leftBaffle.alpha = 0.7;
//		[self addSubview:leftBaffle];
//
//		UIView* rightBaffle = [[UIView alloc] initWithFrame:CGRectMake(kBaffleWidth + kRectangleWidth, 0, kBaffleWidth, UI_MINIMAP_HEIGHT)];
//		rightBaffle.backgroundColor = [UIColor whiteColor];
//		rightBaffle.alpha = 0.7;
//		[self addSubview:rightBaffle];
//		
//		UIView* leftBar = [[UIView alloc] initWithFrame:CGRectMake(kBaffleWidth, 0, 2, UI_MINIMAP_HEIGHT)];
//		leftBar.backgroundColor = [UIColor whiteColor];
//		[self addSubview:leftBar];
//		
//		UIView* rightBar = [[UIView alloc] initWithFrame:CGRectMake(kBaffleWidth + kRectangleWidth - 2, 0, 2, UI_MINIMAP_HEIGHT)];
//		rightBar.backgroundColor = [UIColor whiteColor];
//		[self addSubview:rightBar];
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
