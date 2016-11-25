//
//  SurfaceViewController.h
//  Hexatone
//
//  Created by Glenn Barnett on 1/23/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Instrument;
@class DragStripView;
@class KeysView;
@class CoreGraphicsKeyOverlayView;
@class GLKeyOverlayView;

@interface SurfaceViewController : UIViewController {

	Instrument *instrument;

	DragStripView *dragStripView;
	KeysView *keysView;
	
	CoreGraphicsKeyOverlayView *keyOverlayView;
	
	float currentInstrumentSurfaceFrameOriginY;
	float destinationInstrumentSurfaceFrameOriginY;
	BOOL isSurfaceMoving;
	BOOL isSurfaceMovingTooFar;
	BOOL isSurfaceReturningFromEdge;
	
}

@property (nonatomic, retain) Instrument *instrument;
@property (nonatomic, retain) DragStripView *dragStripView;
@property (nonatomic, retain) KeysView *keysView;


@property (nonatomic, retain) CoreGraphicsKeyOverlayView *keyOverlayView;

@property float currentInstrumentSurfaceFrameOriginY;
@property float destinationInstrumentSurfaceFrameOriginY;
@property BOOL isSurfaceMoving;
@property BOOL isSurfaceMovingTooFar;
@property BOOL isSurfaceReturningFromEdge;

-(void) updateLabels;


@end
