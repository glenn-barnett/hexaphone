/*
 
 File: GLKeyOverlayView.h
 Abstract: This class wraps the CAEAGLLayer from CoreAnimation into a convenient
 UIView subclass. The view content is basically an EAGL surface you render your
 OpenGL scene into.  Note that setting the view non-opaque will only work if the
 EAGL surface has an alpha channel.
 */

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
@class Instrument;

@interface GLVectorOverlayView : UIView
{
@private
	
	BOOL isRendering;
	
	/* The pixel dimensions of the backbuffer */
	GLint backingWidth;
	GLint backingHeight;
	
	BOOL viewNeedsUpdate;

	SInt16 offsetX;
	
	EAGLContext* context;
	
	Instrument* instrument;
	
	/* OpenGL names for the renderbuffer and framebuffers used to render to this view */
	GLuint viewRenderbuffer, viewFramebuffer;
	
	/* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
	GLuint depthRenderbuffer;
	
	/* OpenGL name for the sprite texture */
	GLuint spriteTexture;
	
	NSTimer* animationTimer;
	NSTimeInterval animationInterval;
}

- (id)initWithFrame:(CGRect)frame instrument:(Instrument*) instrumentArg;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;
- (void)viewNeedsUpdate;

@property SInt16 offsetX;
@property (nonatomic) NSTimeInterval animationInterval;

@end
