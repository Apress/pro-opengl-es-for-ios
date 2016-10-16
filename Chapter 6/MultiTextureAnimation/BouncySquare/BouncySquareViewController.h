//
//  BouncySquareViewController.h
//  BouncySquare
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface BouncySquareViewController : GLKViewController
{
   GLKTextureInfo *m_Texture0;
   GLKTextureInfo *m_Texture1;
}

-(void)setClipping;
-(GLKTextureInfo *)loadTexture:(NSString *)filename;
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
-(void)multiTexture:(GLuint)tex0 tex1:(GLuint)tex1;

@end
