//
//  RecordingManager.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RecordingManager.h"
#import "Recording.h"
#import "RecordedEvent.h"
#import "LoopPlayer.h"
#import "JSON.h"
#import "Instrument.h"
#import "RecordingPlayer.h"
#import "HexaphoneAppDelegate.h"
#import "RecViewController.h" // bad form, should go through appDelegate
#import "UpperViewController.h" // ... as if
#import "Loop.h"
#import "RecPickerViewController.h"
#import "LoopPlayer.h"

#import "LandscapeMailComposeViewController.h"

@implementation RecordingManager

@synthesize appDelegate;
@synthesize instrument;
@synthesize loopPlayer;
@synthesize recordingPlayer;
@synthesize recordingRecording;
@synthesize isRecording;
@synthesize isIgnoringAllNotesUntilLoop;

- (id)init {
    self = [super init];
	
    if (self) {

		isRenameAction = NO;
		
		// The first time we get here, ask the system
		// how to convert mach time units to nanoseconds
		mach_timebase_info_data_t timebase;
		// to be completely pedantic, check the return code of this next call.
		mach_timebase_info(&timebase);
		ticksToNanoseconds = (double)timebase.numer / timebase.denom;
		ticksToMilliseconds = ticksToNanoseconds / 1000000.0;
		//recordingStartTime = mach_absolute_time();

		isRecording = NO;
		isIgnoringAllNotesUntilLoop = NO;
		repeatPlayback = NO;
		
		areKeysPlayingAtStart = NO;
		
    }
    return self;
}

-(BOOL) haveKeysBeenPlayed {
	// can't OR against areKeysPlayingAtStart, or loopIter wont reset the loop
	return recordingRecording != nil && [recordingRecording haveKeysBeenPlayed];
}

-(BOOL) hasEarlyEvent {
	// can't OR against areKeysPlayingAtStart, or loopIter wont reset the loop
	return recordingRecording != nil && [recordingRecording hasEarlyEvent];
}


-(SInt64) getMilliseconds {
	SInt64 ms = (mach_absolute_time() - recordingStartTime) * ticksToMilliseconds;
	return ms;
}

-(void) startedLoopId:(NSString*) loopId {
	if(isRecording) {
//		NSLog(@"RecordingManager: startedLoop - logging event");
		
		//GSB:
		if(!recordingRecording.haveKeysBeenPlayed) {
			//  if NO NOTES have yet been played
			lastLoopId = loopId;
			lastLoopStartTime = [NSDate timeIntervalSinceReferenceDate];
			recordingRecording.initialLoopId = loopId;
			recordingStartTime = mach_absolute_time();

//			 loopStartUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:([loopPlayer activePlayer].duration)
//														 target:self 
//													   selector:@selector(tickLoop) 
//													   userInfo:nil 
//														repeats:YES];
			
		} else {
			//  otherwise (it's a loop change mid-recording)
			[recordingRecording addEventAtMillisecond:[self getMilliseconds] loopId:loopId];
		}
	} else {
//		NSLog(@"RecordingManager: startedLoop - storing loop id and start time");
		lastLoopId = loopId;
		lastLoopStartTime = [NSDate timeIntervalSinceReferenceDate];
	}
}

-(void) stoppedLoop {
	if(loopStartUpdateTimer != nil) {
		[loopStartUpdateTimer invalidate];
	}

	if(isRecording) {
//		NSLog(@"RecordingManager: stoppedLoop - storing STOP event");
		[recordingRecording addEventAtMillisecond:[self getMilliseconds] loopId:@"STOP"];
	} else {
//		NSLog(@"RecordingManager: stoppedLoop - clearing loop id and start time");
		lastLoopId = nil;
		lastLoopStartTime = 0.0;
	}
}

-(void) changedPatchId:(NSString*) patchId scaleId:(NSString*) scaleId tuningId:(NSString*) tuningId {
	if(isRecording) {
//		NSLog(@"RecordingManager: changedPatch - logging event");
		[recordingRecording addEventAtMillisecond:[self getMilliseconds] patchId:patchId scaleId:scaleId tuningId:tuningId];
	} else {
	}
}

