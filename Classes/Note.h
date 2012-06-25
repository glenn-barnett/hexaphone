//
//  Note.h
//  Hexatone
//
//  Created by Glenn Barnett on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//{
//	"noteLetter" : "C",
//	"noteTitle": "R",
//	"noteSubTitle": "-root-"
//},

@interface Note : UIView {

	NSString* noteLetter;
	NSString* noteTitle;
	NSString* noteSubTitle;
}

@property(retain,nonatomic) NSString* noteLetter;
@property(retain,nonatomic) NSString* noteTitle;
@property(retain,nonatomic) NSString* noteSubTitle;

+(id) fromDictionary:(NSDictionary*) otherDictionary; //GSB: static initializer
-(NSDictionary*) toDictionary;

@end
