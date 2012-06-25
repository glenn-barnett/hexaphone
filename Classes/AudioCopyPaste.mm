//
//  AudioCopyPaste.mm
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//


#import "AudioCopyPaste.h"

#define PASTE_FILE_TYPE kAudioFileWAVEType
#define PASTE_BYTES_PER_FRAME 2
#define GP_CLIPBOARD_CHUNK_SIZE (5 * 1024 * 1024)


const int kReadBufSize = 65536;
const int kCopyDataBlockSize = (65536 * 32);//(65536 * 4);// This must be a multiple of READ_BUF_SIZE!
const int kPreviewDataMax = 3;

/*
 - AudioCopyPaste is used for for copying a 44.1kHz - 16bit PCM mono or stereo audio file to a pasteboard, & vice-versa
 - The unit of data for transfer to/from the pasteboard is a dictionary (containing an NSData object representing the audio file, plus metadata about the audio file)
 - The pasteboard type is specified by the #define RAW16_PASTEBOARD_TYPE. CAUTION: All apps involved in copy-paste will need to be aware of RAW16_PASTEBOARD_TYPE
 - The pasteboard name must be SWW_AUDIOCOPY_PASTEBOARD_NAME and it must be persistent so it may be accessed by multiple apps.
 - The audio file must be rendered and remain unaltered throughout the AudioCopy operation. If you render your audio file in a seperate thread, make sure it blocks until complete, before copyAudioFileAtPath is called.
 
 This is the only class necessary for implementing AudioCopy/AudioPaste.  Using these methods, your own custom UI may be developed.  However, we highly recommend you use the framework provided
 by the MAPI Example App.  Doing so provides a consistent experience to the user, and also gaurantees your App Name in the Compatible Apps List.  If you do not show the Compatible Apps List in your
 own Application, you will not be added to the Compatible Apps List used by any other application.  You of course may implement your own UI for the Compatible Apps List, but a working UI has been provided 
 for you in the MAPI Example App.  
*/

@implementation AudioCopyPaste

// This function should be called on launch by the AppDelegate Class.
+ (void)initPasteBoard
{
	//TODO: Make sure you have an URL Scheme in your Info.plist
	/*
	 Check for the URLScheme here - if you don't have an URL Scheme in your info.plist, this will assert(0) in order to bring that to your attention!
	 Refer to the MAPI Example App "Example-Info.plist" to see how to add an URL Scheme to your info.plist.
	 Use all lowercase, no spaces, and no punctuation (ex: swwmapiapp).
	 
	 After you've added the URL Scheme, the #if/#endif block of code is not needed. You may change #if 1 to #if 0 to avoid compiling it. 
	 */ 
	
#if 1
	NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
	NSArray *urlSchemes = (NSArray*)[[(NSArray*)[info objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
	if([urlSchemes count] == 0)
		assert(0);
#endif
	
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:SWW_AUDIOCOPY_PASTEBOARD_NAME create:YES];
	pasteboard.persistent = YES;
	
	pasteboard	= [UIPasteboard pasteboardWithName:SWW_AUDIOCOPY_PASTEBOARD_INDEX_NAME create:YES];
	pasteboard.persistent = YES;
	
	for (int i=0; i<HISTORY_SIZE; i++)
	{
		pasteboard = [UIPasteboard pasteboardWithName:[NSString stringWithFormat:@"%@%d",SWW_AUDIOCOPY_PASTEBOARD_NAME,i] create:YES];
		pasteboard.persistent = YES;
	}
}

/*
1) MAKE SURE FILE EXISTS AT 'PATH'
2) MAKE SURE PASTEBOARD WITH THE GIVEN NAME EXISTS
3) READ AUDIO FILE AT 'PATH' INTO AN NSDATA OBJECT
4) CREATE A DICTIONARY CONTAINING THE NSDATA OBJECT, PLUS METADATA ABOUT THE AUDIO FILE
5) COPY THE DICTIONARY ONTO THE PASTEBOARD
6) CLEANUP
*/

+(BOOL)copyAudioFileAtPathToGeneralPasteboard:(NSString*)path
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSLog(@"%@", [NSString stringWithFormat: @"File does not exist at path %@\n", path]);
		return NO;
	}
	
	// This is the copy operation using the General Pasteboard otherwise known as the Intua Pasteboard
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	NSData *dataFile = [NSData dataWithContentsOfMappedFile:path];
	
	if (!dataFile) {
		NSLog(@"Can't open file");
		return NO;
	}
	
	// Create chunked data and append to clipboard
	NSUInteger sz = [dataFile length];
	NSUInteger chunkNumbers = (sz / GP_CLIPBOARD_CHUNK_SIZE) + 1;
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:chunkNumbers];
	NSRange curRange;
	
	for (NSUInteger i = 0; i < chunkNumbers; i++) {
		curRange.location = i * GP_CLIPBOARD_CHUNK_SIZE;
		curRange.length = MIN(GP_CLIPBOARD_CHUNK_SIZE, sz - curRange.location);
		NSData *subData = [dataFile subdataWithRange:curRange];
		NSDictionary *dict = [NSDictionary dictionaryWithObject:subData forKey:(NSString *)kUTTypeAudio];
		[items addObject:dict];
	}
	
	board.items = items;
	return YES;
}

+(int32_t)_getDataOffset:(void*)databuf
{
	char *data = (char*)databuf;
	int32_t offset = 12;
	data += offset;
	//find the data chunk
	char nextchunkid[4];
	int32_t nextchunksize = 0;
	size_t amountread = 1;
	
	
	while (amountread > 0)
	{
		strncpy(nextchunkid, data, 4);
		nextchunksize = *((int32_t*)(data+=4));
		offset += 8;
		//look for the data chunk ID
		if (strncmp(nextchunkid, "data", 4) == 0)
		{
			fprintf(stderr, "we found the data chunk with size = %d\n", nextchunksize);
			return offset;
		}
		else
		{
			//see the file if we didn't find the data
			printf("seeking to next chunk\n");
			data += nextchunksize + 4;
			offset += nextchunksize;
		}
	}
	return 0;
}

