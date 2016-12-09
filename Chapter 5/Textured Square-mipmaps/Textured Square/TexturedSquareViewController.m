//
//  TexturedSquareViewController.m
//  Textured Square
//
//  Created by mike on 8/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TexturedSquareViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

struct vertex2DStruct
{
    GLfloat xy[2];
    GLfloat rgba[4];
    GLfloat st[2];
};

static const struct vertex2DStruct m_SquareVertices[4]=
{
    {{-0.5f,  -0.5f},     { 1.0f,1.0f,0.0f,1.0f},   {0.0f,0.0f}},
    {{ 0.5f,  -0.5f},     { 0.0f,1.0f,1.0f,1.0f},   {1.0f,0.0f}},
    {{-0.5f,   0.5f},     { 0.0f,0.0f,0.0f,0.0f},   {0.0f,1.0f}},
    {{ 0.5f,   0.5f},     { 1.0f,0.0f,1.0f,1.0f},   {1.0f,1.0f}}
};


@interface TexturedSquareViewController () 
{   
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint m_MMTexture;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;
- (int)createTexture:(NSString *)imageFileName imageID:(GLuint *)imageID mipmapID:(int)mipmapID;
- (void)loadTextures;
- (void)loadTexture;

@end

@implementation TexturedSquareViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) 
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) 
    {
        [EAGLContext setCurrentContext:nil];
    }
    
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}

- (void)setupGL
{
    GLuint structSize=sizeof(struct vertex2DStruct);
    
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_FALSE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    //       [self loadTextures];

      
    [self loadTexture];
    

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(m_SquareVertices), m_SquareVertices, GL_STATIC_DRAW);
    
    //from Stackoverflow
    //    We assigned the attribute index of the position attribute to 0 in the vertex shader, 
    //    so the call to glEnableVertexAttribArray(0) enables the attribute index for the position attribute. ... 
    //    If the attribute is not enabled, it will not be used during rendering.
    //    (ie, the position, color, texcoords indices are fixed by OGL 2, but GLKit chooses to use an Enum 
    //    to represent them.
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);                 
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, structSize, BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);                 
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, structSize, BUFFER_OFFSET(24));
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    static int counter=1;
    static float direction=-1.0;
    static float transZ=-1.0;
    static GLfloat rotation=0;
    
    GLfloat offset=0;
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4Identity;  
        
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix,rotation, 0.0f, 0.0f, 1.0f);

    GLKMatrix4 scaleViewMatrix = GLKMatrix4Scale(baseModelViewMatrix,2.0f,2.0f,2.0f);
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f,transZ);
    modelViewMatrix = GLKMatrix4Multiply(scaleViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    if(!(counter%100))
    {
        if(direction==1.0)
        {
            direction=-1.0;
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        }
        else
        {
            direction=1.0;
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_NEAREST);
        }
    }
    
    transZ+=(.10*direction);
    
    rotation += self.timeSinceLastUpdate; 
    counter++;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(0.0f,-1.0f,0.0);

    self.effect.transform.modelviewMatrix=GLKMatrix4Multiply(translation ,self.effect.transform.modelviewMatrix);
    
    glBindVertexArrayOES(_vertexArray);
    
    [self.effect prepareToDraw];
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    translation = GLKMatrix4MakeTranslation(0.0f,2.0f,0.0);
    self.effect.transform.modelviewMatrix=GLKMatrix4Multiply(translation ,self.effect.transform.modelviewMatrix);

    [self.effect prepareToDraw];
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_NEAREST);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

}


-(void)loadTexture
{
    GLKTextureInfo *info;
    NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:TRUE],GLKTextureLoaderGenerateMipmaps,nil];

    NSString *path=[[NSBundle mainBundle]pathForResource:@"hedly" ofType:@"png"];
    
    info=[GLKTextureLoader textureWithContentsOfFile:path options:options error:NULL];
    
    self.effect.texture2d0.name=info.name;
}

@end
