//
//  SimpleSettingCell.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//


#import "SimpleSettingCell.h"

@implementation SimpleSettingCell

@synthesize name = mName;
@synthesize status = mInstallLabel;
@synthesize button = mButton;
@synthesize appIcon = mAppIcon;
@synthesize supportedImage1 = mSupportedImage1;
@synthesize supportedImage2 = mSupportedImage2;
@synthesize actionImage = mActionImage;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
	self.name = nil;
	self.status = nil;
	self.button = nil;
	self.supportedImage1 = nil;
	self.supportedImage2 = nil;
	self.appIcon = nil;
	self.actionImage = nil;
    [super dealloc];
}


+ (SimpleSettingCell*)create
{
    NSArray *topObjs = nil;
    topObjs = [[NSBundle mainBundle] loadNibNamed:@"SimpleSettingCell" owner:self options:nil];
	SimpleSettingCell *cell = nil;
	for(int i=0; i<[topObjs count]; i++)
	{
		NSObject *object = [topObjs objectAtIndex:i];
		if([object isKindOfClass:[SimpleSettingCell class]])
		{
			cell = (SimpleSettingCell*)object;
			[cell retain];
			break;
		}
	}
    return cell;
}
@end