+(BOOL)copyMappedAudioFileAtPath:(NSString*)path withMeta:(NSDictionary*)meta toPasteboard:(NSString*)pasteboardName
{
	// Clear Version 1 pasteboard so the old pasteboard won't sit around 
	[AudioCopyPaste clearVersion1Pasteboard];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSLog(@"%@", [NSString stringWithFormat: @"File does not exist at path %@\n", path]);
		return NO;
	}
	
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];	
	if(!pasteboard){
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@\n", pasteboardName]);
		return NO;
	}

	// Check file has length, is 44.1kHz and 16-bit
	const char *cStr = [path cStringUsingEncoding:NSUTF8StringEncoding];
	CFURLRef	fileURL = CFURLCreateFromFileSystemRepresentation(NULL, (UInt8*)cStr, strlen(cStr), false);
	
	AudioFileID audioFile;
	OSStatus osstatus = AudioFileOpenURL(fileURL, kAudioFileReadPermission, kAudioFileWAVEType, &audioFile); //Open
	switch (osstatus) {
		case kAudioFileUnspecifiedError:
		case kAudioFileUnsupportedFileTypeError:
		case kAudioFileUnsupportedDataFormatError:
		case kAudioFileUnsupportedPropertyError:
		case kAudioFileBadPropertySizeError:
		case kAudioFilePermissionsError:
		case kAudioFileNotOptimizedError:
		case kAudioFileInvalidChunkError:
		case kAudioFileDoesNotAllow64BitDataSizeError:
		case kAudioFileInvalidPacketOffsetError:
		case kAudioFileInvalidFileError:
		case kAudioFileOperationNotSupportedError:{
			NSLog(@"%@", [NSString stringWithFormat: @"Error opening Audio file at path %@\n", path]);
			return NO;
		}
	}
	
	UInt64 totalBytes;
	UInt32 propertySize = sizeof(totalBytes);
	AudioFileGetProperty(audioFile, kAudioFilePropertyAudioDataByteCount,&propertySize, &totalBytes);
	
	if (totalBytes == 0)
	{
		NSLog(@"Error: AudioCopy - file of 0 bytes\n");
		return NO;
	}
	
	AudioStreamBasicDescription desc;
	propertySize = sizeof(desc);
	AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat,&propertySize, &desc);
	
	if (desc.mSampleRate != 44100.0f)
	{
		NSLog(@"AudioCopy only supports the 44100.0f sample rate\n");
		return NO;
	}
	
	if (desc.mBitsPerChannel != 16)
	{
		NSLog(@"AudioCopy only supports 16-bit audio\n");
		return NO;
	}
	
	// Must add multiple items to pasteboard to keep NSData size down
	UInt32 numPasteItems = totalBytes/kCopyDataBlockSize;
	if (totalBytes%kCopyDataBlockSize > 0)
		numPasteItems++;
		
	// Set all the paste info
	float dur = (totalBytes/desc.mBytesPerFrame)/44100.0f;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:meta];
	[dict setObject:[NSNumber numberWithFloat:dur] forKey:@"duration"];
	[dict setObject:[NSNumber numberWithInt:desc.mChannelsPerFrame] forKey:@"channels"];
	[dict setObject:[NSNumber numberWithInt:numPasteItems] forKey:@"pastedcount"];
	
	//NSString *errorStr = nil;
	//NSData *dataRep = [NSPropertyListSerialization dataFromPropertyList: dict
	//													 format: NSPropertyListXMLFormat_v1_0
	//													errorDescription: &errorStr];
													
	//if (!dataRep) {
	//	[errorStr release];
	//	return NO;
	//}
	
	//[pasteboard setData:dataRep forPasteboardType: AUDIOINFO_PASTEBOARD_TYPE];
	//[dict release];

	AudioFileClose(audioFile);
	
	
	NSData *dataFile = [NSData dataWithContentsOfMappedFile:path];
	if (!dataFile) {
		NSLog(@"Can't open file");
		return NO;
	}
	// Find size of header (we only want the raw data)
	int32_t dataoffset = [AudioCopyPaste _getDataOffset:(void*)[dataFile bytes]];
	// Create chunked data and append to clipboard
	NSUInteger totalsize = [dataFile length];
	NSUInteger sz = totalsize - dataoffset;
	NSUInteger chunkNumbers = (sz / kCopyDataBlockSize) + 1;
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:chunkNumbers];
	NSDictionary *infodict = [NSDictionary dictionaryWithObject:dict forKey:AUDIOINFO_PASTEBOARD_TYPE];
	[items addObject:infodict];
	
	NSRange curRange;
	
	for (NSUInteger i = 0; i < chunkNumbers; i++) {
		curRange.location = i * kCopyDataBlockSize + dataoffset;
		curRange.length = MIN(kCopyDataBlockSize, totalsize - curRange.location);
		NSData *subData = [dataFile subdataWithRange:curRange];
		NSDictionary *dict = [NSDictionary dictionaryWithObject:subData forKey:RAW16_PASTEBOARD_TYPE];
		[items addObject:dict];
	}
	
	pasteboard.items = items;
	return YES;
}

