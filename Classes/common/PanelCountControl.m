//
//  PanelCountControl.m
//	MAPI - SongTools
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import "PanelCountControl.h"


@implementation PanelCountControl


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.autoresizesSubviews = NO;
		
		// Initialization code
		mImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"songtools_button_panelcount.png"]];
		[self addSubview:mImage];
		[mImage release];
		
		mLabel = [[UILabel alloc] init];
		mLabel.frame = CGRectMake(0.0, 6.0, 25.0, 25.0);
		mLabel.backgroundColor = [UIColor clearColor];
		mLabel.font = [UIFont boldSystemFontOfSize:12.0];
		mLabel.textAlignment = UITextAlignmentCenter;
		mLabel.textColor = [UIColor blackColor];
		[self addSubview:mLabel];
		[mLabel release];

		self.frame = mImage.frame;	
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


- (void)setPanelCount:(NSInteger)count
{
	mLabel.text = [NSString stringWithFormat:@"%d", count];
}

@end
