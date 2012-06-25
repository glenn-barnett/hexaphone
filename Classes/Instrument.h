//
//  TrackInstrument.h
//  Hexatone
//
//  Created by Glenn Barnett on 1/5/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tuning.h"
#import "Scale.h"
#import "Patch.h"
#import <AudioUnit/AudioUnit.h>
#import "RecordingManager.h"
#import <AudioToolbox/AudioToolbox.h>

@class HexaphoneAppDelegate;
@class Patch;
@class Scale;

#define kOutputBus 0
#define kInputBus 1

#define kOurBufferSize 1024
#define kOurBufferCount 4


#define kFilterGain 0.1

#define kVolumeSliderAmplification 2.0f
#define kMaxTouchExpansionPixels 26


@interface Instrument : UIResponder {
	HexaphoneAppDelegate* appDelegate;

	float instrumentVolume;
	int touchExpansionPixels;
	//float volumePedalEffect;
	float volumePedalMinimum;
	float volumePedalModifier;
	 
	//GSB 20100809 lowpass2 http://musicdsp.org/showArchiveComment.php?ArchiveID=26
	float in1, in2, in3, in4, out1, out2, out3, out4;
	float target_filter_cutoff, filter_cutoff, resonance;
	//GSB 20100809 /lowpass2

	// performance - bitwise boolean arrays.  
	// first 31 bits used, one per key, starting at C-1
	//   6 keys per octave, ending at C-7
	UInt32 keysArePlaying;
	UInt32 keysAreStopping;
	UInt32 keysAreStarting;
	UInt32 interfaceKeysPlaying;
	UInt32 recordedKeysPlaying;
	UInt32 keysToIndicate;
	

	// we need to know about the view in which the touch occurred, as to
	// be able to derive the touches x/y.  this is necessary so we can
	// "hold" keys through a slide, even though touches aren't changing.
	UIView* touchView;

	NSMutableDictionary* mapNoteIdToKey;

	//high performance array containing information about keys - x,y position, etc.
	NSMutableData* _keysData;
	
	// selected ids / current state
	NSString* scaleId;
	NSString* patchId;
	Tuning* tuning;

	// custom data structures to persist touches (for recordings and touchpoint-spreading)
	UInt8 _activeTouchPointCount;
	NSMutableData* _activeTouchPointsData;

	
	// for AudioUnits / RemoteIO
	AudioComponentInstance _audioUnit;
	AudioBufferList* _mSampleBufferList;
	UInt32 _mSampleBufferCursors[31];
	
//	BOOL externalSpeakerWasUsed;
	
	//GSB 20100815 v1.2 wave recording
	AudioFileID wavOutAudioFile;
	SInt64 wavOutCurrentPacket;
	//GSB 20100815 /v1.2 wave recording
	
}


@property (nonatomic,retain) UIView* touchView;

@property (nonatomic,retain) NSString* scaleId;
@property (nonatomic,retain) NSString* patchId;
@property (nonatomic,retain) Tuning* tuning;

@property UInt32 keysArePlaying;
@property UInt32 keysAreStopping;
@property UInt32 keysAreStarting;
@property UInt32 interfaceKeysPlaying;
@property UInt32 recordedKeysPlaying;
@property UInt32 keysToIndicate;

-(void) setKeyVolume:(float) percentage;
-(void) setTouchSize:(float) percentage;
-(void) setPedalAngle:(float) degrees;
-(void) setVolumePedalMinimum:(float) percentage;

//@property BOOL externalSpeakerWasUsed;

-(Scale*) scale;
-(Patch*) patch;

-(id) init;

-(void) initRemoteIO;
-(void) clearRIO;

-(void) loadPatchIdRIO:(NSString*) patchId scaleId:(NSString*) scaleId tuningId:(NSString*) tuningId;
-(void) reloadPatchesRIO;

-(void) playTouches:(NSSet *)touches;

-(void) playTouchPoints;

-(void) startKeys:(UInt32)keysToStart stopKeys:(UInt32) keysToStop;

-(UInt32) getKeyNumberForPoint:(CGPoint)point;

-(void) slideTouchPoints:(float) pixelsX;

-(void) loadTuning:(Tuning*) tuning;
-(void) loadPatch:(Patch*) patch;
-(void) loadScale:(Scale*) scale;

-(SInt16*) createTransposedBufferFrom:(SInt16*)sourceBuffer sourceFrameCount:(UInt32)sourceFrameCount destFrameCount:(UInt32)destFrameCount;

-(void) setFilterRez:(float)percent;

-(void) startRecordWavOut;
-(void) stopRecordWavOut;

@end
