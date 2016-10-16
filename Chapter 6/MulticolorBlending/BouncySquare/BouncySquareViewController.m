//
//  BouncySquareViewController.m
//  BouncySquare
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BouncySquareViewController.h"

@interface BouncySquareViewController () 
{


}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end


@implementation BouncySquareViewController

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
    [EAGLContext setCurrentContext:self.context];

    [self setClipping];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static const GLfloat squareVertices[] = 		//1
    {
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        -0.5,  0.5, 0.0,
        0.5,  0.5, 0.0
    };
	
    static const GLfloat squareColorsYMCA[] = 
    {
        1.0, 1.0,     0, 1.0,
        0,  1.0, 1.0, 1.0,
        0,     0,     0, 1.0,
        1.0,    0,  1.0, 1.0,
    };
    
    static const GLfloat squareColorsRGBA[] = 
    {
        1.0,    0,     0, 1.0,
        0, 1.0,     0, 1.0,
        0,     0, 1.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
    };
    
    static float transY = 0.0;
    
    glClearColor(0.0, 0.0, 0.0, 1.0);			//2
	
	glClear(GL_COLOR_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
	//Do square one bouncing up and down.
	
    glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), -4.0);	//3
	
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glEnableClientState(GL_COLOR_ARRAY);

	////The Complementary colors
	
	//SQUARE 1
	
    glColorPointer(4, GL_FLOAT, 0, squareColorsYMCA);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	//SQUARE 2
    
    glColorPointer(4, GL_FLOAT, 0, squareColorsRGBA);
    
	glLoadIdentity();
	glTranslatef( (GLfloat)(sinf(transY)/2.0),0.0, -3.0);	//6
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);		//7
	
	transY += 0.075;					//8
}


-(void)setClipping
{
	float aspectRatio;						
	const float zNear = .01;
	const float zFar = 100;
	const float fieldOfView =30.0;
	GLfloat	size;
	
	CGRect frame = [[UIScreen mainScreen] bounds];		
	
	//h/w clamps the fov to the height; flipping it would make it relative to the width.
	
	aspectRatio=(float)frame.size.height/(float)frame.size.width;
	
	//Set the OpenGL projection matrix.
	
	glMatrixMode(GL_PROJECTION);
	
	size = zNear * tanf((fieldOfView/57.3)/ 2.0);
	
	glFrustumf(-size, size, -size *aspectRatio,	 	
			   size *aspectRatio, zNear, zFar);
	
	glViewport(0, 0, frame.size.width, frame.size.height);	
	
	//Make the OpenGL modelview matrix the default.
	
	glMatrixMode(GL_MODELVIEW);
}

@end
