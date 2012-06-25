//
//  NoteManager.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface NotesManager : UIView {

	// GSB: could be a single instance or an array
	NSMutableArray* notes;
	
}

@property (nonatomic,retain) NSMutableArray* notes;
-(id) initFromJsonFile:(NSString*) jsonFile;

@end
