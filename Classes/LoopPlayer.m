//
//  LoopPlayer.m
//  Hexatone
//
//  Created by Glenn Barnett on 4/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoopPlayer.h"
#import "Loop.h"
#import "HexaphoneAppDelegate.h"
#import "UpperViewController.h"
#import "LoopManager.h"
#import "RecordingManager.h"
#import "RecordingPlayer.h"
#import "Recording.h"
#import "UIConstants.h" // for UIColorFromRGB

@interface LoopPlayer (private)

@end

@implementation LoopPlayer (private)


- (id)init {
    self = [super init];
	
    if (self) {
		//class-specific init
		loopPlaybackStartTime = 0;
		
		loopVolume = 0.5f;
		isLooping = NO;
	}
    return self;
}

@end

@implementation LoopPlayer

@synthesize appDelegate;
@synthesize beatTickNumber;


-(void) setLoopVolume:(float) percentage {
	loopVolume = percentage;
	if(activePlayer != nil) {
		activePlayer.volume = loopVolume;
	}
	//	NSLog(@"LoopPlayer: -setLoopVolume: volume is now   %.2f", activePlayer.volume);
}

-(float) loopVolume {
	if(activePlayer != nil) {
		return activePlayer.volume;
	} else {
		return 0.0f;
	}
}
-(Loop*) activeLoop {
	return activeLoop;
}
-(AVAudioPlayer*) activePlayer {
	return activePlayer;
}
-(void) switchToLoop:(Loop*) loop {
	[self stop];
	[self loadLoop:loop];
	[self play];
}	

-(void) loadLoopId:(NSString*) loopId {
	
	Loop* loop = [appDelegate.loopManager.loopsMap objectForKey:loopId];
	if(loop != nil) {
		[self loadLoop:loop];
	} else {
//		NSLog(@"loadLoopId: can't load null loopId!!!!!");
	}
}

-(void) loadLoop:(Loop*) loop {
	[self stop];
	if(appDelegate.recordingManager.isRecording) {
		[appDelegate.recordingManager stopRecording];
	}
	[activePlayer release];
	[appDelegate.recordingManager stopRecording];
	activeLoop = loop;
	
	
	NSMutableData* data = [NSMutableData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:loop.file ofType:NULL]]];
	activePlayer = [[AVAudioPlayer alloc] initWithData:data error:NULL];
	activePlayer.volume = loopVolume;

	//[activePlayer setDelegate:self];
	[activePlayer prepareToPlay];
	[activePlayer setNumberOfLoops:-1];
//	[data release]; //GSB: crashes

	beatTickCount = activePlayer.duration / (1.0f / ([activeLoop.bpm floatValue] / 60.0f));

	[appDelegate changedLoop:loop.loopId];
}


-(void) stop {
	isLooping = NO;
	if(activePlayer != nil && [activePlayer isPlaying]) {
		if(appDelegate.recordingManager.isRecording) {
			[appDelegate.recordingManager stopRecording];
		}

		loopPlaybackStartTime = 0;

		[activePlayer stop];

		if(beatTickTimer != nil) {
			[beatTickTimer invalidate];
			beatTickTimer = nil;
			//[tickTimer release];
		}

		if(loopIterationTimer != nil) {
			[loopIterationTimer invalidate];
			loopIterationTimer = nil;
		}
		
		appDelegate.upperViewController.loopDisplayLabel.text = @"";
		appDelegate.upperViewController.iconLoopPlay.hidden = NO;
		
		[activePlayer setCurrentTime:0.0];
		[activePlayer prepareToPlay];
		[appDelegate stoppedLoopPlayback];
		appDelegate.recordingManager.isIgnoringAllNotesUntilLoop = NO;
	}
	[self updateLabels:YES];
}
-(void) play {
	isLooping = YES;
	loopPlaybackStartTime = [NSDate timeIntervalSinceReferenceDate];
	[activePlayer play];
	
	
	appDelegate.upperViewController.iconLoopPlay.hidden = YES;
	beatTickNumber = 0;
	[self beatTick];

	beatTickTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / ([activeLoop.bpm floatValue] / 60.0f))
												 target:self 
											   selector:@selector(beatTick) 
											   userInfo:nil 
												repeats:YES];
	
	loopIterationTimer = [NSTimer scheduledTimerWithTimeInterval:activePlayer.duration
													 target:self 
												   selector:@selector(loopIterated) 
												   userInfo:nil 
													repeats:YES];
	
	[appDelegate startedLoopPlayback];
}

