//
//  EmptyLandscapeViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "SongToolsMainController.h"
#import "AudioCopyTool.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface EmptyLandscapeViewController : UIViewController <SongToolsDelegate, AudioCopyDelegate, AVAudioPlayerDelegate> {

	SongToolsMainController* songToolsMainController;

	// This is to play audio in the app, but may be replaced by your own custom audio playback methods
	AVAudioPlayer *					mAudioPlayer;
	BOOL							mIsPlaying;
	int tempoForExport;
}
@property (nonatomic) int tempoForExport;

-(IBAction)launchSongTools;
-(void)setupSongTools;

@end