// This supports the general pasteboard copy
+(BOOL)pasteAudioFileFromGeneralPasteboard:(NSMutableArray*)filepaths withLoopCount:(int)loopCount atOffset:(UInt64)offset pasteDelegate:(id)pasteDelegate
{
	//First write general pasteboard data to temp file
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	
	NSArray *typeArray = [NSArray arrayWithObject:(NSString *) kUTTypeAudio];
	NSIndexSet *set = [board itemSetWithPasteboardTypes:typeArray];
	if (!set) {
		return NO;
	}
		
	// Get the subset of kUTTypeAudio elements, and write each chunk to a temporary file
	NSString *temppath;
	NSArray *items = [board dataForPasteboardType:(NSString *) kUTTypeAudio inItemSet:set];		
	if (items) {
		UInt32 cnt = [items count];
		if (!cnt) {
			return NO;
		}
		
		// Create a file and write each chunks to it.
		temppath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithString:@"temp-pasteboard"]];
		if (![[NSFileManager defaultManager] createFileAtPath:temppath contents:nil attributes:nil]) {
			return NO;
		}
		
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:temppath];
		if (!handle) {
			return NO;
		}
		
		// Write each chunk to file
		for (UInt32 i = 0; i < cnt; i++) {
			[handle writeData:[items objectAtIndex:i]];
		}
		[handle closeFile];
	}
	
	//Begin normal paste operation using written temp files as source
	id<AudioPasteCallbackDelegate> audioPasteCallbackDelegate = nil;
	Protocol *prot = @protocol(AudioPasteCallbackDelegate);
	if ([pasteDelegate conformsToProtocol:prot])
	{
		audioPasteCallbackDelegate = pasteDelegate;
	}

	UInt64 packetPosition = offset;
	OSStatus osstatus;
	
	// Copy the original files tracks to temporary paste tracks
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (int i = 0; i < [filepaths count]; i++)
	{
		NSString *srcPath = [filepaths objectAtIndex:i];
		NSString *destPath = [srcPath stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		[fileManager removeItemAtPath:destPath error:nil];		
		[fileManager copyItemAtPath:srcPath toPath:destPath error:nil];	
	}
	
	// Open all audio files
	AudioFileID audioFiles[[filepaths count]];
	for (int i = 0; i < [filepaths count]; i++)
	{
		// Open the source file for this track.
		NSString *filepath = [[filepaths objectAtIndex:i] stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		CFURLRef audioUrl = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *) [filepath UTF8String], strlen ((const char *)[filepath UTF8String]), false);
		OSStatus osstatus = AudioFileOpenURL(audioUrl, kAudioFileReadWritePermission, PASTE_FILE_TYPE, &audioFiles[i]);
		if (osstatus != noErr)
		{
			NSLog(@"%@", [NSString stringWithFormat:@"Error opening file %s for read/write", audioUrl]);
		}
		CFRelease(audioUrl);		
	}
	
	// Find out if these are mono or stereo file(s) we're pasting to
	// If you have more than one file path in the filepaths array, we assume they're both the same type
	AudioStreamBasicDescription desc;
	UInt32 propertySize = sizeof(desc);
	AudioFileGetProperty(audioFiles[0], kAudioFilePropertyDataFormat,&propertySize, &desc);
	BOOL fileIsMono = (desc.mChannelsPerFrame == 1);
	
	// If there is more than one filepath, the files are assumed to be the same length (more than one filepath should only be used for split stereo)
	UInt64 trackLengthInPackets;
	propertySize = sizeof(trackLengthInPackets);
	AudioFileGetProperty(audioFiles[0], kAudioFilePropertyAudioDataPacketCount,&propertySize, &trackLengthInPackets);

	UInt32 byteOffset = packetPosition * PASTE_BYTES_PER_FRAME * desc.mChannelsPerFrame;
	// make sure we are always byte aligned
	if(byteOffset % 2 != 0)
	{
		//NSLog(@"adjusting byteoffset");
		--byteOffset;
	}
	
	//Open AudioFile for pasting and get channel count
	AudioFileID pasteFile; 
	osstatus = AudioFileOpenURL((CFURLRef) [NSURL fileURLWithPath:temppath], kAudioFileReadPermission, 0, &pasteFile);
	if (osstatus != noErr)
	{
		NSLog(@"Failed open audio file for general pasteboard\n");
		return NO;
	}
	propertySize = sizeof(desc);
	AudioFileGetProperty(pasteFile, kAudioFilePropertyDataFormat,&propertySize, &desc);
	int channels = desc.mChannelsPerFrame;
	for (int loop=0; loop<loopCount; loop++)
	{
		UInt32 framecount = (kReadBufSize/4)*channels;
		short *audioBuf = new short[framecount];
		UInt32 numBytesRead = framecount*2;
		SInt64 bytePosition = 0;
		while (numBytesRead != 0)
		{
			osstatus = AudioFileReadBytes(pasteFile, 0, bytePosition, &numBytesRead, audioBuf);
			if (numBytesRead == 0)
			{
				delete [] audioBuf;
				break;
			}
			// Get audio info
			bytePosition += numBytesRead;
			UInt32 audioDataBytes = numBytesRead;
			// Determine the audio paste length
			UInt64 pastePackets = numBytesRead/2/channels;;
			
			//NSLog(@"channels = %d", channels);
			
			// Copy the audio data to the tracks
			// Mono to Mono
			if(channels == 1 && fileIsMono && ([filepaths count] == 1))
			{
				//NSLog(@"bytes to write = %d", audioDataBytes);	
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, audioBuf);		
				byteOffset += audioDataBytes;
				//NSLog(@"bytes written = %d", audioDataBytes);	
			}
			// Mono to Stereo
			else if (channels == 1 && !fileIsMono)
			{
				/* Since this data is Mono, if we don't use a gain multiplier when making it mono, it could clip.
				 * Instead, muliply by 0.707f, and that should reduce the gain without causing much of a perceivable gain drop.  
				 */
				int samplesPerChannel = numBytesRead/2;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				// Create buffer for stereo 
				short *stereo = new short[samplesPerChannel*2];
				for(int i=0; i<samplesPerChannel; ++i)
				{
					stereo[2*i] = (int)(0.707f*(*data));
					stereo[2*i+1] = (int)(0.707f*(*data++));
				}
				
				audioDataBytes = bytesPerChannel*2;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, stereo);		
				byteOffset += audioDataBytes;
				delete [] stereo;
			}
			// Stereo to Split Mono
			else if (channels == 2 && fileIsMono && ([filepaths count] > 1))
			{
				// To use this function, your filePaths array must contain two paths to two existing Mono files.
				int samplesPerChannel = (numBytesRead/2)/channels;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				short *left = new short[samplesPerChannel];
				short *right = new short[samplesPerChannel];
				// Create buffers for left / right channels
				for(int i=0; i<samplesPerChannel; ++i)
				{
					left[i] = *data++;
					right[i] = *data++;
				}
				
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, left);		
				osstatus = AudioFileWriteBytes (audioFiles[1], NO, byteOffset, &audioDataBytes, right);
				byteOffset += audioDataBytes;
				delete [] left;
				delete [] right;
			}
			// Mono to Split Mono
			else if (channels == 1 && fileIsMono && ([filepaths count] > 1))
			{
				// This would only be used if you were always using stereo split mono for paste, even when the paste source is mono
				// To use this function, your filePaths array must contain two paths to two existing Mono files.
				int samplesPerChannel = (numBytesRead/2)/channels;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				short *scaledmono = new short[samplesPerChannel];
				// Create buffers for left / right channels
				for(int i=0; i<samplesPerChannel; ++i)
				{
					scaledmono[i] = (0.5f*(*data++));
				}
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, scaledmono);		
				osstatus = AudioFileWriteBytes (audioFiles[1], NO, byteOffset, &audioDataBytes, scaledmono);
				byteOffset += audioDataBytes;
				delete [] scaledmono;
			}
			// Stereo to Mono
			else if (channels == 2 && fileIsMono && ([filepaths count] == 1))
			{
				/* The stereo channels are summed together.  We add in a 0.5 multiplier to gaurantee no clipping. 
				 * If someone gave you mono data as a stereo file so that the left channel was indentical to the right channel, this would clip.
				 */
				int samplesPerChannel = (numBytesRead/2)/channels;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				short *left = new short[samplesPerChannel];
				// Create buffer for left channel
				for(int i=0; i<samplesPerChannel; ++i)
				{
					left[i] = (int)(0.5f*(*data++));
					left[i] +=(int)(0.5f*(*data++));
				}
				
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, left);		
				byteOffset += audioDataBytes;
				delete [] left;
			}
			// Stereo to Stereo
			else if (channels == 2 && !fileIsMono)
			{
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, audioBuf);		
				byteOffset += audioDataBytes;
			}
			
			/*
			Call the audioPasteBlockCompleted callback here in case you need to do anything special during 
			the paste process.  For example, FourTrack must modify the other tracks in the song during AudioPaste.  
			*/
			if (audioPasteCallbackDelegate)
			{
				[audioPasteCallbackDelegate audioPasteBlockCompleted:&packetPosition numPackets:&pastePackets totalFileLengthInPackets:&trackLengthInPackets channels:channels];
			}
		}
	}
	// Close all files
	AudioFileClose(pasteFile);
	[fileManager removeItemAtPath:temppath error:nil];
	for (int i = 0; i < [filepaths count]; i++)
	{
		AudioFileOptimize(audioFiles[i]);
		AudioFileClose(audioFiles[i]);
	}
	// Replace the original tracks with the temp paste tracks
	for (int i = 0; i < [filepaths count]; i++)
	{
		NSString *trackFile = [filepaths objectAtIndex:i];
		NSString *pasteFile = [trackFile stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		[fileManager removeItemAtPath:trackFile error:nil];
		[fileManager moveItemAtPath:pasteFile toPath:trackFile error:nil];
	}	
	return YES;
}

