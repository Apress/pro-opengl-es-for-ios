//
//  OpenGLLensFlareViewController.m
//  OpenGL Lens Flare
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OpenGLCreateTexture.h"
#import "OpenGLLensFlareViewController.h"
#import "EAGLView.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface OpenGLLensFlareViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (weak, nonatomic) CADisplayLink *displayLink;

- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationWillTerminate:(NSNotification *)notification;
@end

@implementation OpenGLLensFlareViewController

@synthesize animating;
@synthesize context;
@synthesize displayLink;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) 
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
        
      
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateActive:) name:UIApplicationWillTerminateNotification object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMove:) name:UIApplicationWillTerminateNotification object:nil];

    
    m_LensFlare=[[LensFlare alloc]init];

    [[OpenGLCreateTexture getObject]createTexture:@"gimp_sun3.png" imageID:&m_FlareSource mipmapID:0];
    
    [self setClipping];
    

    
    //   [self drawFrame];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if ([self isViewLoaded] && self.view.window) {
        [self stopAnimation];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ([self isViewLoaded] && self.view.window) {
        [self startAnimation];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    if ([self isViewLoaded] && self.view.window) {
        [self stopAnimation];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) 
    {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{

}

- (void)stopAnimation
{

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    GLfloat cx,cy;
    CGPoint centerRelative;
    CGRect frame = [[UIScreen mainScreen] bounds];		
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    cx=(frame.size.width/2.0);
    cy=(frame.size.height/2.0);

    centerRelative=CGPointMake(m_PointerLocation.x-cx,cy-m_PointerLocation.y);
    
    [[OpenGLCreateTexture getObject]renderTextureAt:centerRelative name:m_FlareSource size:3.0 r:1.0 g:1.0 b:1.0 a:1.0];

    [m_LensFlare execute:[[UIScreen mainScreen]applicationFrame] source:m_PointerLocation];
}

-(void)setClipping
{
	float aspectRatio;						
	const float zNear = .01;
	const float zFar = 100;
	const float fieldOfView =30.0;
	GLfloat	size;
	
    
	CGRect frame = [[UIScreen mainScreen] bounds];		
	
	//h/w clamps the fov to the height, flipping it would make it relative to the width
	
	aspectRatio=(float)frame.size.height/(float)frame.size.width;
	
	//Set the OpenGL projection matrix
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    
	size = zNear * tanf((fieldOfView/57.3)/ 2.0);
	
	glFrustumf(-size, size, -size *aspectRatio,	 	
			   size *aspectRatio, zNear, zFar);
	
	glViewport(0, 0, frame.size.width, frame.size.height);	
	
	//Make the OpenGL modelview matrix the default
	
	glMatrixMode(GL_MODELVIEW);
}

- (void)handleMove:(NSNotification *)notification
{

}

/****************************************************************************************
 * touchesBegan :                                                                       *
 ****************************************************************************************/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_IsDragging=YES;
}

/****************************************************************************************
 * touchesMoved :																		*
 ****************************************************************************************/
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
        
	CGPoint location = [touch locationInView:self.view];

    [[NSNotificationCenter defaultCenter]postNotificationName:OGL_NOTIFICATION_DRAG_MOVE object:NULL userInfo:NULL];
    
 //   NSLog(@"Touches Moved x=%f, y=%f\n",location.x,location.y);
    
    m_PointerLocation=CGPointMake(location.x, location.y);
}

/****************************************************************************************
 * touchesEnded :																		*
 ****************************************************************************************/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_IsDragging=NO;
}



@end
