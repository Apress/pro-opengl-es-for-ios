//
//  BouncyCubeViewController.m
//  BouncyCube
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BouncyCubeViewController.h"

@interface BouncyCubeViewController () 
{


}

-(void)setClipping;

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end


@implementation BouncyCubeViewController

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
    static int counter=0;
    
    static const GLfloat cubeVertices[] = 					//1
    {
        -0.5f, 0.5f, 0.5f,						//vertex 0
        0.5f, 0.5f, 0.5f, 						// v1
        0.5f,-0.5f, 0.5f,						// v2
        -0.5f,-0.5f, 0.5f, 						// v3
		
        -0.5f, 0.5f,-0.5f,						// v4
        0.5f, 0.5f,-0.5f,						// v5
        0.5f,-0.5f,-0.5f,						// v6
        -0.5f,-0.5f,-0.5f,						// v7
    };
	
    static const GLubyte cubeColors[] = {					//2
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
		
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
	
    static const GLubyte tfan1[6 * 3] =					//3
    {
        1,0,3,
        1,3,2,
        1,2,6,
        1,6,5,
        1,5,4,
        1,4,0
    };
    
    static const GLubyte tfan2[6 * 3] =					//4
    {
        7,4,5,
        7,5,6,
        7,6,2,
        7,2,3,
        7,3,0,
        7,0,4
    };
        
    static GLfloat transY = 0.0f;
    static GLfloat z=-2.0f;						//1
    static GLfloat spinX=0;
    static GLfloat spinY=0;

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);                                                                                //2
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_CULL_FACE);						//3
    glCullFace(GL_FRONT);
	
    //	glMatrixMode(GL_PROJECTION);				//4
    //	glLoadIdentity();
	
    glMatrixMode(GL_MODELVIEW);					//5
    glLoadIdentity();
	
    //glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);	
    


    glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), z); 	     	                 //6
    glRotatef(spinY, 0.0, 1.0, 0.0);
    glRotatef(spinX, 1.0, 0.0, 0.0);
    

    
    transY += 0.075f;
	
    //glVertexPointer(2, GL_FLOAT, 0, squareVertices);			
    
    glVertexPointer(3, GL_FLOAT, 0, cubeVertices);			//7
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors);			//8
    glEnableClientState(GL_COLOR_ARRAY);
    
    // glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);				
    
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);	//9
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
	
    if(!(counter%100))
        NSLog(@"FPS: %d\n",self.framesPerSecond);
    
    counter++;
    spinY+=.25;
	spinX+=.25;

}

-(void)setClipping
{
	float aspectRatio;
	const float zNear = 1.5;					//1
	const float zFar = 1000.0f;					//2
	const float fieldOfView = 60.0;				//3
	GLfloat	size;
	
	CGRect frame = [[UIScreen mainScreen] bounds];		//4
	
    //height and width values clamp the fov to the height; flipping it would make it relative to the width. So if we
    //want the field-of-view to be 60 degrees, similar to that of a wide angle lens, it will be 
    //based on the height of our window and not the width, Important to know when rendering to a 
    //non-square screen.
    
	aspectRatio=(float)frame.size.width/(float)frame.size.height;	//5				
                                                                    //Set the OpenGL projection matrix
	
	glMatrixMode(GL_PROJECTION);				//6
	glLoadIdentity();
    
	size = zNear * tanf(GLKMathDegreesToRadians (fieldOfView) / 2.0);	//7
    
	glFrustumf(-size, size, -size /aspectRatio, size /aspectRatio, zNear, zFar);	//8
	glViewport(0, 0, frame.size.width, frame.size.height);		//9
	
	//Make the OpenGL ModelView matrix the default.
	
	glMatrixMode(GL_MODELVIEW);				//10
}


@end
