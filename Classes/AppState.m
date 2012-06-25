//
//  Preset.m
//  Hexatone
//
//  Created by Glenn Barnett on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppState.h"
#import "UIDevice+machine.h"

@implementation AppState

@synthesize startupCount;
@synthesize patchId;
@synthesize scaleId;
@synthesize tuningId;
@synthesize kbOffset;
@synthesize loopId;

@synthesize uuid;

@synthesize recentPatchId1;
@synthesize recentPatchId2;
@synthesize recentPatchId3;

@synthesize recentScaleId1;
@synthesize recentScaleId2;
@synthesize recentScaleId3;

@synthesize recentLoopId1;
@synthesize recentLoopId2;
@synthesize recentLoopId3;

@synthesize rotateView;
@synthesize showKeyLabels;
@synthesize showKeyIllum;
@synthesize sliderFilterRez;
@synthesize sliderKeyVol;
@synthesize sliderLoopVol;
@synthesize sliderTouchSize;


+(id) fromDictionary:(NSDictionary*) dict {
//	NSLog(@"AppState +fromDictionary: %@", dict);
	AppState* o = [[AppState alloc] init];
	
	o.startupCount = [dict objectForKey:@"startupCount"];
	if(o.startupCount == nil) {
		o.startupCount = [NSDecimalNumber zero];
	}
	
	o.patchId = [dict objectForKey:@"patchId"];
	o.scaleId = [dict objectForKey:@"scaleId"];
	o.tuningId = [dict objectForKey:@"tuningId"];
	o.kbOffset = [dict objectForKey:@"kbOffset"];
	o.loopId = [dict objectForKey:@"loopId"];
	o.uuid = [dict objectForKey:@"uuid"];
	
	o.recentPatchId1 = [dict objectForKey:@"recentPatchId1"];
	o.recentPatchId2 = [dict objectForKey:@"recentPatchId2"];
	o.recentPatchId3 = [dict objectForKey:@"recentPatchId3"];

	o.recentScaleId1 = [dict objectForKey:@"recentScaleId1"];
	o.recentScaleId2 = [dict objectForKey:@"recentScaleId2"];
	o.recentScaleId3 = [dict objectForKey:@"recentScaleId3"];

	o.recentLoopId1 = [dict objectForKey:@"recentLoopId1"];
	o.recentLoopId2 = [dict objectForKey:@"recentLoopId2"];
	o.recentLoopId3 = [dict objectForKey:@"recentLoopId3"];

	NSString* rotateViewStr = [dict objectForKey:@"rotateView"];
	if(rotateViewStr == nil) {
		NSString* machine = [[UIDevice currentDevice] machine];
		if(machine != nil &&
		   ([machine isEqualToString:@"iPod1,1"] || 
			[machine isEqualToString:@"iPod1,2"] ||
			[machine isEqualToString:@"iPhone1,1"] ||
			[machine isEqualToString:@"iPhone1,2"])) {
			o.rotateView = YES;
	   } else {
		    o.rotateView = NO;
	   }
	} else {
		if([rotateViewStr isEqualToString:@"YES"]) {
			o.rotateView = YES;
		} else {
			o.rotateView = NO;
		}
	}
	
	NSString* showKeyLabelsStr = [dict objectForKey:@"showKeyLabels"];
	if(showKeyLabelsStr == nil || [showKeyLabelsStr isEqualToString:@"YES"]) {
		o.showKeyLabels = YES;
	} else {
		o.showKeyLabels = NO;
	}

	NSString* showKeyIllumStr = [dict objectForKey:@"showKeyIllum"];
	if(showKeyIllumStr == nil || [showKeyIllumStr isEqualToString:@"YES"]) {
		o.showKeyIllum = YES;
	} else {
		o.showKeyIllum = NO;
	}
	
	o.sliderFilterRez = [dict objectForKey:@"sliderFilterRez"];
	if(o.sliderFilterRez == nil) {
		o.sliderFilterRez = [NSNumber numberWithFloat:0.0f];
	}

	o.sliderKeyVol = [dict objectForKey:@"sliderKeyVol"];
	if(o.sliderKeyVol == nil) {
		o.sliderKeyVol = [NSNumber numberWithFloat:0.35f];
	}

	o.sliderLoopVol = [dict objectForKey:@"sliderLoopVol"];
	if(o.sliderLoopVol == nil) {
		o.sliderLoopVol = [NSNumber numberWithFloat:0.5f];
	}

	o.sliderTouchSize = [dict objectForKey:@"sliderTouchSize"];
	if(o.sliderTouchSize == nil) {
		o.sliderTouchSize = [NSNumber numberWithFloat:0.35f];
	}
	
	return o;
}


