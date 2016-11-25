//
//  LoopCopy.h
//	MAPI - AudioCopyPaste
//
//  Copyright 2009 Sonoma Wire Works and Retronyms. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LoopCopy : NSThread {
	BOOL didSucceed;
	NSString *mixPath;
	NSString *pasteboard;
	NSDictionary *meta;
}

@property(nonatomic, readonly) BOOL didSucceed;
@property(nonatomic, retain) NSString *mixPath;
@property(nonatomic, retain) NSString *pasteboard;
@property(nonatomic, retain) NSDictionary *meta;

- (void) main;

@end
