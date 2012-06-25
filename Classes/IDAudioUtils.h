//
//  IDAudioUtils.h
//  Hexatone
//
//  Created by Glenn Barnett on 2/2/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface IDAudioUtils : NSObject {

}

// open the audio file
// returns a big audio ID struct
+(AudioFileID)openAudioFile:(NSString*)filePath;

// find the audio portion of the file
// return the size in bytes
+(UInt32)audioFileSize:(AudioFileID)fileDescriptor;

+(void) closeAudioFile:(AudioFileID)fileDescriptor;

@end
