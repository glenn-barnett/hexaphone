//
//  EffectsViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUISwitch.h"
@class HexaphoneAppDelegate;
@class TiltIndicatorView;

@interface SetupViewController : UIViewController<CustomUISwitchDelegate> {

	HexaphoneAppDelegate* appDelegate;
	BOOL isShown;
	
	UISlider* sliderKeyVolume;
	UISlider* sliderLoopVolume;
	UISlider* sliderTouchSize;
	UISlider* sliderVolumePedalEffect;

	UISlider* sliderFilterRez;
	TiltIndicatorView* tiltIndicatorView;
	
	CustomUISwitch* rotateViewSwitch;
	CustomUISwitch* keyLabelsSwitch;
	CustomUISwitch* keyIllumSwitch;
	
	IBOutlet UIButton* pedalBehaviorButton;
	IBOutlet UIButton* rotationBehaviorButton;
	
	IBOutlet UILabel* versionLabel;
	IBOutlet UILabel* accelDisplayLabel;
	
}
@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;

@property (nonatomic, retain) IBOutlet UIButton* pedalBehaviorButton;
@property (nonatomic, retain) IBOutlet UIButton* rotationBehaviorButton;
@property (nonatomic, retain) IBOutlet UILabel* versionLabel;
@property (nonatomic, retain) IBOutlet UILabel* accelDisplayLabel;


-(IBAction) slideInView;
-(IBAction) slideOutView;
-(void) hideView;

-(void) sliderKeyVolumeChanged: (id) slider;
-(void) sliderLoopVolumeChanged: (id) slider;
-(void) sliderTouchSizeChanged: (id) slider;
-(void) sliderVolumePedalEffectChanged: (id) slider;
-(void) sliderFilterRezChanged: (id) slider;
-(BOOL) isKeyIllumEnabled;

//CustomUISwitchDelegate:
-(void) valueChangedInView: (id) view;

@end
