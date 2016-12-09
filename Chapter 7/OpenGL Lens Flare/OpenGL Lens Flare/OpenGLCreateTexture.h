//
//  OpenGLCreateTexture.h
//  MultiTexture
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenGLCreateTexture.h"

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>


@interface OpenGLCreateTexture : NSObject
{
    
    
    
}

+(id)allocWithZone:(NSZone *)zone;
+(OpenGLCreateTexture *)getObject;
-(void)renderTextureAt:(CGPoint)position  name:(GLuint)name   size:(GLfloat)size r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a;
-(int)createTexture:(NSString *)imageFileName imageID:(GLuint *)imageID mipmapID:(int)mipmapID;

@end
