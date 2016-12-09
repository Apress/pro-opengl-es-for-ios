//
//  OpenGL_ReflectionViewController.h
//  OpenGL_Reflection
//
//  Created by mike on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GLKit/GLKit.h>


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define SS_SUNLIGHT		GL_LIGHT0
#define SS_FILLLIGHT1	GL_LIGHT1
#define SS_FILLLIGHT2	GL_LIGHT2

@interface OpenGL_ReflectionViewController : GLKViewController 
{
    EAGLContext *context;
    GLuint program;
    BOOL animating;
    NSInteger animationFrameInterval;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

-(void)startAnimation;
-(void)stopAnimation;
-(void)setClipping;
-(void)renderToStencil;
-(void)renderStage;
-(void)initLighting;

@end