#define kLoopLatencyTolerance 0.1f // seconds of "flex"

-(void) changedKeys:(UInt32) keysArePlaying {
//	NSLog(@"RM:changedKeys: %X", keysArePlaying);
	
		  
	if(isRecording && !isIgnoringAllNotesUntilLoop) {
		
		float durUntilEnd = [loopPlayer durUntilEnd];
		BOOL haveKeysBeenPlayed = [self haveKeysBeenPlayed];

		
		if(!haveKeysBeenPlayed &&
		   [loopPlayer isLooping] &&
		   ((durUntilEnd < 0.2f) || durUntilEnd > loopPlayer.activePlayer.duration - kLoopLatencyTolerance
			)) {
//			NSLog(@"|||||||            stored early event at 0");
			areKeysPlayingAtStart = YES;
			[recordingRecording addEarlyEventKeysPlayingEvent:keysArePlaying];
		} else {
//			NSLog(@"|||||||            storing normal event at %qi", [self getMilliseconds]);
			[recordingRecording addEventAtMillisecond:[self getMilliseconds] keysPlaying:keysArePlaying];
	//		NSLog(@" %qi changedKeys:%u", ms, keysArePlaying);
		}

		if(!haveKeysBeenPlayed) {
			[loopPlayer updateLabels:YES];
		}
		
		
	}
}


-(void) resetLoopState {
	isIgnoringAllNotesUntilLoop = NO;
	
	
	if(appDelegate.recordingManager.recordingRecording.isSoloStart) {
//		NSLog(@"RP:resetLoopState: cancelling solo start");
		recordingRecording.isSoloStart = NO;
		recordingRecording.loopPlaybackDurationBeforeStart = 0.0f;
	}
	
//	NSLog(@"RP:resetLoopState: resetting timers for loop iteration");
	lastLoopStartTime = [NSDate timeIntervalSinceReferenceDate];
	recordingStartTime = mach_absolute_time();
		
		
}

-(void) startRecording {
	NSLog(@"RecordingManager: -startRecording - RELEASING old recording...");
	isRecording = YES;
	recordingStartTime = mach_absolute_time();
	
	[recordingRecording release]; // TODO validate release
	recordingRecording = [[Recording alloc] init];
	recordingRecording.isSoloStart = [loopPlayer isLooping];
	recordingRecording.initialPatchId = instrument.patchId;
	recordingRecording.initialScaleId = instrument.scaleId;
	recordingRecording.initialTuningId = instrument.tuning.tuningId;
	if(lastLoopId != nil && recordingRecording.isSoloStart) {
		recordingRecording.initialLoopId = lastLoopId;
		
		NSTimeInterval loopPlaybackDuration = [NSDate timeIntervalSinceReferenceDate] - lastLoopStartTime;
		NSTimeInterval timeBetweenLoopAndRecordStart = fmod(loopPlaybackDuration,[loopPlayer activePlayer].duration);
		recordingRecording.loopPlaybackDurationBeforeStart = timeBetweenLoopAndRecordStart;
	} else {
		recordingRecording.loopPlaybackDurationBeforeStart = 0.0f;
	}
//	NSLog(@"RM:startRecording: loop durBeforeStart: %.2f", recordingRecording.loopPlaybackDurationBeforeStart);
	
	tickTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f)
												 target:self 
											   selector:@selector(tick) 
											   userInfo:nil 
												repeats:YES];
	

	appDelegate.recViewController.recordingChooserLabel.text = @" Latest Recording*";
	if([recordingPlayer isRecordingPlaying]) {
		NSLog(@"RM: -startRecording: player is playing - additive.");
		isIgnoringAllNotesUntilLoop = YES;
	} else {
		NSLog(@"RM: -startRecording: player is NOT playing.  fresh start?");
		isIgnoringAllNotesUntilLoop = NO;
	}
	
	[loopPlayer updateLabels:NO];
}

