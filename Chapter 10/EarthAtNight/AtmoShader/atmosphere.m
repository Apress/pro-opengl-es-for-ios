//
//  Atmosphere.m
//  AtmoShader
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Atmosphere.h"

@implementation Atmosphere

- (id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius 
     squash:(GLfloat) squash textureFile:(NSString *)textureFile configFile:(NSString *)configFile	
{
	if(self=[super init:stacks slices:slices radius:radius squash:squash textureFile:textureFile])
    {
        
        [self initData:configFile];
    }
    
    return self;
}


-(void)initData:(NSString *)configFile
{  
    NSString *thePath = [[NSBundle mainBundle]  pathForResource:configFile ofType:NULL];

    m_Configuration=[[NSMutableDictionary alloc] initWithContentsOfFile:thePath];
    
    m_nSamples=[[m_Configuration objectForKey:@"samples"]intValue];
    m_fSamples=(float)m_nSamples;
    m_OuterRadius=[[m_Configuration objectForKey:@"outerRadius"]floatValue];
    m_OuterRadius2=m_OuterRadius*m_OuterRadius;
    m_InnerRadius=[[m_Configuration objectForKey:@"innerRadius"]floatValue];
    m_InnerRadius2=m_InnerRadius*m_InnerRadius;

    m_RadiusScale=1.0/(m_OuterRadius-m_InnerRadius);
    
    m_ScaleDepth=[[m_Configuration objectForKey:@"scaleDepth"]floatValue];
    m_ScaleOverScaleDepth=m_RadiusScale/m_ScaleDepth;
    
    m_ESun=[[m_Configuration objectForKey:@"sunBrightness"]floatValue];

    m_KrESun=[[m_Configuration objectForKey:@"rayleigh"]floatValue]*m_ESun;
    m_Kr4PI=4.0*m_KrESun*PI;
    
    m_KmESun=[[m_Configuration objectForKey:@"mie"]floatValue]*m_ESun;
    m_Km4PI=4.0*m_KmESun*PI;
    
    m_g=[[m_Configuration objectForKey:@"miePhaseAsymmetry"]floatValue];

    
    m_InnerRadius=[[m_Configuration objectForKey:@"innerRadius"]floatValue];
    m_OuterRadius=[[m_Configuration objectForKey:@"outerRadius"]floatValue];
    
    m_Wavelength.r=[[m_Configuration objectForKey:@"waveLengthRed"]floatValue];
    m_Wavelength.g=[[m_Configuration objectForKey:@"waveLengthGreen"]floatValue];
    m_Wavelength.b=[[m_Configuration objectForKey:@"waveLengthBlue"]floatValue];

    m_WavelengthInv.r=1.0/powf(m_Wavelength.r,4.0f);
    m_WavelengthInv.g=1.0/powf(m_Wavelength.g,4.0f);
    m_WavelengthInv.b=1.0/powf(m_Wavelength.b,4.0f);
    
    m_MieScaleDepth=[[m_Configuration objectForKey:@"mieScaleDepth"]floatValue];

    m_Exposure=[[m_Configuration objectForKey:@"exposure"]floatValue];
    
    m_g=[[m_Configuration objectForKey:@"g"]floatValue];
    m_g2=m_g*m_g;
    //    m_CameraHeight=15.0;
    m_CameraHeight2=m_CameraHeight*m_CameraHeight;
    
}

- (BOOL)loadShaders:(NSString *)shaderName
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    
    m_ShaderProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) 
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) 
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(m_ShaderProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(m_ShaderProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(m_ShaderProgram, ATMO_ATTRIB_VERTEX, "position");
    //    glBindAttribLocation(m_ShaderProgram, ATMO_ATTRIB_NORMAL, "normal");
    
    // Link program.
    
    if (![self linkProgram:m_ShaderProgram]) 
    {
        NSLog(@"Failed to link program: %d", m_ShaderProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (m_ShaderProgram) {
            glDeleteProgram(m_ShaderProgram);
            m_ShaderProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.

    //lifted, er, borrowed from http://sponeil.net/
    
    
    m_AtmoUniforms[ATMO_UNIFORM_LIGHT_POSITION] = glGetUniformLocation(m_ShaderProgram, "lightPosition");
    m_AtmoUniforms[ATMO_UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(m_ShaderProgram, "modelViewProjectionMatrix");
    m_AtmoUniforms[ATMO_CAMERA_POS] = glGetUniformLocation(m_ShaderProgram, "v3CameraPos");
    m_AtmoUniforms[ATMO_INV_WAVELENGTH] = glGetUniformLocation(m_ShaderProgram, "v3InvWavelength");
    //    m_AtmoUniforms[ATMO_CAMERA_HEIGHT] = glGetUniformLocation(m_ShaderProgram, "fCameraHeight");
    m_AtmoUniforms[ATMO_CAMERA_HEIGHT2] = glGetUniformLocation(m_ShaderProgram, "fCameraHeight2");
    m_AtmoUniforms[ATMO_OUTER_RADIUS] = glGetUniformLocation(m_ShaderProgram, "fOuterRadius");
    m_AtmoUniforms[ATMO_OUTER_RADIUS2] = glGetUniformLocation(m_ShaderProgram, "fOuterRadius2");
    m_AtmoUniforms[ATMO_INNER_RADIUS] = glGetUniformLocation(m_ShaderProgram, "fInnerRadius");
    //    m_AtmoUniforms[ATMO_INNER_RADIUS2] = glGetUniformLocation(m_ShaderProgram, "fInnerRadius2");
    m_AtmoUniforms[ATMO_KR_E_SUN] = glGetUniformLocation(m_ShaderProgram, "fKrESun");
    m_AtmoUniforms[ATMO_KM_E_SUN] = glGetUniformLocation(m_ShaderProgram, "fKmESun");
    m_AtmoUniforms[ATMO_SCALE] = glGetUniformLocation(m_ShaderProgram, "fScale");
    m_AtmoUniforms[ATMO_KR4_SUN_PI] = glGetUniformLocation(m_ShaderProgram, "fKr4PI");
    m_AtmoUniforms[ATMO_KM4_SUN_PI] = glGetUniformLocation(m_ShaderProgram, "fKm4PI");
    m_AtmoUniforms[ATMO_SCALE_DEPTH] = glGetUniformLocation(m_ShaderProgram, "fScaleDepth");
    m_AtmoUniforms[ATMO_SCALE_OVER_SCALE_DEPTH] = glGetUniformLocation(m_ShaderProgram, "fScaleOverScaleDepth");
    m_AtmoUniforms[ATMO_NSAMPLES] = glGetUniformLocation(m_ShaderProgram, "nSamples");
    m_AtmoUniforms[ATMO_FSAMPLES] = glGetUniformLocation(m_ShaderProgram, "fSamples");
    m_AtmoUniforms[ATMO_G] = glGetUniformLocation(m_ShaderProgram, "g");
    m_AtmoUniforms[ATMO_G2] = glGetUniformLocation(m_ShaderProgram, "g2");
    
    // Release vertex and fragment shaders.
    
    if (vertShader) 
    {
        glDetachShader(m_ShaderProgram, vertShader);
        glDeleteShader(vertShader);
    }
    
    if (fragShader) 
    {
        glDetachShader(m_ShaderProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file 
                                                  encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
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

-(void)useProgram:(GLKMatrix4)mvpMatrix lightPosition:(GLKVector3)lightPosition cameraPosition:(GLKVector3)cameraPosition
{    
    GLenum error;
    
    m_CameraHeight=GLKVector3Length(cameraPosition);
    m_CameraHeight2=m_CameraHeight*m_CameraHeight;
    
    glUseProgram(m_ShaderProgram);
    
    glUniformMatrix4fv(m_AtmoUniforms[ATMO_UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, mvpMatrix.m);
    
    error=glGetError();
    
    glUniform3fv(m_AtmoUniforms[ATMO_UNIFORM_LIGHT_POSITION],1,lightPosition.v);
    
    error=glGetError();

    glUniform3fv(m_AtmoUniforms[ATMO_CAMERA_POS],1,cameraPosition.v);
    
    error=glGetError();
   
    glUniform3fv(m_AtmoUniforms[ATMO_INV_WAVELENGTH],1,m_WavelengthInv.v);
    
    error=glGetError();
    
    //    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_CAMERA_HEIGHT]],m_CameraHeight);
    
    error=glGetError();
    
    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_CAMERA_HEIGHT2]],m_CameraHeight2);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_OUTER_RADIUS]],m_OuterRadius);
    
    error=glGetError();
    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_OUTER_RADIUS2]],m_OuterRadius2);

    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_INNER_RADIUS]],m_InnerRadius);
    
    
    error=glGetError();

    //    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_INNER_RADIUS2]],m_InnerRadius2);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_KR_E_SUN]],m_KrESun);
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_KM_E_SUN]],m_KmESun);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_KR4_SUN_PI]],m_Kr4PI);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_KM4_SUN_PI]],m_Km4PI);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_SCALE]],m_RadiusScale);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_SCALE_DEPTH]],m_ScaleDepth);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_SCALE_OVER_SCALE_DEPTH]],m_ScaleOverScaleDepth);

    
    error=glGetError();

    glUniform1i(m_AtmoUniforms[m_AtmoUniforms[ATMO_NSAMPLES]],m_nSamples);
    
    
    error=glGetError();

    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_FSAMPLES]],m_fSamples);
    
    
    error=glGetError();
    
    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_G]],m_g);

    error=glGetError();
    
    glUniform1f(m_AtmoUniforms[m_AtmoUniforms[ATMO_G2]],m_g2);

    error=glGetError();

    [self testShaderAlgorithm:lightPosition cameraPosition:cameraPosition];

}