+(void)_createHeader:(wavefileheader *)header channels:(int32_t)channels dataSize:(int32_t)length
{
	int32_t samplerate = 44100;
	int32_t bytespersamp = 2;
	strncpy(header->ChunkID, "RIFF", 4);
	header->ChunkSize = length + 36;
	strncpy(header->Format, "WAVE", 4);
	strncpy(header->Subchunk1ID,"fmt ",4);
	header->Subchunk1Size = 16;
	header->AudioFormat = 1;
	header->NumChannels = channels;
	header->SampleRate = samplerate;
	header->ByteRate = samplerate*channels*bytespersamp;
	header->BlockAlign = channels*bytespersamp;
	header->BitsPerSample = bytespersamp*8;
	strncpy(header->Subchunk2ID, "data", 4);
	header->Subchunk2Size = length;
}

// This supports AudioCopy 1.1
+(BOOL)pasteAudioFileFromHistoryPasteboard:(NSString*)pasteboardName ToPaths:(NSMutableArray*)filepaths withLoopCount:(int)loopCount atOffset:(UInt64)offset pasteDelegate:(id)pasteDelegate
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:NO];	
	if(!pasteboard){
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@\n", pasteboardName]);
		return NO;
	}
	NSString *type = RAW16_PASTEBOARD_TYPE;
	NSArray *typeArray = [NSArray arrayWithObject:type];
	NSIndexSet *set = [pasteboard itemSetWithPasteboardTypes:typeArray];
	if (!set) {
		return NO;
	}
		
	// Get the subset of RAW16_PASTEBOARD_TYPE elements, write to temp file
	NSString *temppath;
	NSArray *pasteItems = [pasteboard dataForPasteboardType:RAW16_PASTEBOARD_TYPE inItemSet:set];		
	if (pasteItems) {
		UInt32 cnt = [pasteItems count];
		if (!cnt) {
			return NO;
		}
		// Create a file and write each chunks to it.
		temppath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithString:@"temp-pasteboard"]];
		[temppath retain];
		if (![[NSFileManager defaultManager] createFileAtPath:temppath contents:nil attributes:nil]) {
			return NO;
		}
		
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:temppath];
		if (!handle) {
			return NO;
		}
		UInt32 datasize = 0;
		for (UInt32 i=0; i< cnt; i++)
		{
			datasize += [[pasteItems objectAtIndex:i] length];
		}
		NSDictionary *infodict = [AudioCopyPaste getPasteInfoWithPasteboardName:pasteboardName];
		int channels = [[infodict objectForKey:@"channels"] intValue];
		wavefileheader header;
		[AudioCopyPaste _createHeader:&header channels:channels dataSize:datasize];
		[handle writeData:[NSData dataWithBytes:&header length:sizeof(wavefileheader)]];
		// Write each chunk to file
		for (UInt32 i = 0; i < cnt; i++) {
			[handle writeData:[pasteItems objectAtIndex:i]];
		}
		[handle closeFile];
	}

	
	// Begin paste operation using pasteitmes 
	id<AudioPasteCallbackDelegate> audioPasteCallbackDelegate = nil;
	Protocol *prot = @protocol(AudioPasteCallbackDelegate);
	if ([pasteDelegate conformsToProtocol:prot])
	{
		audioPasteCallbackDelegate = pasteDelegate;
	}

	UInt64 packetPosition = offset;
	OSStatus osstatus;
	
	// Copy the original files tracks to temporary paste tracks
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (int i = 0; i < [filepaths count]; i++)
	{
		NSString *srcPath = [filepaths objectAtIndex:i];
		NSString *destPath = [srcPath stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		[fileManager removeItemAtPath:destPath error:nil];		
		[fileManager copyItemAtPath:srcPath toPath:destPath error:nil];	
	}
	
	// Open all audio files
	AudioFileID audioFiles[[filepaths count]];
	for (int i = 0; i < [filepaths count]; i++)
	{
		// Open the source file for this track.
		NSString *filepath = [[filepaths objectAtIndex:i] stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		CFURLRef audioUrl = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *) [filepath UTF8String], strlen ((const char *)[filepath UTF8String]), false);
		OSStatus osstatus = AudioFileOpenURL(audioUrl, kAudioFileReadWritePermission, PASTE_FILE_TYPE, &audioFiles[i]);
		if (osstatus != noErr)
		{
			NSLog(@"%@", [NSString stringWithFormat:@"Error opening file %s for read/write", audioUrl]);
		}
		CFRelease(audioUrl);		
	}
	
	// Find out if these are mono or stereo file(s) we're pasting to
	// If you have more than one file path in the filepaths array, we assume they're both the same type
	AudioStreamBasicDescription desc;
	UInt32 propertySize = sizeof(desc);
	AudioFileGetProperty(audioFiles[0], kAudioFilePropertyDataFormat,&propertySize, &desc);
	BOOL fileIsMono = (desc.mChannelsPerFrame == 1);
	
	// If there is more than one filepath, the files are assumed to be the same length (more than one filepath should only be used for split stereo)
	UInt64 trackLengthInPackets;
	propertySize = sizeof(trackLengthInPackets);
	AudioFileGetProperty(audioFiles[0], kAudioFilePropertyAudioDataPacketCount,&propertySize, &trackLengthInPackets);

	UInt32 byteOffset = packetPosition * PASTE_BYTES_PER_FRAME * desc.mChannelsPerFrame;
	// make sure we are always byte aligned
	if(byteOffset % 2 != 0)
	{
		//NSLog(@"adjusting byteoffset");
		--byteOffset;
	}
	
	//Open AudioFile for pasting and get channel count
	AudioFileID pasteFile; 
	osstatus = AudioFileOpenURL((CFURLRef) [NSURL fileURLWithPath:temppath], kAudioFileReadPermission, 0, &pasteFile);
	if (osstatus != noErr)
	{
		NSLog(@"Failed open audio file for general pasteboard\n");
		return NO;
	}
	propertySize = sizeof(desc);
	AudioFileGetProperty(pasteFile, kAudioFilePropertyDataFormat,&propertySize, &desc);
	int channels = desc.mChannelsPerFrame;
	for (int loop=0; loop<loopCount; loop++)
	{
		UInt32 framecount = (kReadBufSize/4)*channels;
		short *audioBuf = new short[framecount];
		UInt32 numBytesRead = framecount*2;
		SInt64 bytePosition = 0;
		while (numBytesRead != 0)
		{
			osstatus = AudioFileReadBytes(pasteFile, 0, bytePosition, &numBytesRead, audioBuf);
			if (numBytesRead == 0)
			{
				delete [] audioBuf;
				break;
			}
			// Get audio info
			bytePosition += numBytesRead;
			UInt32 audioDataBytes = numBytesRead;
			// Determine the audio paste length
			UInt64 pastePackets = numBytesRead/2/channels;;

			
			// Copy the audio data to the tracks
			// Mono to Mono
			if(channels == 1 && fileIsMono && ([filepaths count] == 1))
			{
				//NSLog(@"bytes to write = %d", audioDataBytes);	
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, audioBuf);		
				byteOffset += audioDataBytes;
				//NSLog(@"bytes written = %d", audioDataBytes);	
			}
			// Mono to Stereo
			else if (channels == 1 && !fileIsMono)
			{
				/* Since this data is Mono, if we don't use a gain multiplier when making it mono, it could clip.
				 * Instead, muliply by 0.707f, and that should reduce the gain without causing much of a perceivable gain drop.  
				 */
				int samplesPerChannel = numBytesRead/2;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				// Create buffer for stereo 
				short *stereo = new short[samplesPerChannel*2];
				for(int i=0; i<samplesPerChannel; ++i)
				{
					stereo[2*i] = (int)(0.707f*(*data));
					stereo[2*i+1] = (int)(0.707f*(*data++));
				}
				
				audioDataBytes = bytesPerChannel*2;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, stereo);		
				byteOffset += audioDataBytes;
				delete [] stereo;
			}
			// Stereo to Split Mono
			else if (channels == 2 && fileIsMono && ([filepaths count] > 1))
			{
				// To use this function, your filePaths array must contain two paths to two existing Mono files.
				int samplesPerChannel = numBytesRead/2 /channels;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				short *left = new short[samplesPerChannel];
				short *right = new short[samplesPerChannel];
				// Create buffers for left / right channels
				for(int i=0; i<samplesPerChannel; ++i)
				{
					left[i] = *data++;
					right[i] = *data++;
				}
				
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, left);		
				osstatus = AudioFileWriteBytes (audioFiles[1], NO, byteOffset, &audioDataBytes, right);
				byteOffset += audioDataBytes;
				delete [] left;
				delete [] right;
			}
			// Mono to Split Mono
			else if (channels == 1 && fileIsMono && ([filepaths count] > 1))
			{
				// This would only be used if you were always using stereo split mono for paste, even when the paste source is mono
				// To use this function, your filePaths array must contain two paths to two existing Mono files.
				int samplesPerChannel = (numBytesRead/2)/channels;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				short *scaledmono = new short[samplesPerChannel];
				// Create buffers for left / right channels
				for(int i=0; i<samplesPerChannel; ++i)
				{
					scaledmono[i] = (0.5f*(*data++));
				}
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, scaledmono);		
				osstatus = AudioFileWriteBytes (audioFiles[1], NO, byteOffset, &audioDataBytes, scaledmono);
				byteOffset += audioDataBytes;
				delete [] scaledmono;
			}
			// Stereo to Mono
			else if (channels == 2 && fileIsMono && ([filepaths count] == 1))
			{
				/* The stereo channels are summed together.  We add in a 0.5 multiplier to gaurantee no clipping. 
				 * If someone gave you mono data as a stereo file so that the left channel was indentical to the right channel, this would clip.
				 */
				int samplesPerChannel = numBytesRead/2 /channels;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = audioBuf;
				short *left = new short[samplesPerChannel];
				// Create buffer for left channel
				for(int i=0; i<samplesPerChannel; ++i)
				{
					left[i] = (int)(0.5f*(*data++));
					left[i] +=(int)(0.5f*(*data++));
				}
				
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, left);		
				byteOffset += audioDataBytes;
				delete [] left;
			}
			// Stereo to Stereo
			else if (channels == 2 && !fileIsMono)
			{
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, audioBuf);		
				byteOffset += audioDataBytes;
			}
			
			/*
			Call the audioPasteBlockCompleted callback here in case you need to do anything special during 
			the paste process.  For example, FourTrack must modify the other tracks in the song during AudioPaste.  
			*/
			if (audioPasteCallbackDelegate)
			{
				[audioPasteCallbackDelegate audioPasteBlockCompleted:&packetPosition numPackets:&pastePackets totalFileLengthInPackets:&trackLengthInPackets channels:channels];
			}
		}
	}
	// Close temp file
	AudioFileClose(pasteFile);
	[fileManager removeItemAtPath:temppath error:nil];
	[temppath release];
	// Close all files
	for (int i = 0; i < [filepaths count]; i++)
	{
		AudioFileOptimize(audioFiles[i]);
		AudioFileClose(audioFiles[i]);
	}
	// Replace the original tracks with the temp paste tracks
	for (int i = 0; i < [filepaths count]; i++)
	{
		NSString *trackFile = [filepaths objectAtIndex:i];
		NSString *pasteFile = [trackFile stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		[fileManager removeItemAtPath:trackFile error:nil];
		[fileManager moveItemAtPath:pasteFile toPath:trackFile error:nil];
	}	
	return YES;
}

