//
//  EarthAtNightViewController.m
//  EarthAtNight
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "Atmosphere.h"
#import "EarthAtNightViewController.h"

#import "planet.h"
#import "OpenglIOS.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_LIGHT_POSITION,
    UNIFORM_EYE_POSITION,
    UNIFORM_SAMPLER0,
    UNIFORM_SAMPLER1,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface EarthAtNightViewController () 
{
    GLuint m_DaysideProgram;
    GLuint m_NightsideProgram;
    GLuint m_AtmoProgram;
    
    float m_Rotation;
    
    GLuint m_VertexArray;
    GLuint m_VertexBuffer;
    
    GLKMatrix4 m_ProjectionMatrix;
    GLKMatrix4 m_ModelViewProjectionMatrix;
    GLKMatrix3 m_NormalMatrix;
    GLKMatrix4 m_WorldModelViewMatrix;
    
    GLKVector3 m_LightPosition;
    GLKVector3 m_EyePosition;
    
    GLKTextureInfo *m_EarthDayTexture;
    GLKTextureInfo *m_EarthNightTexture;
    GLKTextureInfo *m_EarthCloudTexture;

    Planet *m_Sphere;
    Atmosphere *m_Atmo;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders:(GLuint *)program shaderName:(NSString *)shaderName;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (GLKTextureInfo *)loadTexture:(NSString *)fileName;
- (void)useProgram:(GLuint)program;

@end

@implementation EarthAtNightViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
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
    // Release any cached data, images, etc. that aren't in use.
}

-(GLKTextureInfo *)loadTexture:(NSString *)fileName
{    
    GLKTextureInfo *ti;
    NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,nil];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:fileName ofType:NULL];
    
    ti=[GLKTextureLoader textureWithContentsOfFile:path options:options error:NULL];
    
    return ti;
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
    int planetSize=100;
    
    [EAGLContext setCurrentContext:self.context];
    
    //shows the light side of the earth, then fades to transparency on the dark side
    //so the earth-at-night part can show through, (the "solid" shaders do that, 
    //as in the night side doesn't fade from transparent to solid, it just is always
    //solid to ensure that nothing can show trhought he earth.
    
    [self loadShaders:&m_NightsideProgram shaderName:@"nightside"];
    [self loadShaders:&m_DaysideProgram shaderName:@"dayside"];          
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    m_ProjectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    m_EyePosition=GLKVector3Make(0.0,0.0,65.0);

    m_WorldModelViewMatrix=GLKMatrix4MakeTranslation(-m_EyePosition.x,-m_EyePosition.y,-m_EyePosition.z);          //sets the eyepoint

    m_Sphere=[[Planet alloc] init:planetSize slices:planetSize radius:10.0f squash:1.0f textureFile:NULL];	
    [m_Sphere setPositionX:0.0 Y:0.0 Z:0.0]; 
    
    m_EarthDayTexture=[self loadTexture:@"earth_light.png"];
    m_EarthNightTexture=[self loadTexture:@"earth_night.png"];
    m_EarthCloudTexture=[self loadTexture:@"clouds_1024.png"];
    
    //bind the clouds to texture unit 1
    
    glUseProgram(m_DaysideProgram);
    glUniform1i(uniforms[UNIFORM_SAMPLER0],0);
    glUniform1i(uniforms[UNIFORM_SAMPLER1],1);
 
    glUseProgram(m_NightsideProgram);
    glUniform1i(uniforms[UNIFORM_SAMPLER0],0);
    glUniform1i(uniforms[UNIFORM_SAMPLER1],1);
   
    m_LightPosition=GLKVector3Make(0.0, 0.0,100.0); 
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &m_VertexBuffer);
    glDeleteVertexArraysOES(1, &m_VertexArray);
    
    self.effect = nil;
    
    if (m_DaysideProgram) 
    {
        glDeleteProgram(m_DaysideProgram);
        m_DaysideProgram = 0;
    }
    
    if (m_NightsideProgram) 
    {
        glDeleteProgram(m_NightsideProgram);
        m_NightsideProgram = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    GLfloat scale=2.0;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4Identity;  
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;  
    
    baseModelViewMatrix = GLKMatrix4Scale(baseModelViewMatrix,scale,scale,scale);
    
    modelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, m_Rotation, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Multiply(m_WorldModelViewMatrix, modelViewMatrix);   
    
    m_ModelViewProjectionMatrix=GLKMatrix4Multiply(m_ProjectionMatrix, modelViewMatrix);
    
    m_NormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
       
    m_Rotation+=GLKMathDegreesToRadians(1.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    GLfloat gray=0.0;
    static int frame=0;

    glClearColor(gray,gray,gray, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //nightside
   
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,m_EarthNightTexture.name); 
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,m_EarthCloudTexture.name); 
   
    [self useProgram:m_NightsideProgram];
   
    [m_Sphere setBlendMode:PLANET_BLEND_MODE_SOLID];
    [m_Sphere execute:m_EarthNightTexture.name];
    
    //dayside
  
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,m_EarthDayTexture.name); 
  
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,m_EarthCloudTexture.name); 
    
    [self useProgram:m_DaysideProgram];
    
    [m_Sphere setBlendMode:PLANET_BLEND_MODE_FADE];
    [m_Sphere execute:m_EarthDayTexture.name];

    //atmosphere
    
    glCullFace(GL_FRONT);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW);
    
    frame++;
}

