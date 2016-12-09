//
//  OpenGL_ReflectionViewController.m
//  OpenGL_Reflection
//
//  Created by mike on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OpenGL_ReflectionViewController.h"
#import "EAGLView.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

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

@interface OpenGL_ReflectionViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (weak, nonatomic) CADisplayLink *displayLink;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationWillTerminate:(NSNotification *)notification;
@end

@implementation OpenGL_ReflectionViewController

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
    view.drawableStencilFormat=GLKViewDrawableStencilFormat8;
    
    [EAGLContext setCurrentContext:self.context];       
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateActive:) name:UIApplicationWillTerminateNotification object:nil];
        
    [self setClipping];
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
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

/****************************************************************************************
 * setClipping :																		*
 ****************************************************************************************/
-(void)setClipping
{
	float aspectRatio;
	const float zNear =.1;
	const float zFar =1000;
	const float fieldOfView = 45;
	GLfloat	size;
	
	glEnable(GL_NORMALIZE);
    
	CGRect frame = [[UIScreen mainScreen] bounds];
	
	aspectRatio=(float)frame.size.width/(float)frame.size.height;				//h/w clamps the fov to the height, flipping it would make it relative to the width
	
	//Set the OpenGL projection matrix
	
	glMatrixMode(GL_PROJECTION);
	
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	glFrustumf(-size, size, -size /aspectRatio, size /aspectRatio, zNear, zFar);
	glViewport(0, 0, frame.size.width, frame.size.height);
	
	//Make the OpenGL modelview matrix the default
	
	glMatrixMode(GL_MODELVIEW);
}

- (void)startAnimation
{

}

- (void)stopAnimation
{

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	static GLfloat z=-3.0;
	static GLfloat spinX=0;
	static GLfloat spinY=0;
	   
    // Replace the implementation of this method to do your own custom drawing.
	
	static const GLfloat cubeVertices[] = {
		-0.5f, 0.5f, 0.5f,
        0.5f, 0.5f, 0.5f,
        0.5f,-0.5f, 0.5f,
		-0.5f,-0.5f, 0.5f,
		
		
		-0.5f, 0.5f,-0.5f,
        0.5f, 0.5f,-0.5f,
        0.5f,-0.5f,-0.5f,
		-0.5f,-0.5f,-0.5f,	
	};

    static const GLfloat normalData[] = {
		0.0, 0.0, 1.0,
        0.0, 0.0, 1.0,

        1.0, 0.0, 0.0,
		1.0, 0.0, 0.0,

        
        0.0, 1.0, 0.0,
		0.0, 1.0, 0.0,

		0.0, 0.0, -1.0,
        0.0, 0.0, -1.0,	
        
        0.0, -1.0, 0.0,
		0.0, -1.0, 0.0,
        
        -1.0, 0.0, 0.0,
		-1.0, 0.0, 0.0,
        
	};
    
	static const GLubyte cubeColors[] = {
        255, 0,   0, 255,
        0,   255, 0, 255,
        0,     0,   0,   0,
        0,   0, 255, 255,
		
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
	
	static const GLubyte tfan1[6 * 3] =
	{
		1,0,3,
		1,3,2,
		1,2,6,
		1,6,5,
		1,5,4,
		1,4,0
	};
    
	static const GLubyte tfan2[6 * 3] =
	{
		7,4,5,
		7,5,6,
		7,6,2,
		7,2,3,
		7,3,0,
		7,0,4
	};

    static float transY = 0.0f;
    
    glClearColor(0.7f, 0.5f, 0.7f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    //render to the stencil first
    
    [self renderToStencil];
    	
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);

    
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    glPushMatrix();

    glEnable(GL_STENCIL_TEST);
    glDisable(GL_DEPTH_TEST);
    
	glVertexPointer(3, GL_FLOAT, 0, cubeVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors);
	glEnableClientState(GL_COLOR_ARRAY);
    
    glNormalPointer(GL_FLOAT, 0, normalData);	
    glEnableClientState(GL_NORMAL_ARRAY);
    
    //flip the image

    glTranslatef(0.0f,((GLfloat)(sinf(-transY)/2.0f)-1.5),z);	
    glRotatef(spinY, 0.0, 1.0, 0.0);

    glScalef(1.0f, -1.0f, 1.0f);
    glFrontFace(GL_CW);

    glEnable(GL_BLEND); 
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR); 
    
	glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
	glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
	
    glDisable(GL_BLEND); 

    glPopMatrix();
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_STENCIL_TEST);

    //do the main image

    glPushMatrix();
    glScalef(1.0f, 1.0f, 1.0f);
    glFrontFace(GL_CCW);
    
    glTranslatef(0.0f, (GLfloat)1.5*(sinf(transY)/2.0f)+0.5,z);
    
    glRotatef(spinY, 0.0, 1.0, 0.0);
    
	glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
	glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
    
    glPopMatrix();
    
    //	z+=.005;
	spinY+=.25;
	spinX+=.25;
    
    transY += 0.075f;
}