// This supports AudioCopy version 1.0
+(BOOL)pasteAudioFileFromPasteboard:(NSString*)pasteboardName ToPaths:(NSMutableArray*)filepaths withLoopCount:(int)loopCount atOffset:(UInt64)offset pasteDelegate:(id)pasteDelegate
{
	/* Pasting procedure
	 *
	 * 1. Copy the original tracks and perform paste with these temporary tracks
	 * 2. Open all audio files
	 * 3. Paste the audio into the given filepaths
	 * 4. Do any extra stuff in the AudioPasteCallbackDelegate
	 * 5. Close the audio files
	 * 6. Replace the original files with the new "paste" files
	 *
	 */
	if ([pasteboardName caseInsensitiveCompare:@"generalpasteboard"] == NSOrderedSame)
	{
		BOOL success = [AudioCopyPaste pasteAudioFileFromGeneralPasteboard:filepaths withLoopCount:loopCount atOffset:offset pasteDelegate:pasteDelegate];;
		return success;
	}
	if ([pasteboardName caseInsensitiveCompare:SWW_AUDIOCOPY_PASTEBOARD_NAME] != NSOrderedSame)
	{
		BOOL success = [AudioCopyPaste pasteAudioFileFromHistoryPasteboard:pasteboardName ToPaths:filepaths withLoopCount:loopCount atOffset:offset pasteDelegate:pasteDelegate];;
		return success;
	}
	id<AudioPasteCallbackDelegate> audioPasteCallbackDelegate = nil;
	Protocol *prot = @protocol(AudioPasteCallbackDelegate);
	if ([pasteDelegate conformsToProtocol:prot])
	{
		audioPasteCallbackDelegate = pasteDelegate;
	}

	UInt64 packetPosition = offset;
	OSStatus osstatus;
	
	// Copy the original files tracks to temporary paste tracks
	NSFileManager *fileManager = [NSFileManager defaultManager];
	for (int i = 0; i < [filepaths count]; i++)
	{
		NSString *srcPath = [filepaths objectAtIndex:i];
		NSString *destPath = [srcPath stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		[fileManager removeItemAtPath:destPath error:nil];		
		[fileManager copyItemAtPath:srcPath toPath:destPath error:nil];	
	}
	
	// Open all audio files
	AudioFileID audioFiles[[filepaths count]];
	for (int i = 0; i < [filepaths count]; i++)
	{
		// Open the source file for this track.
		NSString *filepath = [[filepaths objectAtIndex:i] stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		CFURLRef audioUrl = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *) [filepath UTF8String], strlen ((const char *)[filepath UTF8String]), false);
		OSStatus osstatus = AudioFileOpenURL(audioUrl, kAudioFileReadWritePermission, PASTE_FILE_TYPE, &audioFiles[i]);
		if (osstatus != noErr)
		{
			NSLog(@"%@", [NSString stringWithFormat:@"Error opening file %s for read/write", audioUrl]);
		}
		CFRelease(audioUrl);		
	}
	
	// Find out if these are mono or stereo file(s) we're pasting to
	// If you have more than one file path in the filepaths array, we assume they're both the same type
	AudioStreamBasicDescription desc;
	UInt32 propertySize = sizeof(desc);
	AudioFileGetProperty(audioFiles[0], kAudioFilePropertyDataFormat,&propertySize, &desc);
	BOOL fileIsMono = (desc.mChannelsPerFrame == 1);
	
	// If there is more than one filepath, the files are assumed to be the same length (more than one filepath should only be used for split stereo)
	UInt64 trackLengthInPackets;
	propertySize = sizeof(trackLengthInPackets);
	AudioFileGetProperty(audioFiles[0], kAudioFilePropertyAudioDataPacketCount,&propertySize, &trackLengthInPackets);

	UInt32 byteOffset = packetPosition * PASTE_BYTES_PER_FRAME * desc.mChannelsPerFrame;
	// make sure we are always byte aligned
	if(byteOffset % 2 != 0)
	{
		//NSLog(@"adjusting byteoffset");
		--byteOffset;
	}
	//NSLog(@"byteoffset = %d", byteOffset);		
	NSDictionary *dict = [AudioCopyPaste getPasteInfoWithPasteboardName:pasteboardName];
	int channels = [(NSNumber*)[dict objectForKey:@"channels"] intValue];
	int pastecount = [(NSNumber*)[dict objectForKey:@"pastedcount"] intValue];

	
	for (int loop=0; loop<loopCount; loop++)
	{
		for (int pasteindex = 0; pasteindex < pastecount; pasteindex++)
		{
			NSData *audioData = [AudioCopyPaste getDataForIndexWithPasteboardName:pasteindex pasteboardname:pasteboardName];
			if (!audioData)
			{
				NSLog(@"Paste data doesn't match paste count!");
				return NO;
			}
			// Get audio info
			UInt32 audioDataBytes = [audioData length];

			// Determine the audio paste length
			UInt64 pastePackets = audioDataBytes / 2 / channels;
			
			//NSLog(@"channels = %d", channels);
			
			// Copy the audio data to the tracks
			// Mono to Mono
			if(channels == 1 && fileIsMono)
			{
				//NSLog(@"bytes to write = %d", audioDataBytes);	
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, [audioData bytes]);		
				byteOffset += audioDataBytes;
				//NSLog(@"bytes written = %d", audioDataBytes);	
			}
			// Mono to Stereo
			else if (channels == 1 && !fileIsMono)
			{
				/* Since this data is Mono, if we don't use a gain multiplier when making it mono, it could clip.
				 * Instead, muliply by 0.707f, and that should reduce the gain without causing a perceivable gain drop.  
				 */
				int samplesPerChannel = [audioData length] / 2;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = (short*)[audioData bytes];
				// Create buffer for stereo 
				short *stereo = new short[samplesPerChannel*2];
				for(int i=0; i<samplesPerChannel; ++i)
				{
					stereo[2*i] = (int)(0.707f*(*data));
					stereo[2*i+1] = (int)(0.707f*(*data++));
				}
				
				audioDataBytes = bytesPerChannel*2;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, stereo);		
				byteOffset += audioDataBytes;
				delete [] stereo;
			}
			// Stereo to Split Mono
			else if (channels == 2 && fileIsMono && ([filepaths count] > 1))
			{
				// To use this function, your filePaths array must contain two paths to two existing Mono files.
				int samplesPerChannel = [audioData length] / 2 / 2;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = (short*)[audioData bytes];
				short *left = new short[samplesPerChannel];
				short *right = new short[samplesPerChannel];
				// Create buffers for left / right channels
				for(int i=0; i<samplesPerChannel; ++i)
				{
					left[i] = *data++;
					right[i] = *data++;
				}
				
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, left);		
				osstatus = AudioFileWriteBytes (audioFiles[1], NO, byteOffset, &audioDataBytes, right);
				byteOffset += audioDataBytes;
				delete [] left;
				delete [] right;
			}
			// Stereo to Mono
			else if (channels == 2 && fileIsMono && ([filepaths count] == 1))
			{
				/* The stereo channels are summed together.  We add in a 0.5 multiplier to gaurantee no clipping. 
				 * If someone gave you mono data as a stereo file so that the left channel was indentical to the right channel, this would clip.
				 */
				int samplesPerChannel = [audioData length] / 2 / 2;
				int bytesPerChannel = samplesPerChannel * 2;
				short *data = (short*)[audioData bytes];
				short *left = new short[samplesPerChannel];
				// Create buffer for left channel
				for(int i=0; i<samplesPerChannel; ++i)
				{
					left[i] = (int)(0.5f*(*data++));
					left[i] +=(int)(0.5f*(*data++));
				}
				
				audioDataBytes = bytesPerChannel;
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, left);		
				byteOffset += audioDataBytes;
				delete [] left;
			}
			// Stereo to Stereo
			else if (channels == 2 && !fileIsMono)
			{
				osstatus = AudioFileWriteBytes (audioFiles[0], NO, byteOffset, &audioDataBytes, [audioData bytes]);		
				byteOffset += audioDataBytes;
			}
			
			/*
			Call the audioPasteBlockCompleted callback here in case you need to do anything special during 
			the paste process.  For example, FourTrack must modify the other tracks in the song during AudioPaste.  
			*/
			if (audioPasteCallbackDelegate)
			{
				[audioPasteCallbackDelegate audioPasteBlockCompleted:&packetPosition numPackets:&pastePackets totalFileLengthInPackets:&trackLengthInPackets channels:channels];
			}
		}
	}
	
	// Close all files
	for (int i = 0; i < [filepaths count]; i++)
	{
		AudioFileOptimize(audioFiles[i]);
		AudioFileClose(audioFiles[i]);
	}
	// Replace the original tracks with the temp paste tracks
	for (int i = 0; i < [filepaths count]; i++)
	{
		NSString *trackFile = [filepaths objectAtIndex:i];
		NSString *pasteFile = [trackFile stringByReplacingOccurrencesOfString:@".wav" withString:@"pastetemp.wav"];
		[fileManager removeItemAtPath:trackFile error:nil];
		[fileManager moveItemAtPath:pasteFile toPath:trackFile error:nil];
	}	
	return YES;
}

