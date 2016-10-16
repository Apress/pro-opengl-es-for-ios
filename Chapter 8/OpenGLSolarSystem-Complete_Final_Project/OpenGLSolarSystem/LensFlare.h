//
//  LensFlare.h
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

@interface LensFlare : NSObject
{
    NSMutableArray *m_Flares;
}

-(void)createFlares;
-(void)execute:(CGRect)frame source:(CGPoint)source scale:(float)scale alpha:(float)alpha;

@end