-(void) tick {
	appDelegate.upperViewController.iconRecRec.hidden = !appDelegate.upperViewController.iconRecRec.hidden;
	
	if([loopPlayer isLooping]
	   && ![self haveKeysBeenPlayed] 
	   && ![self hasEarlyEvent]) {
		   appDelegate.upperViewController.iconRecPending.hidden = !appDelegate.upperViewController.iconRecRec.hidden;
	} else {
		appDelegate.upperViewController.iconRecPending.hidden = YES;
	}
	   
	
}
//-(void) tickLoop {
//	NSLog(@"tickLoop [%.2f] (%d) %.2f vs %.2f", 
//		  [self getMilliseconds] / 1000.0f,
//		  recordingRecording.haveKeysBeenPlayed,
//		  [self getMilliseconds],
//		  [loopPlayer activePlayer].duration
//		  );
//	
//	if(!recordingRecording.haveKeysBeenPlayed &&
//	 [self getMilliseconds] / 1000.0f >= [loopPlayer activePlayer].duration) {
//		recordingStartTime = mach_absolute_time();
//		NSLog(@"RESETTING");
//	}
//	   
//}

-(void) toggleRecording {
	
	if(isRecording) {
//		NSLog(@"RM:toggleRecording: stopping recording");
		[self stopRecording]; 
	} else {
//		NSLog(@"RM:toggleRecording: starting recording");
		appDelegate.numRecordingsMade++;
		[self startRecording]; 
	}
}	

// http://lists.apple.com/archives/coreaudio-api/2009/Jan/msg00130.html
// http://developer.apple.com/qa/qa2004/qa1398.html
// mach_absolute_time()
// http://stackoverflow.com/questions/1615998/rudimentary-ways-to-measure-execution-time-of-a-method

-(void) stopRecording {
	if(isRecording) {
		isRecording = NO;
		if(tickTimer != nil) {
			[tickTimer invalidate];
			//[tickTimer release];
		}
		if(loopStartUpdateTimer != nil) {
			[loopStartUpdateTimer invalidate];
		}
		appDelegate.upperViewController.iconRecRec.hidden = NO;
		appDelegate.upperViewController.iconRecPending.hidden = YES;
		
		if(recordingRecording.haveKeysBeenPlayed == NO) {
//			NSLog(@"RecordingManager -stopAndSaveRecording: NO KEYS HAVE BEEN PLAYED - NOT SAVING");
			[recordingRecording release];
			recordingRecording = nil;
			return;
		}

		recordingRecording.isUnsaved = YES;
		//recordingPlayer.loadedRecording = recordingRecording; //TODONE pass it to a method, so the old can be released
		[recordingPlayer loadRecording:recordingRecording];
		
		if([loopPlayer isLooping] &&
		   [recordingPlayer.loadedRecording.initialLoopId isEqualToString:loopPlayer.activeLoop.loopId]
		   ) {
			[recordingPlayer startFromToggle];
		}
	}
	[loopPlayer updateLabels:NO];
	
}

-(void) saveLatestRecording {
	[self saveRecording:recordingRecording toFileName:@" Latest Recording.hexrec"];
}

-(NSString*) getPathForFileName:(NSString*) fileName {
	NSArray* systemDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString* documentsDirectory = [systemDirectories objectAtIndex:0];     
	NSString* filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
	return filePath;
}

-(void) saveRecording:(Recording*) recording toFileName:(NSString*) fileName {

	appDelegate.numRecordingsSaved++;

	recording.fileName = fileName;
	recording.isLatest = NO;
	
	NSString* filePath = [self getPathForFileName:fileName];
	
	
//	SBJSON* sbJson = [[SBJSON alloc] init];
//	NSDictionary* recordingDict = [recording toDictionary];
//	NSString* jsonString = [sbJson stringWithObject:recordingDict error:nil];
	
	NSString* jsonString = [self convertRecordingToJsonString:recording];
	
	//[recordingDict release];
	//[sbJson release];
	
	//NSLog(@"SAVING %@:\n---\n%@\n---\n\n", fileName, jsonString);
	
	[jsonString writeToFile:filePath atomically:NO encoding:NSASCIIStringEncoding error:nil];


	[self clearSavedRecordingFilenamesCache];
}

