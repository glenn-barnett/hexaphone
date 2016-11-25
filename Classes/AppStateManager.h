//
//  PresetManager.h
//  Hexatone
//
//  Created by Glenn Barnett on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppState;

@interface AppStateManager : NSObject {

	AppState* appState;

}

@property (nonatomic, retain) AppState* appState;

-(void) saveToPreferences;

@end
