//
//  RecordingManager.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <mach/mach_time.h>
#include <stdint.h>
#import <MessageUI/MessageUI.h>

#import "HexaphoneAppDelegate.h"

@class Recording;
@class Instrument;
@class LoopPlayer;
@class RecordingPlayer;

@interface RecordingManager : NSObject<UIActionSheetDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate> {
	double ticksToNanoseconds;
	double ticksToMilliseconds;
	
	HexaphoneAppDelegate* appDelegate;
	Instrument* instrument;
	LoopPlayer* loopPlayer;
	RecordingPlayer* recordingPlayer;
	
	uint64_t recordingStartTime;
	BOOL areKeysPlayingAtStart;
	
	NSTimeInterval lastLoopStartTime;
	NSString* lastLoopId;
	NSTimer* tickTimer;
	NSTimer* loopStartUpdateTimer;
	
	Recording* recordingRecording;
	BOOL isRecording;
	BOOL isIgnoringAllNotesUntilLoop;
	
	UITextField *dialogTextField;
	
	BOOL repeatPlayback;
	NSTimer* playbackTimer;
	
	NSArray* cachedSavedRecordingFilenames;
	BOOL isRenameAction;

	MFMailComposeViewController* mailComposeViewController;
}

@property(retain,nonatomic) HexaphoneAppDelegate* appDelegate;
@property(retain,nonatomic) Instrument* instrument;
@property(retain,nonatomic) LoopPlayer* loopPlayer;
@property(retain,nonatomic) RecordingPlayer* recordingPlayer;
@property(retain,nonatomic) Recording* recordingRecording;
@property BOOL isRecording;
@property BOOL isIgnoringAllNotesUntilLoop;

-(BOOL) haveKeysBeenPlayed;
-(BOOL) hasEarlyEvent;

-(void) startRecording;
-(void) startedLoopId:(NSString*) loopId;
-(void) stoppedLoop;

-(void) changedPatchId:(NSString*) patchId scaleId:(NSString*) scaleId tuningId:(NSString*) tuningId;
-(void) changedKeys:(UInt32) keysPlaying;

-(void) stopRecording;
-(void) saveLatestRecording;
-(void) saveRecording:(Recording*) recording toFileName:(NSString*) fileName;
-(void) toggleRecording;
-(NSArray*) getSavedRecordingFilenames;
-(void) clearSavedRecordingFilenamesCache;
-(void) showFilenameDialog;
-(void) openActionSheetInView:(UIView*) view; // save/rename, delete, cancel

-(void) resetLoopState;

-(NSString*) convertRecordingToJsonString:(Recording*) recording;
-(void) composeEmail;

@end
