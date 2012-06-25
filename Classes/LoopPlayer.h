//
//  LoopPlayer.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class HexaphoneAppDelegate;
@class Loop;

@interface LoopPlayer : NSObject <AVAudioPlayerDelegate> {
	HexaphoneAppDelegate* appDelegate;

	float loopVolume;
	
	NSTimeInterval loopPlaybackStartTime;
	
	Loop* activeLoop;
	NSTimer* loopIterationTimer;
	NSTimer* beatTickTimer;
	int beatTickNumber;
	int beatTickCount;
	AVAudioPlayer* activePlayer;
	BOOL isLooping;

}

@property (nonatomic, retain) HexaphoneAppDelegate* appDelegate;
@property (nonatomic) int beatTickNumber;

-(void) setLoopVolume:(float) percentage;
-(float) loopVolume;
-(void) loadLoop:(Loop*) loop;
-(void) loadLoopId:(NSString*) loopId;
-(Loop*) activeLoop;
-(AVAudioPlayer*) activePlayer;
-(void) stop;
-(void) play;
-(BOOL) isLooping;
-(void) switchToLoop:(Loop*) loop;
-(void) toggleLoop;
-(NSTimeInterval) durUntilEnd;
-(NSTimeInterval) durElapsed;
-(void) beatTick;
-(void) updateLabels:(BOOL) forced;

@end
