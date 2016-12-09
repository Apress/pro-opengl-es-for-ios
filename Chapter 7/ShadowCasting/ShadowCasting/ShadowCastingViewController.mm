//
//  ShadowCastingViewController.m
//  ShadowCasting
//
//  Created by mike on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ShadowCastingViewController.h"
#import "EAGLView.h"
//#import "ShadowCaster.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)


static const GLfloat m_CubeVertices[] = 
{
    -0.5f, 0.5f, 0.5f,
    0.5f, 0.5f, 0.5f,
    0.5f,-0.5f, 0.5f,
    -0.5f,-0.5f, 0.5f,
    
    
    -0.5f, 0.5f,-0.5f,
    0.5f, 0.5f,-0.5f,
    0.5f,-0.5f,-0.5f,
    -0.5f,-0.5f,-0.5f,	
};

static const GLubyte m_CubeColors[] = {
    255, 255,   0, 255,
    0,   255, 255, 255,
    255, 255,  255, 255,
    255,   0, 255, 255,
    
    255,   0,   0, 255,
    0,   255,   0, 255,
    0,     0, 255, 255,
    255, 255, 255, 255,
};

static const GLubyte m_Tfan1[6 * 3] =
{
    1,0,3,
    1,3,2,
    1,2,6,
    1,6,5,
    1,5,4,
    1,4,0
};


static const GLubyte m_Tfan2[6 * 3] =
{
    7,4,5,
    7,5,6,
    7,6,2,
    7,2,3,
    7,3,0,
    7,0,4
};

static const GLfloat m_CubeNormals1[] = 
{
    0.0, 0.0, 1.0,           //front 
    0.0, 0.0, 1.0,
    
    1.0, 0.0, 0.0,           //right
    1.0, 0.0, 0.0,
    
    0.0, -1.0, 0.0,           //top
    0.0, -1.0, 0.0,
};

static const GLfloat m_CubeNormals2[] = 
{       
    0.0, 0.0,-1.0,           //back
    0.0, 0.0,-1.0,
    
    0.0,-1.0, 0.0,           //bottom
    0.0,-1.0, 0.0,
    
    -1.0, 0.0, 0.0,           //left
    -1.0, 0.0, 0.0,
};

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

@interface ShadowCastingViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) CADisplayLink *displayLink;
- (void)applicationWillResignActive:(NSNotification *)notification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationWillTerminate:(NSNotification *)notification;
@end

@implementation ShadowCastingViewController

@synthesize animating;
@synthesize context;
@synthesize displayLink;
@synthesize animationFrameInterval;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    EAGLContext *aContext=NULL;
        
    if (!aContext) 
    {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
        
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
        
    self.context = aContext;
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableStencilFormat=GLKViewDrawableStencilFormat8;
    
    animationFrameInterval = 1;
        
        
    m_WorldRotationX=35.0;
    m_WorldRotationY=0.0;

    m_SpinX=0.0;
    m_SpinY=0.0;
    m_SpinZ=0.0;
        
    m_WorldZ=-6.0;
    m_WorldY=-1.0;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateActive:) name:UIApplicationWillTerminateNotification object:nil];
    
    m_LightRadius=2.5;
    
    [EAGLContext setCurrentContext:self.context];       
    [self setClipping];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{

}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{

}

