//
//  SurfaceView.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/14/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "KeysView.h"
#import "Instrument.h"
#import "UIConstants.h"
#import "HexaphoneAppDelegate.h"
#import "NotesManager.h"
#import "Note.h"


@implementation KeysView

@synthesize instrument;
@synthesize showKeyLabels;

#define kLabelPosY 105

- (id)initWithImage:(UIImage*)initImage andInstrument:(Instrument*) initInstrument
{
	[super initWithImage:initImage];
	self.instrument = initInstrument;
	self.instrument.touchView = self; // so instrument can resolve x/y
	self.userInteractionEnabled = YES;
	self.multipleTouchEnabled = YES;
	showKeyLabels = YES;

	appDelegate = (HexaphoneAppDelegate*) [[UIApplication sharedApplication] delegate];
	
	arrBigLabels = [[NSMutableArray alloc] init];
	arrSmallLabels = [[NSMutableArray alloc] init];
	
	//for(int x = kXBufferLeft; x < 1281; x += 
	NSArray* arrNotes = appDelegate.notesManager.notes;
	NSMutableDictionary* mapNotesByNoteLetter = [[NSMutableDictionary alloc] init];
	for(Note* note in arrNotes) [mapNotesByNoteLetter setObject:note forKey:note.noteLetter];
	

	for(UInt8 checkedBit = 0; checkedBit < 31; checkedBit++) {
		
		NSString* noteId = (NSString*) [instrument.scale.arrNoteIds objectAtIndex:checkedBit];
	
		Note* note = [mapNotesByNoteLetter objectForKey:[NSString stringWithFormat:@"%c",[noteId characterAtIndex:0]]];
		
		float bigLabelY;
		float smallLabelY;
		if(checkedBit % 2 == 0) { // even, lower 
//			bigLabelY = 115 + UI_KEYS_NOTELABELPADDING;
//			smallLabelY = bigLabelY + UI_KEYS_NOTELABELBIG_HEIGHT;
			bigLabelY = UI_KEYS_NOTELABELLOWER_OFFSET + UI_KEYS_NOTELABELPADDING;
			smallLabelY = bigLabelY + UI_KEYS_NOTELABELSMALL_YOFFSETBOT;
		} else { // odd, upper
//			bigLabelY = 10 + UI_KEYS_NOTELABELPADDING;
//			smallLabelY = bigLabelY + UI_KEYS_NOTELABELBIG_HEIGHT;
			bigLabelY = UI_KEYS_NOTELABELUPPER_OFFSET + UI_KEYS_NOTELABELPADDING;
			smallLabelY = bigLabelY + UI_KEYS_NOTELABELSMALL_YOFFSETTOP;
		}
		
		
		UILabel* bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(UI_KEYS_NOTELABELBUFFERLEFT + checkedBit*40.0, bigLabelY, UI_KEYS_NOTELABELBIG_WIDTH, UI_KEYS_NOTELABELBIG_HEIGHT)];
		bigLabel.backgroundColor = [UIColor clearColor];
		bigLabel.text = note.noteTitle;
		bigLabel.textColor = [UIColor whiteColor];
		bigLabel.textAlignment = UITextAlignmentCenter;
		
//		bigLabel.shadowColor = [UIColor blackColor];
//		bigLabel.shadowOffset = CGSizeMake(0,1);
		
		bigLabel.text = @"X";
		bigLabel.font = [UIFont fontWithName:UI_KEYS_NOTELABELBIG_FONT_NAME size:UI_KEYS_NOTELABELBIG_FONT_SIZE];
		bigLabel.alpha = UI_KEYS_NOTELABELBIG_OPACITY;
		[arrBigLabels addObject:bigLabel];

		[self addSubview:bigLabel];
		
		UILabel* smallLabel = [[UILabel alloc] initWithFrame:CGRectMake(UI_KEYS_NOTELABELSMALL_XOFFSET+UI_KEYS_NOTELABELBUFFERLEFT + checkedBit*40.0, smallLabelY, UI_KEYS_NOTELABELSMALL_WIDTH, UI_KEYS_NOTELABELSMALL_HEIGHT)];
		smallLabel.backgroundColor = [UIColor clearColor];
		smallLabel.textColor = [UIColor whiteColor];
		smallLabel.textAlignment = UITextAlignmentCenter;
		smallLabel.lineBreakMode = UILineBreakModeWordWrap;
		smallLabel.numberOfLines = 0;
//		smallLabel.shadowColor = [UIColor blackColor];
//		smallLabel.shadowOffset = CGSizeMake(0,-0.5);
	
		smallLabel.text = @"default";
		smallLabel.font = [UIFont fontWithName:UI_KEYS_NOTELABELSMALL_FONT_NAME size:UI_KEYS_NOTELABELSMALL_FONT_SIZE];
		smallLabel.alpha = UI_KEYS_NOTELABELSMALL_OPACITY;
		[arrSmallLabels addObject:smallLabel];
	
		[self addSubview:smallLabel];
	}
	
	return self;
}