-(NSDictionary*) toDictionary {
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject:startupCount forKey:@"startupCount"];
	[dict setObject:patchId forKey:@"patchId"];
	[dict setObject:scaleId forKey:@"scaleId"];
	[dict setObject:tuningId forKey:@"tuningId"];
	[dict setObject:kbOffset forKey:@"kbOffset"];
	[dict setObject:loopId forKey:@"loopId"];
	[dict setObject:uuid forKey:@"uuid"];

	if(recentPatchId1 != nil) [dict setObject:recentPatchId1 forKey:@"recentPatchId1"];
	if(recentPatchId2 != nil) [dict setObject:recentPatchId2 forKey:@"recentPatchId2"];
	if(recentPatchId3 != nil) [dict setObject:recentPatchId3 forKey:@"recentPatchId3"];

	if(recentScaleId1 != nil) [dict setObject:recentScaleId1 forKey:@"recentScaleId1"];
	if(recentScaleId2 != nil) [dict setObject:recentScaleId2 forKey:@"recentScaleId2"];
	if(recentScaleId3 != nil) [dict setObject:recentScaleId3 forKey:@"recentScaleId3"];
	
	if(recentLoopId1 != nil) [dict setObject:recentLoopId1 forKey:@"recentLoopId1"];
	if(recentLoopId2 != nil) [dict setObject:recentLoopId2 forKey:@"recentLoopId2"];
	if(recentLoopId3 != nil) [dict setObject:recentLoopId3 forKey:@"recentLoopId3"];
	
	if(rotateView) {
		[dict setObject:@"YES" forKey:@"rotateView"];
	} else {
		[dict setObject:@"NO" forKey:@"rotateView"];
	}

	if(showKeyLabels) {
		[dict setObject:@"YES" forKey:@"showKeyLabels"];
	} else {
		[dict setObject:@"NO" forKey:@"showKeyLabels"];
	}

	if(showKeyIllum) {
		[dict setObject:@"YES" forKey:@"showKeyIllum"];
	} else {
		[dict setObject:@"NO" forKey:@"showKeyIllum"];
	}
	
	[dict setObject:sliderFilterRez forKey:@"sliderFilterRez"];
	[dict setObject:sliderKeyVol forKey:@"sliderKeyVol"];
	[dict setObject:sliderLoopVol forKey:@"sliderLoopVol"];
	[dict setObject:sliderTouchSize forKey:@"sliderTouchSize"];
	
	
//	[dict removeObjectForKey:@"recentPatchId1"];
//	[dict removeObjectForKey:@"recentPatchId2"];
//	[dict removeObjectForKey:@"recentPatchId3"];
	
//	NSLog(@"AppState -toDictionary: %@", dict);
	return [dict autorelease];
}

-(void) changePatchId:(NSString*) patchIdArg {
	
	if(![patchId isEqualToString:patchIdArg]) {
		//		NSLog(@"changePatchId: %@ -> %@", patchId, patchIdArg);
		
		if([patchIdArg isEqualToString:recentPatchId1]) {
			recentPatchId1 = patchId;
			patchId = patchIdArg;
			return;
		}
		
		if([patchIdArg isEqualToString:recentPatchId2]) {
			recentPatchId2 = recentPatchId1;
			recentPatchId1 = patchId;
			patchId = patchIdArg;
			return;
		}
		
		// else
		recentPatchId3 = recentPatchId2;
		recentPatchId2 = recentPatchId1;
		recentPatchId1 = patchId;
		patchId = patchIdArg;
		return;
		
	}
}
-(BOOL) hasAnyRecentPatches {
	BOOL result = !(recentPatchId1 == nil && recentPatchId2 == nil && recentPatchId3 == nil);
	return result;
}

-(void) changeScaleId:(NSString*) scaleIdArg {
	
	if(![scaleId isEqualToString:scaleIdArg]) {
		//		NSLog(@"changeScaleId: %@ -> %@", scaleId, scaleIdArg);
		
		if([scaleIdArg isEqualToString:recentScaleId1]) {
			recentScaleId1 = scaleId;
			scaleId = scaleIdArg;
			return;
		}
		
		if([scaleIdArg isEqualToString:recentScaleId2]) {
			recentScaleId2 = recentScaleId1;
			recentScaleId1 = scaleId;
			scaleId = scaleIdArg;
			return;
		}
		
		// else
		recentScaleId3 = recentScaleId2;
		recentScaleId2 = recentScaleId1;
		recentScaleId1 = scaleId;
		scaleId = scaleIdArg;
		return;
		
	}
}
-(BOOL) hasAnyRecentScales {
	BOOL result = !(recentScaleId1 == nil && recentScaleId2 == nil && recentScaleId3 == nil);
	return result;
}


-(void) changeLoopId:(NSString*) loopIdArg {
	
	if(![loopId isEqualToString:loopIdArg]) {
		//		NSLog(@"changeLoopId: %@ -> %@", loopId, loopIdArg);
		
		if([loopIdArg isEqualToString:recentLoopId1]) {
			recentLoopId1 = loopId;
			loopId = loopIdArg;
			return;
		}
		
		if([loopIdArg isEqualToString:recentLoopId2]) {
			recentLoopId2 = recentLoopId1;
			recentLoopId1 = loopId;
			loopId = loopIdArg;
			return;
		}
		
		// else
		recentLoopId3 = recentLoopId2;
		recentLoopId2 = recentLoopId1;
		recentLoopId1 = loopId;
		loopId = loopIdArg;
		return;
		
	}
}
-(BOOL) hasAnyRecentLoops {
	BOOL result = !(recentLoopId1 == nil && recentLoopId2 == nil && recentLoopId3 == nil);
	return result;
}

-(void) dealloc {
	
	[patchId release];
	[scaleId release];
	[tuningId release];
	[kbOffset release];
	[loopId release];
	
	[recentPatchId1 release];
	[recentPatchId2 release];
	[recentPatchId3 release];
	
	[recentScaleId1 release];
	[recentScaleId2 release];
	[recentScaleId3 release];
	
	[recentLoopId1 release];
	[recentLoopId2 release];
	[recentLoopId3 release];
	
	[super dealloc];
}

@end