+(NSInteger)getPasteIndex
{	
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:SWW_AUDIOCOPY_PASTEBOARD_INDEX_NAME create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", SWW_AUDIOCOPY_PASTEBOARD_NAME]);
		return 0;
	}
	NSString *errorStr = nil;
	NSData *dataRep = [pasteboard dataForPasteboardType: INDEX_PASTEBOARD_TYPE];
	NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData: dataRep
														  mutabilityOption: NSPropertyListImmutable
																	format: &format
														  errorDescription: &errorStr];	
	if (dict)
	{
		NSNumber *index = (NSNumber*)[dict objectForKey:@"currentindex"];
		return [index intValue];
	}
	else
	{
		return 0;
	}
}

+(NSDictionary*)getPasteInfo
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:SWW_AUDIOCOPY_PASTEBOARD_NAME create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", SWW_AUDIOCOPY_PASTEBOARD_NAME]);
		return nil;
	}
	
	NSString *errorStr = nil;
	NSData *dataRep = [pasteboard dataForPasteboardType: AUDIOINFO_PASTEBOARD_TYPE];
	if (!dataRep)
	{
		return nil;
	}
	NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData: dataRep
														  mutabilityOption: NSPropertyListImmutable
																	format: &format
														  errorDescription: &errorStr];	
	return dict;
}

