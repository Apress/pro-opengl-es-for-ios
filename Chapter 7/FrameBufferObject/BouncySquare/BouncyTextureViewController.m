//
//  BouncySquareViewController.m
//  BouncySquare
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BouncyTextureViewController.h"

@interface BouncyTextureViewController () 
{


}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end


@implementation BouncyTextureViewController

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
    
    m_Texture=[self loadTexture:@"hedly.png"];
    [self setClipping];

    m_FBOHeight=480;
    m_FBOWidth=320;
    
    m_FBOController=[[FBOController alloc]initWidth:m_FBOWidth height:m_FBOHeight];
}

-(GLKTextureInfo *)loadTexture:(NSString *)filename
{
    NSError *error;
    GLKTextureInfo *info;
    NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,nil];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:filename ofType:NULL];
    
    info=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    glBindTexture(GL_TEXTURE_2D, info.name);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT); 	
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);	
    


    return info;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static const GLfloat squareVertices[] = 		
    {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        -0.5f,  0.5f, 0.0f,
        0.5f,  0.5f, 0.0f
    };
    
    static const GLfloat fboVertices[] = 		                                                    //1
    {
        -0.5f, -0.75f, 0.0f,
        0.5f, -0.75f, 0.0f,
        -0.5f,  0.75f, 0.0f,
        0.5f,  0.75f, 0.0f
    };
    
    static  GLfloat textureCoords1[] = 
    {				
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    };
    
    static float transY = 0.0f;
    static float rotZ = 0.0f;
    static float z = -1.5;
    
    if(m_DefaultFBO==0)
        glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &m_DefaultFBO);  //2
    
    glDisableClientState(GL_COLOR_ARRAY|GL_DEPTH_BUFFER_BIT);
    
    //Draw to the off-screen FBO first.
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, [m_FBOController getFBOName]); //2 
    
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), z);
    glRotatef(rotZ, 0, 0, 1.0);                                                                                               //3
    
    glEnable(GL_TEXTURE_2D); 
    glBindTexture(GL_TEXTURE_2D, m_Texture.name);				
    
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords1);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);                                                               //4
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_DefaultFBO);                   //5
    
    glLoadIdentity();                                                                                                                //6
    
    glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f),z);
    glRotatef(rotZ, 1, 0, 0.0);                                                                                               

    
    glBindTexture(GL_TEXTURE_2D, [m_FBOController getTextureName]);	     //7			
    
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);                                                                                  //8
    glClear(GL_COLOR_BUFFER_BIT);
    
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords1);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, fboVertices);                                                         //9
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    transY += 0.075f;
    rotZ+=1.0;
}

-(void)setClipping
{
	float aspectRatio;
	const float zNear = .1;					
	const float zFar = 1000;					
	const float fieldOfView = 60.0;			
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
