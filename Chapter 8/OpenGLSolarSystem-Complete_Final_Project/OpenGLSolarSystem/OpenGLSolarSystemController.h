//
//  OpenGLSolarSystemController.h
//  OpenGLSolarSystemController
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "miniglu.h"
#import "Planet.h"
#import "LensFlare.h"
#import "OpenGLCreateTexture.h"
#import "OpenGLConstellations.h"

#define X_VALUE								0
#define Y_VALUE								1
#define Z_VALUE								2

#define STANDARD_FOV                        30.0               //in degrees

@interface OpenGLSolarSystemController : NSObject 
{
	Planet *m_Earth;
	Planet *m_Sun;
	GLKVector3	m_Eyeposition;
    float m_FieldOfView;
    LensFlare *m_LensFlare;
    GLKTextureInfo *m_FlareSource;
    
    OpenGLConstellations *m_Constellations;
    
    BOOL m_ConstNamesOn;
    BOOL m_ConstOutlinesOn;
    BOOL m_LensFlareOn;
}

-(void)execute;
-(void)executePlanet:(Planet *)planet sx:(float *)sx sy:(float *)sy sz:(float *)sz 
        screenRadius:(float *)screenRadius render:(BOOL)render;
-(id)init;
-(void)initGeometry;
-(void)setClipping;
-(float)getFieldOfView;
-(void)setFieldOfView:(float)fov;
-(GLKVector3)getTargetLocation;
-(void)lookAtTarget;
-(GLKVector3)getEyeposition;
-(void)setEyeposition:(GLKVector3)loc;
-(void)setFeatureNames:(BOOL)constNames outlines:(BOOL)constOutlines lensFlare:(BOOL)lensFlare;

@end