-(NSTimeInterval) durUntilEnd {
	NSTimeInterval playbackDur = [NSDate timeIntervalSinceReferenceDate] - loopPlaybackStartTime;

	NSTimeInterval loopDur = activePlayer.duration;
	
	return loopDur - fmod(playbackDur, loopDur);
	
}

-(NSTimeInterval) durElapsed {
	NSTimeInterval playbackDur = [NSDate timeIntervalSinceReferenceDate] - loopPlaybackStartTime;
	
	NSTimeInterval loopDur = activePlayer.duration;
	
	return fmod(playbackDur, loopDur);
}

-(void) beatTick {
//	NSLog(@"LoopPlayer: beatTick [%d]", beatTickNumber);
	if(beatTickNumber < beatTickCount) { 
		beatTickNumber = beatTickNumber + 1;
		
		//INVERTED: //appDelegate.upperViewController.loopDisplayLabel.text = [NSString stringWithFormat:@"%d", (beatTickCount - beatTickNumber) + 1];
		appDelegate.upperViewController.loopDisplayLabel.text = [NSString stringWithFormat:@"%d", beatTickNumber];
		[self updateLabels:NO];
	}
}

-(void) updateLabels:(BOOL) forced {
//	NSLog(@"updateLabels: forced=%d, recording=%d, kbp=%d", forced, appDelegate.recordingManager.isRecording, [appDelegate.recordingManager haveKeysBeenPlayed]);
	if(!forced
	   && [self isLooping]
	   && ((appDelegate.recordingManager.isRecording 
	   && ![appDelegate.recordingPlayer isRecordingPlaying]
	   && ![appDelegate.recordingManager haveKeysBeenPlayed]
	   && ![appDelegate.recordingManager hasEarlyEvent]) || appDelegate.recordingManager.isIgnoringAllNotesUntilLoop)
	   ) {
		// YELLOW count down
		appDelegate.upperViewController.messageLabel.hidden = NO;
		appDelegate.upperViewController.messageLabel.text = [NSString stringWithFormat:@"Ready to Record in: %d", (beatTickCount - beatTickNumber) + 1];
		appDelegate.upperViewController.messageLabel.textColor = UIColorFromRGB(0xFFFFFF00);
		appDelegate.upperViewController.loopDisplayLabel.textColor = UIColorFromRGB(0xFFFFFF00);
	} else if(appDelegate.recordingManager.isRecording 
			  && ![appDelegate.recordingPlayer isRecordingPlaying]) {
		// RED no message
		appDelegate.upperViewController.messageLabel.hidden = YES;
		appDelegate.upperViewController.messageLabel.textColor = UIColorFromRGB(0xFFFF0000);
		appDelegate.upperViewController.loopDisplayLabel.textColor = UIColorFromRGB(0xFFFF0000);
	} else {
		//GREEN
		appDelegate.upperViewController.messageLabel.hidden = YES;
		appDelegate.upperViewController.loopDisplayLabel.textColor = UIColorFromRGB(0xFF009900);
	}

//	NSLog(@"updateLabels: EXIT");
}

-(void) loopIterated {
//	NSLog(@"LoopPlayer:loopIterated: rm.isRecording=%@, haveKeysBeenPlayed=%@", appDelegate.recordingManager.isRecording?@"Y":@"N", [appDelegate.recordingManager haveKeysBeenPlayed]?@"Y":@"N");
	[appDelegate.recordingPlayer loopIterated];
	if(appDelegate.recordingManager.isRecording
	   && ![appDelegate.recordingManager haveKeysBeenPlayed]) {
		[appDelegate.recordingManager resetLoopState];
	}
	
	if(beatTickTimer != nil && [beatTickTimer isValid]) { //20100830: crash
		[beatTickTimer invalidate];
		beatTickTimer = nil;
	}
	beatTickNumber = 0;

	if(isLooping) {
		[self beatTick];
		beatTickTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f / ([activeLoop.bpm floatValue] / 60.0f))
														 target:self 
													   selector:@selector(beatTick) 
													   userInfo:nil 
														repeats:YES];
	}

}

-(BOOL) isLooping {
	return isLooping;
}
-(void) toggleLoop {
	if([self isLooping]) {
//		NSLog(@"LP:toggleLoop: Stopping loop");
		[self stop];
		if([appDelegate.recordingPlayer isRecordingPlaying]) {
//			NSLog(@"LP:toggleLoop: Stopping recording playback");
			[appDelegate.recordingPlayer stop]; 
		}
	} else {
//		NSLog(@"LP:toggleLoop: Starting loop");
		[self play];
	}
}
-(void) dealloc {
	[activePlayer release];
	[super dealloc];
}
@end

