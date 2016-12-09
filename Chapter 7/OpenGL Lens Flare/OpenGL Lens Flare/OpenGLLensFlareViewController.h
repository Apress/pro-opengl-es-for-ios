//
//  OpenGLLensFlareViewController.h
//  OpenGL Lens Flare
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "LensFlare.h"

#define OGL_NOTIFICATION_DRAG_MOVE              @"moveLookAt"

@interface OpenGLLensFlareViewController : GLKViewController 
{
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;  
    LensFlare *m_LensFlare;
    GLuint m_FlareSource;
    CGPoint m_PointerLocation;
    BOOL m_IsDragging;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

-(void)startAnimation;
-(void)stopAnimation;
-(void)setClipping;
-(void)handleMove:(NSNotification *)notification;

@end
