//
//  IDAudioUtils.m
//  Hexatone
//
//  Created by Glenn Barnett on 2/2/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "IDAudioUtils.h"
#import <AudioToolbox/AudioToolbox.h>



@implementation IDAudioUtils

// open the audio file
// returns a big audio ID struct
+(AudioFileID) openAudioFile:(NSString*)filePath
{
	AudioFileID outAFID;
	// use the NSURl instead of a cfurlref cuz it is easier
	NSURL * afUrl = [NSURL fileURLWithPath:filePath];
    
	// do some platform specific stuff..
#if TARGET_OS_IPHONE
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
#else
	OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, fsRdPerm, 0, &outAFID);
#endif
	if (result != 0) NSLog(@"   ERROR   IDAudioUtils: -openAudioFile[%@]: open failed, result: %d", filePath, result);
	return outAFID;
}

+(void) closeAudioFile:(AudioFileID)fileDescriptor {
	AudioFileClose(fileDescriptor);
}


// find the audio portion of the file
// return the size in bytes
+(UInt32) audioFileSize:(AudioFileID)fileDescriptor
{
	UInt64 outDataSize = 0;
	UInt32 thePropSize = sizeof(UInt64);
	OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
	if (result != 0) NSLog(@"   ERROR   IDAudioUtils: -audioFileSize: couldn't find size, result: %d", result);
	return (UInt32)outDataSize;
}

@end
