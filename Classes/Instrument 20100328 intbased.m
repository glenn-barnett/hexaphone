//
//  TrackInstrument.m
//  Hexatone
//
//  Created by Glenn Barnett on 1/5/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "Instrument.h"
#import "Sample.h"
#import "IDAudioUtils.h"
#import "Tuning.h"
#import "Scale.h"
#import "Patch.h"


#import "HexatoneAppDelegate.h"
#import "ScaleManager.h"
#import "PatchManager.h"
#import "GLVectorOverlayView.h"

#import <AudioToolbox/AudioToolbox.h>

#define kNumBytesPerPacket 2

@implementation Instrument;


@synthesize touchView;

@synthesize keysArePlaying;
@synthesize keysAreStarting;
@synthesize keysAreStopping;
@synthesize keysToIndicate;

@dynamic tuning;
@synthesize patchId;
@synthesize scaleId;



void interruptionListenerCallback (
								   void	*inUserData,
								   UInt32	interruptionState
) {

	
	//GSB: from speakhere
	// This callback, being outside the implementation block, needs a reference 
	//	to the AudioViewController object. You provide this reference when
	//	initializing the audio session (see the call to AudioSessionInitialize).
//	AudioViewController *controller = (AudioViewController *) inUserData;

	//NSLog (@"Instrument: interruptionListenerCallback");

//	if (interruptionState == kAudioSessionBeginInterruption) {
//		
//		NSLog (@"Interrupted. Stopping playback or recording.");
//		
////		if (controller.audioPlayer) {
////			// if currently playing, pause
////			[controller pausePlayback];
////			controller.interruptedOnPlayback = YES;
////		}
//		
//	} else if ((interruptionState == kAudioSessionEndInterruption) && controller.interruptedOnPlayback) {
//		// if the interruption was removed, and the app had been playing, resume playback
//		[controller resumePlayback];
//		controller.interruptedOnPlayback = NO;
//	}
}


// Audio session callback function for responding to audio route changes. This 
//	callback behaves as follows when a headset gets plugged in or unplugged:
//
//	If playing back:	pauses playback and displays an alert that allows the user
//						to resume playback
//
//	If recording:		stops recording and displays an alert that notifies the
//						user that recording has stopped.

void audioRouteChangeListenerCallback (
									   void                      *inUserData,
									   AudioSessionPropertyID    inPropertyID,
									   UInt32                    inPropertyValueSize,
									   const void                *inPropertyValue
) {

	NSLog (@"Instrument: audioRouteChangeListenerCallback");

	// ensure that this callback was invoked for the correct property change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
	
	// This callback, being outside the implementation block, needs a reference 
	//	to the AudioViewController object. You provide this reference when
	//	registering this callback (see the call to AudioSessionAddPropertyListener).
//	AudioViewController *controller = (AudioViewController *) inUserData;
	
	// A change in audio session category counts as an "audio route change." Because
	//	this sample sets the audio session category only when beginning playback 
	//	or recording, it should not pause or stop for that. To avoid inappropriate
	//	pausing or stopping, this callback queries the "reason" for the route change 
	//	and branches accordingly.
	CFDictionaryRef	routeChangeDictionary	= inPropertyValue;
	
	CFNumberRef		routeChangeReasonRef	=
	CFDictionaryGetValue (
						  routeChangeDictionary,
						  CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
						  );
	
	SInt32			routeChangeReason;
	
	CFNumberGetValue (
					  routeChangeReasonRef,
					  kCFNumberSInt32Type,
					  &routeChangeReason
					  );
	
	if (routeChangeReason != kAudioSessionRouteChangeReason_CategoryChange) {
		
			CFStringRef newAudioRoute;
			UInt32 propertySize = sizeof (CFStringRef);
			
			AudioSessionGetProperty (
									 kAudioSessionProperty_AudioRoute,
									 &propertySize,
									 &newAudioRoute
									 );
			
			CFComparisonResult newDeviceIsSpeaker =	CFStringCompare (
																	 newAudioRoute,
																	 (CFStringRef) @"Speaker",
																	 0
																	 );
			
			if (newDeviceIsSpeaker == kCFCompareEqualTo) {
				
				NSLog (@"New audio route is %@.", newAudioRoute);
				
//				UIAlertView *routeChangeAlertView;
//				routeChangeAlertView = [[UIAlertView alloc]	initWithTitle:		@"Playback Paused"
//																  message:			@"Audio output was changed"
//																 delegate:			self
//														cancelButtonTitle:	@"Stop"
//														otherButtonTitles:	@"Play", nil];
//				[routeChangeAlertView show];
				// release takes place in alertView:clickedButtonAtIndex: method
				
			} else {
				
				NSLog (@"New audio route is %@.", newAudioRoute);
			} // end if (newDeviceIsSpeaker == kCFCompareEqualTo)
			
		
	} else {
		
		NSLog (@"Audio category change.");
	}
}


-(id) init {
	NSLog(@"Instrument: -init");

	[super init];
	
	appDelegate = (HexatoneAppDelegate*) [[UIApplication sharedApplication] delegate];

	keysArePlaying = 0;
	
	_keysData = [[NSMutableData alloc] init];

	
	// Audio Session: (for both OpenAL and RemoteIO/AudioUnits):
	//audio session init - so we can get notifications when user
    // returns from phone call or alarm.  taken from SpeakHere app.
	
	AudioSessionInitialize (
							NULL,
							NULL,
							interruptionListenerCallback,
							self
							);
	
	AudioSessionAddPropertyListener (
									 kAudioSessionProperty_AudioRouteChange,
									 audioRouteChangeListenerCallback,
									 self
									 );
	
	// this works - allows ipod in background - http://stackoverflow.com/questions/1090871/implementing-ipod-playback
	UInt32  sessionCategory = kAudioSessionCategory_AmbientSound;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	AudioSessionSetActive(true);
	
	
	//GSB post-MX: going back to openAL
	[self initRemoteIO];
	return self;
}



