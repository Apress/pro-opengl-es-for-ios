//
//  OpenGLUtils.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenGLUtils : NSObject


+(OpenGLUtils *)getObject;
+(id)allocWithZone:(NSZone *)zone;
-(void)sphereToRectTheta:(float)theta phi:(float)phi radius:(float)radius  
                  xprime:(float *)xprime   yprime:(float *)yprime zprime:(float *)zprime;
@end
