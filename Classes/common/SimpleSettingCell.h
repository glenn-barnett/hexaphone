//
//  SimpleSettingCell.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface SimpleSettingCell : UITableViewCell {
	UILabel 	*mName;
	UILabel 	*mInstallLabel;
	UIButton 	*mButton;
	UIImageView *mAppIcon;
	UIImageView *mSupportedImage1;
	UIImageView *mSupportedImage2;	
	UIImageView *mActionImage;	
}

@property (nonatomic, retain) IBOutlet UILabel  	*name;
@property (nonatomic, retain) IBOutlet UILabel  	*status;
@property (nonatomic, retain) IBOutlet UIButton 	*button;
@property (nonatomic, retain) IBOutlet UIImageView	*appIcon;
@property (nonatomic, retain) IBOutlet UIImageView 	*supportedImage1;
@property (nonatomic, retain) IBOutlet UIImageView 	*supportedImage2;
@property (nonatomic, retain) IBOutlet UIImageView 	*actionImage;

+ (SimpleSettingCell*)create;
//- (void)setAppName:(NSString*)name promptValue:(NSString*)prompt buttonLabel:(NSString*)label;

@end
