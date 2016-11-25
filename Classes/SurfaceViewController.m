//
//  SurfaceViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 1/23/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import "SurfaceViewController.h"
#import "UIConstants.h"

#import "Instrument.h"
#import "KeysView.h"
#import "GLVectorOverlayView.h"


@implementation SurfaceViewController

@synthesize instrument;
@synthesize dragStripView;
@synthesize keysView;

@synthesize keyOverlayView;

@synthesize currentInstrumentSurfaceFrameOriginY;
@synthesize destinationInstrumentSurfaceFrameOriginY;
@synthesize isSurfaceMoving;
@synthesize isSurfaceMovingTooFar;
@synthesize isSurfaceReturningFromEdge;

-(void) updateLabels {
	[keysView updateLabels];
}
- (void)loadView {

	self.isSurfaceMoving = NO;
	self.isSurfaceMovingTooFar = NO;
	self.isSurfaceReturningFromEdge = NO;

//	self.dragStripView = [[DragStripView alloc] init];

	UIImage* scaleImage = [UIImage imageNamed:@"Scale.png"];
	self.keysView = [[KeysView alloc] initWithImage:scaleImage andInstrument:instrument];

//	dragStripView.delegate = keysView;
	self.view = keysView; 
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