-(void)renderToStencil
{	
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS,1, 0xffffffff);
    glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);

    [self renderStage];
        
    glStencilFunc(GL_EQUAL, 1, 0xFFFFFFFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
}

-(void)renderStage
{
    static const GLfloat flatSquareVertices[] = 		
    {
        -0.5f,  0.0f, -0.5f,
         0.5f,  0.0f, -0.5f,
        -0.5f,  0.0f,   0.5f,
         0.5f,  0.0f,   0.5f
    };

    static const GLubyte colors[] = 
    {
        255, 0,   0, 128,
        255,   0,   0, 255,
        0,   0,   0, 0,
        128,   0,   0, 128
    };
    
    glFrontFace(GL_CW);
	glPushMatrix();
	glTranslatef(0.0,-1.0,-3.0);	
    glScalef(2.5,1.5,2.0);
    
    glVertexPointer(3, GL_FLOAT, 0, flatSquareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
//    glDisableClientState(GL_COLOR_ARRAY);

   glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
//    glEnableClientState(GL_COLOR_ARRAY);
    
    glDepthMask(GL_FALSE);
    glColorMask(GL_TRUE, GL_TRUE, GL_FALSE, GL_TRUE);
    glDrawArrays( GL_TRIANGLE_STRIP,0, 4);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_TRUE);
    
    glPopMatrix();
}

-(void)initLighting
{
	GLfloat posFill1[]={-8.0,5.0,0.0,1.0};			
	GLfloat posFill2[]={-10.0,-7.0,1.0,1.0};			
    
	GLfloat white[]={1.0,1.0,1.0,1.0};
	GLfloat dimblue[]={0.0,0.0,.2,1.0};			
    
	GLfloat cyan[]={0.0,1.0,1.0,1.0};			
	GLfloat yellow[]={1.0,1.0,0.0,1.0};
	GLfloat magenta[]={1.0,0.0,1.0,1.0};			
	
	
	//lights go here
	
	glLightfv(SS_SUNLIGHT,GL_DIFFUSE,white);
	glLightfv(SS_SUNLIGHT,GL_SPECULAR,yellow);		
	
	glLightfv(SS_FILLLIGHT1,GL_POSITION,posFill1);
	glLightfv(SS_FILLLIGHT1,GL_DIFFUSE,cyan);
	glLightfv(SS_FILLLIGHT1,GL_SPECULAR,yellow);	
    
	glLightfv(SS_FILLLIGHT2,GL_POSITION,posFill2);
	glLightfv(SS_FILLLIGHT2,GL_SPECULAR,magenta);
	glLightfv(SS_FILLLIGHT2,GL_DIFFUSE,dimblue);
    
	//materials go here
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, cyan);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, white);
    
	glLightf(SS_SUNLIGHT,GL_QUADRATIC_ATTENUATION,.001);
	
	glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,25);				
    
	glShadeModel(GL_SMOOTH);				
	glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
	
	glEnable(GL_LIGHTING);
	glEnable(SS_SUNLIGHT);
	glEnable(SS_FILLLIGHT1);
	glEnable(SS_FILLLIGHT2);
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return NO;
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return NO;
    
    return YES;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // Release vertex and fragment shaders.
    if (vertShader)
    {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}
/*  cache
-(void)renderToStencil
{
    static const GLfloat flatSquareVertices[] = 		
    {
        -0.5f, -0.15f, 0.0f,
        0.5f, -0.15f, 0.0f,
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f
    };
    
    
    static const GLfloat squareVertices[] = 		
    {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        -0.5f,  0.5f, 0.0f,
        0.5f,  0.5f, 0.0f
    };
    
    
    static const GLubyte colors[] = 
    {
        255, 255,   0, 255,
        0,   0, 0, 255,
        0,   255,   0,   255,
        255,   255, 255, 255
    };
    
	glPushMatrix();
	glTranslatef(0.0,-1.0,-1.0);	
	
    //    glFrontFace(GL_CW);
    glEnable(GL_STENCIL_TEST);
    glStencilOp(GL_REPLACE, GL_REPLACE, GL_REPLACE);
    glStencilFunc(GL_ALWAYS,1, 0xffffffff);
    
    glVertexPointer(3, GL_FLOAT, 0, flatSquareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDepthMask(GL_FALSE);
    glColorMask(GL_TRUE, GL_FALSE, GL_FALSE, GL_FALSE);
    glDrawArrays( GL_TRIANGLE_STRIP,0, 4);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask(GL_TRUE);
    
    glStencilFunc(GL_EQUAL, 1, 0xFFFFFFFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    glPopMatrix();
}

*/
@end