-(NSString*) convertRecordingToJsonString:(Recording*) recording {
	SBJSON* sbJson = [[SBJSON alloc] init];
	NSDictionary* recordingDict = [recording toDictionary];
	return [sbJson stringWithObject:recordingDict error:nil];
	
	//TODO release sbJson?
	
}

-(void) deleteRecordingWithFileName:(NSString*) fileName {
	[appDelegate.recordingPlayer stop];
	
	NSArray* systemDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString* documentsDirectory = [systemDirectories objectAtIndex:0];     
	NSString* filePath = [documentsDirectory stringByAppendingPathComponent:fileName];

//	NSLog(@"RM: deleteRecordingWithFileName: %@  **********************************************", fileName);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:filePath error:NULL];

	[self clearSavedRecordingFilenamesCache];
	[appDelegate.recPickerViewController.tableView reloadData];
	
}

-(NSArray*) getSavedRecordingFilenames {
	
	if(cachedSavedRecordingFilenames != nil)
		return cachedSavedRecordingFilenames;

//	NSLog(@"RecordingManager: getSavedRecordingFilenames: scanning filesystem for .hexrec files");

	NSArray* systemDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString* documentsDirectory = [systemDirectories objectAtIndex:0];  
	
	// get the list of all files and directories
    NSFileManager* fM = [NSFileManager defaultManager];

	NSError* error = nil;
    // deprecated: 
	//NSArray* fileList = [[fM directoryContentsAtPath:documentsDirectory] retain];
	NSArray* fileList = [[fM contentsOfDirectoryAtPath:documentsDirectory error:&error] retain];

    NSMutableArray* resultList = [[NSMutableArray alloc] init];

	NSArray* filteredFileList = [fileList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.hexrec'"]];

    for(NSString* file in filteredFileList) {
//	for(id file in [filteredFileList reverseObjectEnumerator]) {
//		NSLog(@"RM: fs scan: %@", file);
        NSString* path = [documentsDirectory stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        [fM fileExistsAtPath:path isDirectory:(&isDir)];
        if(!isDir) {
            [resultList addObject:file];
        }
    }
	
	cachedSavedRecordingFilenames = resultList;
	
	return cachedSavedRecordingFilenames;
	
}

-(void) clearSavedRecordingFilenamesCache {
	[cachedSavedRecordingFilenames release];
	cachedSavedRecordingFilenames = nil;
}


-(void) openActionSheetInView:(UIView*) view {
	// open a dialog with an OK and cancel button
	
	NSString* actionSheetTitle;
	NSString* otherButtonTitle;
	NSString* destructiveButtonTitle;
	if(recordingPlayer.loadedRecording.isLatest || recordingPlayer.loadedRecording.isUnsaved) {
		actionSheetTitle = nil;
		otherButtonTitle = @"Save Recording";
		destructiveButtonTitle = nil;
	} else {
		actionSheetTitle = recordingPlayer.loadedRecording.fileName;
		otherButtonTitle = @"Rename Recording";
		destructiveButtonTitle = @"Delete Recording";
	}
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:destructiveButtonTitle
													otherButtonTitles:otherButtonTitle, @"Email Recording", nil];
	
//	NSArray* fileNames = [self getSavedRecordingFilenames];
//	
//	for(NSString* fileName in fileNames) {
//		[actionSheet addButtonWithTitle:fileName];
//	}
//	
//	[actionSheet addButtonWithTitle:@"Cancel"];
//	actionSheet.cancelButtonIndex = [fileNames count];

	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[actionSheet showInView:view];
	[actionSheet release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[recordingPlayer stop];
	[loopPlayer stop];
	
//	NSLog(@"RM: actionSheet clickedButtonAtIndex: %d", buttonIndex);
	
	if(recordingPlayer.loadedRecording.isLatest || recordingPlayer.loadedRecording.isUnsaved) {
		if(buttonIndex == 0) { // save
//			NSLog(@"RM File Action: 1.0 (Save Latest)");
			isRenameAction = NO;
			[self showFilenameDialog];
		} else if(buttonIndex == 1) { // email
			[self composeEmail];
		} else {
//			NSLog(@"RM File Action: 1.1 (Cancel)");
		}
		return;
	} else {
		
		switch (buttonIndex) {
			case 0:
//				NSLog(@"RM File Action: 2.0 (Delete)");
				[recordingPlayer stop];
				NSString* currentFilename = recordingPlayer.loadedRecording.fileName;
				[self deleteRecordingWithFileName:currentFilename];
				[appDelegate.recPickerViewController tableView:appDelegate.recPickerViewController.tableView
									  willSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

				break;
			case 1:
//				NSLog(@"RM File Action: 2.2 (Rename)");
				isRenameAction = YES;
				[self showFilenameDialog];
				break;
			case 2:
				[self composeEmail];
				break;
			case 3:
//				NSLog(@"RM File Action: 2.3 (Cancel)");
				break;
		}
	}
}

-(void) showFilenameDialog {

	NSString* dialogTitle;
	NSString* defaultFilename;
	if(recordingPlayer.loadedRecording.isLatest) {
		dialogTitle = @"Save Latest Recording:";

		// default filename for save
		NSDateFormatter* dfYYYYMMDD = [[NSDateFormatter alloc] init];
		[dfYYYYMMDD setTimeStyle:NSDateFormatterFullStyle];
		[dfYYYYMMDD setDateFormat:@"MM-dd E"];
		
		NSDateFormatter* dfHHmmsss = [[NSDateFormatter alloc] init];
		[dfHHmmsss setTimeStyle:NSDateFormatterFullStyle];
		[dfHHmmsss setDateFormat:@"HHmmss"];
		
		defaultFilename = [NSString stringWithFormat:@"%@ %@ %@ %@", 
							  [dfYYYYMMDD stringFromDate:[NSDate date]],
							  instrument.patch.patchNameShort,
							  instrument.scale.scaleName,
							  [dfHHmmsss stringFromDate:[NSDate date]]
							  ];
		
		[dfYYYYMMDD release];

	} else {
		dialogTitle = @"Rename Recording:";
		defaultFilename = [recordingPlayer.loadedRecording.fileName substringWithRange:NSMakeRange(0, [recordingPlayer.loadedRecording.fileName length] - 7)];
	}

	
	UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:dialogTitle 
													 message:@"\n\n"
													delegate:self 
										   cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
	
	
	UIImageView *textBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dialogfield-bg" ofType:@"png"]]];
	textBackgroundImage.frame = CGRectMake(11,51,262,31); // x-5 and y-4
	[dialog addSubview:textBackgroundImage];
	
	dialogTextField = [[UITextField alloc] initWithFrame:CGRectMake(16,55,252,25)];
	dialogTextField.font = [UIFont systemFontOfSize:18];
	dialogTextField.backgroundColor = [UIColor whiteColor];
	//dialogTextField.secureTextEntry = YES;
	dialogTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
//	dialogTextField.delegate = self;
	dialogTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	dialogTextField.text = defaultFilename;
	dialogTextField.clearButtonMode = UITextFieldViewModeAlways;
	[dialogTextField becomeFirstResponder];
	[dialog addSubview:dialogTextField];
	
	float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	if(osVersion < 4.0) {
		[dialog setTransform:CGAffineTransformMakeTranslation(0,87)];
	} else {
		[dialog setTransform:CGAffineTransformMakeTranslation(0,0)];
	}

	[dialog show];
	[dialog release];
	
	
//	[dialogTextField release];
	[textBackgroundImage release];
//	[messageLabel release];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
//	NSLog(@"AlertView willDismissWithButtonIndex: %d", buttonIndex);
	
	if(buttonIndex == 1) { //OK BUTTON WAS PRESSED!
		NSString* newFilename = [NSString stringWithFormat: @"%@.hexrec", dialogTextField.text];
		BOOL fileAlreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:[self getPathForFileName:newFilename]];

		// if newFilename exists AND we're not on the "are you sure" step...
		if(fileAlreadyExists && alertView.message != nil) {
			UIAlertView *confirmationDialog = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Exists; Overwrite?", newFilename] 
															 message:nil
															delegate:self 
												   cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Overwrite",nil), nil];
			
			[confirmationDialog setTransform:CGAffineTransformMakeTranslation(0,87)];
			[confirmationDialog show];
			[confirmationDialog release];
			return;
		}
		
		
		if(recordingPlayer.loadedRecording.isLatest) {
//			NSLog(@"RM: -alertView willDismiss: saving unsaved recording to %@", newFilename);
			[self saveRecording:recordingPlayer.loadedRecording toFileName:newFilename];
			recordingPlayer.loadedRecording.isUnsaved = NO;
		} else {
			NSString* currentFilename = recordingPlayer.loadedRecording.fileName;
//			NSLog(@"RM: -alertView willDismiss: renaming %@ to %@", currentFilename, newFilename);
			
			[self saveRecording:recordingPlayer.loadedRecording toFileName:newFilename];
			[self deleteRecordingWithFileName:currentFilename];
		}
		[appDelegate.recPickerViewController.tableView reloadData];
		[appDelegate.recPickerViewController selectRecordingNamed:newFilename];

		
		dialogTextField.text = @"";
		
		appDelegate.recViewController.recordingChooserLabel.text = [recordingPlayer.loadedRecording.fileName substringWithRange:NSMakeRange(0, [recordingPlayer.loadedRecording.fileName length] - 7)];
		//[appDelegate.recViewController.recordingChooserButton setTitle:recordingPlayer.loadedRecording.fileName forState:UIControlStateNormal];

	}
	
}


-(void) composeEmail {
	
	if([MFMailComposeViewController canSendMail]) {
		
		if(mailComposeViewController != nil)
			[mailComposeViewController release];
		
		//mailComposeViewController = [[MFMailComposeViewController alloc] init];
		mailComposeViewController = [[LandscapeMailComposeViewController alloc] init];
		mailComposeViewController.mailComposeDelegate = self;
		
		
		NSString* hexrecString = [self convertRecordingToJsonString:recordingPlayer.loadedRecording];
		NSString* hexrecFilename = recordingPlayer.loadedRecording.fileName;
		if(hexrecFilename == nil || [hexrecFilename isEqualToString:@""]) {
			hexrecFilename = @"Latest Recording.hexrec";
		}

		[mailComposeViewController setSubject:[NSString stringWithFormat:@"Hexaphone Recording: %@", hexrecFilename]];

		[mailComposeViewController addAttachmentData:[hexrecString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] mimeType:@"text/plain" fileName:hexrecFilename];
		[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"To open %@, tap the attachment below.\n\nRequires iOS4 and Hexaphone v1.1 (http://hexaphone.com)", hexrecFilename] isHTML:NO];
		
		[appDelegate.emptyLandscapeViewController presentModalViewController:mailComposeViewController animated:YES];
	} else {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Cannot Send Email", @"alert_title_CannotSendEmail") message:NSLocalizedString(@"This device is not yet configured with an e-mail account.", @"alert_body_CannotSendEmail")
//													   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"button_OK") otherButtonTitles: nil];
//		[alert show];	
//		[alert release];
	}
	
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {

	[appDelegate.emptyLandscapeViewController dismissModalViewControllerAnimated:true];
	
}



@end