- (void)updateLabels {

	
	NSArray* arrNotes = appDelegate.notesManager.notes;
	NSMutableDictionary* mapNotesByNoteLetter = [[NSMutableDictionary alloc] init];
	for(Note* note in arrNotes) [mapNotesByNoteLetter setObject:note forKey:note.noteLetter];
	
	for(UInt8 checkedBit = 0; checkedBit < 31; checkedBit++) {
		
		UILabel* bigLabel = [arrBigLabels objectAtIndex:checkedBit];
		UILabel* smallLabel = [arrSmallLabels objectAtIndex:checkedBit];

		if(!showKeyLabels) {
			bigLabel.hidden = YES;
			smallLabel.hidden = YES;
		} else {
			bigLabel.hidden = NO;
			smallLabel.hidden = NO;
			
			NSString* noteId = (NSString*) [instrument.scale.arrNoteIds objectAtIndex:checkedBit];

			Note* note;
			BOOL noteIsFlat = [noteId characterAtIndex:1] == 'b';
			
			if(noteIsFlat) {
				note = [mapNotesByNoteLetter objectForKey:[NSString stringWithFormat:@"%cb",[noteId characterAtIndex:0]]];
			} else {
				note = [mapNotesByNoteLetter objectForKey:[NSString stringWithFormat:@"%c",[noteId characterAtIndex:0]]];
			}
			
			bigLabel.text = note.noteTitle;
			smallLabel.text = note.noteSubTitle;
			
			if([note.noteTitle isEqualToString:@"1"]) {
				bigLabel.alpha = 0.9;
				bigLabel.textColor = UIColorFromRGB(0xFF10315E);
				//bigLabel.shadowColor = UIColorFromRGB(0xFF000000);
				
				smallLabel.alpha = 0.8;
				smallLabel.textColor = UIColorFromRGB(0xFF10315E);
			}
		}
	}
}

- (void)dealloc {
	[arrBigLabels release];
	[arrSmallLabels release];
    [super dealloc];
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"SurfaceView: touchesBegan() BEGIN");

//	for (UITouch *touch in touches) {
//		CGPoint locationInView = [touch locationInView:self];
//		NSLog(@"Instrument: playTouches: touchPoint(%.02f,%.02f) %@", locationInView.x, locationInView.y, touch.phase == UITouchPhaseBegan ? @"BEGAN" : touch.phase == UITouchPhaseMoved ? @"MOVED" : @"STATIONARY");
//	}

	
	[self.instrument playTouches:[event allTouches]];
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ 
//    NSLog(@"SurfaceView: touchesMoved() BEGIN");
	[self.instrument playTouches:[event allTouches]];
}

// Handles the end of a touch event.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"SurfaceView: touchesEnded() BEGIN");
	[self.instrument playTouches:[event allTouches]];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"SurfaceView: touchesCancelled() BEGIN");
	[self.instrument playTouches:[event allTouches]];
}





@end