//GSB: unknown audiounit code
//OSStatus callback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
//	AudioBufferList list;
//	
//	// redundant
//	list.mNumberBuffers = 1;
//	list.mBuffers[0].mData = sampleBuffer;
//	list.mBuffers[0].mDataByteSize = 2 * inNumberFrames;
//	list.mBuffers[0].mNumberChannels = 1;
//	
//	ioData = &list;
//	
//	AudioUnitRender(instance, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
//	
//	// the sample buffer now contains samples you can work with
//	
//	return 0;
//}


//GSB SUNDAY MARCH 1ST: rewrite playbackCallback to not assume a 1:1 relationship between ioData buffer count and sample buffer list (duh)

#define kFadeSteps 256
#define kFadeStepsFloat 256.0f
#define kFadeThresholdNeg -10
#define kFadeThresholdPos 10


// audiounit playback callback
static OSStatus playbackCallback(void *inRefCon,
								 AudioUnitRenderActionFlags *ioActionFlags,
								 const AudioTimeStamp *inTimeStamp,
								 UInt32 inBusNumber,
								 UInt32 inNumberFrames,
								 AudioBufferList *ioData) {
    // Keys: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
	//	NSLog(@"   PBCB: inNumberFrames=%d", inNumberFrames);   //512
	//	NSLog(@"   PBCB: ioData->mBuffers[0].mDataByteSize=%d", ioData->mBuffers[0].mDataByteSize);   //512
	
	Instrument *instrument =(Instrument*)inRefCon;
	AudioBufferList *_mSampleBufferList = instrument->_mSampleBufferList;
	
	// initialize to 0
	memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
	
	// cast buffer to SInt16 for arithmatic
	SInt16 *deviceBuffer = (SInt16*) ioData->mBuffers[0].mData;
	
	//		NSLog(@"PBCB: playing=%x starting=%x stopping=%x", instrument->keysArePlaying, instrument->keysAreStarting, instrument->keysAreStopping);
	UInt32 framesToRead = inNumberFrames; // 512
	//		ioData->mBuffers[i].mDataByteSize = framesToRead * 2; // no need
	
	
	//		for ( int i=0; i<_mSampleBufferList->mBuffers[18].mDataByteSize / 2; i++ ) {
	//			NSLog(@"_mSampleBufferList->mBuffers[18].mData[+%3d]: %d", i, *((SInt16*)_mSampleBufferList->mBuffers[18].mData + i));
	//		}
	//		
	for(volatile UInt8 checkedBit = 0; checkedBit < 31; checkedBit++) {
		
		// only bother with keys that are active:
		if(((instrument->keysAreStarting | instrument->keysAreStopping | instrument->keysArePlaying) >> checkedBit) & 1 == 1) {
			
			SInt16 *sampleBuffer = (SInt16*) _mSampleBufferList->mBuffers[checkedBit].mData;
			
			UInt32 remainingFramesToFill = framesToRead;
			UInt32 deviceBufferCursor = 0;
			UInt32 sampleBufferSizeFrames = _mSampleBufferList->mBuffers[checkedBit].mDataByteSize/2;
			volatile UInt32 sampleBufferCursor = instrument->_mSampleBufferCursors[checkedBit];
			
			UInt32 fadeInFraction = kFadeSteps; // out of 256
			UInt32 fadeOutFraction = 0; // out of 256
			
			if((instrument->keysAreStarting >> checkedBit) & 1 == 1) {
				// sample[checkedBit] should be faded in
				fadeInFraction = 0; // set to 0, will be incremented until 256
				
				// zero out keysAreStarting[checkedBit] since we've "claimed" the fadein
				instrument->keysAreStarting = instrument->keysAreStarting & (0xFFFFFFFF ^ 1<<checkedBit);

				while(remainingFramesToFill > (sampleBufferSizeFrames - sampleBufferCursor)) {
					//						NSLog(@"A remainingFrames: %d, sampFrames: %d, lastFramePos: %d", remainingFramesToFill, sampleBufferSizeFrames, lastFramePosition);
					
					// we can put the whole (remaining) sample in
					
					for(int i=0; i<sampleBufferSizeFrames-sampleBufferCursor; i++) {
						
						SInt16 fadedValue = sampleBuffer[sampleBufferCursor+i];
						
						if(fadeInFraction < kFadeSteps) {
							fadedValue = fadedValue * ((Float32) ++fadeInFraction / kFadeStepsFloat);
						} 
						
						if((SInt64) deviceBuffer[deviceBufferCursor+i] + (SInt64) fadedValue > 32766) {
							NSLog(@" CLIP PREVENTION (value >32767)");
							deviceBuffer[deviceBufferCursor+i] = 32766;
						} else {
							deviceBuffer[deviceBufferCursor+i] += fadedValue;
						}
						
					}
					
					deviceBufferCursor += (sampleBufferSizeFrames - sampleBufferCursor);
					remainingFramesToFill -= (sampleBufferSizeFrames - sampleBufferCursor);
					sampleBufferCursor = 0;
				}
				
				if(remainingFramesToFill > 0) {
					//						NSLog(@"B remainingFrames: %d, sampFrames: %d, lastFramePos: %d", remainingFramesToFill, sampleBufferSizeFrames, lastFramePosition);
					// we have more bytes to fill, but can't fit our sample in.
					// put in as much as we can, and save the position so we can
					// resume on the next callback.
					
					for(int i=0; i<remainingFramesToFill; i++) {
						UInt32 debugBufferOffset = sampleBufferCursor+i;
						BOOL bufferOverflow;
						UInt32 debugSampleBufferSizeFrames = sampleBufferSizeFrames;
						if(debugBufferOffset >= debugSampleBufferSizeFrames) {
							bufferOverflow = YES;
						} else {
							bufferOverflow = NO;
						}
						
						
						SInt16 fadedValue = sampleBuffer[sampleBufferCursor+i];
						
						if(fadeInFraction < kFadeSteps) {
							fadedValue = fadedValue * ((Float32) ++fadeInFraction / kFadeStepsFloat);
						} 
						
						if((SInt64) deviceBuffer[deviceBufferCursor+i] + (SInt64) fadedValue > 32766) {
							NSLog(@" CLIP PREVENTION (value >32767)");
							deviceBuffer[deviceBufferCursor+i] = 32766;
						} else {
							deviceBuffer[deviceBufferCursor+i] += fadedValue;
						}
						
					}
					
					
					if(remainingFramesToFill == sampleBufferSizeFrames) {
						sampleBufferCursor = 0; // it just fit!
					} else {
						sampleBufferCursor += remainingFramesToFill;
					}
					
					instrument->_mSampleBufferCursors[checkedBit] = sampleBufferCursor;
					remainingFramesToFill = 0;
				}
				
				
			} else if((instrument->keysAreStopping >> checkedBit) & 1 == 1) {
				// sample[checkedBit] should be faded out
				fadeOutFraction = kFadeSteps; // set to 256, will be decremented until 0
				
				// zero out keysAreStopping[checkedBit] since we've "claimed" the fadein
				instrument->keysAreStopping = instrument->keysAreStopping & (0xFFFFFFFF ^ 1<<checkedBit);
				
				BOOL noteHasStopped = false;
				
				while(remainingFramesToFill > (sampleBufferSizeFrames - sampleBufferCursor) && !noteHasStopped) {
					//						NSLog(@"A remainingFrames: %d, sampFrames: %d, lastFramePos: %d", remainingFramesToFill, sampleBufferSizeFrames, lastFramePosition);
					
					// we can put the whole (remaining) sample in
					
					for(int i=0; i<sampleBufferSizeFrames-sampleBufferCursor && !noteHasStopped; i++) {
						
						SInt16 fadedValue = sampleBuffer[sampleBufferCursor+i];
						
						if(fadeOutFraction > 0) {
							fadedValue = fadedValue * pow(((Float32) --fadeOutFraction / kFadeStepsFloat), 2);
						} else {
							fadedValue = 0;
							noteHasStopped = YES;
							sampleBufferCursor = 0;
						}

//						NSLog(@"fade(%d): %.3f :%d to %d", fadeOutFraction, pow(((Float32) --fadeOutFraction / kFadeStepsFloat), 2), sampleBuffer[sampleBufferCursor+i], fadedValue);

						if(kFadeThresholdNeg < fadedValue && fadedValue < kFadeThresholdPos) {
							// close enough
							fadedValue = 0;
							noteHasStopped = YES;
							sampleBufferCursor = 0;
						}
						
						if((SInt64) deviceBuffer[deviceBufferCursor+i] + (SInt64) fadedValue > 32766) {
							NSLog(@" CLIP PREVENTION (value >32767)");
							deviceBuffer[deviceBufferCursor+i] = 32766;
						} else {
							deviceBuffer[deviceBufferCursor+i] += fadedValue;
						}
					}
					
					deviceBufferCursor += (sampleBufferSizeFrames - sampleBufferCursor);
					remainingFramesToFill -= (sampleBufferSizeFrames - sampleBufferCursor);
					sampleBufferCursor = 0;
				}
				
				if(remainingFramesToFill > 0  && !noteHasStopped) {
					//						NSLog(@"B remainingFrames: %d, sampFrames: %d, lastFramePos: %d", remainingFramesToFill, sampleBufferSizeFrames, lastFramePosition);
					// we have more bytes to fill, but can't fit our sample in.
					// put in as much as we can, and save the position so we can
					// resume on the next callback.
					
					for(int i=0; i<remainingFramesToFill && !noteHasStopped; i++) {
						SInt16 fadedValue = sampleBuffer[sampleBufferCursor+i];
						
						if(fadeOutFraction > 0) {
							fadedValue = fadedValue * pow(((Float32) --fadeOutFraction / kFadeStepsFloat), 2);
						} else {
							fadedValue = 0;
							noteHasStopped = YES;
							sampleBufferCursor = 0;
						}
						
						if(kFadeThresholdNeg < fadedValue && fadedValue < kFadeThresholdPos) {
							// close enough
							fadedValue = 0;
							noteHasStopped = YES;
							sampleBufferCursor = 0;
						}
						
						if((SInt64) deviceBuffer[deviceBufferCursor+i] + (SInt64) fadedValue > 32766) {
							NSLog(@" CLIP PREVENTION (value >32767)");
							deviceBuffer[deviceBufferCursor+i] = 32766;
						} else {
							deviceBuffer[deviceBufferCursor+i] += fadedValue;
						}
						
					}
					
					
					if(remainingFramesToFill == sampleBufferSizeFrames) {
						sampleBufferCursor = 0; // it just fit!
					} else {
						sampleBufferCursor += remainingFramesToFill;
					}
					
					instrument->_mSampleBufferCursors[checkedBit] = sampleBufferCursor;
					remainingFramesToFill = 0;
				}

//				NSLog(@"--------------------------");

			} else { 
				// sample[checkedBit] should be mixed in normally
				while(remainingFramesToFill > (sampleBufferSizeFrames - sampleBufferCursor)) {
					//						NSLog(@"A remainingFrames: %d, sampFrames: %d, lastFramePos: %d", remainingFramesToFill, sampleBufferSizeFrames, lastFramePosition);
					
					// we can put the whole (remaining) sample in
					
					for(int i=0; i<sampleBufferSizeFrames-sampleBufferCursor; i++) {
						if((SInt64) deviceBuffer[deviceBufferCursor+i] + (SInt64) sampleBuffer[sampleBufferCursor+i] > 32766) {
							NSLog(@" CLIP PREVENTION (value >32767)");
							deviceBuffer[deviceBufferCursor+i] = 32766;
						} else {
							deviceBuffer[deviceBufferCursor+i] += sampleBuffer[sampleBufferCursor+i];
						}
					}
					
					deviceBufferCursor += (sampleBufferSizeFrames - sampleBufferCursor);
					remainingFramesToFill -= (sampleBufferSizeFrames - sampleBufferCursor);
					sampleBufferCursor = 0;
				}
				
				if(remainingFramesToFill > 0) {
					//						NSLog(@"B remainingFrames: %d, sampFrames: %d, lastFramePos: %d", remainingFramesToFill, sampleBufferSizeFrames, lastFramePosition);
					// we have more bytes to fill, but can't fit our sample in.
					// put in as much as we can, and save the position so we can
					// resume on the next callback.
					
					for(int i=0; i<remainingFramesToFill; i++) {
						if((SInt64) deviceBuffer[deviceBufferCursor+i] + (SInt64) sampleBuffer[sampleBufferCursor+i] > 32766) {
							NSLog(@" CLIP PREVENTION (value >32767)");
							deviceBuffer[deviceBufferCursor+i] = 32766;
						} else {
							deviceBuffer[deviceBufferCursor+i] += sampleBuffer[sampleBufferCursor+i];
						}
					}
					
					
					if(remainingFramesToFill == sampleBufferSizeFrames) {
						sampleBufferCursor = 0; // it just fit!
					} else {
						sampleBufferCursor += remainingFramesToFill;
					}
					
					instrument->_mSampleBufferCursors[checkedBit] = sampleBufferCursor;
					remainingFramesToFill = 0;
				}
			}
		}
	}
	
	return noErr;
}


