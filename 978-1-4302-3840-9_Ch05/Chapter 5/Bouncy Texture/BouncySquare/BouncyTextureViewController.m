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
        -0.5f, -0.33f,
        0.5f, -0.15f,
        -0.5f,  0.33f,
        0.5f,  0.15f,
    };
;
    
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    static  GLfloat textureCoords[] =
    {
        0.0, 0.0,
        2.0, 0.0,
        0.0, 2.0,
        2.0, 2.0
    };
    
    static float texIncrease=0.01;
    textureCoords[0]+=texIncrease;
    textureCoords[2]+=texIncrease;
    textureCoords[4]+=texIncrease;
    textureCoords[6]+=texIncrease;
    textureCoords[1]+=texIncrease;
    textureCoords[3]+=texIncrease;
    textureCoords[5]+=texIncrease;
    textureCoords[7]+=texIncrease;
    
    static float transY = 0.0f;
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
 
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);
    
    transY += 0.075f;
    
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    //    glEnableClientState(GL_COLOR_ARRAY);
    
    
    glEnable(GL_TEXTURE_2D);                                            //2
    glEnable(GL_BLEND);                                                 //3
    glBlendFunc(GL_ONE, GL_SRC_COLOR);                                  //4
    glBindTexture(GL_TEXTURE_2D,m_Texture.name);                        //5
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords);                     //6
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);                        //7
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);                              //8
      
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);                       //9
}


@end
