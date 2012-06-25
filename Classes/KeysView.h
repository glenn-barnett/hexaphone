//
//  SurfaceView.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/14/09.
//  Copyright 2009 Impresario Digital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HexaphoneAppDelegate;
@class Instrument;


@interface KeysView : UIImageView <UIScrollViewDelegate> {
	HexaphoneAppDelegate* appDelegate;
	Instrument *instrument; // bidirectional - so view can signal events back to the instrument
	
	BOOL showKeyLabels;
	
	NSMutableArray* arrBigLabels;
	NSMutableArray* arrSmallLabels;

}


@property(nonatomic, retain) Instrument *instrument;
@property(nonatomic) BOOL showKeyLabels;


- (id)initWithImage:(UIImage*)initImage andInstrument:(Instrument*) initInstrument;
- (void)updateLabels;

@end
