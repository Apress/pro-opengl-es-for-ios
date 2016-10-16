//
//  BouncyTextureViewController.h
//  BouncyTexture
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "FBOController.h"

@interface BouncyTextureViewController : GLKViewController
{
    GLKTextureInfo *m_Texture;
    FBOController *m_FBOController;
    float m_FBOHeight;
    float m_FBOWidth;
    GLint m_DefaultFBO;
}

-(GLKTextureInfo *)loadTexture:(NSString *)filename;
-(void)setClipping;

@end
