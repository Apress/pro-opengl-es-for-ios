//
//  OpenGLCreateTexture.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


@interface OpenGLCreateTexture : NSObject

-(id)init;
-(GLKTextureInfo *)loadTexture:(NSString *)filename;
+(OpenGLCreateTexture *)getObject;
+(id)allocWithZone:(NSZone *)zone;
-(void)renderTextureAt:(CGPoint)position  name:(GLuint)name   
                  size:(GLfloat)size r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a;
-(void)renderTextureInRect:(CGRect)rect  name:(GLuint)name depth:(GLfloat)depth 
                         r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a;  
@end
