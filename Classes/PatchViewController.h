//
//  PatchViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Instrument;
@class HexaphoneAppDelegate;

@interface PatchViewController : UIViewController {

	Instrument *instrument;
	HexaphoneAppDelegate* appDelegate;
	BOOL isShown;
	
	IBOutlet UIButton* patchButton;
	IBOutlet UIButton* scaleButton;

	IBOutlet UIButton* tuningButtonAb;
	IBOutlet UIButton* tuningButtonA;
	IBOutlet UIButton* tuningButtonBb;
	IBOutlet UIButton* tuningButtonB;
	IBOutlet UIButton* tuningButtonC;
	IBOutlet UIButton* tuningButtonDb;
	IBOutlet UIButton* tuningButtonD;
	IBOutlet UIButton* tuningButtonEb;
	IBOutlet UIButton* tuningButtonE;
	IBOutlet UIButton* tuningButtonF;
	IBOutlet UIButton* tuningButtonGb;
	IBOutlet UIButton* tuningButtonG;
	
	IBOutlet UIButton* closeButton;
	
}

@property (nonatomic, retain) Instrument* instrument;
@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;

@property (nonatomic, retain) IBOutlet UIButton* patchButton;
@property (nonatomic, retain) IBOutlet UIButton* scaleButton;

@property (nonatomic, retain) IBOutlet UIButton* tuningButtonAb;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonA;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonBb;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonB;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonC;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonDb;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonD;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonEb;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonE;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonF;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonGb;
@property (nonatomic, retain) IBOutlet UIButton* tuningButtonG;

@property (nonatomic, retain) IBOutlet UIButton* closeButton;

-(IBAction) changePatch:(id) sender;
-(IBAction) changeScale:(id) sender;

-(IBAction) tuneAb:(id) sender;
-(IBAction) tuneA:(id) sender;
-(IBAction) tuneBb:(id) sender;
-(IBAction) tuneB:(id) sender;
-(IBAction) tuneC:(id) sender;
-(IBAction) tuneDb:(id) sender;
-(IBAction) tuneD:(id) sender;
-(IBAction) tuneEb:(id) sender;
-(IBAction) tuneE:(id) sender;
-(IBAction) tuneF:(id) sender;
-(IBAction) tuneGb:(id) sender;
-(IBAction) tuneG:(id) sender;

-(void) setInitialTuningId:(NSString*) tuningId;
-(void) clearTuningSelection;

-(IBAction) slideInView;
-(IBAction) slideOutView;
-(void) hideView;
-(void) activateTuningId:(NSString*) tuningId;

@end