-(void) initRemoteIO {
	NSLog(@"Instrument: initRemoteIO");
	
	OSStatus status;
	
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
	
    // DISABLE IO for recording
    UInt32 enableInputFlag = 0;
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioOutputUnitProperty_EnableIO, 
                                  kAudioUnitScope_Input, 
                                  kInputBus,
                                  &enableInputFlag, 
                                  sizeof(enableInputFlag));
    // Enable IO for playback
    UInt32 enableOutputFlag = 1;
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioOutputUnitProperty_EnableIO, 
                                  kAudioUnitScope_Output, 
                                  kOutputBus,
                                  &enableOutputFlag, 
                                  sizeof(enableOutputFlag));
	
    // Describe format
    AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate= 44100.00;
	audioFormat.mFormatID= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket= 1;
	audioFormat.mChannelsPerFrame= 1;
	audioFormat.mBitsPerChannel= 16;
	audioFormat.mBytesPerPacket= 2;
	audioFormat.mBytesPerFrame= 2;
	
	
	AudioUnitSetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, 
						 kAudioUnitScope_Input, kOutputBus, &audioFormat, sizeof(audioFormat));
	
    // Apply format (for output)
//GSB: disabling as per alex
//    status = AudioUnitSetProperty(_audioUnit, 
//                                  kAudioUnitProperty_StreamFormat, 
//                                  kAudioUnitScope_Output, 
//                                  kInputBus, 
//                                  &audioFormat, 
//                                  sizeof(audioFormat));
//    [self checkStatus:status];

