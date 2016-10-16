//
//  FBOController.m
//  Bouncy Texture
//
//  Created by mike on 9/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "FBOController.h"


@implementation FBOController

-(id)initWidth:(float)width height:(float)height
{
    GLint originalFBO;
    GLuint depthBuffer;
    
    //Cache the original FBO, and restore it later.
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, &originalFBO);     //1
    
    glGenRenderbuffersOES(1, &depthBuffer);                                                //2
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthBuffer);
    
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES,                          //3
                             GL_DEPTH_COMPONENT16_OES, width, height);
    
    //Make the texture to render to.
    
    glGenTextures(1, &m_Texture);                                                                        //4
    glBindTexture(GL_TEXTURE_2D, m_Texture);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, 
                 GL_RGB, GL_UNSIGNED_SHORT_5_6_5, 0);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //Now create the actual FBO.
    
    glGenFramebuffersOES(1, &m_FBO1);                                                        //5
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_FBO1);
    
    // Attach the texture to the FBO.
    
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES,                        //6
                              GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, m_Texture, 0);
    
    // Attach the depth buffer we created earlier to our FBO.
    
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,                   //7
                                 GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthBuffer);
    
    // Check that our FBO creation was successful.
    
    glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);                   //8
    
    GLuint uStatus = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    
    if(uStatus != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@ "ERROR: Failed to initialise FBO");
        return 0;
    }
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, originalFBO);        //9
    
    return self;
}

-(GLint)getFBOName                                                                                            //10
{
    return m_FBO1;  
}

-(GLuint)getTextureName                                                                                    //11
{
    return m_Texture;  
}

@end