+(NSDictionary*)getPasteInfoWithPasteboardName:(NSString*)pasteboardname
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardname create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", pasteboardname]);
		return nil;
	}
	
	NSString *errorStr = nil;
	NSData *dataRep = [pasteboard dataForPasteboardType: AUDIOINFO_PASTEBOARD_TYPE];
	if (!dataRep)
	{
		return nil;
	}
	NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData: dataRep
														  mutabilityOption: NSPropertyListImmutable
																	format: &format
														  errorDescription: &errorStr];	
	return dict;
}

+(NSDictionary*)getPasteInfoForIndex:(int)pasteboardindex
{
	NSString *name = [NSString stringWithFormat:@"%@%d", SWW_AUDIOCOPY_PASTEBOARD_NAME, pasteboardindex];
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:name create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", name]);
		return nil;
	}
	
	NSString *errorStr = nil;
	NSData *dataRep = [pasteboard dataForPasteboardType: AUDIOINFO_PASTEBOARD_TYPE];
	if (!dataRep)
	{
		return nil;
	}
	NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData: dataRep
														  mutabilityOption: NSPropertyListImmutable
																	format: &format
														  errorDescription: &errorStr];	
	return dict;
}

+(NSData*)getDataForIndexWithPasteboardName:(int)pasteindex pasteboardname:(NSString*)pasteboardname
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardname create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", pasteboardname]);
		return nil;
	}
	NSString *pastetype = [NSString stringWithFormat:@"%@%d", RAW16_PASTEBOARD_TYPE, pasteindex];
	NSArray *array = [NSArray arrayWithObject:pastetype];
	NSIndexSet *set = [pasteboard itemSetWithPasteboardTypes:array];
	NSArray *stuffIwant = [pasteboard dataForPasteboardType:pastetype inItemSet:set];
	if ([stuffIwant count] > 0)
	{
		NSData *data = [stuffIwant objectAtIndex:0];
		return data;
	}
	else
	{
		return nil;
	}
}

