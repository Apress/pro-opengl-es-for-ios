//
//  Atmosphere.h
//  AtmoShader
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "planet.h"

#define PI              3.14159


// Uniform index.
enum
{
    ATMO_UNIFORM_MODELVIEWPROJECTION_MATRIX,
    ATMO_UNIFORM_NORMAL_MATRIX,
    ATMO_UNIFORM_LIGHT_POSITION,
    ATMO_CAMERA_POS,
    ATMO_INV_WAVELENGTH,
    ATMO_CAMERA_HEIGHT,
    ATMO_CAMERA_HEIGHT2,
    ATMO_OUTER_RADIUS,
    ATMO_OUTER_RADIUS2,
    ATMO_INNER_RADIUS,
    ATMO_INNER_RADIUS2,
    ATMO_KR_E_SUN,
    ATMO_KM_E_SUN,
    ATMO_KR4_SUN_PI,
    ATMO_KM4_SUN_PI,
    ATMO_SCALE,
    ATMO_SCALE_DEPTH,
    ATMO_SCALE_OVER_SCALE_DEPTH,
    ATMO_NSAMPLES,
    ATMO_FSAMPLES,
    ATMO_G,
    ATMO_G2,
    ATMO_NUM_UNIFORMS
};


// Attribute index.
enum
{
    ATMO_ATTRIB_VERTEX,
    ATMO_ATTRIB_NORMAL,
    ATMO_NUM_ATTRIBUTES
};

@interface Atmosphere : Planet
{
    int m_PolygonMode;
	BOOL m_bHDR;
    
	GLKVector3 m_Light;
	GLKVector3 m_LightDirection;
	
	// Variables that can be tweaked with keypresses
	BOOL  m_ShowTexture;
    float m_ScaleOverScaleDepth;
	int   m_nSamples;
    float m_fSamples;
    float m_CameraHeight;
    float m_CameraHeight2;
	float m_KrESun, m_Kr4PI;
	float m_KmESun, m_Km4PI;
	float m_ESun;
	float m_g;
    float m_g2;
    float m_RadiusScale;            //actually just the "scale" but m_Scale was already taken
	float m_InnerRadius;
    float m_InnerRadius2;
    float m_OuterRadius;
	float m_OuterRadius2;
	GLKVector3 m_Wavelength;
	GLKVector3 m_WavelengthInv;
	float m_ScaleDepth;         //aka, the Rayleigh Scale Depth
	float m_MieScaleDepth;
    float m_Exposure;
    GLuint m_ShaderProgram;

    NSMutableDictionary *m_Configuration;
    
    GLint m_AtmoUniforms[ATMO_NUM_UNIFORMS];
}

-(id)init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat) squash textureFile:(NSString *)textureFile configFile:(NSString *)configFile;
-(BOOL)loadShaders:(NSString *)shaderName;
-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
-(BOOL)linkProgram:(GLuint)prog;
-(BOOL)validateProgram:(GLuint)prog;
-(void)useProgram:(GLKMatrix4)mvpMatrix lightPosition:(GLKVector3)lightPosition cameraPosition:(GLKVector3)cameraPosition;
-(void)initData:(NSString *)configFile;
-(float)scalex:(float)fCos;
-(void)testShaderAlgorithm:(GLKVector3)lightPosition cameraPosition:(GLKVector3)v3CameraPos;

@end
