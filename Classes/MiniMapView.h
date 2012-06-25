//
//  MiniMapView.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MiniMapSelectionView;
@class HexaphoneAppDelegate;

@interface MiniMapView : UIView {

	HexaphoneAppDelegate* appDelegate;
	
	MiniMapSelectionView* selectionView;
	
	UIView* rectangle;

}

-(void) positionSelection:(SInt16) offset;


@end