-(void)useProgram:(GLuint)program
{    
    glUseProgram(program);
    
    //updates the uniform values
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, m_ModelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, m_NormalMatrix.m);
    
    //now rotate the light as well, but not as much as the earth, so we can still see
    //different parts at night. I need to rotate it here just to ensure it is properly
    //synched with the proper programs
    
    GLKMatrix4 lightMatrix=GLKMatrix4Identity;
    
    lightMatrix = GLKMatrix4Rotate(lightMatrix, m_Rotation*.6, 0.0f, 1.0f, 0.0f);

    lightMatrix = GLKMatrix4Rotate(lightMatrix, m_Rotation, 0.0f, 1.0f, 0.0f);
    
//lightMatrix=GLKMatrix4Identity;
    
    lightMatrix = GLKMatrix4Multiply(m_WorldModelViewMatrix, lightMatrix);   
    
    GLKVector3 lightPosition=GLKMatrix4MultiplyVector3(lightMatrix,m_LightPosition);
   
    glUniform3fv(uniforms[UNIFORM_LIGHT_POSITION],1,lightPosition.v);
    glUniform3fv(uniforms[UNIFORM_EYE_POSITION], 1, m_EyePosition.v);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders:(GLuint *)program  shaderName:(NSString *)shaderName
{
    GLint temp;
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    
    *program = glCreateProgram();
    
    // Create and compile fragment shader.
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) 
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Create and compile vertex shader.
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) 
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    

    
    // Attach vertex shader to program.
    glAttachShader(*program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(*program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(*program, ATTRIB_NORMAL, "normal");
    glBindAttribLocation(*program, GLKVertexAttribTexCoord0, "texCoord");

    // Link program.
    
    if (![self linkProgram:*program]) 
    {
        NSLog(@"Failed to link program: %d", *program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (*program) {
            glDeleteProgram(*program);
            *program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    
    uniforms[UNIFORM_LIGHT_POSITION] = glGetUniformLocation(*program, "lightPosition");
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(*program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(*program, "normalMatrix");
    uniforms[UNIFORM_EYE_POSITION] = glGetUniformLocation(*program, "eyePosition");
    uniforms[UNIFORM_SAMPLER1] = glGetUniformLocation(*program, "cloud_texture");
    uniforms[UNIFORM_SAMPLER0] = glGetUniformLocation(*program, "s_texture");

    temp=uniforms[UNIFORM_LIGHT_POSITION];
    temp=uniforms[UNIFORM_SAMPLER1];
    temp=uniforms[UNIFORM_SAMPLER0] ;
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(*program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(*program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
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
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
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
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
