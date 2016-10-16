//
//  OpenGLStars.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

struct starData                                                                                                                    //1
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat mag;
    GLfloat r,g,b,a;
    GLint hdnum;
};

@interface OpenGLStars : NSObject
{
    struct starData *m_Data;
    int m_TotalStars;
}

-(void)execute;
-(void)init:(NSString *)filename;
-(id)init;

@end
