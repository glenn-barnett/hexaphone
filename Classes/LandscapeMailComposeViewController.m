//
//  LandscapeMailComposeViewController.m
//  Hexatone
//
//  Created by Glenn Barnett on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LandscapeMailComposeViewController.h"


@implementation LandscapeMailComposeViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