-(float)scalex:(float)fCos
{
       if(fCos<0)
          fCos*= -1.0;
    
	float x = 1.0 - fCos;
    float temp;
    
    temp=(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
    
	float rvalue=m_ScaleDepth * expf(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
    
    return rvalue;
}

-(void)testShaderAlgorithm:(GLKVector3)lightPosition cameraPosition:(GLKVector3)cameraPosition
{
    int i;
    
    GLKVector3 v3Pos=GLKVector3Make(0.0, 13.0, 0.0);            //a sample vertex
    GLKVector3 v3CameraPos=cameraPosition;
    GLKVector3 v3Ray=GLKVector3Subtract(v3Pos, v3CameraPos);
    
    float fFar=GLKVector3Length(v3Ray);
    v3Ray=GLKVector3Normalize(v3Ray);
    
    float B=2.0*GLKVector3DotProduct(v3CameraPos, v3Ray);
    float C=m_CameraHeight2-m_OuterRadius2;
	float fDet = MAX(0.0, B*B - 4.0 * C);
	float fNear = 0.5 * (-B - sqrt(fDet));
    
    GLKVector3 v3Temp=GLKVector3MultiplyScalar(v3Ray, fNear);
    GLKVector3 v3Start=GLKVector3Add(v3CameraPos, v3Temp);
    
    fFar-=fNear;
    
    float fStartAngle=GLKVector3DotProduct(v3Ray,v3Start);
    float fStartDepth=expf(-1.0/m_ScaleDepth);
    float fStartOffset = fStartDepth*[self scalex:fStartAngle];

    float fSampleLength = fFar / m_fSamples;
	float fScaledLength = fSampleLength * m_RadiusScale;
    
    GLKVector3 v3SampleRay=GLKVector3MultiplyScalar(v3Ray, fSampleLength);
    GLKVector3 v3SamplePoint=GLKVector3Add(v3Start,GLKVector3MultiplyScalar(v3SampleRay, 0.5));
    
    v3Temp=GLKVector3MultiplyScalar(v3SampleRay, 0.5);
    v3SamplePoint=GLKVector3Add(v3Start,v3Temp);
    GLKVector3 v3FrontColor=GLKVector3Make(0.0, 0.0, 0.0);
    
    for(i=0;i<m_nSamples;i++)
    {
        float fHeight = GLKVector3Length(v3SamplePoint);
		float fDepth = expf(m_ScaleOverScaleDepth * (m_InnerRadius - fHeight));
		float fLightAngle = GLKVector3DotProduct(lightPosition,v3SamplePoint) / fHeight;
		float fCameraAngle = GLKVector3DotProduct(v3Ray, v3SamplePoint) / fHeight;
		float fScatter = (fStartOffset + fDepth*([self scalex:fLightAngle] - [self scalex:fCameraAngle]));
        
        v3Temp=GLKVector3MultiplyScalar(m_WavelengthInv, m_Kr4PI);
        v3Temp=GLKVector3AddScalar(v3Temp,m_Km4PI);
        v3Temp=GLKVector3MultiplyScalar(v3Temp,-fScatter);
        
		GLKVector3 v3Attenuate;
        
        v3Attenuate.x= expf(v3Temp.x);
        v3Attenuate.y= expf(v3Temp.y);
        v3Attenuate.z= expf(v3Temp.z);

        v3Temp=GLKVector3MultiplyScalar(v3Attenuate, fDepth*fScaledLength);
		v3FrontColor = GLKVector3Add(v3FrontColor,v3Temp);
		v3SamplePoint = GLKVector3Add(v3SamplePoint,v3SampleRay);        
    }
    
    GLKVector3 frontSecondaryColorVarying=GLKVector3MultiplyScalar(v3FrontColor, m_KmESun);
    
    v3Temp=GLKVector3MultiplyScalar(m_WavelengthInv,m_KrESun);
    GLKVector3 colorVarying=GLKVector3Multiply(v3FrontColor,v3Temp);
    
    GLKVector3 v3Direction=GLKVector3Subtract(v3CameraPos, v3Pos);
    GLKVector3 v3LightPos=lightPosition;

    //glPosition not relevant here
    
    //Now the fragment shader
    
    float fCos = GLKVector3DotProduct(v3LightPos,v3Direction) / GLKVector3Length(v3Direction);
    
    float fTemp=1.0 + m_g2 - 2.0*m_g*fCos;
    
    fTemp=powf(fTemp, 1.5f);

	float fRayleighPhase = 0.75 * (1.0 + fCos*fCos);
	float fMiePhase = 1.5 * ((1.0 - m_g2) / (2.0 + m_g2)) * (1.0 + fCos*fCos) / powf(1.0 + m_g2 - 2.0*m_g*fCos, 1.5);
    
             //the max it could be, for testing
    
    v3Temp=GLKVector3MultiplyScalar(colorVarying, fRayleighPhase);
    GLKVector3 v3Temp2=GLKVector3MultiplyScalar(frontSecondaryColorVarying,fMiePhase);

    GLKVector3 gl_FragColor = GLKVector3Add(v3Temp2, v3Temp);
}

@end