+(NSData*)getPreviewDataForPasteboardName:(NSString*)pasteboardname
{
	NSDictionary *pasteinfodict = [AudioCopyPaste getPasteInfoWithPasteboardName:pasteboardname];
	if (!pasteinfodict)
		return nil;
	NSData *databuf;
	NSMutableData *rawdata, *previewdata;
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardname create:NO];	
	if(!pasteboard){
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@\n", pasteboardname]);
		return NO;
	}
	int32_t channels = 0;
	// Legacy Pasteboard
	if ([pasteboardname caseInsensitiveCompare:SWW_AUDIOCOPY_PASTEBOARD_NAME] == NSOrderedSame)
	{
		int32_t pastecount = [[pasteinfodict objectForKey:@"pastedcount"] intValue];
		channels = [[pasteinfodict objectForKey:@"channels"] intValue];
		if (pastecount > kPreviewDataMax*channels)
			pastecount = kPreviewDataMax*channels;
		rawdata = [NSMutableData dataWithCapacity:(NSUInteger)kReadBufSize];
		for (int32_t i=0; i<pastecount; i++)
		{
			databuf = [AudioCopyPaste getDataForIndexWithPasteboardName:i pasteboardname:pasteboardname];
			if (!databuf)
				break;
			[rawdata appendData:databuf];
		}
	}
	// History Pasteboard
	else
	{
		NSArray *typeArray = [NSArray arrayWithObject:RAW16_PASTEBOARD_TYPE];
		NSIndexSet *set = [pasteboard itemSetWithPasteboardTypes:typeArray];
		if (!set) {
			return NO;
		}
			
		// Get the subset of RAW16_PASTEBOARD_TYPE elements
		NSArray *pasteItems = [pasteboard dataForPasteboardType:RAW16_PASTEBOARD_TYPE inItemSet:set];		
		if (pasteItems) {
			UInt32 cnt = [pasteItems count];
			if (!cnt) {
				return NO;
			}
		}

		int32_t pastecount = [pasteItems count];
		channels = [[pasteinfodict objectForKey:@"channels"] intValue];
		if (pastecount > kPreviewDataMax*channels)
			pastecount = kPreviewDataMax*channels;
		rawdata = [NSMutableData dataWithCapacity:(NSUInteger)kReadBufSize];
		for (int32_t i=0; i<pastecount; i++)
		{
			databuf = [pasteItems objectAtIndex:i];
			if (!databuf)
				break;
			[rawdata appendData:databuf];
		}
	}
	// make waveheader for data
	wavefileheader header;
	[AudioCopyPaste _createHeader:&header channels:channels dataSize:[rawdata length]];
	previewdata = [NSMutableData dataWithBytes:&header length:sizeof(wavefileheader)];
	[previewdata appendData:rawdata];
	return previewdata;
}

+(NSString*)incrementPasteIndexAndGetPasteboardName
{
	[AudioCopyPaste incrementPasteIndex];
	NSString *name = [NSString stringWithFormat:@"%@%d", SWW_AUDIOCOPY_PASTEBOARD_NAME, [AudioCopyPaste getPasteIndex]];
	return name;
}

+(BOOL)hasGeneralPasteboardData
{
	// Check general pasteboard
	NSArray *typeArray = [NSArray arrayWithObject:(NSString *) kUTTypeAudio];
	UIPasteboard *gp = [UIPasteboard generalPasteboard];
	NSIndexSet *itemSet = [gp itemSetWithPasteboardTypes:typeArray];
	
	if ([gp containsPasteboardTypes:typeArray inItemSet:itemSet])
	{
		return YES;
	}
	else 
	{
		return NO;
	}
}

// Below functions should not be called outside of this class
+(void)incrementPasteIndex
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:SWW_AUDIOCOPY_PASTEBOARD_INDEX_NAME create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", SWW_AUDIOCOPY_PASTEBOARD_NAME]);
		return;
	}

	NSInteger index = [AudioCopyPaste getPasteIndex];
	index = (index+1)%HISTORY_SIZE;
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index], @"currentindex", nil];
	NSString *errorStr = nil;
	NSData *dataRep = [NSPropertyListSerialization dataFromPropertyList: dict
														 format: NSPropertyListXMLFormat_v1_0
														errorDescription: &errorStr];
														
	if (!dataRep) {
		[errorStr release];
	}
	
	[pasteboard setData:dataRep forPasteboardType: INDEX_PASTEBOARD_TYPE];	
}


+(void)clearVersion1Pasteboard
{
	UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:SWW_AUDIOCOPY_PASTEBOARD_NAME create:YES];
	if(!pasteboard)
	{
		NSLog(@"%@", [NSString stringWithFormat: @"No pasteboard with name %@", SWW_AUDIOCOPY_PASTEBOARD_NAME]);
		return;
	}

	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"cleared", nil];
	NSString *errorStr = nil;
	NSData *dataRep = [NSPropertyListSerialization dataFromPropertyList: dict
														 format: NSPropertyListXMLFormat_v1_0
														errorDescription: &errorStr];
	if (!dataRep) {
		[errorStr release];
	}
	
	[pasteboard setData:dataRep forPasteboardType: PASTEBOARD_CLEAR_TYPE];
}

@end