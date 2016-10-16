//
//  Flare.m
//  OpenGL Lens Flare
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLCreateTexture.h"

#import "Flare.h"
//#import "OpenGLCreateTexture.h"

@implementation Flare

/************************************************************************************
 * init: initializes an individual flare.                                           *
 ************************************************************************************
 * filename: the filename, duh. No path needed.                                     *
 * size: the "basic" core size. Used to vary the sizes of duplicate bitmaps         *
 * opacity: alpha.                                                                  *
 * position: position along the light vector. The sum total of positions across all *
 *          the flares should be 2, going from -1 to 1.                             *
 * r,g,b: normalized.                                                               *
 ************************************************************************************/
-(id)init:(NSString *)filename size:(GLfloat)size vectorPosition:(GLfloat)vectorPosition r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a
{
    OpenGLCreateTexture *ct;
    GLKTextureInfo *texture;

    self = [super init];
    
    if (self) 
    {
        ct=[OpenGLCreateTexture getObject];
        
        texture=[ct loadTexture:filename];
        
        m_Name=texture.name;
        m_Size=size;
        m_VectorPosition=vectorPosition;
        m_Red=r;
        m_Green=g;
        m_Blue=b;
        m_Alpha=a;
        
        m_Red*=m_Alpha;
        m_Green*=m_Alpha;
        m_Blue*=m_Alpha;   
    }
    
    return self;
}

-(GLfloat)getVectorPosition
{
    return m_VectorPosition;
}

-(void)renderFlareAt:(CGPoint)position  scale:(float)scale alpha:(float)alpha
{      
    [[OpenGLCreateTexture getObject]renderTextureAt:position 
                                                name:m_Name size:m_Size*scale  r:m_Red*alpha g:m_Green*alpha b:m_Blue*alpha a:alpha];    
}

@end
