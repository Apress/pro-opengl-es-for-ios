//
//  OpenGLSolarSystemViewController.m
//  BouncySquare
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SolarSystem.h"
#import "OpenGLSolarSystemViewController.h"

@interface OpenGLSolarSystemViewController () 
{


}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end


@implementation OpenGLSolarSystemViewController

@synthesize context = _context;
@synthesize effect = _effect;

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
    
    m_SolarSystem=[[SolarSystemController alloc] init];	
    
    [EAGLContext setCurrentContext:self.context];
    
    [self setClipping];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor(0.0f,0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	    
	[m_SolarSystem execute];
}


-(void)setClipping
{
	float aspectRatio;
	const float zNear = .1;					
	const float zFar = 1000;					
	const float fieldOfView = 50.0;			
	GLfloat	size;
	
	CGRect frame = [[UIScreen mainScreen] bounds];		
    
	aspectRatio=(float)frame.size.width/(float)frame.size.height;					
	
	glMatrixMode(GL_PROJECTION);				
	glLoadIdentity();
    
	size = zNear * tanf(GLKMathDegreesToRadians (fieldOfView) / 2.0);	
    
	glFrustumf(-size, size, -size /aspectRatio, size /aspectRatio, zNear, zFar);	
	glViewport(0, 0, frame.size.width, frame.size.height);		
	
	glMatrixMode(GL_MODELVIEW);				
}


@end