//  //GSB: for lower latency / smaller buffer size: https://devforums.apple.com/message/16446#16446	
//	Float32 preferredBufferSize = 0.005;
//	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);

	//GSB: no need to do for input
//    status = AudioUnitSetProperty(_audioUnit, 
//	                              kAudioUnitProperty_StreamFormat, 
//                                  kAudioUnitScope_Input, 
//                                  kOutputBus, 
//                                  &audioFormat, 
//                                  sizeof(audioFormat));
//    [self checkStatus:status];

	//GSB: adding:
	AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = self;
	
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioUnitProperty_SetRenderCallback, 
                                  kAudioUnitScope_Global, 
                                  kOutputBus,
                                  &callbackStruct, 
                                  sizeof(callbackStruct));
	//GSB: no recorder config needed - but should set this for output, no?
	// from pastie: http://pastie.org/pastes/219616
	//	UInt32 shouldAllocateBuffer = 1;
	//	AudioUnitSetProperty(instance, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Global, 1, &shouldAllocateBuffer, sizeof(shouldAllocateBuffer));

	
	//    // Disable buffer allocation for the recorder
//    UInt32 shouldAllocateBuffer = 0;
//    status = AudioUnitSetProperty(_audioUnit, 
//                                  kAudioUnitProperty_ShouldAllocateBuffer,
//                                  kAudioUnitScope_Output, 
//                                  kInputBus,
//                                  &shouldAllocateBuffer, 
//                                  sizeof(shouldAllocateBuffer));
	
	//GSB: need to set the following callback (from pastie)?
//	err = AudioUnitSetProperty(instance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &callback_struct, sizeof(callback_struct));
	

	//calculate number of buffers from channels

	//malloc buffer lists
	
	
//	UInt32 nchannels = 1;
//	//http://lists.apple.com/archives/coreaudio-api/2005/Nov/msg00252.html
//	_mSampleBufferList =  (AudioBufferList *)malloc(offsetof(AudioBufferList, mBuffers) + nchannels * sizeof(AudioBuffer));	
//	_mSampleBufferList->mNumberBuffers = 1;
//
//	
//	//TODO: for each note
//	
//	AudioFileID fileID = [IDAudioUtils openAudioFile:[[NSBundle mainBundle] pathForResource:@"Organ838-C4-LEI16" ofType:@"caf"]];
//	//AudioFileID fileID = [IDAudioUtils openAudioFile:[[NSBundle mainBundle] pathForResource:@"Sick_IIe_C3dub" ofType:@"caf"]];
//	//AudioFileID fileID = [IDAudioUtils openAudioFile:[[NSBundle mainBundle] pathForResource:@"Sick_IIe_Gb1" ofType:@"caf"]];
//	UInt32 fileSize = [IDAudioUtils audioFileSize:fileID];
//
////	unsigned char * outData = malloc(fileSize);
////	// get the bytes from the file and put them into the data buffer
////	status = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);	
//
//	
//	//GSB: AudioFileReadPackets, from MT's blog
//	SInt64 position = 0;
//	UInt32 numPackets = fileSize / kNumBytesPerPacket;
//	UInt32 numBytesRead;
//	SInt16 *fileBuffer = malloc(fileSize);
//	status = AudioFileReadPackets(fileID, NO, &numBytesRead, NULL, position, &numPackets, fileBuffer);
//	[IDAudioUtils closeAudioFile:fileID];
//	UInt32 numFramesRead = numBytesRead / 2;
//
////	for ( int i=0; i<numBytesRead / 2; i++ ) {
////		NSLog(@"fileBuffer: %d", (SInt16) fileBuffer[i]);
////	}
//	
//	
//
//	UInt32 sourceFrameCount = numBytesRead / 2;
//	for ( int i=0; i<sourceFrameCount; i++ ) {
//		NSLog(@"sourceBuffer: %d", (SInt16) fileBuffer[i]);
//	}
//	
//
//	float halfStepAdj = 5.0f; //float freq_mult = pow(2,halfstep_adj/12.0f); // 2^(h/12)
//	Float32 frequencyMultiplier = pow(2,halfStepAdj/12.0f); // 2^(h/12)
//	NSLog(@"frequencyMultiplier = %f", frequencyMultiplier);
//	UInt32 destFrameCount = floor(sourceFrameCount / frequencyMultiplier); 
//
//	SInt16 *transposedBuffer = [self createTransposedBufferFrom:fileBuffer sourceFrameCount:numFramesRead destFrameCount:destFrameCount];
//	for ( int i=0; i<destFrameCount; i++ ) {
//		NSLog(@"transposedBuffer: %d", (SInt16) transposedBuffer[i]);
//	}
//
//
//	
//	
//    _mSampleBufferList->mBuffers[0].mData = transposedBuffer;
//    _mSampleBufferList->mBuffers[0].mDataByteSize = destFrameCount * 2;
//    _mSampleBufferList->mBuffers[0].mNumberChannels = 1;
//
	
	
	
