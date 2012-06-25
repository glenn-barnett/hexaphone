/*
 
 File: GLVectorOverlayView.m
 Abstract: This class wraps the CAEAGLLayer from CoreAnimation into a convenient
 UIView subclass. The view content is basically an EAGL surface you render your
 OpenGL scene into.  Note that setting the view non-opaque will only work if the
 EAGL surface has an alpha channel.
 
 Version: 1.7
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "GLVectorOverlayView.h"
#import "Instrument.h"

@interface GLVectorOverlayView (GLVectorOverlayViewPrivate)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@interface GLVectorOverlayView (GLVectorOverlayViewSprite)

- (void)setupView;

@end

@implementation GLVectorOverlayView

@synthesize offsetX;
@synthesize animationInterval;

// You must implement this
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame instrument:(Instrument*) instrumentArg {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		NSLog(@"GLKeyOverlayView: -initWithFrame");
		isRendering = NO;
		
		instrument = instrumentArg;
		viewNeedsUpdate = NO;
		offsetX = 0;
		
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
			[self release];
			return nil;
		}
		
		[self setupView];
		[self drawView];
		
	}
	
	return self;
	
}	


- (void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}


- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	
	// http://discussions.apple.com/thread.jspa?threadID=1837474&tstart=105
	//	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_RGB8_OES, backingWidth, backingHeight);
	
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
//	NSLog(@"GLVectorOverlayView: : -createFramebuffer got (backingWidth: %.02f, backingHeight: %.02f", backingWidth, backingHeight);
//
//	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) == GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES) {
//		NSLog(@"GLVectorOverlayView: -createFramebuffer: got bad FB Status: GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES");
//	}
//	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) == GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_OES) {
//		NSLog(@"GLVectorOverlayView: -createFramebuffer: got bad FB Status: GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_OES");
//	}
//	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) == GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_OES) {
//		NSLog(@"GLVectorOverlayView: -createFramebuffer: got bad FB Status: GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_OES");
//	}
//	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) == GL_FRAMEBUFFER_UNSUPPORTED_OES) {
//		NSLog(@"GLVectorOverlayView: -createFramebuffer: got bad FB Status: GL_FRAMEBUFFER_UNSUPPORTED_OES");
//	}
	
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
//		NSLog(@"GLVectorOverlayView: -createFramebuffer: failed to make complete framebuffer object (%x)", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}


- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}


- (void)startAnimation
{
	isRendering = YES;
	if(animationTimer == nil || ![animationTimer isValid]) {
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];  
	} else {
//		NSLog(@"WARN: GLVectorOverlayView: startAnimation: Animation was already running.  Ignoring start request.");
	}
}


- (void)stopAnimation
{
	isRendering = NO;
	if(animationTimer != nil) {
		[animationTimer invalidate];
		animationTimer = nil;
	}
		
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	// clear the view
	glClear(GL_COLOR_BUFFER_BIT);
	
	// swap the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}



- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval = interval;
	
	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void)setupView
{
//	NSLog(@"GLVectorOverlayView: : -setupView: ENTER (backingWidth: %.02f, backingHeight: %.02f", backingWidth, backingHeight);

	// Sets up matrices and transforms for OpenGL ES
	//glViewport(0.0, 0.0, 1.0, 1.0);
	//glViewport(0, 0, backingWidth, backingHeight);
	//glViewport(0, 0, 2562.0, 410.0);
	//glViewport(0, 0, 32, 5.1209922);

	
	//glOrthof(0, 1281.0, 0, 205.0, 0, 0.1);

	
	glViewport(0, 0, 480.0, 205.0); // works A
	//glViewport(0, 0, 1281.0, 205.0); // works B, squished on device
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0.0, 480.0, 0.0, 205.0, -1.0, 1.0); // works A
	//glOrthof(0.0, 1281.0, 0.0, 205.0, -1.0, 1.0); // works B, squished on device

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	// perf enhancements
	glDisable(GL_DITHER); 
	glDisable(GL_MULTISAMPLE); 
	glDisable(GL_LIGHTING);
	glDisable(GL_FOG);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_NORMALIZE);
	glDisable(GL_TEXTURE);
	glDisable(GL_DITHER);
	glDisable(GL_STENCIL_TEST);
	glDisable(GL_ALPHA_TEST); 
	
	// prepare to draw a vertex array
	glEnableClientState(GL_VERTEX_ARRAY); 

	
}

-(void)viewNeedsUpdate {
	viewNeedsUpdate = YES;
}

// Updates the OpenGL view when the timer fires
- (void)drawView
{
	if(viewNeedsUpdate && isRendering) {
		
		
		//NSLog(@"-drawView: keysArePlaying: %d", instrument.keysArePlaying);
		// Clears the view with a background color
		//glClearColor(0.5f, 0.5f, 0.5f, 0.5f);
		
		// Make sure that you are drawing to the current context
		[EAGLContext setCurrentContext:context];
		
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		
		
		// clear the view
		glClear(GL_COLOR_BUFFER_BIT);
		
		// set the color (white)
		glColor4f(1.0, 1.0, 1.0, 1.0); 

		
		// set up the shape
		//	GLfloat triangle[] = { 
		//		0.0, 0.0,     /* lower left corner */ 
		//		0.0, 0.5,      /* upper left corner */ 
		//		0.5, 0.5};      /* lower right corner */ 
		
		
		for(UInt8 checkedBit = 0; checkedBit < 32; checkedBit++) {
			UInt32 noteIsOn = (instrument.keysArePlaying >> checkedBit) & 1;
			if(noteIsOn == 1) {
//				NSLog(@"GLVectorOverlayView: illuminate key %d", checkedBit);
				
				GLfloat* pentagon;
				
				if(checkedBit % 2 == 1) { // odd - top row
					// bottom left corner
					float x = (checkedBit * 40) - offsetX - 40;
					if(480.0f < x || x < -81.0f) {
						continue;
					}
					float y = 90.0;
					
					GLfloat downwardsPentagon[10] = { 
						x +  1.0,	y + 114.0,
						x +  1.0,	y +  27.0,
						x + 41.0,	y +   0.0,
						x + 81.0,	y +  27.0,
						x + 81.0,	y + 114.0
					};
					
					pentagon = downwardsPentagon;
					
				} else { // even - bottom row
					// bottom left corner
					float x = (checkedBit * 40) - offsetX - 40;
					if(480.0f < x || x < -81.0f) {
						continue;
					}
					float y = 0.0;
					
					GLfloat upwardsPentagon[10] = { 
						x +  1.0,	y +   3.0,
						x +  1.0,	y +  90.0,
						x + 41.0,	y + 117.0,
						x + 81.0,	y +  90.0,
						x + 81.0,	y +   3.0
					};
					
					pentagon = upwardsPentagon;
				}
				
//				NSLog(@"GLVectorOverlayView: drawing pentagon: %.2f,%.2f", pentagon[0], pentagon[1]);
				
				// set the vertex pointer to our shape
				//   2 values per point (x,y)
				//   floats
				//   0 values between points
				//   the array
				glVertexPointer(2, GL_FLOAT, 0, pentagon); 
				
				
				// draw the arrays
				//   mode
				//   start index
				//   how many
				//glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);
				glDrawArrays(GL_TRIANGLE_FAN, 0, 5);
				
			}
		}
		
		//	// bottom left corner
		//	float x = 400.0 - offsetX - 40;
		//	float y = 0.0;
		//
		//	GLfloat upwardsPentagon[] = { 
		//		x +  3.0,	y +   3.0,
		//		x +  3.0,	y +  90.0,
		//		x + 41.0,	y + 116.0,
		//		x + 80.0,	y +  90.0,
		//		x + 80.0,	y +   3.0
		//	};
		
		//	GLfloat upwardsPentagon[] = { 
		//		x +  0.0,	y +   0.0,
		//		x +  0.0,	y + 0.1180,
		//		x + 0.400,	y + 0.1480,
		//		x + 0.800,	y + 0.1180,
		//		x + 0.800,	y +   0.0
		//	};
		
		
		
		// swap the buffer
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
		viewNeedsUpdate = NO;
	}
}
// http://www.iphonedevsdk.com/forum/iphone-sdk-development/7481-draw-top-texture.html

// from: http://discussions.apple.com/thread.jspa?messageID=7367314

//- (void)draw
//{		
//	NSLog(@"-draw");
//	GLfloat triangle[] = { 
//		-0.5, -0.5,
//		-0.5, 0.5,
//		0.5, -0.5};
//	glVertexPointer(2, GL_FLOAT, 0, triangle); 
//	
//	glEnableClientState(GL_VERTEX_ARRAY);
//	glEnableClientState(GL_COLOR_ARRAY);
//	
//	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//	
//	glDisableClientState(GL_VERTEX_ARRAY);
//	glDisableClientState(GL_COLOR_ARRAY);
//}

// Stop animating and release resources when they are no longer needed.
- (void)dealloc
{
	[self stopAnimation];
	
	if([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
