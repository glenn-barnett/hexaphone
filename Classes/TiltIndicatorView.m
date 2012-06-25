//
//  TiltIndicatorView.m
//  Hexatone
//
//  Created by Glenn Barnett on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TiltIndicatorView.h"
#import "HexaphoneAppDelegate.h"

@implementation TiltIndicatorView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.8;
		self.userInteractionEnabled = NO;
		
		tiltIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tilt-indicator.png"]];
		[self addSubview:tiltIndicatorImageView];
		
		appDelegate = (HexaphoneAppDelegate*) [[UIApplication sharedApplication] delegate];
		
		NSTimer* indicatorUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f
										 target:self 
									   selector:@selector(updateTimerTick) 
									   userInfo:nil 
										repeats:YES];
		
    }
    return self;
}

-(void) updateTimerTick {
	CGRect rect = tiltIndicatorImageView.frame;
//	if(rect.origin.y == 0) {
//		rect.origin.y = 85;
//	} else {
//		rect.origin.y = 0;
//	}
	
	rect.origin.y = 85.0f - appDelegate.lastAveragePitch / 1.06f; // 0-90 -> 0-85

	tiltIndicatorImageView.frame = rect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
