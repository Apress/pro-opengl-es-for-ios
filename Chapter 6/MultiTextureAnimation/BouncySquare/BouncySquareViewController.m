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
    
    [EAGLContext setCurrentContext:self.context];
    m_Texture0=[self loadTexture:@"hedly.png"];
    m_Texture1=[self loadTexture:@"rgb_splats.256.color.png"];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static const GLfloat squareVertices[] = 		
    {
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        -0.5,  0.5, 0.0,
        0.5,  0.5, 0.0
    };
    
    static  GLfloat textureCoords1[] = 
    {				
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    };
    
    static  GLfloat textureCoords2[] = 
    {				
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    };
    
    int i=0;
    
    static float transY = 0.0;
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
    [self setClipping];
	
    glClearColor(0.0, 0.0,0.0, 1.0);
	
    glClear(GL_COLOR_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
    //Set up for using textures.
    
    glEnable(GL_TEXTURE_2D); 
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glClientActiveTexture(GL_TEXTURE0);                 //1
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords1);
    
    glClientActiveTexture(GL_TEXTURE1); 				//2
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords2);
    
    glLoadIdentity();
    glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), -2.5);
    
    [self multiTexture:m_Texture0.name tex1:m_Texture1.name];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
    for(i=0;i<8;i++)
    {
        textureCoords2[i]+=.01;
    }
    
    transY += 0.075f;	
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

-(void)multiTexture:(GLuint)tex0 tex1:(GLuint)tex1
{
    GLfloat combineParameter=GL_MODULATE;			//1
    
    // Set up the First Texture.
    
    glActiveTexture(GL_TEXTURE0);					//2
    glBindTexture(GL_TEXTURE_2D, tex0);				//3
    
    // Set up the Second Texture.
    
    glActiveTexture(GL_TEXTURE1);					
    glBindTexture(GL_TEXTURE_2D, tex1);				
    
    // Set the texture environment mode for this texture to combine.
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, combineParameter);	//4
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