//	for ( int i=0; i<_mSampleBufferList->mBuffers[0].mDataByteSize / 2; i++ ) {
//		NSLog(@"_mSampleBufferList->mBuffers[0].mData[+%3d]: %d", i, *((SInt16*)_mSampleBufferList->mBuffers[0].mData + i));
//	}
	

	[self clearRIO];
	
    // Initialise
    status = AudioUnitInitialize(_audioUnit);

//	// fire it up!
//	status = AudioOutputUnitStart(_audioUnit);
//	NSLog(@"AudioOutputUnitStart: got status %d", status);
	
//	AudioStreamBasicDescription remoteIODeviceFormat;
//	UInt32 size = sizeof(AudioStreamBasicDescription);
//	AudioUnitGetProperty(_audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &remoteIODeviceFormat, &size);
//	//GSB: this yielded
//	//  mSampleRate 44100
//	//  mFormatId 1819304813
//	//  mFormatFlags 12
//	//  mBytesPerPacket 2
//	//  mFramesPerPacket 1
//	//  mBytesPerFrame 2
//	//  mChannelsPerFrame 1
//	//  mBitsPerChannel 16
//	//  mReserved 0

	
//	NSLog(@"remoteIODeviceFormat.mSampleRate: %f", remoteIODeviceFormat.mSampleRate);
//	NSLog(@"remoteIODeviceFormat.mFormatID: %d", remoteIODeviceFormat.mFormatID);
//	NSLog(@"remoteIODeviceFormat.mFormatFlags: %x", remoteIODeviceFormat.mFormatFlags);
//	NSLog(@"remoteIODeviceFormat.mFramesPerPacket: %d", remoteIODeviceFormat.mFramesPerPacket);
//	NSLog(@"remoteIODeviceFormat.mChannelsPerFrame: %d", remoteIODeviceFormat.mChannelsPerFrame);
//	NSLog(@"remoteIODeviceFormat.mBitsPerChannel: %d", remoteIODeviceFormat.mBitsPerChannel);
//	NSLog(@"remoteIODeviceFormat.mBytesPerPacket: %d", remoteIODeviceFormat.mBytesPerPacket);
//	NSLog(@"remoteIODeviceFormat.mBytesPerFrame: %d", remoteIODeviceFormat.mBytesPerFrame);
}


#define kBytesPerFrame 2
-(SInt16*) createTransposedBufferFrom:(SInt16*)sourceBuffer sourceFrameCount:(UInt32)sourceFrameCount destFrameCount:(UInt32)destFrameCount {
	//NSLog(@"Instrument: -createTransposedBuffer...: sf:%d df:%d ", sourceFrameCount, destFrameCount);

//	// half step up:  1.05946;
//	// half step down: .94387
	Float32 frequencyMultiplier = (Float32) sourceFrameCount / (Float32) destFrameCount;
	//NSLog(@"Instrument: -createTransposedBuffer...: frequencyMultiplier = %f", frequencyMultiplier);
	
//	for ( int i=0; i<sourceFrameCount; i++ ) {
//		NSLog(@"sourceBuffer: %d", (SInt16) sourceBuffer[i]);
//	}
	
	
	SInt16 *destBuffer = malloc(destFrameCount * kBytesPerFrame);
	
	Float32 idxTarget; // the extrapolated, floating-point index for the target value
	UInt16 idxPrevNeighbor, idxNextNeighbor; // the indicies of the two "nearest neighbors" to the target value
	Float32 nextNeighborBias; // to what degree we should weight one neighbor over the other (out of 100%)
	Float32 prevNeighborBias; // 100% - nextNeighborBias;  included for readability - could just divide by next for a performance improvement
	
	// for each desired frame for the destination buffer:
	for(int idxDest=0; idxDest<destFrameCount; idxDest++) {
		
		idxTarget = idxDest * frequencyMultiplier;
		idxPrevNeighbor = floor(idxTarget);
		idxNextNeighbor = ceil(idxTarget);
		
		if(idxNextNeighbor >= sourceFrameCount) {
			// loop around - don't overflow!
			idxNextNeighbor = 0;
		}
		
		// if target index is [4.78], use [4] (prev) with a 22% weighting, and [5] (next) with a 78% weighting
		nextNeighborBias = idxTarget - idxPrevNeighbor;  
		prevNeighborBias = 1.0 - nextNeighborBias; 
		
		
		Float32 interpolatedValue = sourceBuffer[idxPrevNeighbor] * prevNeighborBias 
								  + sourceBuffer[idxNextNeighbor] * nextNeighborBias;
		destBuffer[idxDest] = round(interpolatedValue); // convert to int, store
		
	} 
	
//	for ( int i=0; i<destFrameCount; i++ ) {
//		NSLog(@"destBuffer: %d", (SInt16) destBuffer[i]);
//	}

	return destBuffer;
	
}


//-(Key*) getKey:(UInt32) keyNumber {
//	Key** keysArray = (Key**)[_keysData bytes];
//	
//	Key** keyPtr = keysArray + keyNumber;
//	
//	return *keyPtr;
//
//}		