- (void)applicationWillTerminate:(NSNotification *)notification
{

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

/*
- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1) 
    {
        animationFrameInterval = frameInterval;
        
        if (animating) 
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}
*/

/****************************************************************************************
 * setClipping :																		*
 ****************************************************************************************/
-(void)setClipping
{
 	float aspectRatio;
	const float zNear =1.0;
	const float zFar =1000;
	const float fieldOfView = 45.0;
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

/****************************************************************************************
 * calculateShadowMatrix :                                                              *
 ****************************************************************************************/
-(void)calculateShadowMatrix
{
    GLfloat shadowMat_local[16] = 
    {  
        iLightPosY,        0.0,                  0.0,         0.0, 
        -iLightPosX,        0.0, -iLightPosZ,        -1.0, 
        0.0,        0.0,  iLightPosY,         0.0, 
        0.0,        0.0,                 0.0,  iLightPosY 
    };
    
    for ( int i=0;i<16;i++ )
    {
        iShadowMat[i] = shadowMat_local[i];                      
    }
}

/****************************************************************************************
 * drawInRect :                                                                         *
 ****************************************************************************************/
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    int lightsOnFlagTrigger=300;                                                                              //1
    bool lightsOnFlag=true;
    static int frameNumber=0;
    GLfloat minY=3.0;
    static GLfloat transY=0.0;
        
    m_TransY=(GLfloat)(sinf(transY)/2.0)+minY;                                             //2               
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);                    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    glEnable(GL_DEPTH_TEST);	
    
    [self updateLightPosition];                                                                                    //3
    
    glDisable( GL_LIGHTING );                                                                                    //4
    
    glLoadIdentity();
    
    glTranslatef(0.0,m_WorldY,m_WorldZ);                                                         //5
    
    [self drawPlatform:0.0 y:0.0 z:0.0];                                                               //6
    
    if(frameNumber>(lightsOnFlagTrigger/2))                                                      //7
        lightsOnFlag=false;
    else
        lightsOnFlag=true;
    
    if(frameNumber>lightsOnFlagTrigger)
        frameNumber=0;
    
    [self drawLight: GL_LIGHT0];                                                                             //8
    
    glDisable( GL_DEPTH_TEST );                                                                             //9
    
    [self calculateShadowMatrix];                                                                            //10
    
    //    if(lightsOnFlag)
        [self drawShadow];                                                                                           //11
    
    glShadeModel( GL_SMOOTH );                                                                          
    
    glEnableClientState(GL_VERTEX_ARRAY);                                                    //12
    glVertexPointer( 3, GL_FLOAT, 0, m_CubeVertices );
    
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_CubeColors);
    
    glRotatef(m_WorldRotationX, 1.0, 0.0, 0.0);                                             //13
    glRotatef(m_WorldRotationY, 0.0, 1.0, 0.0);
    
    glTranslatef(0.0,m_TransY, 0.0);                                                                   //14
    
    glRotatef( m_SpinZ, 0.0, 0.0, 1.0 );                                                       //15
    glRotatef( m_SpinY, 0.0, 1.0, 0.0 );
    glRotatef( m_SpinX, 1.0, 0.0, 0.0 );
    
    glEnable( GL_DEPTH_TEST );                                                                            //16
    glFrontFace(GL_CCW);
    
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, m_Tfan1);
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, m_Tfan2);
    
    glDisable(GL_BLEND);
    glEnable(GL_LIGHTING);
    
    transY+=.1;                                                                                                             //17
    frameNumber++;
    
    m_SpinX+=.4f;
    m_SpinY+=.6f;
    m_SpinZ+=.9f;
    
    return;
}
/****************************************************************************************
 * drawLight :                                                                          *
 ****************************************************************************************/
-(void)drawLight:(int)lightNumber
{
    static GLbyte lampVertices[]={0,0,0};

    glDisableClientState(GL_COLOR_ARRAY);

    glHint(GL_POINT_SMOOTH_HINT,GL_FASTEST); 
    glEnable(GL_POINT_SMOOTH);
    
    glPointSize(5.0); 
    glLightfv( lightNumber, GL_POSITION, iLightPos ); 
    glPushMatrix();
    
    glRotatef(m_WorldRotationX, 1.0, 0.0, 0.0);
    glRotatef(m_WorldRotationY, 0.0, 1.0, 0.0);

    glTranslatef( iLightPosX, iLightPosY, iLightPosZ );

    glColor4f(1.0, 1.0, 0, 1.0); 
    glVertexPointer( 3, GL_BYTE, 0, lampVertices );  
    glDrawArrays(GL_POINTS, 0,1);
    glPopMatrix();

    glEnableClientState(GL_COLOR_ARRAY);
}

