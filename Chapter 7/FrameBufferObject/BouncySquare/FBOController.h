//
//  FBOController.h
//  Bouncy Texture
//
//  Created by mike on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface FBOController : NSObject 
{
    GLuint m_Texture;
    GLuint m_FBO1;
}

-(GLint)getFBOName;
-(GLuint)getTextureName;
-(id)initWidth:(float)width height:(float)height;

@end