-(void) clearRIO {
	//NSLog(@"Instrument: -clearRIO: doing nothing!");
	for(int i=0; i<31; i++) {
		_mSampleBufferCursors[i] = 0;
		if(_mSampleBufferList != nil 
			&& _mSampleBufferList->mBuffers != nil) { 
			free(_mSampleBufferList->mBuffers[i].mData);
		}
//		_mSampleBufferList->mBuffers[checkedBit].mDataByteSize = destFrameCount * 2;
//		_mSampleBufferList->mBuffers[checkedBit].mNumberChannels = 1;
	}

	if(_mSampleBufferList != nil) {
		free(_mSampleBufferList);	
	}

	OSStatus status = AudioOutputUnitStop(_audioUnit);
	//NSLog(@"AudioOutputUnitStop: got status %d", status);
}


-(void) reloadPatchesRIO {
	[self loadPatchIdRIO:self.patchId scaleId:self.scaleId tuning:self.tuning];
}

-(void) loadPatchIdRIO:(NSString*) patchIdArg scaleId:(NSString*) scaleIdArg tuning:(Tuning*) tuningArg {
	[appDelegate changedPatch:patchIdArg scale:scaleIdArg key:tuningArg.label];
	
	//NSLog(@"Instrument: -loadPatchIdRIO: %@ scale:%@ tuning:%@", patchIdArg, scaleIdArg, tuningArg.label);
	
	self.patchId = patchIdArg;
	self.scaleId = scaleIdArg;
	self.tuning = tuningArg;
	
	[self clearRIO];
	
	//malloc buffer lists
	
	UInt32 numBuffers = 31;
	//http://lists.apple.com/archives/coreaudio-api/2005/Nov/msg00252.html

	_mSampleBufferList =  (AudioBufferList *)malloc(offsetof(AudioBufferList, mBuffers) + numBuffers * sizeof(AudioBuffer));	
	_mSampleBufferList->mNumberBuffers = numBuffers;
	
	// 1. resolve patch
	
	Patch* patch = (Patch*) [appDelegate.patchManager.patchesMap objectForKey:self.patchId];
	
	// 2. resolve scale
	
	Scale* scale = (Scale*) [appDelegate.scaleManager.scalesMap objectForKey:self.scaleId];
	
	// for each key
	// load corresponding patch
	// store buffers for later release
	
	//Key** keysArray = (Key**)[_keysData bytes];
	
	for(UInt8 checkedBit = 0; checkedBit < 31; checkedBit++) {
		//Key** keyPtr = keysArray + checkedBit;
		
		NSString* noteId = (NSString*) [scale.arrNoteIds objectAtIndex:checkedBit];
		
		Sample* sample = [patch getSampleForNoteId:noteId];
		
		//Key* key = *keyPtr;
		
		if(sample == nil || sample.cafFilePath == nil) {
			NSLog(@"*** ERROR ***   Instrument: -loadPatchIdRIO: got nil sample for noteId[%@]", noteId);
			continue;
		}
		
		
		AudioFileID fileID = [IDAudioUtils openAudioFile:sample.cafFilePath];
		UInt32 fileSize = [IDAudioUtils audioFileSize:fileID];
		
		//GSB: AudioFileReadPackets, from MT's blog
		SInt64 position = 0;
		UInt32 numPackets = fileSize / kNumBytesPerPacket;
		UInt32 numBytesRead;
		SInt16 *fileBuffer = malloc(fileSize);
		OSStatus status = AudioFileReadPackets(fileID, NO, &numBytesRead, NULL, position, &numPackets, fileBuffer);
		[IDAudioUtils closeAudioFile:fileID];

		// convert bytes to frames
		UInt32 numFramesRead = numBytesRead / 2;
		UInt32 sourceFrameCount = numBytesRead / 2;

		if(status != 0) {
			NSLog(@"*** ERROR ***   Instrument: -loadPatchIdRIO: error on AudioFileReadPackets");
		}
		//		for ( int i=0; i<sourceFrameCount; i++ ) {
//			NSLog(@"sourceBuffer: %d", (SInt16) fileBuffer[i]);
//		}
		
		
//		float halfStepAdj = 5.0f; //float freq_mult = pow(2,halfstep_adj/12.0f); // 2^(h/12)
//		Float32 frequencyMultiplier = pow(2,halfStepAdj/12.0f); // 2^(h/12)
		Float32 frequencyMultiplier = [sample sampleRateMultiplierForTuning:self.tuning]; 

		//NSLog(@"loadPatchIdRIO: Key[%d] -> Note[%@] -> Sample[%@] x %f", checkedBit, noteId, sample.cafFilePath, frequencyMultiplier);
		UInt32 destFrameCount = floor(sourceFrameCount / frequencyMultiplier); 
		
		SInt16 *transposedBuffer = [self createTransposedBufferFrom:fileBuffer sourceFrameCount:numFramesRead destFrameCount:destFrameCount];
		free(fileBuffer);
		
//		if([noteId isEqualToString:@"C4"]) {
//			for ( int i=0; i<destFrameCount; i++ ) {
//				NSLog(@"transposedBuffer: %d", (SInt16) transposedBuffer[i]);
//			}
//		}
		
		
		_mSampleBufferList->mBuffers[checkedBit].mData = transposedBuffer;
		_mSampleBufferList->mBuffers[checkedBit].mDataByteSize = destFrameCount * 2;
		_mSampleBufferList->mBuffers[checkedBit].mNumberChannels = 1;

		
//		if([noteId isEqualToString:@"C4"] || [noteId isEqualToString:@"F4"]) {
//			for ( int i=0; i<_mSampleBufferList->mBuffers[checkedBit].mDataByteSize / 2; i++ ) {
//				NSLog(@"samp[%d].mData[%3d]: %d", checkedBit, i, *((SInt16*)_mSampleBufferList->mBuffers[checkedBit].mData + i));
//			}
//		}
		
	}

	//	// fire it up!
	OSStatus status = AudioOutputUnitStart(_audioUnit);
	NSLog(@"AudioOutputUnitStart: got status %d", status);
	
}





