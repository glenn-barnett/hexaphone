//
//  AudioCopyPaste.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <UIKit/UIPasteboard.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import <MobileCoreServices/UTCoreTypes.h>

#define SWW_AUDIOCOPY_PASTEBOARD_NAME		@"com.sonomawireworks.audioCopyPasteboard"
#define RAW16_PASTEBOARD_TYPE				@"com.sonomawireworks.16bitrawaudiotype"
#define AUDIOINFO_PASTEBOARD_TYPE			@"com.sonomawireworks.audioinfo"
#define SWW_AUDIOCOPY_PASTEBOARD_INDEX_NAME	@"com.sonomawireworks.audioCopyPasteboardIndex"
#define INDEX_PASTEBOARD_TYPE				@"com.sonomawireworks.currentPasteboardIndex"
#define PASTEBOARD_CLEAR_TYPE				@"com.sonomawireworks.pasteboardClear"
#define HISTORY_SIZE 12

@protocol AudioPasteCallbackDelegate
 -(void)audioPasteBlockCompleted:(UInt64*)packetPosition numPackets:(UInt64*)pastePackets totalFileLengthInPackets:(UInt64*)trackLengthInPackets channels:(int)channels;
@end

typedef struct
{
	char	ChunkID[4];
	int32_t	ChunkSize;
	char	Format[4];
	char	Subchunk1ID[4];
	int32_t	Subchunk1Size;
	int16_t	AudioFormat;
	int16_t	NumChannels;
	int32_t	SampleRate;
	int32_t	ByteRate;
	int16_t	BlockAlign;
	int16_t	BitsPerSample;
	char	Subchunk2ID[4];
	int32_t	Subchunk2Size;
}wavefileheader;

@interface AudioCopyPaste : NSObject {
	wavefileheader *mHeader;
}


// init
+ (void)initPasteBoard;

// Copy methods
+(BOOL)copyAudioFileAtPathToGeneralPasteboard:(NSString*)path;
+(BOOL)copyMappedAudioFileAtPath:(NSString*)path withMeta:(NSDictionary*)meta toPasteboard:(NSString*)pasteboardName;

// Paste methods
+(BOOL)pasteAudioFileFromGeneralPasteboard:(NSMutableArray*)filepaths withLoopCount:(int)loopCount atOffset:(UInt64)offset pasteDelegate:(id)pasteDelegate;
+(BOOL)pasteAudioFileFromHistoryPasteboard:(NSString*)pasteboardName ToPaths:(NSMutableArray*)filepaths withLoopCount:(int)loopCount atOffset:(UInt64)offset pasteDelegate:(id)pasteDelegate;
+(BOOL)pasteAudioFileFromPasteboard:(NSString*)pasteboardName ToPaths:(NSMutableArray*)filepaths withLoopCount:(int)loopCount atOffset:(UInt64)offset pasteDelegate:(id)pasteDelegate;

// Pasteboard accessor methods
+(NSInteger)getPasteIndex;
+(NSDictionary*)getPasteInfo; //used in version 1.0 SDK
+(NSDictionary*)getPasteInfoWithPasteboardName:(NSString*)pasteboardname;
+(NSDictionary*)getPasteInfoForIndex:(int)pasteboardindex; //used in version >= 1.1 SDK
+(NSData*)getDataForIndexWithPasteboardName:(int)pasteindex pasteboardname:(NSString*)pasteboardname;
+(NSData*)getPreviewDataForPasteboardName:(NSString*)pasteboardname;
+(NSString*)incrementPasteIndexAndGetPasteboardName;
+(BOOL)hasGeneralPasteboardData;

// Pasteboard maintenance methods
+(void)incrementPasteIndex;
+(void)clearVersion1Pasteboard;


@end
