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
    
    m_Texture0=[self loadTexture:@"usa_normal_really_hc.png"];   
    m_Texture1=[self loadTexture:@"usa_texture.png"];
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
    
    static  GLfloat textureCoords[] = 
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
    glClientActiveTexture(GL_TEXTURE0);				//1
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords);
    
    glClientActiveTexture(GL_TEXTURE1); 				//2
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords2);
    
    glLoadIdentity();
    glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), -2.5);
    
    [self multiTextureBumpMap:m_Texture0.name tex1:m_Texture1.name];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
    //  transY += 0.075f;	
}
-(void)multiTexture:(GLuint)tex0 tex1:(GLuint)tex1
{
    GLfloat combineParameter=GL_DECAL;			//1
    
    // Set up the First Texture.
    
    glActiveTexture(GL_TEXTURE0);					//2
    glBindTexture(GL_TEXTURE_2D, tex0);				//3
    
    // Set up the Second Texture.
    
    glActiveTexture(GL_TEXTURE1);					
    glBindTexture(GL_TEXTURE_2D, tex1);				
    
    // Set the texture environment mode for this texture to combine.
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, combineParameter);	//4
}

-(void)multiTextureBumpMap:(GLuint)tex0 tex1:(GLuint)tex1
{
    GLfloat x,y,z;
    static float lightAngle=0.0;
    
    lightAngle+=1.0;							//1
    
    if(lightAngle>180)
        lightAngle=0;
    
    // Set up the light vector.
    
    x = sin(lightAngle * (3.14159 / 180.0));                 			//2
    y = 0.0;
    z = cos(lightAngle * (3.14159 / 180.0));
    
    // Half shifting to have a value between 0.0 and 1.0.
    
    x = x * 0.5 + 0.5;						//3
    y = y * 0.5 + 0.5;
    z = z * 0.5 + 0.5;
    
    glColor4f(x, y, z, 1.0);  						//4
    
    //The color and normal map are combined.
    
    glActiveTexture(GL_TEXTURE0);					//5
    glBindTexture(GL_TEXTURE_2D, tex0);
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);	//6
    glTexEnvf(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB);	//7
    glTexEnvf(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE);	//8
    glTexEnvf(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_PREVIOUS);	//9
    
    // Set up the Second Texture, and combine it with the result of the Dot3 combination.
    
    glActiveTexture(GL_TEXTURE1);					//10
    glBindTexture(GL_TEXTURE_2D, tex1);
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);	//11
    
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
@end