-(void) startKeys:(UInt32)keysToStart stopKeys:(UInt32) keysToStop {

	keysAreStarting |= keysToStart; // used in RIO callback to avoid pop
	keysAreStopping |= keysToStop;  // used in RIO callback to avoid pop
	
	if(keysToStop > 0) {
		for(UInt8 checkedBit = 0; checkedBit < 32; checkedBit++) {
			UInt32 result = (keysToStop >> checkedBit) & 1;
			if(result == 1) {
				keysArePlaying = keysArePlaying & (0xFFFFFFFF ^ 1<<checkedBit);
			}
		}
		[appDelegate.glVectorOverlayView viewNeedsUpdate];

	}
	
	if(keysToStart > 0) {
		for(UInt8 checkedBit = 0; checkedBit < 32; checkedBit++) {
			UInt32 result = (keysToStart >> checkedBit) & 1;
			if(result == 1) {
				keysArePlaying = keysArePlaying | 1<<checkedBit;
			}
		}
		[appDelegate.glVectorOverlayView viewNeedsUpdate];
	}
	
}

-(void) fadeOutOALSource:(NSNumber*)audioSourceObj {
	//NSLog(@"GSB: fadeOutOALSource");
	//alSourceStop([audioSourceObj intValue]);
}


//-(void) addKey:(Key*) key {
//	[_keysData appendBytes:&key length:sizeof(Key*)];
//
//}

-(void) playTouches:(NSSet *)touches {
	
	//NSLog(@"    %2.2f: Instrument: playTouches: BEGIN", [NSDate timeIntervalSinceReferenceDate] - start);

	_activeTouchPointCount = 0;
	if(_activeTouchPointsData != nil) {
		[_activeTouchPointsData release];
	}
	_activeTouchPointsData = [[NSMutableData alloc] init];

	for (UITouch *touch in touches) {
		if(touch.phase != UITouchPhaseEnded) {
			_activeTouchPointCount++;
			CGPoint locationInView = [touch locationInView:self.touchView];
			if(locationInView.y > -205.0f) {
				//NSLog(@"Instrument: playTouches: touchPoint(%.02f,%.02f) %@", locationInView.x, locationInView.y, touch.phase == UITouchPhaseBegan ? @"BEGAN" : touch.phase == UITouchPhaseMoved ? @"MOVED" : @"STATIONARY");
				[_activeTouchPointsData appendBytes:&locationInView length:sizeof(CGPoint)];
			}
		}
	}

//	if(_activeTouchPointCount > 1)
//		NSLog(@"    %2.2f: Instrument: playTouches:     2+ touches!", [NSDate timeIntervalSinceReferenceDate]);

	[self playTouchPoints];

//	NSLog(@"    %2.2f: Instrument: playTouches: END", [NSDate timeIntervalSinceReferenceDate] - start);

}

-(void) playTouchPoints {
	
	UInt32 keysShouldBePlaying = 0;

	CGPoint* begin = (CGPoint*)[_activeTouchPointsData bytes];
	CGPoint* end = begin + _activeTouchPointCount;
	
	for (CGPoint* touchPoint=begin; touchPoint!=end; ++touchPoint) {

//		keysShouldBePlaying |= 1 << [self getKeyNumberForPoint:*touchPoint];

		
		UInt32 key1 = [self getKeyNumberForPoint:CGPointMake(touchPoint->x-7,touchPoint->y-7)];
		UInt32 key2 = [self getKeyNumberForPoint:CGPointMake(touchPoint->x-7,touchPoint->y+7)];
		UInt32 key3 = [self getKeyNumberForPoint:CGPointMake(touchPoint->x+7,touchPoint->y-7)];
		UInt32 key4 = [self getKeyNumberForPoint:CGPointMake(touchPoint->x+7,touchPoint->y+7)];
		
//		NSLog(@"Instrument: -playTouchPoints: Playing %d / %d / %d / %d", key1, key2, key3, key4);
		
		if(key1 < 32) keysShouldBePlaying |= 1 << key1;
		if(key2 < 32) keysShouldBePlaying |= 1 << key2;
		if(key3 < 32) keysShouldBePlaying |= 1 << key3;
		if(key4 < 32) keysShouldBePlaying |= 1 << key4;

	}
	
	
	// should:		0 1 1
	// !should:     1 0 0

	// are:			1 1 0
	// !are:        0 0 1

	// should:		0 1 1
	// !are:        0 0 1
	// toStart:     0 0 1 (should & !are)

	
	// !should:     1 0 0
	// are:			1 1 0
	// toStop:      1 0 0 (!should & are)
	
	UInt32 keysToStart = keysShouldBePlaying & ~keysArePlaying;
	UInt32 keysToStop = ~keysShouldBePlaying & keysArePlaying;
	
	[self startKeys:keysToStart stopKeys:keysToStop];
	
}



//-(Key**) getKeyByBitValue:(UInt32)keyBitValue {
//	Key** keysArray = (Key**)[_keysData bytes];
//
//	for(UInt8 checkedBit = 0; checkedBit < 32; checkedBit++) {
//		if((keyBitValue >> checkedBit) & 1 == 1) {
//			return (Key**) keysArray + checkedBit;
//		}
//	}
//	
//	return nil;
//	
//}

//-(Key**) getKeyByBitNumber:(UInt8)keyBitNumber {
//	Key** keysArray = (Key**)[_keysData bytes];
//	
//	return (Key**) keysArray + keyBitNumber;
//	
//}

//-(UInt32[]) getPlayingKeyIndexArray {
//	UInt32[] ret = {0};
//	return ret;
//}


-(void) slideTouchPoints:(float) pixelsX {
	
	CGPoint* begin = (CGPoint*)[_activeTouchPointsData bytes];
	CGPoint* end = begin + _activeTouchPointCount;
	for (CGPoint* touchPoint=begin; touchPoint!=end; ++touchPoint) {
		touchPoint->x = touchPoint->x + pixelsX;
	}
	[self playTouchPoints];

}

-(void) setTuning:(Tuning*) tuningArg {
	tuning = tuningArg;
}

-(Tuning*) tuning {
	return tuning;
}

-(void) incrementTuning {
	[self.tuning increment];
	[self reloadPatchesRIO]; //[self reloadPatchesOAL];
}