/****************************************************************************************
 * drawPlatform :                                                                          *
 ****************************************************************************************/
-(void)drawPlatform:(float)x y:(float)y z:(float)z                                               
{
    static const GLfloat platformVertices[] =                                                            //1
    {
        -1.0,-0.01,-1.0,
        1.0,-0.01,-1.0,
        -1.0,-0.01,1.0,
        1.0,-0.01,1.0
    };
    
    static const GLubyte platformColors[] =  
    {
        128, 128,   128, 255,                                                                                             
        128,   0, 255, 255,
        64,     64,   64,   0,
        255,   64, 128, 255
    };
    
    GLfloat scale=1.5;                                                                                                    //2
    
    glEnable( GL_DEPTH_TEST ); 
    glShadeModel( GL_SMOOTH ); 
    glDisable(GL_CULL_FACE);                                                                                  //3
    glVertexPointer(3, GL_FLOAT, 0, platformVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, platformColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glPushMatrix();
    
    glRotatef(m_WorldRotationX, 1.0, 0.0, 0.0);                                                  //4
    glRotatef(m_WorldRotationY, 0.0, 1.0, 0.0);
    
    glTranslatef(x,y,z);
    
    glScalef(scale,scale,scale);                                                                                  //5
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);  
    
    glEnable(GL_CULL_FACE);
    
    glPopMatrix();
}

/****************************************************************************************
 * drawShadow :                                                                         *
 ****************************************************************************************/
- (void)drawShadow
{
    glPushMatrix();     
    
    glEnable(GL_DEPTH_TEST);
    glRotatef(m_WorldRotationX, 1.0, 0.0, 0.0);
    glRotatef(m_WorldRotationY, 0.0, 1.0, 0.0);

    glMultMatrixf( iShadowMat ); // Multiply shadow matrix with current
    
    //place the shadows
    
    glTranslatef(0.0,m_TransY, 0.0);
    
    glRotatef( float(m_SpinZ), 0.0, 0.0, 1.0 );
    glRotatef( float(m_SpinY), 0.0, 1.0, 0.0 );
    glRotatef( float(m_SpinX), 1.0, 0.0, 0.0 );
    
    //draw them 
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ZERO,GL_ONE_MINUS_SRC_ALPHA);
    
    glColor4f( 0.0, 0.0, 0.0, .3); // Black
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer( 3, GL_FLOAT, 0, m_CubeVertices );
          
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, m_Tfan1);
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, m_Tfan2);
    
    //  glLineWidth(3.0);
    //  glDrawElements( GL_LINES, 6 * 3, GL_UNSIGNED_BYTE, m_Tfan1);
    //  glDrawElements( GL_LINES, 6 * 3, GL_UNSIGNED_BYTE, m_Tfan2);
    
    glDisable(GL_BLEND);
    
    glPopMatrix();      
}


/****************************************************************************************
 * shouldAutorotateToInterfaceOrientation :												*
 ****************************************************************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || UIInterfaceOrientationLandscapeRight);
}

/****************************************************************************************
 * updateLightPosition :                                                                *
 ****************************************************************************************/
- (void)updateLightPosition 
{
    iLightAngle += (GLfloat)1.0;                //in degrees

    iLightPosX   = m_LightRadius * cos( iLightAngle/57.29 );
    iLightPosY   = 10.0;
    iLightPosZ   = m_LightRadius * sin( iLightAngle/57.29  );
  
    //   iLightPos[0] = iLightPosX;
    iLightPos[1] = iLightPosY;
    //   iLightPos[2] = iLightPosZ;
    
    iLightPos[0]=iLightPos[2]=0;
}

@end
