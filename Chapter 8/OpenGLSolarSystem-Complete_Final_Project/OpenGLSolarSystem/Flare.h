//
//  Flare.h
//  OpenGL Lens Flare
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>

@interface Flare : NSObject
{
    GLfloat m_Size;
    GLfloat m_Red;
    GLfloat m_Green;
    GLfloat m_Blue;
    GLfloat m_Alpha;
    GLfloat m_VectorPosition;
    GLuint  m_Name;
}

-(id)init:(NSString *)filename size:(GLfloat)size vectorPosition:(GLfloat)vectorPosition r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a;
-(void)renderFlareAt:(CGPoint)position scale:(float)scale alpha:(float)alpha;
-(GLfloat)getVectorPosition;

@end