-(void) decrementTuning {
	[self.tuning decrement];
	[self reloadPatchesRIO]; //[self reloadPatchesOAL];
}

-(void) incrementPatch {
    NSArray* sortedPatchIds = [[appDelegate.patchManager.patchesMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
	SInt16 currentPatchIndex = [sortedPatchIds indexOfObject:self.patchId];
	SInt16 newPatchIndex = currentPatchIndex + 1;
	if(newPatchIndex >= [sortedPatchIds count]) {
		newPatchIndex = 0;
	}
	self.patchId = [sortedPatchIds objectAtIndex:newPatchIndex];
	[self reloadPatchesRIO]; //[self reloadPatchesOAL];
}
-(void) decrementPatch {
    NSArray* sortedPatchIds = [[appDelegate.patchManager.patchesMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
    SInt16 currentPatchIndex = [sortedPatchIds indexOfObject:self.patchId];
    SInt16 newPatchIndex = currentPatchIndex - 1;
    if(newPatchIndex < 0) {
        newPatchIndex = [sortedPatchIds count] - 1;
    }
    self.patchId = [sortedPatchIds objectAtIndex:newPatchIndex];
	[self reloadPatchesRIO]; //[self reloadPatchesOAL];
}
-(void) incrementScale {
    NSArray* sortedScaleIds = [[appDelegate.scaleManager.scalesMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
    SInt16 currentScaleIndex = [sortedScaleIds indexOfObject:self.scaleId];
    SInt16 newScaleIndex = currentScaleIndex + 1;
    if(newScaleIndex >= [sortedScaleIds count]) {
		newScaleIndex = 0;
    }
    self.scaleId = [sortedScaleIds objectAtIndex:newScaleIndex];
	[self reloadPatchesRIO]; //[self reloadPatchesOAL];
}
-(void) decrementScale {
    NSArray* sortedScaleIds = [[appDelegate.scaleManager.scalesMap allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  
    SInt16 currentScaleIndex = [sortedScaleIds indexOfObject:self.scaleId];
    SInt16 newScaleIndex = currentScaleIndex - 1;
    if(newScaleIndex < 0) {
        newScaleIndex = [sortedScaleIds count] - 1;
    }
    self.scaleId = [sortedScaleIds objectAtIndex:newScaleIndex];
	[self reloadPatchesRIO]; //[self reloadPatchesOAL];
}

-(Scale*) scale {
	return (Scale*) [appDelegate.scaleManager.scalesMap objectForKey:self.scaleId];
	
}
-(Patch*) patch {
	return (Patch*) [appDelegate.patchManager.patchesMap objectForKey:self.patchId];
}


-(UInt32) getKeyNumberForPoint:(CGPoint)point {
	UInt32 octaveAdjustedKeyNumber = 32; // default - no key
	
	UInt32 x = point.x;
	UInt32 y = 204 - abs(point.y);
	UInt32 octave = 0;
	UInt32 keyNum = 0;
	
	UInt32 local_x;
	UInt32 limbo_x;
	UInt32 limbo_y;

	float LIMBO_SLOPE = 1.4285;
	int Y_LIMBO_BOTTOM = 87;
	int Y_LIMBO_TOP = 115;
	
	local_x = x % 240;
	octave = floor(x / 240);
	
	if(point.y < 0) {
	} else if(Y_LIMBO_TOP <= y) {  // top row
		
		if(local_x < 40) {
			octave--; // left edge of Bb
			keyNum = 6;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		} else if(local_x < 120) {
			keyNum = 2;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		} else if(local_x < 200) {
			keyNum = 4;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		} else {
			keyNum = 6;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		} 
	} else if(y <= Y_LIMBO_BOTTOM) {  // bottom row
		
		if(local_x < 80) {
			keyNum = 1;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		} else if(local_x < 160) {
			keyNum = 3;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		} else {
			keyNum = 5;
			octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
		}
	} else if(Y_LIMBO_BOTTOM < y && y < Y_LIMBO_TOP) {
		// limbo
		limbo_y = y - Y_LIMBO_BOTTOM;
		
		if(local_x < 40) {
			limbo_x = local_x;
			
			if(limbo_x / limbo_y < LIMBO_SLOPE) {
				octave--; // left edge of Bb
				keyNum = 6;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			} else {
				keyNum = 1;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			}
			
		} else if(40 <= local_x && local_x < 80) {
			limbo_x = local_x - 40;
			limbo_y = 28 - limbo_y; // flip y to invert slope
			if(limbo_x / limbo_y < LIMBO_SLOPE) {
				keyNum = 1;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			} else {
				keyNum = 2;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			}
			
		} else if(80 <= local_x && local_x < 120) {
			limbo_x = local_x - 80;
			
			if(limbo_x / limbo_y < LIMBO_SLOPE) {
				keyNum = 2;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			} else {
				keyNum = 3;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			}
			
		} else if(120 <= local_x && local_x < 160) {
			limbo_x = local_x - 120;
			
			limbo_y = 28 - limbo_y; // flip y to invert slope
			if(limbo_x / limbo_y < LIMBO_SLOPE) {
				keyNum = 3;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			} else {
				keyNum = 4;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			}
			
		} else if(160 <= local_x && local_x < 200) {
			limbo_x = local_x - 160;
			
			if(limbo_x / limbo_y < LIMBO_SLOPE) {
				keyNum = 4;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			} else {
				keyNum = 5;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			}
			
		} else if(200 <= local_x) {
			limbo_x = local_x - 200;
			
			limbo_y = 28 - limbo_y; // flip y to invert slope
			if(limbo_x / limbo_y < LIMBO_SLOPE) {
				keyNum = 5;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			} else {
				keyNum = 6;
				octaveAdjustedKeyNumber = ((octave) * 6) + (keyNum - 1);
			}
			
		} 
	}
	
	//NSLog(@"getKeyNumberForPoint (%.02f, %.02f): %d", point.x, point.y, octaveAdjustedKeyNumber);
	
	return octaveAdjustedKeyNumber;

}

-(void) release {
	//GSB: todo add remoteio cleanup
	//GSB: ensure this has happened [instrumentXMLReader release];  
	

	
    
 	
}
	
@end
