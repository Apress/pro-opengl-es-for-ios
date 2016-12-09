//
//  ShadowCastingViewController.h
//  ShadowCasting
//
//  Created by mike on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ShadowCastingViewController : GLKViewController 
{
    EAGLContext *context;
    GLuint program;
       
    GLfloat m_WorldRotationX;
    GLfloat m_WorldRotationY;
    
    GLfloat m_LightRadius;
    
    /** Angle of the light. */
    GLfloat iLightAngle;
    
    /** X coordinate of the light */
    GLfloat iLightPosX;
    
    /** Y coordinate of the light */
    GLfloat iLightPosY;
    GLfloat iLightPosZ;
    GLfloat iLightPos[4];
    
    GLfloat m_WorldZ;
    GLfloat m_WorldY;
    
    GLfloat m_TransY;
    GLfloat m_SpinX;
    GLfloat m_SpinY;
    GLfloat m_SpinZ;
    
    GLfloat iShadowMat[16];
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

-(void)drawPlatform:(float)x y:(float)y z:(float)z;
-(void)drawLight:(int)lightNumber;
-(void)updateLightPosition;
-(void)drawShadow;
-(void)calculateShadowMatrix;
-(void)setClipping;
-(void)viewDidLoad;
-(void)viewDidUnload;
-(void)applicationWillResignActive:(NSNotification *)notification;
-(void)applicationDidBecomeActive:(NSNotification *)notification;
-(void)applicationWillTerminate:(NSNotification *)notification;
-(void)dealloc;
-(void)didReceiveMemoryWarning;


@end
